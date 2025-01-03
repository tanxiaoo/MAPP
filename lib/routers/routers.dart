import 'package:get/get.dart';

import '../pages/tabs.dart';
import '../pages/home.dart';
import '../pages/plan.dart';
import '../pages/list.dart';
import '../pages/me.dart';
import '../pages/detail.dart';
import '../pages/pay.dart';
import '../pages/login.dart';
import '../pages/auth_page.dart';

class AppPage {
  static final routers = [
    GetPage(name: "/", page: () => const Tabs()),
    GetPage(name: "/home", page: () => const HomePage()),
    GetPage(name: "/plan", page: () => const PlanPage()),
    GetPage(name: "/list", page: () => const ListPage()),
    GetPage(name: "/me", page: () => const MePage()),
    GetPage(name: "/detail", page: () => const DetailPage()),
    GetPage(name: "/pay", page: () => const PayPage()),
    GetPage(name: "/login", page: () => const LoginPage()),
    GetPage(name: "/auth_page", page: () => const AuthPage()),
  ];
}
