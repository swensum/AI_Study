import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:study_assistant/providers/chat_provider.dart';
import 'package:study_assistant/screens/chat_screen.dart';
import 'package:study_assistant/widgets/theme.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF0A1929),
      statusBarIconBrightness: Brightness.light,
    ),
  );
   await dotenv.load(fileName: ".env");
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
   return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(  // Listen to theme changes
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'AI Study Assistant',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,   // Use light theme from provider
            darkTheme: themeProvider.darkTheme, // Use dark theme from provider
            themeMode: themeProvider.isDarkMode 
                ? ThemeMode.dark 
                : ThemeMode.light,  // Dynamically switch based on user preference
            home: const ChatScreen(),
          );
        },
      ),
    );
  }
}