import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'logic/auth_bloc/auth_bloc.dart';
import 'logic/transaction_bloc/transaction_bloc.dart';
import 'login/login_screen.dart';
import 'home/home_screen.dart';
import 'core/firebase_options.dart';

// This is the main entry point of the Flutter application.
void main() async {
  // Ensure that Flutter bindings are initialized before calling native code.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with the platform-specific options.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app with the root widget.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // RepositoryProvider provides a repository instance to its children.
    // It's used here to make AuthRepository available to the AuthBloc.
    return RepositoryProvider(
      create: (context) => AuthRepository(
        firebaseAuth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
      ),
      child: BlocProvider(
        // The AuthBloc is created and listens to the AuthRepository for changes.
        create: (context) => AuthBloc(context.read<AuthRepository>()),
        child: MaterialApp(
          title: 'Finance Tracker',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'Inter',
          ),
          // AuthWrapper handles the routing based on the authentication state.
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocBuilder rebuilds its widget tree when the AuthBloc state changes.
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          // If the user is authenticated, provide the TransactionBloc and navigate to HomeScreen.
          return RepositoryProvider(
            create: (context) => TransactionRepository(
              userId: state.user.id,
              firestore: FirebaseFirestore.instance,
            ),
            child: BlocProvider(
              create: (context) => TransactionBloc(
                context.read<TransactionRepository>(),
              )..add(LoadTransactions()),
              child: HomeScreen(user: state.user),
            ),
          );
        } else {
          // If the user is not authenticated, show the LoginScreen.
          return const LoginScreen();
        }
      },
    );
  }
}
