import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mfheqwjohjavnpswtlar.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1maGVxd2pvaGphdm5wc3d0bGFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkzODM4NjgsImV4cCI6MjA2NDk1OTg2OH0.LFHgp-bdcUcomfbN0WhqLfmF9Q9hoyX4On4bd6p3ADs',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Antrean Percetakan',
      home: HomeScreen(),
    );
  }
}
