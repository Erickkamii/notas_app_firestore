import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // NOVO IMPORT!
import 'views/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização correta para todas as plataformas (incluindo Web)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const NotasApp());
}