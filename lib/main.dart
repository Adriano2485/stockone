import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ← CORREÇÃO AQUI
  await Firebase.initializeApp();
  runApp(MyApp());
}

const verdeEscuro = Color(0xFF006400);
const vermelhoEscuro = Color(0xFF8B0000);
const branco = Color(0xfff1eaea);
const preto = Color(0xff0e0101);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ajudaí',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Color(0xFFFFF8F0),
        fontFamily: 'Lora',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'Lora',
            color: Color(0xFF5D4037),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontFamily: 'Lora',
            color: Color(0xFF6D4C41),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFD7A86E),
            foregroundColor: Colors.white,
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ),
      home: RedeScreen(),
    );
  }
}

class RedeScreen extends StatelessWidget {
  const RedeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0), // fundo aconchegante
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2691E),
        elevation: 4,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/StockOnesf.png', height: 50),
            const SizedBox(width: 12),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFE5B4), // topo claro
              Color(0xFFD29752), // marrom padaria
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                "Escolha a Rede:",
                style: TextStyle(
                  fontSize: 28,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037),
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Grid de opções
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2, // duas colunas
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2, // altura proporcional
                  children: [
                    _padariaCard("assets/images/bahamas.jpg", () {
                      Navigator.push(
                        // ✅ Alterado para push (em vez de pushReplacement)
                        context,
                        MaterialPageRoute(
                          builder: (context) => Codigos(),
                        ),
                      );
                    }),
                    _padariaCard("assets/images/paisefilhos.jpg", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Codigos(),
                        ),
                      );
                    }),
                    _padariaCard("assets/images/bh.jpg", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Codigos(),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _padariaCard(String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover, // preenche todo o card
            ),
          ),
          height: 150,
          width: double.infinity,
        ),
      ),
    );
  }
}

class Codigos extends StatelessWidget {
  const Codigos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Conteúdo rolável
          SingleChildScrollView(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 1.0,
              maxScale: 5.0,
              child: Image.asset(
                'assets/images/codigos.png',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 20,
            left: 10,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 20,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
