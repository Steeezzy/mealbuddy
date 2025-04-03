import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// It's handy to extract the Supabase client in a variable for later uses
late final SupabaseClient supabase;

Future<void> main() async {
  try {
    await _initializeApp();
    runApp(const MealBuddyApp());
  } catch (e) {
    debugPrint('Error initializing app: $e');
    // You might want to show a proper error screen here
    runApp(const ErrorApp());
  }
}

Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUrlStrategy(PathUrlStrategy());

  // Load environment variables
  await _loadEnvironment();
  
  // Initialize Supabase
  await _initializeSupabase();
}

Future<void> _initializeSupabase() async {
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  
  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('Supabase credentials not found in environment');
  }
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
  supabase = Supabase.instance.client;
  debugPrint('Supabase initialized successfully');
}

Future<void> _loadEnvironment() async {
  try {
    await dotenv.load(fileName: ".env");
    final hasApiKey = dotenv.env['GROQ_API_KEY'] != null;
    debugPrint('Environment loaded: ${hasApiKey ? 'API Key found' : 'API Key missing'}');
    
    if (!hasApiKey) {
      throw Exception('GROQ_API_KEY not found in environment');
    }
  } catch (e) {
    debugPrint('Error loading environment: $e');
    throw Exception('Failed to load environment variables');
  }
}

class MealBuddyApp extends StatelessWidget {
  const MealBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealBuddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              SizedBox(height: 16),
              Text(
                'Failed to initialize app',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
