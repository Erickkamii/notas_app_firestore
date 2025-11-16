// views/app.dart
import 'package:flutter/material.dart';
import 'list.dart';
import 'create.dart';
import 'edit.dart';
import 'package:provider/provider.dart';
import '../viewmodels/notaviewmodel.dart';

// 1. Adicionado o construtor 'const' para otimização e compilação
class NotasApp extends StatelessWidget {
  const NotasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // 2. Cria e fornece o NotaViewModel (que agora usa o Firestore)
      create: (context) => NotaViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          "/list": (context) =>  ListPage(),
          "/create": (context) =>  CreatePage(),
          "/edit": (context) =>  EditPage(),
        },
        initialRoute: "/list",
      ),
    );
  }
}