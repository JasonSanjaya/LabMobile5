import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:main2/provider/app_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:main2/provider/auth_provider.dart';
import 'package:provider/provider.dart';

import 'config/routes.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Google Sign-In
  // Note: clientId dan serverClientId bisa dikonfigurasi di sini jika diperlukan
  // Untuk Android/iOS, konfigurasi sudah ada di google-services.json/GoogleService-Info.plist
  await GoogleSignIn.instance.initialize(
    // clientId: 'YOUR_WEB_CLIENT_ID', // Uncomment jika butuh untuk Web
    // serverClientId: 'YOUR_SERVER_CLIENT_ID', // Uncomment jika butuh server auth code
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp.router(
        title: 'AnimeVerse',
        theme: ThemeData(fontFamily: 'Urbanist'),
        routerConfig: createRouter(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}