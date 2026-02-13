import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:void_surge/core/constants/void_surge_constants.dart';
import 'package:void_surge/features/game/game_screen.dart';
import 'package:void_surge/features/home/home_screen.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/game',
      builder: (context, state) => const GameScreen(),
    ),
  ],
);

class VoidSurgeApp extends StatelessWidget {
  const VoidSurgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Void Surge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: VoidSurgeConstants.backgroundColor,
      ),
      routerConfig: _router,
    );
  }
}
