import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 💡 NOVO: Import do Firestore
import 'package:provider/provider.dart';
import '../models/nota.dart';
// Remova: os imports de http, dart:convert e uuid (não são mais necessários)

class NotaViewModel extends ChangeNotifier {
  // Referência ao Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Nome da coleção no seu banco de dados
  final String _collectionName = 'notas';
  List<Nota> _notas = [];

  List<Nota> get notas => List.unmodifiable(_notas);

  // O construtor carrega os dados ao iniciar
  NotaViewModel() {
    read();
  }

  // --- CREATE (Criar) ---
  void create(String title) async {
    // 1. Cria um objeto Nota (o ID temporário será substituído)
    Nota novaNota = Nota("temp_id", title, DateTime.now());

    // 2. Adiciona ao Firestore e obtém a referência do novo documento (docRef)
    await _db.collection(_collectionName).add(novaNota.toJson()).then((docRef) {
      // 3. Atualiza o documento no Firestore com o ID gerado (docRef.id)
      docRef.update({'id': docRef.id});
    });

    // 4. Recarrega a lista para atualizar a UI
    await read();
    notifyListeners();
  }

  // --- DELETE (Deletar) ---
  void delete(String id) async {
    // 1. Atualiza a lista local primeiro (feedback rápido)
    _notas.removeWhere((e) => e.id == id);
    notifyListeners();

    // 2. Deleta o documento no Firestore pelo ID
    await _db.collection(_collectionName).doc(id).delete().catchError((e) {
      print("Erro ao deletar no Firestore: $e");
    });
  }

  // --- UPDATE (Atualizar) ---
  void update(Nota nota) async {
    // 1. Atualiza a lista local (feedback rápido)
    var index = _notas.indexWhere((e) => e.id == nota.id);
    if (index != -1) {
      _notas[index] = nota;
    }
    notifyListeners();

    // 2. Atualiza o documento no Firestore.
    await _db
        .collection(_collectionName)
        .doc(nota.id) // Usa o ID da nota para localizar
        .update(nota.toJson()) // Atualiza com os novos dados
        .catchError((e) {
      print("Erro ao atualizar no Firestore: $e");
    });
  }

  // --- READ (Ler) ---
  Future<void> read() async {
    try {
      // 1. Busca todos os documentos na coleção
      QuerySnapshot snapshot = await _db.collection(_collectionName).get();

      // 2. Mapeia os documentos do Firestore para objetos Nota do Dart
      _notas = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

        // O ID do documento é o ID da nota
        data['id'] = doc.id;

        // Converte o Timestamp do Firestore para o formato DateTime esperado pelo Dart
        if (data['date'] is Timestamp) {
          data['date'] =
              (data['date'] as Timestamp).toDate().toIso8601String();
        }

        return Nota.fromJson(data);
      }).toList();
    } catch (e) {
      print("Erro ao ler dados do Firestore: $e");
      _notas = [];
    } finally {
      notifyListeners(); // Atualiza a UI
    }
  }
}
