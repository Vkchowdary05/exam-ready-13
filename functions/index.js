/**
 * Cloud Functions for Exam Ready
 *
 * Security-critical API proxies and Firestore triggers.
 * All sensitive API keys live HERE, not in the Flutter client.
 *
 * Functions:
 *   1. extractTopics  — Groq LLM proxy (authenticated, rate-limited)
 *   2. getUploadSignature — Cloudinary signed-upload URL generator
 *   3. onPaperCreated — Firestore trigger: normalize topics, update stats
 *   4. onPaperVoted   — Auto-flag papers with net votes < -5
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const fetch = require("node-fetch");

admin.initializeApp();
const db = admin.firestore();

// ═══════════════════════════════════════════════════════════════════
// CONFIG — Set these with:
//   firebase functions:config:set groq.api_key="gsk_..."
//   firebase functions:config:set cloudinary.cloud_name="..."
//   firebase functions:config:set cloudinary.api_key="..."
//   firebase functions:config:set cloudinary.api_secret="..."
// ═══════════════════════════════════════════════════════════════════

const GROQ_API_KEY = functions.config().groq?.api_key || "";
const CLOUDINARY_CLOUD_NAME = functions.config().cloudinary?.cloud_name || "";
const CLOUDINARY_API_KEY = functions.config().cloudinary?.api_key || "";
const CLOUDINARY_API_SECRET = functions.config().cloudinary?.api_secret || "";

// ═══════════════════════════════════════════════════════════════════
// 1. extractTopics — Groq LLM Proxy
// ═══════════════════════════════════════════════════════════════════

exports.extractTopics = functions.https.onCall(async (data, context) => {
  // Auth check
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in to extract topics."
    );
  }

  const { extractedText } = data;

  if (!extractedText || typeof extractedText !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "extractedText is required and must be a string."
    );
  }

  if (extractedText.length < 50) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Extracted text is too short. Minimum 50 characters."
    );
  }

  if (extractedText.length > 10000) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Extracted text is too long. Maximum 10,000 characters."
    );
  }

  // Rate limit: max 20 calls per user per day
  const userId = context.auth.uid;
  const today = new Date().toISOString().slice(0, 10);
  const rateLimitRef = db
    .collection("daily_uploads")
    .doc(`${userId}_${today}`);

  const rateLimitDoc = await rateLimitRef.get();
  const currentCount = rateLimitDoc.exists
    ? rateLimitDoc.data().topicExtractions || 0
    : 0;

  if (currentCount >= 20) {
    throw new functions.https.HttpsError(
      "resource-exhausted",
      "Daily topic extraction limit reached. Try again tomorrow."
    );
  }

  // Call Groq API
  try {
    const response = await fetch(
      "https://api.groq.com/openai/v1/chat/completions",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${GROQ_API_KEY}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: "llama3-8b-8192",
          messages: [
            {
              role: "system",
              content:
                "You are an expert at analyzing exam papers for Indian B.Tech universities. " +
                "Extract the main topics and concepts from the given question paper text. " +
                "Return ONLY a JSON array of topic strings, nothing else. " +
                "Example: [\"Binary Search Trees\", \"Graph Traversal\", \"Dynamic Programming\"]",
            },
            {
              role: "user",
              content: `Extract the Part-B (long-answer) topics from this question paper:\n\n${extractedText}`,
            },
          ],
          temperature: 0.2,
          max_tokens: 1024,
        }),
        signal: AbortSignal.timeout(25000), // 25s timeout
      }
    );

    if (!response.ok) {
      const errorBody = await response.text();
      console.error("Groq API error:", response.status, errorBody);
      throw new functions.https.HttpsError(
        "internal",
        "Topic extraction failed. Please try again."
      );
    }

    const result = await response.json();
    const content = result.choices?.[0]?.message?.content || "[]";

    // Parse topics from response
    let topics = [];
    try {
      topics = JSON.parse(content);
      if (!Array.isArray(topics)) {
        topics = [];
      }
    } catch {
      // If JSON parsing fails, try to extract topics from text
      topics = content
        .split("\n")
        .map((line) => line.replace(/^[\d.\-*]+\s*/, "").trim())
        .filter((line) => line.length > 2 && line.length < 200);
    }

    // Sanitize topics
    topics = topics
      .map((t) => String(t).trim().toUpperCase())
      .filter((t) => t.length >= 3 && t.length <= 100)
      .filter((t) => !/^\d+$/.test(t))
      .slice(0, 30); // max 30 topics

    // Remove duplicates
    topics = [...new Set(topics)];

    // Update rate limit
    await rateLimitRef.set(
      {
        topicExtractions: admin.firestore.FieldValue.increment(1),
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    return { topics };
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    console.error("extractTopics error:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Failed to extract topics. Please try again."
    );
  }
});

// ═══════════════════════════════════════════════════════════════════
// 2. getUploadSignature — Cloudinary Signed Upload
// ═══════════════════════════════════════════════════════════════════

exports.getUploadSignature = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in to upload."
    );
  }

  // Rate limit: max 10 uploads per day
  const userId = context.auth.uid;
  const today = new Date().toISOString().slice(0, 10);
  const rateLimitRef = db
    .collection("daily_uploads")
    .doc(`${userId}_${today}`);

  const rateLimitDoc = await rateLimitRef.get();
  const currentCount = rateLimitDoc.exists
    ? rateLimitDoc.data().uploads || 0
    : 0;

  if (currentCount >= 10) {
    throw new functions.https.HttpsError(
      "resource-exhausted",
      "Daily upload limit reached. Try again tomorrow."
    );
  }

  const timestamp = Math.round(new Date().getTime() / 1000);
  const folder = "exam_ready_papers";

  // Generate signature
  const crypto = require("crypto");
  const paramsToSign = `folder=${folder}&timestamp=${timestamp}`;
  const signature = crypto
    .createHash("sha1")
    .update(paramsToSign + CLOUDINARY_API_SECRET)
    .digest("hex");

  // Increment daily upload counter
  await rateLimitRef.set(
    {
      uploads: admin.firestore.FieldValue.increment(1),
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  return {
    signature,
    timestamp,
    cloudName: CLOUDINARY_CLOUD_NAME,
    apiKey: CLOUDINARY_API_KEY,
    folder,
  };
});

// ═══════════════════════════════════════════════════════════════════
// 3. onPaperCreated — Firestore Trigger
// ═══════════════════════════════════════════════════════════════════

exports.onPaperCreated = functions.firestore
  .document("submitted_papers/{paperId}")
  .onCreate(async (snapshot, context) => {
    const paper = snapshot.data();
    const paperId = context.params.paperId;

    try {
      // ── Update platform stats ──────────────────────────────────
      await db
        .collection("platform_stats")
        .doc("global")
        .set(
          {
            totalPapers: admin.firestore.FieldValue.increment(1),
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );

      // ── Update user's upload count ─────────────────────────────
      if (paper.userId) {
        await db
          .collection("users")
          .doc(paper.userId)
          .set(
            {
              papersUploaded: admin.firestore.FieldValue.increment(1),
              contributorXP: admin.firestore.FieldValue.increment(50),
              lastActive: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true }
          );
      }

      // ── Log activity ───────────────────────────────────────────
      await db.collection("notifications").add({
        type: "paper_added",
        title: "New paper uploaded",
        description: `${paper.subject} — ${paper.college}`,
        paperId: paperId,
        userId: paper.userId || null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        read: false,
      });

      console.log(`onPaperCreated: processed ${paperId}`);
    } catch (error) {
      console.error(`onPaperCreated error for ${paperId}:`, error);
    }
  });

// ═══════════════════════════════════════════════════════════════════
// 4. onPaperVoted — Auto-flag low-quality papers
// ═══════════════════════════════════════════════════════════════════

exports.onPaperVoted = functions.firestore
  .document("submitted_papers/{paperId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const paperId = context.params.paperId;

    const beforeNet = (before.upvotes || 0) - (before.downvotes || 0);
    const afterNet = (after.upvotes || 0) - (after.downvotes || 0);

    // Auto-flag if net votes drop below -5
    if (afterNet < -5 && beforeNet >= -5 && !after.flagged) {
      await change.after.ref.update({
        flagged: true,
        flagReason: "auto_downvoted",
        flaggedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Add to admin queue
      await db.collection("admin_queue").add({
        type: "flagged_paper",
        paperId: paperId,
        reason: "Net votes below -5",
        netVotes: afterNet,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        resolved: false,
      });

      console.log(`Paper ${paperId} auto-flagged (net votes: ${afterNet})`);
    }
  });
