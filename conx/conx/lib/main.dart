import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter + PHP + MySQL',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const UsuariosPage(),
    );
  }
}

class Usuario {
  final int raaluno;
  final String nomealuno;
  final String telaluno;
  final String celaluno;
  Usuario({
    required this.raaluno,
    required this.nomealuno,
    required this.telaluno,
    required this.celaluno,
  });

  factory Usuario.fromMap(Map<String, dynamic> m) => Usuario(
        raaluno: int.tryParse("${m['raaluno']}") ?? 0,
        nomealuno: "${m['nomealuno'] ?? ''}",
        telaluno: "${m['telaluno'] ?? ''}",
        celaluno: "${m['celaluno'] ?? ''}",
      );
}

class Api {
  static const String base = "http://localhost/api_flutter";

static Future<List<Usuario>> listar() async {
  final res = await http.get(Uri.parse("$base/usuarios_listar.php"));
  print('Resposta listar: ${res.body}');
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body) as List;
    return data.map((e) => Usuario.fromMap(e)).toList();
  }
  throw Exception("Erro ao listar: ${res.statusCode}");
}
  static Future<int> inserir(String nomealuno, String telaluno, String celaluno) async {
    final res = await http.post(
      Uri.parse("$base/usuarios_inserir.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nome": nomealuno,
        "telefone": telaluno,
        "email": celaluno,
      }),
    );
    if (res.statusCode == 201) {
      final obj = jsonDecode(res.body);
      return obj["id"] ?? 0;
    }
    throw Exception("Erro ao inserir: ${res.body}");
  }

  static Future<void> atualizar(int raaluno, String nomealuno, String telaluno, String celaluno) async {
    final res = await http.post(
      Uri.parse("$base/usuarios_atualizar.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "raaluno": raaluno,
        "nomealuno": nomealuno,
        "telaluno": telaluno,
        "celaluno": celaluno,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception("Erro ao atualizar: ${res.body}");
    }
  }

  static Future<void> excluir(int raaluno) async {
    final res = await http.post(
      Uri.parse("$base/usuarios_excluir.php?id=$raaluno"),
    );
    if (res.statusCode != 200) {
      throw Exception("Erro ao excluir: ${res.body}");
    }
  }
}

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});
  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  late Future<List<Usuario>> future;

  @override
  void initState() {
    super.initState();
    future = Api.listar();
  }

  Future<void> refresh() async {
    setState(() {
      future = Api.listar();
    });
  }

  Future<void> abrirForm([Usuario? u]) async {
    final nomeCtrl = TextEditingController(text: u?.nomealuno ?? "");
    final telCtrl = TextEditingController(text: u?.telaluno ?? "");
    final celCtrl = TextEditingController(text: u?.celaluno ?? "");

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(u == null ? "Novo usuário" : "Editar usuário #${u.raaluno}"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nomeCtrl, decoration: const InputDecoration(labelText: "Nome")),
              TextField(controller: telCtrl, decoration: const InputDecoration(labelText: "Telefone")),
              TextField(controller: celCtrl, decoration: const InputDecoration(labelText: "Email")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text("Salvar")),
        ],
      ),
    );

    if (ok == true) {
      if (u == null) {
        await Api.inserir(nomeCtrl.text, telCtrl.text, celCtrl.text);
      } else {
        await Api.atualizar(u.raaluno, nomeCtrl.text, telCtrl.text, celCtrl.text);
      }
      await refresh();
    }
  }

  Future<void> confirmarExcluir(Usuario u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar exclusão"),
        content: Text("Excluir o usuário \"${u.nomealuno}\"?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text("Excluir")),
        ],
      ),
    );
    if (ok == true) {
      await Api.excluir(u.raaluno);
      await refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Usuários (MySQL via PHP)")),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: FutureBuilder<List<Usuario>>(
          future: future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text("Erro: ${snap.error}"));
            }
            final lista = snap.data ?? [];
            if (lista.isEmpty) {
              return const Center(child: Text("Nenhum usuário cadastrado."));
            }
            return ListView.separated(
              itemCount: lista.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final u = lista[i];
                return ListTile(
                  title: Text(u.nomealuno),
                  subtitle: Text("${u.celaluno}  •  ${u.telaluno}"),
                  onTap: () => abrirForm(u),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => confirmarExcluir(u),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => abrirForm(),
        icon: const Icon(Icons.add),
        label: const Text("Adicionar"),
      ),
    );
  }
}
