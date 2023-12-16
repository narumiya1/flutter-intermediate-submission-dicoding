import 'package:flutter/material.dart';
import 'package:submission_intermediate/data/pref/token.dart';
import 'package:submission_intermediate/ui/post_story.dart';
import 'package:submission_intermediate/ui/detail_story.dart';
import 'package:submission_intermediate/ui/list_story.dart';
import 'package:submission_intermediate/ui/login.dart';
import 'package:submission_intermediate/ui/register.dart';
import 'package:submission_intermediate/ui/splash.dart';

class MyRouterDelegate extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> _navigatorKey;

  bool? isLoggedIn;
  String? storyId;

  List<Page> storyStack = [];
  bool isRegister = false;
  bool isAddStory = false;

  MyRouterDelegate() : _navigatorKey = GlobalKey<NavigatorState>() {
    _init();
  }

  _init() async {
    var tokenPrefrence = Token();
    isLoggedIn = (await tokenPrefrence.getToken()).isNotEmpty;

    notifyListeners();
  }

  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;
  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      storyStack = _splashStack;
    } else if (isLoggedIn == true) {
      storyStack = _loggedInStack;
    } else {
      storyStack = _loggedOutStack;
    }

    return Navigator(
      key: navigatorKey,
      pages: storyStack,
      onPopPage: (route, result) {
        final didPops = route.didPop(result);
        if (!didPops) {
          return false;
        }

        isRegister = false;
        isAddStory = false;
        storyId = null;
        notifyListeners();

        return true;
      },
    );
  }

  List<Page> get _splashStack => [
        const MaterialPage(
          key: ValueKey("SplashPage"),
          child: SplashScreenPage(),
        ),
      ];

  List<Page> get _loggedInStack => [
        MaterialPage(
          key: const ValueKey("ListOfStoryPage"),
          child: ListStoryPage(
            onLogoutSucces: () {
              isLoggedIn = false;
              notifyListeners();
            },
            onStoryClickd: (String? id) {
              storyId = id;
              notifyListeners();
            },
            onPostStoryClicked: () {
              isAddStory = true;
              notifyListeners();
            },
          ),
        ),

        //story detail
        if (storyId != null)
          MaterialPage(
            key: const ValueKey("DetailStoryPage"),
            child: DetailStoryPage(
              storyId: storyId!,
              onCloseDetailPage: () {
                storyId = null;
                notifyListeners();
              },
            ),
          ),

          //addStory
        if (isAddStory)
          MaterialPage(
            child: PostStoryPage(
              onSuccessAddStory: () {
                isAddStory = false;
                notifyListeners();
              },
            ),
          )
      ];

  List<Page> get _loggedOutStack => [
        MaterialPage(
          key: const ValueKey("LoginPage"),
          child: LoginPage(
            onLoginSuccess: () {
              isLoggedIn = true;
              notifyListeners();
            },
            onRegisterClicked: () {
              isRegister = true;
              notifyListeners();
            },
          ),
        ),
        if (isRegister == true)
          MaterialPage(
            child: Registerpage(
              onRegisterSuccess: () {
                isRegister = false;
                notifyListeners();
              },
            ),
          ),
      ];

  @override
  Future<void> setNewRoutePath(configuration) {
    throw UnimplementedError();
  }
}
