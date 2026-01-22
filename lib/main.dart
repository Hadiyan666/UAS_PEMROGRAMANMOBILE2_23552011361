import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'services/supabase_service.dart';
import 'cubits/transaction_cubit.dart';
import 'cubits/category_cubit.dart';
import 'cubits/budget_cubit.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://jwykdsvsxjedxurwstju.supabase.co',
    anonKey: 'sb_publishable_kEBQRyw6uTFBeP7yt1rnCA_9B3eyMhQ',
  );
        
  WidgetsFlutterBinding.ensureInitialized();
  
  // Menginisiasi Supabase
  await SupabaseService().initialize();
  
  runApp(const DompetKuApp());
}

class DompetKuApp extends StatelessWidget {
  const DompetKuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => TransactionCubit()),
        BlocProvider(create: (context) => CategoryCubit()),
        BlocProvider(create: (context) => BudgetCubit()),
      ],
      child: MaterialApp(
        title: 'DompetKu',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

// Wrapper to check authentication
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final supabase = SupabaseService().client;
    
    return StreamBuilder(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final session = supabase.auth.currentSession;
        
        if (session != null) {
          return MainScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
