/*
 * Copyright (c) 2021 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:navigation_app/app_state.dart';
import 'package:navigation_app/router/back_dispatcher.dart';
import 'package:navigation_app/router/ui_pages.dart';
import 'package:navigation_app/ui/cart.dart';
import 'package:navigation_app/ui/checkout.dart';
import 'package:navigation_app/ui/create_account.dart';
import 'package:navigation_app/ui/details.dart';
import 'package:navigation_app/ui/list_items.dart';
import 'package:navigation_app/ui/login.dart';
import 'package:navigation_app/ui/settings.dart';
import 'package:navigation_app/ui/splash.dart';

class ShoppingRouterDelegate extends RouterDelegate<PageConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PageConfiguration> {
  final List<MaterialPage> _pages = [];
  late ShoppingBackButtonDispatcher backButtonDispatcher;

  @override
  final GlobalKey<NavigatorState> navigatorKey;
  final AppState appState;

  ShoppingRouterDelegate(this.appState) : navigatorKey = GlobalKey() {
    appState.addListener(() {
      notifyListeners();
    });
  }

  /// Getter for a list that cannot be changed
  List<MaterialPage> get pages => List.unmodifiable(_pages);

  /// Number of pages function
  int numPages() => _pages.length;

  @override
  PageConfiguration get currentConfiguration =>
      _pages.last.arguments as PageConfiguration;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: _onPopPage,
      pages: buildPages(),
    );
  }

  bool _onPopPage(Route<dynamic> route, result) {
    final didPop = route.didPop(result);
    if (!didPop) {
      return false;
    }
    if (canPop()) {
      pop();
      return true;
    } else {
      return false;
    }
  }

  void _removePage(MaterialPage page) {
    _pages.remove(page);
  }

  void pop() {
    if (canPop()) {
      _removePage(_pages.last);
    }
  }

  bool canPop() {
    return _pages.length > 1;
  }

  @override
  Future<bool> popRoute() {
    if (canPop()) {
      _removePage(_pages.last);
      return Future.value(true);
    }
    return Future.value(false);
  }

  MaterialPage _createPage(Widget child, PageConfiguration? pageConfig) {
    return MaterialPage(
      child: child,
      key: ValueKey(pageConfig?.key),
      name: pageConfig?.path,
      arguments: pageConfig,
    );
  }

  void _addPageData(Widget child, PageConfiguration? pageConfig) {
    _pages.add(
      _createPage(child, pageConfig),
    );
  }

  void addPage(PageConfiguration pageConfig) {
    final shouldAddPage = _pages.isEmpty ||
        (_pages.last.arguments as PageConfiguration).uiPage !=
            pageConfig.uiPage;
    if (shouldAddPage) {
      switch (pageConfig.uiPage) {
        case Pages.Splash:
          _addPageData(
            const Splash(),
            SplashPageConfig,
          );
          break;
        case Pages.Login:
          _addPageData(
            const Login(),
            LoginPageConfig,
          );
          break;
        case Pages.CreateAccount:
          _addPageData(
            const CreateAccount(),
            CreateAccountPageConfig,
          );
          break;
        case Pages.List:
          _addPageData(
            const ListItems(),
            ListItemsPageConfig,
          );
          break;
        case Pages.Cart:
          _addPageData(const Cart(), CartPageConfig);
          break;
        case Pages.Checkout:
          _addPageData(
            const Checkout(),
            CheckoutPageConfig,
          );
          break;
        case Pages.Settings:
          _addPageData(
            const Settings(),
            SettingsPageConfig,
          );
          break;
        case Pages.Details:
          if (pageConfig.currentPageAction != null) {
            _addPageData(
              pageConfig.currentPageAction!.widget!,
              pageConfig,
            );
          }
          break;
        default:
          break;
      }
    }
  }

  void replace(PageConfiguration newRoute) {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    addPage(newRoute);
  }

  void setPath(List<MaterialPage> path) {
    _pages.clear();
    _pages.addAll(path);
  }

  void replaceAll(PageConfiguration newRoute) {
    setNewRoutePath(newRoute);
  }

  void push(PageConfiguration newRoute) {
    addPage(newRoute);
  }

  void pushWidget(Widget child, PageConfiguration newRoute) {
    _addPageData(child, newRoute);
  }

  void addAll(List<PageConfiguration> routes) {
    _pages.clear();
    routes.forEach((route) {
      addPage(route);
    });
  }

  @override
  Future<void> setNewRoutePath(PageConfiguration configuration) {
    final shouldAddPage = _pages.isEmpty ||
        (_pages.last.arguments as PageConfiguration).uiPage !=
            configuration.uiPage;
    if (shouldAddPage) {
      _pages.clear();
      addPage(configuration);
    }
    return SynchronousFuture(null);
  }

  void _setPageAction(PageAction action) {
    switch (action.page!.uiPage) {
      case Pages.Splash:
        SplashPageConfig.currentPageAction = action;
        break;
      case Pages.Login:
        LoginPageConfig.currentPageAction = action;
        break;
      case Pages.CreateAccount:
        CreateAccountPageConfig.currentPageAction = action;
        break;
      case Pages.List:
        ListItemsPageConfig.currentPageAction = action;
        break;
      case Pages.Cart:
        CartPageConfig.currentPageAction = action;
        break;
      case Pages.Checkout:
        CheckoutPageConfig.currentPageAction = action;
        break;
      case Pages.Settings:
        SettingsPageConfig.currentPageAction = action;
        break;
      case Pages.Details:
        DetailsPageConfig.currentPageAction = action;
        break;
      default:
        throw UnimplementedError();
    }
  }

  List<Page> buildPages() {
    if (!appState.splashFinished) {
      replaceAll(SplashPageConfig);
    } else {
      _FutureTracking(appState.currentAction);
      switch (appState.currentAction.state) {
        case PageState.none:
          break;
        case PageState.addPage:
          _setPageAction(appState.currentAction);
          addPage(appState.currentAction.page!);
          break;
        case PageState.pop:
          pop();
          break;
        case PageState.replace:
          _setPageAction(appState.currentAction);
          replace(appState.currentAction.page!);
          break;
        case PageState.replaceAll:
          _setPageAction(appState.currentAction);
          replaceAll(appState.currentAction.page!);
          break;
        case PageState.addWidget:
          _setPageAction(appState.currentAction);
          pushWidget(
            appState.currentAction.widget!,
            appState.currentAction.page!,
          );
          break;
        case PageState.addAll:
          addAll(appState.currentAction.pages!);
          break;
      }
    }
    appState.resetCurrentAction();
    return List.of(_pages);
  }

  void _FutureTracking(PageAction data) {
    print(data.args);
    print(data.page?.uiPage);
  }

  void parseRoute(Uri uri) {
    if (uri.pathSegments.isEmpty) {
      setNewRoutePath(SplashPageConfig);
      return;
    }

    // Handle navapp://deeplinks/details/#
    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] == 'details') {
        pushWidget(
          Details(id: int.parse(uri.pathSegments[1])),
          DetailsPageConfig,
        );
      }
    } else if (uri.pathSegments.length == 1) {
      final path = uri.pathSegments[0];
      switch (path) {
        case 'splash':
          replaceAll(SplashPageConfig);
          break;
        case 'login':
          replaceAll(LoginPageConfig);
          break;
        case 'createAccount':
          setPath([
            _createPage(
              const Login(),
              LoginPageConfig,
            ),
            _createPage(
              const CreateAccount(),
              CreateAccountPageConfig,
            )
          ]);
          break;
        case 'listItems':
          replaceAll(ListItemsPageConfig);
          break;
        case 'cart':
          setPath([
            _createPage(
              const ListItems(),
              ListItemsPageConfig,
            ),
            _createPage(
              const Cart(),
              CartPageConfig,
            )
          ]);
          break;
        case 'checkout':
          setPath([
            _createPage(
              const ListItems(),
              ListItemsPageConfig,
            ),
            _createPage(
              const Checkout(),
              CheckoutPageConfig,
            )
          ]);
          break;
        case 'settings':
          setPath([
            _createPage(
              const ListItems(),
              ListItemsPageConfig,
            ),
            _createPage(
              const Settings(),
              SettingsPageConfig,
            )
          ]);
          break;
      }
    }
  }
}
