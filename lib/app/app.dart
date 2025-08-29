import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'constants/theme.dart';
import '../features/home/presentation/view/home_view.dart';

class BoitodexApp extends StatelessWidget {
  const BoitodexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boitodex',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR')],
      locale: const Locale('fr', 'FR'),
      home: const HomeView(),
    );
  }
}