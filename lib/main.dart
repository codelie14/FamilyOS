import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/gallery/gallery_screen.dart';
import 'screens/files/files_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/tasks/tasks_screen.dart';
import 'screens/vault/vault_screen.dart';
import 'screens/notes/notes_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  await dotenv.load(fileName: ".env");
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const FamilyOSApp());
}

class FamilyOSApp extends StatelessWidget {
  const FamilyOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FamilyOS',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/chat_list': (context) => const ChatListScreen(),
        '/gallery': (context) => const GalleryScreen(),
        '/files': (context) => const FilesScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/tasks': (context) => const TasksScreen(),
        '/vault': (context) => const VaultScreen(),
        '/notes': (context) => const NotesScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: kBg,
              body: Center(child: CircularProgressIndicator(color: kPurple)),
            );
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
