import 'package:FitApp/views/IntroScreen.dart';
import 'package:FitApp/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'services/user_service.dart';
import 'viewmodels/banner_viewmodel.dart';
import 'viewmodels/hydration_viewmodel.dart';
import 'viewmodels/user_history_viewmodel.dart';
import 'viewmodels/device_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BannerViewModel()),
        ChangeNotifierProvider(create: (_) => HydrationViewModel()),
        ChangeNotifierProvider(create: (_) => UserHistoryViewModel()),
        ChangeNotifierProvider(create: (_) => DeviceViewModel()),
      ],
      child: MaterialApp(
        title: 'Fit Data App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await UserService.isLoggedIn();
    final jwtToken = await UserService.getJwtToken();
    if (isLoggedIn && mounted && jwtToken != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const IntroScreen();
  }
}
