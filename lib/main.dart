import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/job_detail_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/register_screen.dart';
import 'screens/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.containsKey('user_id');

  runApp(JobPlatformApp(initialRoute: isLoggedIn ? '/' : '/login'));
}

class JobPlatformApp extends StatefulWidget {
  final String initialRoute;

  const JobPlatformApp({super.key, required this.initialRoute});

  @override
  State<JobPlatformApp> createState() => _JobPlatformAppState();
}

class _JobPlatformAppState extends State<JobPlatformApp> {
  bool isLoggedIn = false;

  void handleLogin() {
    setState(() {
      isLoggedIn = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  void handleLogout() {
    setState(() {
      isLoggedIn = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Platform',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: widget.initialRoute,
      routes: {
        '/': (context) => HomeScreen(onLogout: handleLogout),
        '/loading': (context) => SplashScreen(),
        '/jobDetail': (context) => JobDetailScreen(),
        '/login': (context) => LoginScreen(
          onLogin: handleLogin,
        ),
        '/profile': (context) => ProfileScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}
