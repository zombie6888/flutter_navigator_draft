import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:router_app/navigation/core/navigation_observer.dart';
import 'package:router_app/navigation/core/tab_routes_config.dart';
import 'package:router_app/navigation/platform_tabs_page.dart';

import 'test_routes.dart';

void main() {
  late TabRoutesConfig config;
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Navigate forward tests', () {
    loadApp(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: config,
      ));
      await tester.pump();
    }

    setUp(() {
      config = TabRoutesConfig(
          routes: tabRoutes,
          observer: LocationObserver(),
          builder: (context, tabRoutes, view, controller) => PlatformTabsPage(
              tabRoutes: tabRoutes, view: view, controller: controller));
    });
    testWidgets('HomeScreen loaded', (WidgetTester tester) async {
      await loadApp(tester);
      expect(find.text('home'), findsWidgets);
    });
    testWidgets('Push a single page', (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_page6')));
      await tester.pumpAndSettle();
      expect(find.text('page6'), findsWidgets);
    });
    testWidgets('Push a tab page', (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_tab2_page1')));
      await tester.pump();
      expect(find.text('page1'), findsWidgets);
    });
    testWidgets('Push a tab nested page', (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_tab2_page5')));
      await tester.pump();
      expect(find.text('page5'), findsWidgets);
    });
    testWidgets('Push a tab page, then nested page', (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_tab2_page1')));
      await tester.pump();
      expect(find.text('page1'), findsWidgets);
       await tester.tap(find.byKey(const Key('btn_tab2_page5')));
      await tester.pump();
      expect(find.text('page5'), findsWidgets);
    });
    testWidgets('Navigate between tabs', (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_tab2_page1')));
      await tester.pump();
      expect(find.text('page1'), findsWidgets);
      await tester.tap(find.byKey(const Key('btn_tab1_page4')));
      await tester.pump();
      expect(find.text('page4'), findsWidgets);
    });  
    testWidgets('Push redirect page', (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_tab2_page1')));
      await tester.pump();
      expect(find.text('page1'), findsWidgets);
      await tester.tap(find.byKey(const Key('btn_tab2_page8')));
      await tester.pumpAndSettle();
      expect(find.text('page5'), findsWidgets);
    });    
  });
  group('Navigate forward and backward tests', () {
    loadApp(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: config,
      ));
      await tester.pump();
    }
    setUp(() {
      config = TabRoutesConfig(
          routes: tabRoutes,
          observer: LocationObserver(),
          builder: (context, tabRoutes, view, controller) => PlatformTabsPage(
              tabRoutes: tabRoutes, view: view, controller: controller));
    });   
    testWidgets('Navigate between tabs and back', (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_tab2_page1')));
      await tester.pump();
      expect(find.text('page1'), findsWidgets);
      await tester.tap(find.byKey(const Key('btn_tab1_page4')));
      await tester.pumpAndSettle();
      expect(find.text('tab1/page4'), findsWidgets);
      await tester.tap(find.byKey(const Key('back_btn')));     
      await tester.pump();    
      expect(find.text('page1'), findsWidgets);
    });
    testWidgets('Navigate to redirect and back', (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_tab2_page1')));
      await tester.pump();
      expect(find.text('page1'), findsWidgets);
      await tester.tap(find.byKey(const Key('btn_tab2_page8')));
      await tester.pumpAndSettle();
      expect(find.text('page5'), findsWidgets);
      await tester.tap(find.byKey(const Key('back_btn')));
      await tester.pump();   
      expect(find.text('home'), findsWidgets);
    });
  });
}
