import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exam_ready/utils/responsive_helper.dart';

void main() {
  group('Responsive Layout Tests', () {
    testWidgets('ResponsiveHelper works on mobile screens', (tester) async {
      await tester.binding.setSurfaceSize(
        const Size(375, 667),
      ); // iPhone SE size

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final padding = ResponsiveHelper.getResponsivePadding(context);
              final isMobile = ResponsiveHelper.isMobile(context);
              final gridCount = ResponsiveHelper.getResponsiveGridCount(
                context,
              );

              return Scaffold(
                body: Container(
                  padding: padding,
                  child: Text('Mobile: $isMobile, Grid: $gridCount'),
                ),
              );
            },
          ),
        ),
      );

      await tester.pump();

      expect(find.textContaining('Mobile: true'), findsOneWidget);
      expect(find.textContaining('Grid: 1'), findsOneWidget);
    });

    testWidgets('ResponsiveHelper works on tablet screens', (tester) async {
      await tester.binding.setSurfaceSize(const Size(768, 1024)); // iPad size

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final isTablet = ResponsiveHelper.isTablet(context);
              final gridCount = ResponsiveHelper.getResponsiveGridCount(
                context,
              );

              return Scaffold(
                body: Text('Tablet: $isTablet, Grid: $gridCount'),
              );
            },
          ),
        ),
      );

      await tester.pump();

      expect(find.textContaining('Tablet: true'), findsOneWidget);
      expect(find.textContaining('Grid: 2'), findsOneWidget);
    });

    testWidgets('ResponsiveHelper works on desktop screens', (tester) async {
      await tester.binding.setSurfaceSize(
        const Size(1200, 800),
      ); // Desktop size

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final isDesktop = ResponsiveHelper.isDesktop(context);
              final gridCount = ResponsiveHelper.getResponsiveGridCount(
                context,
              );

              return Scaffold(
                body: Text('Desktop: $isDesktop, Grid: $gridCount'),
              );
            },
          ),
        ),
      );

      await tester.pump();

      expect(find.textContaining('Desktop: true'), findsOneWidget);
      expect(find.textContaining('Grid: 3'), findsOneWidget);
    });

    testWidgets('Responsive container works correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 600));

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveHelper.responsiveContainer(
            child: const Text('Responsive Container'),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Responsive Container'), findsOneWidget);
    });
  });
}
