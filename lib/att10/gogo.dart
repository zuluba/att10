import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 1. Modelo de Dados (Album)
// Define a estrutura dos dados que esperamos receber da API.
class Album {
  final int userId;
  final int id;
  final String title;

  const Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  // Construtor de fábrica para criar uma instância de Album a partir de um mapa JSON.
  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'] as int, // Garante que seja int
      id: json['id'] as int,         // Garante que seja int
      title: json['title'] as String, // Garante que seja String
    );
  }
}

// 2. Função para Buscar o Álbum da Internet
// Esta função assíncrona faz a requisição HTTP.
Future<Album> fetchAlbum() async {
  try {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));

    if (response.statusCode == 200) {
      // Se a resposta for 200 OK, parseia o JSON e retorna um objeto Album.
      return Album.fromJson(jsonDecode(response.body));
    } else {
      // Se a resposta não for 200 OK, lança uma exceção com o código de status.
      // ignore: avoid_print
      print('Erro na requisição: Status Code ${response.statusCode}');
      throw Exception('Falha ao carregar o álbum. Código: ${response.statusCode}');
    }
  } catch (e) {
    // Captura qualquer erro que possa ocorrer durante a requisição (ex: sem internet).
    // ignore: avoid_print
    print('Ocorreu um erro ao buscar o álbum: $e');
    throw Exception('Não foi possível conectar ou carregar os dados: $e');
  }
}

void main() {
  runApp(const MyApp());
}

// 3. O Widget Principal (MyApp)
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Album> futureAlbum; // Declara uma Future que conterá o objeto Album

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum(); // Inicializa a Future chamando a função de busca
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exemplo de Busca de Dados',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Exemplo de Busca de Dados'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          // 4. FutureBuilder para lidar com o estado assíncrono
          // Ele reconstrói a UI quando a Future é concluída (com dados ou erro).
          child: FutureBuilder<Album>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Enquanto espera, mostra um indicador de carregamento.
                return const CircularProgressIndicator();
              } else if (snapshot.hasData) {
                // Se os dados foram carregados com sucesso, exibe o título.
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Dados Carregados:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(
                      'ID do Usuário: ${snapshot.data!.userId}\n'
                      'ID do Álbum: ${snapshot.data!.id}\n'
                      'Título: ${snapshot.data!.title}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                // Se ocorreu um erro, exibe a mensagem de erro.
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.blueAccent, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      'Erro: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Permite tentar novamente em caso de erro
                        setState(() {
                          futureAlbum = fetchAlbum();
                        });
                      },
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                );
              }
              // Caso nenhum dos estados acima seja atendido (raro, mas para completude)
              return const Text('Nenhum dado disponível.');
            },
          ),
        ),
      ),
    );
  }
}