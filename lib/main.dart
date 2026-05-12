import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.web,
      );
    } else {
      // Android / iOS usam os arquivos nativos
      await Firebase.initializeApp();
    }

    // ✅ AQUI É O LUGAR CERTO (CONFIGURAÇÃO GLOBAL DO CACHE)
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('Erro Firebase: $e');
  }

  runApp(const MyApp());
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
      title: 'StockOne',
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
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
      home: UpdateGate(
        child: RedeScreen(),
      ),
    );
  }
}

class UpdateGate extends StatefulWidget {
  final Widget child;
  const UpdateGate({super.key, required this.child});

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> {
  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    // ❌ Web não suporta In-App Update
    if (kIsWeb) return;

    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable &&
          info.immediateUpdateAllowed) {
        // 🔥 FORÇA ATUALIZAÇÃO
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      // erro silencioso (não trava o app)
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class RedeScreen extends StatefulWidget {
  const RedeScreen({super.key});

  @override
  State<RedeScreen> createState() => _RedeScreenState();
}

class _RedeScreenState extends State<RedeScreen> {
  bool _checking = false;

  Timer? _pressTimer;

  void _mostrarAjuda() async {
    final resposta = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Ajuda"),
          content: const Text("Assistir vídeo explicativo?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Não")),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Sim")),
          ],
        );
      },
    );

    if (resposta == true) {
      final url = "https://youtu.be/Jf6SqKmItZg";
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Não foi possível abrir o vídeo")),
        );
      }
    }
  }

  Future<void> _onCardTap(String rede, Widget destino) async {
    if (_checking) return;
    setState(() => _checking = true);

    try {
      final doc =
          await FirebaseFirestore.instance.collection('redes').doc(rede).get();

      if (!doc.exists) {
        _showError("Rede '$rede' não encontrada.");
        return;
      }

      final senhaFirebase = doc.data()?['senha'];

      final prefs = await SharedPreferences.getInstance();
      final senhaLocal = prefs.getString("senha_$rede");

      if (senhaLocal == senhaFirebase) {
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (_) => destino));
        return;
      }

      final aceita = await _mostrarDialogSenha(rede, senhaFirebase);

      if (aceita == true) {
        await prefs.setString("senha_$rede", senhaFirebase);
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (_) => destino));
      }
    } catch (e) {
      _showError("Erro: $e");
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<bool?> _mostrarDialogSenha(String rede, String senhaCorreta) {
    final controller = TextEditingController();

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Senha $rede"),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Digite a senha",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final digitada = controller.text.trim();

                if (digitada == senhaCorreta) {
                  Navigator.pop(ctx, true);
                } else {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text("Senha incorreta"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Entrar"),
            ),
          ],
        );
      },
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Widget _card(String imgPath, String rede, Widget destino) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onCardTap(rede, destino),
        onLongPress: () {
          if (rede == "bahamas") {
            _pressTimer = Timer(const Duration(seconds: 5), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HoleriteScreen(),
                ),
              );
            });
          }
        },
        onTapUp: (_) {
          _pressTimer?.cancel();
        },
        onTapCancel: () {
          _pressTimer?.cancel();
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image:
                DecorationImage(image: AssetImage(imgPath), fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _mostrarAjuda,
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff4dcd7e),
                  Color(0xff094e0b),
                ],
              ),
            ),
            padding: const EdgeInsets.all(16),
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
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      _card("assets/images/bahamas.jpg", "bahamas",
                          const Bahamas()),
                      _card("assets/images/paisefilhos.jpg", "paisefilhos",
                          const PaiseFilhos()),
                      _card("assets/images/bh.jpg", "bh", const BH()),
                      _card("assets/images/Mart-Minas.jpg", "martminas",
                          const Martminas()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_checking)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class Bahamas extends StatelessWidget {
  const Bahamas({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RedeScreen()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8F0),
        appBar: AppBar(
          backgroundColor: const Color(0xFFD2691E),
          elevation: 4,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/Logo StockOne.png',
                height: 30,
              ),
              const SizedBox(width: 8),
              Image.asset(
                'assets/images/logobahamas.jpg',
                height: 36,
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RedeScreen()),
              );
            },
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFE5B4),
                Color(0xFFD29752),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                const SizedBox(height: 14),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.32, // cards ~10% menores
                    children: [
                      _bahamasCard(
                        Icons.menu_book,
                        'RECEITUÁRIO',
                        Colors.orange.shade300,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReceituarioScreen(),
                            ),
                          );
                        },
                      ),
                      _bahamasCard(
                        Icons.folder,
                        'DOCUMENTOS',
                        Colors.brown.shade300,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Documentos(),
                            ),
                          );
                        },
                      ),
                      _bahamasCard(
                        Icons.list_alt,
                        'CÓDIGOS',
                        Colors.green.shade300,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Codigos(),
                            ),
                          );
                        },
                      ),
                      _bahamasCard(
                        Icons.store,
                        'ATENDIMENTO',
                        Colors.teal.shade300,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StoreSelectionScreen(),
                            ),
                          );
                        },
                      ),
                      _bahamasCard(
                        Icons.kitchen,
                        'COMODATOS',
                        Colors.brown.shade400,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Comodatos(),
                            ),
                          );
                        },
                      ),
                      _bahamasCard(
                        Icons.bar_chart,
                        'METAS',
                        Colors.teal.shade300,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TelaMetasLojas(),
                            ),
                          );
                        },
                      ),
                      _bahamasCard(
                        Icons.search,
                        'CONSULTAR RELATÓRIOS',
                        Colors.blue.shade300,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ConsultarRelatorios(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bahamasCard(
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 3,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        splashColor: color.withOpacity(0.25),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32, // reduzido ~10%
                color: color,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5, // reduzido ~10%
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                  color: Color(0xFF5D4037),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BH extends StatelessWidget {
  const BH({super.key});

  // 🔹 Card estilo Android
  Widget _menuCard(
    BuildContext context,
    IconData icon, // novo parâmetro
    String label,
    Widget destination,
    Color color,
  ) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.brown.withOpacity(0.3),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: const Color(0xFF5D4037),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Roboto',
                  color: Color(0xFF5D4037),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Botão físico de voltar: fecha o app ou navega para outra tela se quiser
        return true; // true permite o comportamento padrão (fecha o app)
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFD2691E),
          centerTitle: true,
          automaticallyImplyLeading:
              false, // se quiser ícone custom, use leading
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RedeScreen()),
              ); // volta para a tela anterior
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/Logo StockOne.png', height: 32),
              const SizedBox(width: 8),
              Image.asset(
                'assets/images/logobahamas.jpg',
                height: 40,
              ), // imagem no lugar do texto
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
                Color(0xFFD29752), // base marrom padaria
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 1, // 1 card por linha
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 3,
              children: [
                _menuCard(
                  context,
                  Icons.menu_book,
                  'RECEITUÁRIO',
                  ReceituarioScreen(),
                  Colors.white,
                ),
                _menuCard(
                  context,
                  Icons.folder,
                  'DOCUMENTOS',
                  Documentos(),
                  Colors.white,
                ),
                _menuCard(
                  context,
                  Icons.list_alt,
                  'CÓDIGOS',
                  Codigos(),
                  Colors.white,
                ),
                _menuCard(
                  context,
                  Icons.store,
                  'ATENDIMENTO',
                  StoreSelectionScreen(),
                  Colors.white,
                ),
                _menuCard(
                  context,
                  Icons.folder,
                  'METAS',
                  Documentos(),
                  Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PaiseFilhos extends StatelessWidget {
  const PaiseFilhos({super.key});

  // 🔹 Card estilo Android
  Widget _menuCard(
    BuildContext context,
    IconData icon, // novo parâmetro
    String label,
    Widget destination,
    Color color,
  ) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.brown.withOpacity(0.3),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: const Color(0xFF5D4037),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Roboto',
                  color: Color(0xFF5D4037),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Botão físico de voltar: fecha o app ou navega para outra tela se quiser
        return true; // true permite o comportamento padrão (fecha o app)
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFD2691E),
          centerTitle: true,
          automaticallyImplyLeading:
              false, // se quiser ícone custom, use leading
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RedeScreen()),
              ); // volta para a tela anterior
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/Logo StockOne.png', height: 32),
              const SizedBox(width: 8),
              Image.asset(
                'assets/images/logobahamas.jpg',
                height: 40,
              ), // imagem no lugar do texto
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
                Color(0xFFD29752), // base marrom padaria
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 1, // 1 card por linha
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 3,
              children: [
                _menuCard(
                  context,
                  Icons.menu_book,
                  'RECEITUÁRIO',
                  ReceituarioScreen(),
                  Colors.white,
                ),
                _menuCard(
                  context,
                  Icons.folder,
                  'DOCUMENTOS',
                  Documentos(),
                  Colors.white,
                ),
                _menuCard(
                  context,
                  Icons.list_alt,
                  'CÓDIGOS',
                  Codigos(),
                  Colors.white,
                ),
                _menuCard(
                  context,
                  Icons.store,
                  'ATENDIMENTO',
                  StoreSelectionScreen(),
                  Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StoreSelectionScreen extends StatefulWidget {
  @override
  _StoreSelectionScreenState createState() => _StoreSelectionScreenState();
}

// Instância global do SecureStorage
final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

class _StoreSelectionScreenState extends State<StoreSelectionScreen> {
  final List<String> stores =
      List.generate(100, (index) => 'Loja ${index + 1}');
  List<String> favoriteStores = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mapa para armazenar os nomes de usuário de cada loja
  Map<String, String> storeUsernames = {};

  // Controle de loading
  bool isLoadingUsernames = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadStoreUsernamesOptimized();
  }

  // SOLUÇÃO OTIMIZADA - Uma única requisição ao Firestore
  Future<void> _loadStoreUsernamesOptimized() async {
    // Tenta carregar do cache primeiro (mais rápido)
    final prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('storeUsernames_cache');
    final cacheTimestamp = prefs.getInt('storeUsernames_timestamp');
    final now = DateTime.now().millisecondsSinceEpoch;

    // Cache válido por 5 minutos
    bool isCacheValid =
        cacheTimestamp != null && (now - cacheTimestamp) < 300000;

    if (cachedData != null && isCacheValid) {
      try {
        final Map<String, String> cachedMap =
            Map<String, String>.from(jsonDecode(cachedData));
        if (mounted) {
          setState(() {
            storeUsernames = cachedMap;
            isLoadingUsernames = false;
          });
        }
      } catch (e) {
        // Erro ao decodificar cache, continua para buscar do Firestore
      }
    }

    // Busca dados atualizados do Firestore em background
    try {
      // Busca TODOS os documentos de uma só vez
      QuerySnapshot snapshot = await _firestore.collection('stores').get();

      // Cria mapa eficientemente
      Map<String, String> tempMap = {};

      // Primeiro, adiciona todas as lojas que existem no Firestore
      for (var doc in snapshot.docs) {
        String storeName = doc.id;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String userName = data['userName'] ?? 'Sem usuário';
        tempMap[storeName] = userName;
      }

      // Depois, preenche as lojas que não existem no Firestore
      for (String store in stores) {
        if (!tempMap.containsKey(store)) {
          tempMap[store] = 'Sem usuário';
        }
      }

      // Salva no cache com timestamp
      await prefs.setString('storeUsernames_cache', jsonEncode(tempMap));
      await prefs.setInt('storeUsernames_timestamp', now);

      // Atualiza a UI apenas se o widget ainda estiver montado
      if (mounted) {
        setState(() {
          storeUsernames = tempMap;
          isLoadingUsernames = false;
        });
      }
    } catch (e) {
      // Em caso de erro, mantém o cache se existir, senão mostra erro
      if (mounted && storeUsernames.isEmpty) {
        setState(() {
          for (String store in stores) {
            storeUsernames[store] = 'Erro ao carregar';
          }
          isLoadingUsernames = false;
        });
      } else if (mounted) {
        setState(() {
          isLoadingUsernames = false;
        });
      }
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        favoriteStores = prefs.getStringList('favoriteStores') ?? [];
      });
    }
  }

  Future<void> _toggleFavorite(String storeName) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoriteStores.contains(storeName)) {
        favoriteStores.remove(storeName);
      } else {
        favoriteStores.add(storeName);
      }
    });
    await prefs.setStringList('favoriteStores', favoriteStores);
  }

  Future<void> _onStoreSelected(BuildContext context, String storeName) async {
    final prefs = await SharedPreferences.getInstance();

    // Verificar se este dispositivo já está autorizado para esta loja
    bool isDeviceAuthorized = await _checkDeviceAuthorization(storeName);

    if (isDeviceAuthorized) {
      // Dispositivo autorizado - acesso direto
      await prefs.setString('selectedStore', storeName);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SecondScreen(storeName: storeName),
          ),
        );
      }
    } else {
      // Verificar se já existe caderno para esta loja
      bool hasExistingPassword = await _checkExistingPassword(storeName);

      await prefs.setString('selectedStore', storeName);

      if (hasExistingPassword) {
        // Loja já tem senha cadastrada - pedir senha
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PasswordScreen(
                storeName: storeName,
                isFirstTime: false,
              ),
            ),
          );
        }
      } else {
        // Primeiro cadastro - criar senha
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FirstTimeScreen(storeName: storeName),
            ),
          );
        }
      }
    }
  }

  Future<bool> _checkDeviceAuthorization(String storeName) async {
    try {
      // 1) Ler token salvo no dispositivo
      String? savedToken =
          await _secureStorage.read(key: '${storeName}_auth_token');

      if (savedToken == null) return false;

      // 2) Buscar senha atual do Firestore
      final doc = await _firestore.collection('stores').doc(storeName).get();

      if (!doc.exists) return false;

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String? currentPassword = data['password'];

      if (currentPassword == null) return false;

      // 3) Se a senha mudou -> FORÇA novo login
      return savedToken == currentPassword;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkExistingPassword(String storeName) async {
    try {
      final doc = await _firestore.collection('stores').doc(storeName).get();
      if (!doc.exists) return false;

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return data['password'] != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 85).floor().clamp(3, 8);

    // Separar lojas favoritas das normais
    final favoriteList =
        stores.where((store) => favoriteStores.contains(store)).toList();
    final normalList =
        stores.where((store) => !favoriteStores.contains(store)).toList();

    return WillPopScope(
      onWillPop: () async {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Bahamas()),
          );
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey.shade700,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Bahamas()),
                );
              }
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/Logo StockOne.png', height: 32),
              const SizedBox(width: 8),
              const Text(
                "ATENDIMENTO",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lora',
                ),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEFEFEF), Color(0xFFFDFDFD)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                const Text(
                  "SELECIONE A LOJA:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown,
                    fontFamily: 'Lora',
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: isLoadingUsernames && storeUsernames.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.brown),
                          ),
                        )
                      : ListView(
                          children: [
                            // Seção de Favoritos
                            if (favoriteList.isNotEmpty) ...[
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber.shade600,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "FAVORITOS",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber.shade800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "${favoriteList.length}",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 0.8,
                                ),
                                itemCount: favoriteList.length,
                                itemBuilder: (context, index) {
                                  final store = favoriteList[index];
                                  return _buildStoreTile(
                                    store,
                                    true,
                                    isFavoriteSection: true,
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              // Divisor
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey.shade300,
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Text(
                                        "TODAS AS LOJAS",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey.shade300,
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Seção de Todas as Lojas
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 0.8,
                              ),
                              itemCount: normalList.length,
                              itemBuilder: (context, index) {
                                final store = normalList[index];
                                return _buildStoreTile(
                                  store,
                                  false,
                                  isFavoriteSection: false,
                                );
                              },
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreTile(
    String store,
    bool isFavorite, {
    required bool isFavoriteSection,
  }) {
    final username = storeUsernames[store] ?? 'Carregando...';

    // Se ainda está carregando, mostra um efeito sutil
    final isLoading = storeUsernames[store] == null && isLoadingUsernames;

    return Card(
      elevation: isFavoriteSection ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isFavoriteSection
            ? BorderSide(color: Colors.amber.shade300, width: 1.5)
            : BorderSide.none,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: isFavoriteSection
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.amber.shade50,
                    Colors.orange.shade50,
                  ],
                )
              : null,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isLoading ? null : () => _onStoreSelected(context, store),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 12,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Espaço extra para compensar o ícone no topo
                    const SizedBox(height: 20),

                    Text(
                      store,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isFavoriteSection
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isFavoriteSection
                            ? Colors.brown.shade800
                            : Colors.brown.shade700,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (isLoading)
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isFavoriteSection
                                ? Colors.brown.shade600
                                : Colors.brown.shade400,
                          ),
                        ),
                      )
                    else
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: isFavoriteSection
                              ? Colors.brown.shade600
                              : Colors.brown.shade500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Positioned(
                top: 4,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.only(
                        bottom: 8), // Espaço abaixo do ícone
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite
                            ? Colors.amber.shade600
                            : Colors.grey.shade400,
                        size: 28,
                      ),
                      onPressed:
                          isLoading ? null : () => _toggleFavorite(store),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FirstTimeScreen extends StatefulWidget {
  final String storeName;
  const FirstTimeScreen({required this.storeName});

  @override
  _FirstTimeScreenState createState() => _FirstTimeScreenState();
}

class _FirstTimeScreenState extends State<FirstTimeScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _saveData() async {
    String userName = _userNameController.text.trim();
    String password = _passwordController.text.trim();

    if (userName.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, preencha todos os campos!")),
      );
      return;
    }

    try {
      // Salvar dados no Firestore
      await _firestore.collection('stores').doc(widget.storeName).set({
        'userName': userName,
        'password': password, // EM PRODUÇÃO: usar hash seguro
        'isFirstLaunch': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Gerar token de autorização para este dispositivo
      await _authorizeThisDevice();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => SecondScreen(storeName: widget.storeName)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar dados: $e")),
      );
    }
  }

  Future<void> _authorizeThisDevice() async {
    // Gerar um token único para este dispositivo
    String deviceToken =
        '${DateTime.now().millisecondsSinceEpoch}_${widget.storeName}_${_userNameController.text}';
    await _secureStorage.write(
        key: '${widget.storeName}_auth_token', value: deviceToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              Image.asset('assets/images/StockOnesf.png', height: 120),
              const SizedBox(height: 24),
              const Text(
                "Olá! Cadastre-se!!!",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037)),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _userNameController,
                decoration: const InputDecoration(
                  labelText: "Nome do Usuário",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Criar Senha",
                  hintText: "Senha que outros dispositivos usarão",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveData,
                child: const Text("Salvar Dados"),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PasswordScreen extends StatefulWidget {
  final String storeName;
  final bool isFirstTime;

  const PasswordScreen({
    required this.storeName,
    required this.isFirstTime,
  });

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  void _verifyPassword() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, digite a senha!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();

      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Loja não encontrada!")),
        );
        return;
      }

      final data = doc.data()!;
      final String? storedPassword = data['password'];
      final String? masterPassword = data['masterPassword'];
      final String inputPassword = _passwordController.text.trim();

      // SENHA NORMAL OU SENHA MESTRA
      if (inputPassword == storedPassword ||
          (masterPassword != null && inputPassword == masterPassword)) {
        // Autoriza o dispositivo
        await _authorizeThisDevice(inputPassword);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SecondScreen(storeName: widget.storeName),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Senha incorreta!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao verificar senha: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Salva a senha usada (normal ou mestra) para liberar acesso automático
  Future<void> _authorizeThisDevice(String passwordUsed) async {
    await _secureStorage.write(
      key: '${widget.storeName}_auth_token',
      value: passwordUsed,
    );
  }

  void _goBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => StoreSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _goBack,
        ),
        title: Text(
          widget.storeName,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/StockOnesf.png', height: 100),
            const SizedBox(height: 30),
            Text(
              widget.isFirstTime ? "Cadastre uma senha" : "Acesso Restrito",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.isFirstTime
                  ? "Crie uma senha para a ${widget.storeName}"
                  : "Esta loja já possui senha cadastrada.\nDigite a senha para continuar:",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // CAMPO SENHA
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Senha",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),

            const SizedBox(height: 30),

            // BOTÃO CONFIRMAR
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifyPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                    child: Text(
                      widget.isFirstTime ? "Criar Senha" : "Acessar Loja",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

            const SizedBox(height: 20),

            if (!widget.isFirstTime)
              TextButton(
                onPressed: _goBack,
                child: Text(
                  "Voltar para seleção de lojas",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  final String storeName;
  const SecondScreen({required this.storeName});

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('stores')
          .doc(widget.storeName)
          .get();

      if (doc.exists) {
        setState(() {
          userName = doc.data()?['userName'] ?? "Usuário";
        });
      } else {
        setState(() {
          userName = "Usuário";
        });
      }
    } catch (e) {
      setState(() {
        userName = "Usuário";
      });
    }
  }

  Future<void> _resetStoreData() async {
    try {
      final storeDoc =
          FirebaseFirestore.instance.collection('stores').doc(widget.storeName);

      await storeDoc.update({
        'password': null,
        'isFirstLaunch': true,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });

      await _secureStorage.delete(key: '${widget.storeName}_auth_token');

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => FirstTimeScreen(storeName: widget.storeName),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao resetar dados: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => StoreSelectionScreen()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8F0),
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => StoreSelectionScreen()),
                (route) => false,
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Opções"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.refresh,
                                color: Color(0xFFD2691E)),
                            title: const Text("Alterar usuário/senha"),
                            onTap: () async {
                              Navigator.pop(context);
                              await _resetStoreData();
                            },
                          ),
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFE5B4),
                Color(0xFFD29752),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12), // reduzido
            child: Column(
              children: [
                Text(
                  "${widget.storeName}",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  "Bem-vindo, $userName!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown.shade700,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.45, // 🔥 MAIS COMPACTO (cabe 8+)
                    children: [
                      _padariaCard(Icons.bakery_dining, "Venda Produtos",
                          Colors.orange.shade300, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ThirdScreen(storeName: widget.storeName),
                          ),
                        );
                      }),
                      _padariaCard(Icons.inventory, "Acerto Estoque",
                          Colors.brown.shade300, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StockAdjustmentScreen(
                                storeName: widget.storeName),
                          ),
                        );
                      }),
                      _padariaCard(
                          Icons.note_alt, "Pedido", Colors.green.shade300, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FourthScreen(storeName: widget.storeName),
                          ),
                        );
                      }),
                      _padariaCard(
                          Icons.note, "Relatórios", Colors.teal.shade300, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MenuScreen(storeName: widget.storeName),
                          ),
                        );
                      }),
                      _padariaCard(
                          Icons.kitchen, "Equipamento", Colors.brown.shade400,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Equipamentos(storeName: widget.storeName),
                          ),
                        );
                      }),
                      _padariaCard(
                          Icons.note_add, "Requisição", Colors.teal.shade300,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Requisicao(storeName: widget.storeName),
                          ),
                        );
                      }),
                      _padariaCard(
                          Icons.track_changes, "Meta", Colors.teal.shade300,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Meta(storeName: widget.storeName),
                          ),
                        );
                      }),
                      _padariaCard(Icons.schedule, "Cronograma de Produção",
                          Colors.teal.shade300, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManutencaoScreen(),
                          ),
                        );
                      }),

                      // 🔽 VOCÊ PODE ADICIONAR MAIS CARDS AQUI
                      // exemplo
                      // _padariaCard(Icons.analytics, "Novo", Colors.blue, () {}),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _padariaCard(
      IconData icon, String label, Color color, VoidCallback onPressed) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 3,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        splashColor: color.withOpacity(0.3),
        child: Container(
          padding: const EdgeInsets.all(8), // 🔥 menor padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: color), // 🔥 menor ícone
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14, // 🔥 menor texto
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                  color: Color(0xFF5D4037),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _padariaCard(
    IconData icon, String label, Color color, VoidCallback onPressed) {
  return Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    elevation: 4,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      splashColor: color.withOpacity(0.3),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Roboto',
                color: Color(0xFF5D4037),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class ThirdScreen extends StatefulWidget {
  final String storeName;
  const ThirdScreen({required this.storeName});

  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

// Formatter personalizado que aceita vírgula e ponto
class DecimalWithCommaFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Permite números, vírgula e ponto
    final regex = RegExp(r'^\d*([,.]?\d{0,2})?$');

    // Se não corresponder ao padrão, retorna o valor antigo
    if (!regex.hasMatch(newValue.text)) {
      return oldValue;
    }

    return newValue;
  }
}

class _ThirdScreenState extends State<ThirdScreen> {
  final List<String> subprodutos = [
    'Pão Francês',
    'Pão Francês Fibras',
    'Pão Francês Panhoca',
    'Pão Francês com Queijo',
    'Pão Baguete Francesa Queijo',
    'Pão Baguete Francesa',
    'Pão Baguete Francesa Gergelim',
    'Baguete Francesa Queijo',
    'Baguete Francesa',
    'Pão Queijo Tradicional',
    'Pão Queijo Coquetel',
    'Biscoito Queijo',
    'Biscoito Polvilho',
    'Pão Samaritano',
    'Pão Pizza',
    'Pão Tatu',
    'Mini Pão Sonho',
    'Mini Pão Sonho Chocolate',
    'Pão Bambino',
    'Mini Marta Rocha',
    'Pão Doce Ferradura',
    'Pão Doce Caracol',
    'Rosca Caseira',
    'Rosca Caseira Côco',
    'Rosca Caseira Leite em Pó',
    'Sanduíche Bahamas',
    'Pão Fofinho',
    'Sanduíche Fofinho',
    'Rosca Fofinha Temperada',
    'Caseirinho',
    'Pão Milho',
    'Pão de Alho da Casa',
    'Pão de Alho da Casa Picante',
    'Torta Chocomousse',
    'Torta Chocolate/Coco',
    'Torta Doce De Leite Amendoim',
    'Torta Dois Amores',
  ];

  int deliveriesValue = 7; // Valor real das entregas (7, 4 ou 3)
  int selectedOption = 1; // Opção selecionada (1, 2 ou 3)
  int? diasDeGiro;

  final Map<String, TextEditingController> vendasControllers = {};
  final Map<String, TextEditingController> estoqueControllers = {};
  final Map<String, bool> estoqueEditadoManual = {};

  final TextEditingController giroController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  bool _dataLoaded = false;

  // Mapeamento das opções para valores reais de entregas
  int _getDeliveriesValueFromOption(int option) {
    switch (option) {
      case 1:
        return 7;
      case 2:
        return 4;
      case 3:
        return 3;
      default:
        return 7;
    }
  }

  // Mapeamento do valor real para a opção
  int _getOptionFromDeliveriesValue(int deliveriesValue) {
    switch (deliveriesValue) {
      case 7:
        return 1;
      case 4:
        return 2;
      case 3:
        return 3;
      default:
        return 1;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadAllData();
    WakelockPlus.enable();
  }

  void _initializeControllers() {
    for (var produto in subprodutos) {
      vendasControllers[produto] = TextEditingController();
      estoqueControllers[produto] = TextEditingController();
      estoqueEditadoManual[produto] = false;
    }
  }

  // Função auxiliar para converter string com vírgula/ponto para double
  double _parseDecimalString(String value) {
    if (value.isEmpty) return 0.0;

    // Substitui vírgula por ponto para garantir o parse correto
    final normalizedValue = value.replaceAll(',', '.');

    // Tenta fazer o parse
    final parsedValue = double.tryParse(normalizedValue);

    // Se não conseguir fazer o parse, tenta remover caracteres não numéricos
    if (parsedValue == null) {
      // Remove tudo que não for dígito, ponto ou vírgula
      final cleanedValue = value.replaceAll(RegExp(r'[^\d,.]'), '');
      if (cleanedValue.isEmpty) return 0.0;

      final normalizedCleanedValue = cleanedValue.replaceAll(',', '.');
      return double.tryParse(normalizedCleanedValue) ?? 0.0;
    }

    return parsedValue;
  }

  Future<void> _loadAllData() async {
    if (_dataLoaded) return;

    setState(() => _isLoading = true);

    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();

      if (doc.exists) {
        final data = doc.data() ?? {};

        // Carrega o valor real das entregas salvo no Firebase
        int loadedDeliveriesValue = data['deliveriesValue'] ?? 7;

        setState(() {
          deliveriesValue = loadedDeliveriesValue;
          selectedOption = _getOptionFromDeliveriesValue(loadedDeliveriesValue);
        });

        final diasGiroData = data['diasGiro'];
        if (diasGiroData != null) {
          setState(() {
            diasDeGiro = diasGiroData is int
                ? diasGiroData
                : int.tryParse(diasGiroData.toString());
            giroController.text = diasDeGiro?.toString() ?? '';
          });
        }

        final vendasData = data['vendas'] ?? {};
        final estoqueData = data['estoque'] ?? {};

        for (var produto in subprodutos) {
          final vendas = vendasData[produto];
          final estoque = estoqueData[produto];
          if (vendas != null) {
            // Converter para string mantendo decimais
            final doubleVendas = vendas is double ? vendas : vendas.toDouble();

            // Formatar: se for inteiro, mostra sem decimais, senão mostra com 2 casas
            if (doubleVendas % 1 == 0) {
              vendasControllers[produto]!.text =
                  doubleVendas.toInt().toString();
            } else {
              // Usar ponto como padrão, mas o usuário pode digitar vírgula depois
              vendasControllers[produto]!.text =
                  doubleVendas.toStringAsFixed(2);
            }
          }

          if (estoque != null) {
            final numero = double.tryParse(estoque.toString());
            if (numero != null) {
              estoqueControllers[produto]!.text = numero.floor().toString();
            } else {
              estoqueControllers[produto]!.text = estoque.toString();
            }
            estoqueEditadoManual[produto] = true;
          }
        }

        if (diasDeGiro != null && diasDeGiro! > 0) {
          _recalculateAllAutocalc(force: false);
        }

        _dataLoaded = true;
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveDeliveries(int option) async {
    int newDeliveriesValue = _getDeliveriesValueFromOption(option);

    try {
      await _firestore.collection('stores').doc(widget.storeName).set({
        'deliveriesValue': newDeliveriesValue,
        'deliveriesOption':
            option, // Opcional: salvar também a opção para referência
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        deliveriesValue = newDeliveriesValue;
        selectedOption = option;
      });

      // Recalcula todos os produtos quando as entregas mudam
      if (diasDeGiro != null && diasDeGiro! > 0) {
        _recalculateAllAutocalc(force: true);
      }
    } catch (e) {
      print('Erro ao salvar entregas por semana: $e');
    }
  }

  void _onVendasChanged(String produto) {
    final textoVenda = vendasControllers[produto]!.text;
    final valorMensal = _parseDecimalString(textoVenda);
    final estoqueMax = _calcularEstoqueMaximo(valorMensal, produto);

    setState(() {
      estoqueControllers[produto]!.text = estoqueMax.toInt().toString();
      estoqueEditadoManual[produto] = false;
    });

    _saveProductData(produto);
  }

  Future<void> _saveProductData(String produto) async {
    try {
      final vendasData = <String, dynamic>{};
      final estoqueData = <String, dynamic>{};

      for (var prod in subprodutos) {
        final vendaText = vendasControllers[prod]!.text;
        final estoqueText = estoqueControllers[prod]!.text;

        if (vendaText.isNotEmpty) {
          // Usar a função de parse que aceita vírgula
          vendasData[prod] = _parseDecimalString(vendaText);
        }
        if (estoqueText.isNotEmpty) {
          estoqueData[prod] = double.tryParse(estoqueText) ?? 0;
        }
      }

      await _firestore.collection('stores').doc(widget.storeName).set({
        'vendas': vendasData,
        'estoque': estoqueData,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Erro ao salvar dados do produto $produto: $e');
    }
  }

  Future<void> _saveDiasDeGiro(int value) async {
    try {
      await _firestore.collection('stores').doc(widget.storeName).set({
        'diasGiro': value,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        diasDeGiro = value;
      });

      if (value > 0) {
        _recalculateAllAutocalc(force: true);
      }
    } catch (e) {
      print('Erro ao salvar dias de giro: $e');
    }
  }

  void _calculateAndSave(String produto) {
    final textoVenda = vendasControllers[produto]!.text;
    final valorMensal = _parseDecimalString(textoVenda);
    final estoqueMax = _calcularEstoqueMaximo(valorMensal, produto);

    setState(() {
      estoqueControllers[produto]!.text = estoqueMax.toInt().toString();
      estoqueEditadoManual[produto] = false;
    });

    _saveProductData(produto);
  }

  void _onEstoqueChanged(String produto) {
    setState(() {
      estoqueEditadoManual[produto] = true;
    });
    _saveProductData(produto);
  }

  void _refreshEstoque(String produto) {
    if (vendasControllers[produto]!.text.isNotEmpty) {
      setState(() {
        estoqueEditadoManual[produto] = false;
        _calculateAndSave(produto);
      });
    }
  }

  void _recalculateAllAutocalc({bool force = false}) {
    if (diasDeGiro == null || diasDeGiro! <= 0) return;

    for (var produto in subprodutos) {
      if (estoqueEditadoManual[produto]! && !force) continue;

      final textoVenda = vendasControllers[produto]!.text;
      final valorMensal = _parseDecimalString(textoVenda);
      final estoqueMax = _calcularEstoqueMaximo(valorMensal, produto);
      estoqueControllers[produto]!.text = estoqueMax.toInt().toString();

      if (force) {
        setState(() {
          estoqueEditadoManual[produto] = false;
        });
      }
    }

    _saveProductData('all');
  }

  void _refreshTodos() {
    for (var produto in subprodutos) {
      _refreshEstoque(produto);
    }
  }

  double _calcularEstoqueMaximo(double valorMensal, String produto) {
    if (diasDeGiro == null || diasDeGiro! <= 0) return 0;

    double estoqueMax = 0;
    switch (produto) {
      case 'Pão Francês':
        estoqueMax =
            (valorMensal * 1.40 / diasDeGiro! / 10.5) * deliveriesValue;
        break;
      case 'Pão Baguete Francesa':
        estoqueMax = (valorMensal * 1.20 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Pão Baguete Francesa Gergelim':
        estoqueMax = (valorMensal * 1.40 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Pão Baguete Francesa Queijo':
        estoqueMax = (valorMensal * 1.40 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Pão Fofinho':
        estoqueMax = (valorMensal * 1.30 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Sanduíche Fofinho':
        estoqueMax =
            (valorMensal * 0.06 * 1.30 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Rosca Fofinha Temperada':
        estoqueMax =
            (valorMensal * 0.3 * 1.30 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Caseirinho':
        estoqueMax = (valorMensal * 1.30 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Pão Francês Fibras':
        estoqueMax = (valorMensal * 1.40 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Pão Francês Panhoca':
        estoqueMax = (valorMensal * 1.40 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Pão Francês com Queijo':
        estoqueMax = (valorMensal * 1.40 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Baguete Francesa Queijo':
        estoqueMax =
            (valorMensal * 0.33 * 1.20 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Baguete Francesa':
        estoqueMax =
            (valorMensal * 0.33 * 1.20 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Pão Queijo Tradicional':
        estoqueMax = (valorMensal * 1.42 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Pão Queijo Coquetel':
        estoqueMax = (valorMensal * 1.5 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Biscoito Queijo':
        estoqueMax = (valorMensal * 1.42 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Biscoito Polvilho':
        estoqueMax = (valorMensal * 2 / diasDeGiro! / 1.35) * deliveriesValue;
        break;
      case 'Pão Samaritano':
        estoqueMax =
            (valorMensal * 0.085 * 1.20 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Pão Pizza':
        estoqueMax =
            (valorMensal * 0.08 * 1.20 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Pão Tatu':
        estoqueMax = (valorMensal * 1.40 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Mini Pão Sonho':
        estoqueMax =
            (valorMensal * 0.5 * 1.20 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Mini Pão Sonho Chocolate':
        estoqueMax =
            (valorMensal * 0.5 * 1.20 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Pão Bambino':
        estoqueMax =
            (valorMensal * 0.6 * 1.20 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Mini Marta Rocha':
        estoqueMax =
            (valorMensal * 0.5 * 1.20 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Pão Doce Ferradura':
        estoqueMax = (valorMensal * 1.20 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Pão Doce Caracol':
        estoqueMax = (valorMensal * 1.20 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Rosca Caseira':
        estoqueMax = (valorMensal * 1.20 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Rosca Caseira Côco':
        estoqueMax = (valorMensal * 1.20 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Rosca Caseira Leite em Pó':
        estoqueMax = (valorMensal * 1.20 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Pão Milho':
        estoqueMax = (valorMensal * 1.3 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Pão de Alho da Casa':
        estoqueMax =
            (valorMensal * 0.24 * 1.20 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Pão de Alho da Casa Picante':
        estoqueMax =
            (valorMensal * 0.24 * 1.20 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Sanduíche Bahamas':
        estoqueMax =
            (valorMensal * 0.085 * 1.20 / diasDeGiro! / 3.3) * deliveriesValue;
        break;
      case 'Torta Chocomousse':
        estoqueMax = (valorMensal * 1.20 / diasDeGiro!) * deliveriesValue;
        break;
      case 'Torta Chocolate/Coco':
        estoqueMax = (valorMensal * 1.20 / diasDeGiro!) * deliveriesValue;
        break;
      case 'Torta Doce De Leite Amendoim':
        estoqueMax = (valorMensal * 1.20 / diasDeGiro!) * deliveriesValue;
        break;
      case 'Torta Dois Amores':
        estoqueMax = (valorMensal * 1.20 / diasDeGiro!) * deliveriesValue;
        break;
      default:
        estoqueMax = 0.0;
    }
    return estoqueMax.ceilToDouble();
  }

  Future<void> _resetAllData() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CONFIRMAÇÃO'),
        content: const Text('Deseja apagar todos os dados?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );

    if (shouldReset == true) {
      try {
        await _firestore.collection('stores').doc(widget.storeName).set({
          'vendas': {},
          'estoque': {},
          'diasGiro': null,
          'deliveriesValue': 7, // Valor padrão 7 (opção 1)
          'deliveriesOption': 1,
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        for (final produto in subprodutos) {
          vendasControllers[produto]!.clear();
          estoqueControllers[produto]!.clear();
          estoqueEditadoManual[produto] = false;
        }

        setState(() {
          diasDeGiro = null;
          giroController.clear();
          deliveriesValue = 7;
          selectedOption = 1;
          _dataLoaded = false;
        });
      } catch (e) {
        print('Erro ao resetar dados: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xffd99f5c),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/Logo StockOne.png', height: 30),
              const SizedBox(width: 10),
              const Text(
                "VENDAS",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  fontFamily: 'Lora',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffd99f5c),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/Logo StockOne.png', height: 30),
            const SizedBox(width: 10),
            const Text(
              "VENDAS",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                fontFamily: 'Lora',
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Apagar Dados',
            onPressed: () => _resetAllData(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade400, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Card for Dias de Giro
              Card(
                elevation: 1,
                margin: const EdgeInsets.all(2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "DIAS DE GIRO",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey.shade800,
                        ),
                      ),
                      Row(
                        children: [
                          // Seletor de dias de giro
                          Container(
                            width: 100,
                            child: TextFormField(
                              controller: giroController,
                              keyboardType: TextInputType.number,
                              maxLength: 3,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              style: const TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                ),
                                counterText: "",
                                suffixIcon: PopupMenuButton<int>(
                                  icon: const Icon(Icons.arrow_drop_down,
                                      size: 18),
                                  onSelected: (val) {
                                    giroController.text = val.toString();
                                    _saveDiasDeGiro(val);
                                    giroController.selection =
                                        TextSelection.fromPosition(
                                      TextPosition(
                                          offset: giroController.text.length),
                                    );
                                  },
                                  itemBuilder: (context) => List.generate(
                                    31,
                                    (index) => PopupMenuItem(
                                      value: index + 1,
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                final val = int.tryParse(value);
                                if (val != null && val > 0)
                                  _saveDiasDeGiro(val);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Botão atualizar
                          IconButton(
                            icon: const Icon(Icons.refresh,
                                color: Colors.blue, size: 20),
                            tooltip: "Atualizar todos",
                            onPressed: _refreshTodos,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // New Card for Entregas por Semana (Deliveries per week)
              // New Card for Entregas por Semana (Deliveries per week)
// New Card for Entregas por Semana (Deliveries per week)
              Card(
                elevation: 1,
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "ENTREGAS P/ SEMANA",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey.shade800,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildDeliveryOption(1),
                          const SizedBox(width: 8),
                          _buildDeliveryOption(2),
                          const SizedBox(width: 8),
                          _buildDeliveryOption(3),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: subprodutos.length,
                  itemBuilder: (context, index) {
                    final produto = subprodutos[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              produto,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey.shade800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                // Campo VENDA - aceita vírgula e ponto
                                Expanded(
                                  flex: 5,
                                  child: TextField(
                                    controller: vendasControllers[produto],
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      DecimalWithCommaFormatter(),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Venda',
                                      hintText: 'Ex: 1500 ou 1500,50',
                                      border: const OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                    ),
                                    onChanged: (_) => _onVendasChanged(produto),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.refresh,
                                      color: Colors.blue),
                                  onPressed: () => _refreshEstoque(produto),
                                ),
                                const SizedBox(width: 4),
                                // Campo MIN. PCTS - apenas inteiros
                                Expanded(
                                  flex: 5,
                                  child: TextField(
                                    controller: estoqueControllers[produto],
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Min. Pcts',
                                      border: const OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                    ),
                                    onChanged: (_) =>
                                        _onEstoqueChanged(produto),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapeamentoEstoqueScreen(
                          storeName: widget.storeName,
                          subprodutos: subprodutos),
                    ),
                  );
                },
                child: Text('Mapeamento de Estoque',
                    style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryOption(int option) {
    final isSelected = selectedOption == option;
    return GestureDetector(
      onTap: () => _saveDeliveries(option),
      child: Container(
        width: 32, // Largura fixa para consistência
        height: 32, // Altura fixa para consistência
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16), // Botão circular
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade400,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            option.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class MapeamentoEstoqueScreen extends StatefulWidget {
  final String storeName;
  final List<String> subprodutos;

  const MapeamentoEstoqueScreen({
    required this.storeName,
    required this.subprodutos,
    Key? key,
  }) : super(key: key);

  @override
  _MapeamentoEstoqueScreenState createState() =>
      _MapeamentoEstoqueScreenState();
}

class _MapeamentoEstoqueScreenState extends State<MapeamentoEstoqueScreen> {
  // ✅ MUDANÇA: Map<String, int> em vez de Map<String, String>
  Map<String, int> estoqueMaximos = {};
  int totalFreezers = 0;
  List<Map<String, dynamic>> freezersData = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadEstoqueMaximoData();
    _loadFreezersData();
  }

  Future<void> _loadFreezersData() async {
    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        final freezersList = data['freezers'] ?? [];

        if (freezersList is List && freezersList.isNotEmpty) {
          setState(() {
            freezersData = List<Map<String, dynamic>>.from(freezersList);
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar freezers: $e');
    }
  }

  Future<void> _loadEstoqueMaximoData() async {
    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        final estoqueData = data['estoque'] ?? {};

        // ✅ MUDANÇA: Map<String, int> em vez de Map<String, String>
        Map<String, int> dadosEstoque = {};

        Map<String, List<String>> categorias = {
          'Massa Pão Fofinho': [
            'Pão Fofinho',
            'Sanduíche Fofinho',
            'Rosca Fofinha Temperada',
            'Caseirinho'
          ],
          'Massa Pão Francês': ['Pão Francês', 'Pão Samaritano'],
          'Massa Pão Francês Fibras': ['Pão Francês Fibras'],
          'Massa Mini Baguete 90g': [
            'Pão de Alho da Casa',
            'Pão de Alho da Casa Picante',
            'Sanduíche Bahamas',
            'Pão Baguete Francesa Queijo',
            'Pão Baguete Francesa',
            'Pão Baguete Francesa Gergelim'
          ],
          'Massa Mini Baguete 40g': ['Pão Francês com Queijo'],
          'Massa Baguete 330g': ['Baguete Francesa Queijo', 'Baguete Francesa'],
          'Massa Pão Doce Comprido': ['Pão Milho'],
          'Massa Rosca 330g': [
            'Rosca Caseira',
            'Rosca Caseira Côco',
            'Rosca Caseira Leite em Pó'
          ],
          'Massa Pão Doce Caracol': ['Pão Doce Caracol'],
          'Massa Pão Doce Ferradura': ['Pão Doce Ferradura'],
          'Massa Bambino': [
            'Mini Pão Sonho',
            'Mini Pão Sonho Chocolate',
            'Pão Bambino'
          ],
          'Massa Mini Marta Rocha': ['Mini Marta Rocha', 'Pão Pizza'],
          'Massa Pão Tatu': ['Pão Tatu'],
          'Massa Biscoito Polvilho': ['Biscoito Polvilho'],
          'Massa Pão Queijo Coquetel': ['Pão Queijo Coquetel'],
          'Massa Pão Queijo Tradicional': ['Pão Queijo Tradicional'],
          'Massa Biscoito Queijo': ['Biscoito Queijo'],
          'Massa Cervejinha': ['Pão Francês Panhoca'],
        };

        final produtosTetoMinimo2 = ['Massa Pão Francês'];

        int pacotesPaoFrances = 0;
        int pacotesOutrasMassas = 0;

        for (var categoria in categorias.entries) {
          int somaEstoque = 0;

          for (String subproduto in categoria.value) {
            final estoqueMax = estoqueData[subproduto];
            if (estoqueMax != null) {
              // ✅ MUDANÇA: Buscar como NUMBER e converter para inteiro
              int valorEstoque = 0;
              if (estoqueMax is int) {
                valorEstoque = estoqueMax;
              } else if (estoqueMax is double) {
                valorEstoque = estoqueMax.floor(); // Converte double para int
              } else if (estoqueMax is String) {
                valorEstoque = int.tryParse(estoqueMax) ?? 0; // Fallback
              }
              somaEstoque += valorEstoque;
            }
          }

          int estoqueFinal;
          if (produtosTetoMinimo2.contains(categoria.key)) {
            estoqueFinal = somaEstoque < 2 ? 2 : somaEstoque;
          } else {
            estoqueFinal = somaEstoque < 6 ? 6 : somaEstoque;
          }

          // ✅ MUDANÇA: Salvar como int diretamente
          dadosEstoque[categoria.key] = estoqueFinal;

          if (categoria.key.contains('Pão Francês')) {
            pacotesPaoFrances += estoqueFinal;
          } else {
            pacotesOutrasMassas += estoqueFinal;
          }
        }

        int freezersPaoFrances = (pacotesPaoFrances / 54).ceil();
        int espacoRestante = freezersPaoFrances * 54 - pacotesPaoFrances;
        int espacoOcupadoOutrasMassas = (pacotesOutrasMassas / 2.3).ceil();

        if (espacoOcupadoOutrasMassas <= espacoRestante) {
          totalFreezers = freezersPaoFrances;
        } else {
          int freezersOutrasMassas = (espacoOcupadoOutrasMassas / 126).ceil();
          totalFreezers = freezersPaoFrances + freezersOutrasMassas;
        }

        setState(() {
          estoqueMaximos = dadosEstoque;
        });
      }
    } catch (e) {
      print('Erro ao carregar estoque máximo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('INVENTÁRIO'),
      ),
      body: estoqueMaximos.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: estoqueMaximos.length,
                    itemBuilder: (context, index) {
                      String categoria = estoqueMaximos.keys.elementAt(index);
                      // ✅ MUDANÇA: Acessar como int diretamente
                      int estoqueMax = estoqueMaximos[categoria] ?? 0;

                      return ListTile(
                        title: Text(
                          categoria,
                          style: TextStyle(fontSize: 20),
                        ),
                        subtitle: Text(
                          'Teto de Estoque: $estoqueMax', // ✅ Já é int
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LayoutDistribuicaoScreen(
                            storeName: widget.storeName,
                            // ✅ MUDANÇA: Passar Map<String, int>
                            estoqueMassas: estoqueMaximos,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Layout de Distribuição',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class LayoutDistribuicaoScreen extends StatefulWidget {
  final String storeName;
  // ✅ MUDANÇA: Map<String, int> em vez de Map<String, String>
  final Map<String, int> estoqueMassas;

  const LayoutDistribuicaoScreen({
    super.key,
    required this.storeName,
    required this.estoqueMassas,
  });

  @override
  State<LayoutDistribuicaoScreen> createState() =>
      _LayoutDistribuicaoScreenState();
}

class _LayoutDistribuicaoScreenState extends State<LayoutDistribuicaoScreen> {
  // Configurações da aplicação
  static const _VOLUME_FATORES = {
    'Massa Pão Francês': 0.0557,
    'Massa Biscoito Polvilho': 0.318,
  };

  static const _VOLUME_PADRAO = {
    'Horizontal': 0.187,
    'Vertical': 0.113,
  };

  // Ordem EXATA de distribuição (pedido do usuário)
  final List<String> _listaMassas = [
    'Massa Rosca 330g',
    'Massa Pão Doce Ferradura',
    'Massa Pão Doce Caracol',
    'Massa Bambino',
    'Massa Mini Marta Rocha',
    'Massa Pão Tatu',
    'Massa Pão Fofinho',
    'Massa Pão Doce Comprido',
    'Massa Biscoito Polvilho',
    'Massa Biscoito Queijo',
    'Massa Pão Queijo Coquetel',
    'Massa Pão Queijo Tradicional',
    'Massa Baguete 330g',
    'Massa Mini Baguete 40g',
    'Massa Mini Baguete 90g',
    'Massa Pão Francês Fibras',
    'Massa Cervejinha',
    'Massa Pão Francês',
  ];

  List<Map<String, dynamic>> _freezersData = [];
  Map<int, Map<String, int>> _distribuicao = {};
  Map<String, int> _massasFaltantes = {};
  bool _faltaEspaco = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _carregarDadosFreezers();
  }

  // =====================================
  // CARREGAMENTO DOS FREEZERS
  // =====================================

  Future<void> _carregarDadosFreezers() async {
    try {
      final snapshot =
          await _firestore.collection('stores').doc(widget.storeName).get();

      if (!snapshot.exists || !_validarFreezers(snapshot)) {
        _mostrarDialogoAtencao();
        return;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final freezersList = data['freezers'] as List<dynamic>? ?? [];

      setState(() {
        _freezersData =
            freezersList.map((item) => item as Map<String, dynamic>).toList();
      });

      _distribuirMassas();
    } catch (e) {
      print('Erro ao carregar freezers: $e');
    }
  }

  bool _validarFreezers(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return (data['freezers'] as List?)?.isNotEmpty ?? false;
  }

  // =====================================
  // LÓGICA DE DISTRIBUIÇÃO
  // =====================================

  void _distribuirMassas() {
    _ordenarFreezersHorizontaisPrimeiro();
    _inicializarDistribuicao();

    final volumes = _calcularVolumesFreezers();
    final volumeOcupado = List.filled(_freezersData.length, 0.0);

    for (final massa in _listaMassas) {
      int qtdRestante = widget.estoqueMassas[massa] ?? 0;

      for (int i = 0; i < _freezersData.length && qtdRestante > 0; i++) {
        qtdRestante = _alocar(
          massa,
          qtdRestante,
          i,
          volumes[i],
          volumeOcupado,
        );
      }

      if (qtdRestante > 0) {
        _massasFaltantes[massa] = qtdRestante;
        _faltaEspaco = true;
      }
    }

    setState(() {});
  }

  void _ordenarFreezersHorizontaisPrimeiro() {
    _freezersData.sort((a, b) {
      final tipoA = a['tipo'] ?? 'Horizontal';
      final tipoB = b['tipo'] ?? 'Horizontal';

      if (tipoA == 'Horizontal' && tipoB != 'Horizontal') return -1;
      if (tipoA != 'Horizontal' && tipoB == 'Horizontal') return 1;
      return 0;
    });
  }

  void _inicializarDistribuicao() {
    _distribuicao = {};
    for (int i = 0; i < _freezersData.length; i++) {
      _distribuicao[i] = {};
    }
    _massasFaltantes = {};
    _faltaEspaco = false;
  }

  List<double> _calcularVolumesFreezers() {
    return _freezersData.map((freezer) {
      return double.tryParse(freezer['volume'].toString()) ?? 0.0;
    }).toList();
  }

  int _alocar(
    String massa,
    int quantidade,
    int index,
    double volumeFreezer,
    List<double> volumeOcupado,
  ) {
    final tipo = _freezersData[index]['tipo'] ?? 'Horizontal';
    final fator = _VOLUME_FATORES[massa] ?? _VOLUME_PADRAO[tipo]!;
    final volumePorPacote = 1 / fator;

    final disponivel = volumeFreezer - volumeOcupado[index];
    final max = (disponivel * fator).floor();

    if (max <= 0) return quantidade;

    final alocar = quantidade <= max ? quantidade : max;

    _distribuicao[index]![massa] = (_distribuicao[index]![massa] ?? 0) + alocar;
    volumeOcupado[index] += alocar * volumePorPacote;

    return quantidade - alocar;
  }

  // =====================================
  // UI
  // =====================================

  void _mostrarDialogoAtencao() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Atenção'),
        content: const Text(
            'Por favor cadastrar conservadores na tela de equipamentos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Distribuição Pacotes')),
      body: _freezersData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Freezer(storeName: widget.storeName),
                ),
              );
              _carregarDadosFreezers();
            },
            child: const Text('Conservadores',
                style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 16),
          ..._buildCardsFreezers(),
          if (_faltaEspaco) _buildAlertaMassas(),
        ],
      ),
    );
  }

  List<Widget> _buildCardsFreezers() {
    return List.generate(_freezersData.length, (index) {
      final freezer = _freezersData[index];
      final massas = _distribuicao[index]!;

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${freezer['modelo']} (${freezer['tipo']}) - ${freezer['volume']} litros",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...massas.entries.map(
                  (e) => Text("${_limparNome(e.key)}: ${e.value} pacotes")),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAlertaMassas() {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      color: Colors.red[300],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ATENÇÃO: Freezers insuficientes!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._massasFaltantes.entries.map((e) {
              return Text("• ${_limparNome(e.key)}: ${e.value} pacotes");
            })
          ],
        ),
      ),
    );
  }

  String _limparNome(String nome) => nome.replaceFirst("Massa ", "");
}

class StockAdjustmentScreen extends StatefulWidget {
  final String storeName;
  const StockAdjustmentScreen({
    Key? key,
    required this.storeName,
  }) : super(key: key);

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  final Map<String, TextEditingController> controllers = {};
  String storeName = '';
  String userName = '';
  DateTime selectedDate = DateTime.now();
  TextEditingController dateController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Produtos por kg com pesos padrão
  final Map<String, double> produtosKg = {
    'Massa Pão Francês': 10.5,
    'Massa Pão Francês Fibras': 3.3,
    'Massa Pão Cervejinha': 3.3,
    'Massa Mini Baguete 40g': 3.3,
    'Massa Mini Baguete 90g': 3.3,
    'Massa Pão De Queijo Coq': 3.3,
    'Massa Pão Biscoito Queijo': 3.3,
    'Massa Pão De Queijo Trad.': 3.3,
    'Massa Pão Tatu': 3.3,
    'Massa Pão Fofinho': 3.3,
    'Massa Pão Doce Comprido': 3.3,
    'Massa Rosca Doce': 3.3,
    'Massa Pão Doce Caracol': 3.3,
    'Massa Pão Doce Ferradura': 3.3,
    'Massa Bambino': 3.3,
    'Massa Mini Pão Marta Rocha': 3.3,
    'Massa Biscoito Polvilho': 1.35,
  };

  // Produtos em unidades com quantidade por pacote
  final Map<String, int> produtosUnidade = {
    'Massa Pão Para Rabanada': 30,
    'Massa Baguete 330g': 10,
    'Torta Chocomousse': 1,
    'Torta Chocolate/Coco': 1,
    'Torta Doce De Leite Amendoim': 1,
    'Torta Dois Amores': 1,
  };

  @override
  void initState() {
    super.initState();
    _inicializarControllers();
    _loadData();
    _loadUserData();
    dateController.text = DateFormat('dd/MM/yy').format(selectedDate);
    WakelockPlus.enable();
  }

  void _inicializarControllers() {
    for (var produto in [...produtosKg.keys, ...produtosUnidade.keys]) {
      controllers[produto] = TextEditingController();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        setState(() {
          storeName = widget.storeName;
          userName = data['userName'] ?? 'Usuário não definido';
        });
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        final acertoData = data['acerto'] ?? {};

        for (var produto in controllers.keys) {
          final value = acertoData[produto];
          if (value != null) {
            if (value is int) {
              controllers[produto]!.text = value.toString();
            } else if (value is double) {
              controllers[produto]!.text =
                  value % 1 == 0 ? value.toInt().toString() : value.toString();
            } else if (value is String) {
              controllers[produto]!.text = value;
            }
          }
        }
        setState(() {});
      }
    } catch (e) {
      print('Erro ao carregar dados de acerto: $e');
    }
  }

  Future<void> _saveData(String produto) async {
    try {
      final acertoData = {};
      for (var prod in controllers.keys) {
        if (controllers[prod]!.text.isNotEmpty) {
          acertoData[prod] = double.tryParse(controllers[prod]!.text) ?? 0;
        }
      }

      await _firestore.collection('stores').doc(widget.storeName).set({
        'acerto': acertoData,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Erro ao salvar dados do produto $produto: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('dd/MM/yy').format(picked);
      });
    }
  }

  void _showAddKgOuUnidDialog(String produto, bool isKg) {
    TextEditingController addController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isKg ? 'Adicionar Kg' : 'Adicionar Unidade(s)'),
          content: TextField(
            controller: addController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: isKg ? 'Valor em Kg' : 'Valor em unidades',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                double atual = double.tryParse(controllers[produto]!.text) ?? 0;
                double adicionar = double.tryParse(addController.text) ?? 0;

                double novoValor;

                if (isKg) {
                  double peso = produtosKg[produto] ?? 3.3;
                  double pacoteAdicional = adicionar / peso;
                  novoValor = atual + pacoteAdicional;
                } else {
                  int unidPorPacote = produtosUnidade[produto] ?? 10;
                  double pacoteAdicional = adicionar / unidPorPacote;
                  novoValor = atual + pacoteAdicional;
                }

                setState(() {
                  controllers[produto]!.text = (novoValor % 1 == 0)
                      ? novoValor.toInt().toString()
                      : novoValor.toStringAsFixed(1);
                });

                _saveData(produto);
                Navigator.pop(context);
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  bool _isAddEnabled(String produto) {
    String value = controllers[produto]!.text;
    return value.isNotEmpty && double.tryParse(value) != null;
  }

  String _calcularConversao(String produto) {
    double quantidade = double.tryParse(controllers[produto]!.text) ?? 0;

    if (produtosUnidade.containsKey(produto)) {
      double unidades = quantidade * produtosUnidade[produto]!;
      return unidades % 1 == 0
          ? "${unidades.toInt()} unid"
          : "${unidades.toStringAsFixed(1)} unid";
    } else {
      double multiplicador = produtosKg[produto] ?? 3.3;
      double resultado = quantidade * multiplicador;
      return resultado % 1 == 0
          ? "${resultado.toInt()} kg"
          : "${resultado.toStringAsFixed(1)} kg";
    }
  }

  Future<void> _sharePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Acerto Estoque')),
          pw.Paragraph(text: "${widget.storeName}"),
          pw.Paragraph(text: 'Responsável: $userName'),
          pw.Paragraph(
              text: 'Data: ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Produto', 'Pacotes', 'Valor Kg/Unid'],
            data: controllers.entries.map((entry) {
              final produto = entry.key;
              final pacotes = entry.value.text.isEmpty ? '0' : entry.value.text;
              final convertido = _calcularConversao(produto);
              return [produto, pacotes, convertido];
            }).toList(),
          ),
        ],
      ),
    );

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final bytes = await pdf.save();

      // Verifica se é Web
      if (kIsWeb) {
        // WEB: Faz download
        final base64 = base64Encode(bytes);
        final anchor = html.AnchorElement(
            href:
                'data:application/octet-stream;charset=utf-16le;base64,$base64')
          ..setAttribute('download',
              'acerto_estoque_${widget.storeName}_${DateFormat('ddMMyyyy').format(selectedDate)}.pdf')
          ..click();

        if (context.mounted) Navigator.of(context).pop();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF baixado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // MOBILE: Compartilha
        final dir = await getTemporaryDirectory();
        final file = File(
            '${dir.path}/acerto_estoque_${widget.storeName}_${DateFormat('ddMMyyyy').format(selectedDate)}.pdf');
        await file.writeAsBytes(bytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text:
              'Acerto Estoque - ${widget.storeName} - ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
        );

        if (context.mounted) Navigator.of(context).pop();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF gerado e compartilhado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _incrementValue(String produto) {
    double atual = double.tryParse(controllers[produto]!.text) ?? 0;
    double novoValor = atual + 1;

    setState(() {
      controllers[produto]!.text = (novoValor % 1 == 0)
          ? novoValor.toInt().toString()
          : novoValor.toStringAsFixed(1);
    });
    _saveData(produto);
  }

  void _decrementValue(String produto) {
    double atual = double.tryParse(controllers[produto]!.text) ?? 0;
    if (atual > 0) {
      double novoValor = atual - 1;
      setState(() {
        controllers[produto]!.text = (novoValor % 1 == 0)
            ? novoValor.toInt().toString()
            : novoValor.toStringAsFixed(1);
      });
      _saveData(produto);
    }
  }

  void _showRemoveKgOuUnidDialog(String produto, bool isKg) {
    TextEditingController removeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isKg ? 'Remover Kg' : 'Remover Unidade(s)'),
          content: TextField(
            controller: removeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: isKg ? 'Valor em Kg' : 'Valor em unidades',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                double atual = double.tryParse(controllers[produto]!.text) ?? 0;
                double remover = double.tryParse(removeController.text) ?? 0;

                double novoValor;

                if (isKg) {
                  double peso = produtosKg[produto] ?? 3.3;
                  double pacoteRemovido = remover / peso;
                  novoValor = atual - pacoteRemovido;
                } else {
                  int unidPorPacote = produtosUnidade[produto] ?? 10;
                  double pacoteRemovido = remover / unidPorPacote;
                  novoValor = atual - pacoteRemovido;
                }

                novoValor = novoValor < 0 ? 0 : novoValor;

                setState(() {
                  controllers[produto]!.text = (novoValor % 1 == 0)
                      ? novoValor.toInt().toString()
                      : novoValor.toStringAsFixed(1);
                });

                _saveData(produto);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[800],
              ),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetAllData() async {
    try {
      await _firestore.collection('stores').doc(widget.storeName).set({
        'acerto': {},
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      for (var controller in controllers.values) {
        controller.clear();
      }
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados apagados com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao apagar dados: $e')),
      );
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    controllers.forEach((_, controller) => controller.dispose());
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/Logo StockOne.png',
              height: 30,
            ),
            const SizedBox(width: 10),
            const Text(
              "ACERTO",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                fontFamily: 'Lora',
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartilhar PDF',
            onPressed: _sharePdf,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Apagar dados',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmação'),
                  content: const Text('Deseja apagar todos os dados?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Apagar'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await _resetAllData();
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFEFEF), Color(0xFFFDFDFD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 4),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      child: TextFormField(
                        controller: dateController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                        ),
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: controllers.entries.map((entry) {
                  String produto = entry.key;
                  TextEditingController controller = entry.value;
                  bool isKg = produtosKg.containsKey(produto);

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            produto,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              SizedBox(
                                width: 70,
                                child: TextField(
                                  controller: controller,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Pct(s).',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    final sanitized = value.replaceAll(
                                        RegExp(r'[^0-9.]'), '');
                                    if (sanitized != value) {
                                      controller.text = sanitized;
                                      controller.selection =
                                          TextSelection.fromPosition(
                                        TextPosition(offset: sanitized.length),
                                      );
                                    }
                                    setState(() {});
                                    _saveData(produto);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _incrementValue(produto),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      minimumSize: const Size(36, 36),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: const Text('+',
                                        style: TextStyle(fontSize: 18)),
                                  ),
                                  const SizedBox(height: 4),
                                  ElevatedButton(
                                    onPressed: () => _decrementValue(produto),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      minimumSize: const Size(36, 36),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: const Text('-',
                                        style: TextStyle(fontSize: 18)),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 80,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _calcularConversao(produto),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: _isAddEnabled(produto)
                                        ? () => _showAddKgOuUnidDialog(
                                            produto, isKg)
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      minimumSize: const Size(36, 36),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: const Text('++',
                                        style: TextStyle(fontSize: 18)),
                                  ),
                                  const SizedBox(height: 4),
                                  ElevatedButton(
                                    onPressed: _isAddEnabled(produto)
                                        ? () => _showRemoveKgOuUnidDialog(
                                            produto, isKg)
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[800],
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      minimumSize: const Size(36, 36),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: const Text('--',
                                        style: TextStyle(fontSize: 18)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FourthScreen extends StatefulWidget {
  final String storeName;
  const FourthScreen({required this.storeName});

  @override
  _FourthScreenState createState() => _FourthScreenState();
}

class _FourthScreenState extends State<FourthScreen> {
  TextEditingController dateController = TextEditingController();

  final Map<String, TextEditingController> controllers = {
    'Massa Pão Francês': TextEditingController(),
    'Massa Pão Fofinho': TextEditingController(),
    'Massa Pão Francês Fibras': TextEditingController(),
    'Massa Pão Cervejinha': TextEditingController(),
    'Massa Mini Baguete 40g': TextEditingController(),
    'Massa Mini Baguete 90g': TextEditingController(),
    'Massa Baguete 330g': TextEditingController(),
    'Massa Pão De Queijo Coq': TextEditingController(),
    'Massa Pão Biscoito Queijo': TextEditingController(),
    'Massa Pão De Queijo Trad.': TextEditingController(),
    'Massa Biscoito Polvilho': TextEditingController(),
    'Massa Pão Doce Comprido': TextEditingController(),
    'Massa Rosca Doce': TextEditingController(),
    'Massa Pão Doce Caracol': TextEditingController(),
    'Massa Pão Doce Ferradura': TextEditingController(),
    'Massa Bambino': TextEditingController(),
    'Massa Mini Pão Marta Rocha': TextEditingController(),
    'Massa Pão Tatu': TextEditingController(),
    'Torta Chocomousse': TextEditingController(),
    'Torta Chocolate/Coco': TextEditingController(),
    'Torta Doce De Leite Amendoim': TextEditingController(),
    'Torta Dois Amores': TextEditingController(),
  };

  final Map<String, TextEditingController> resultadoControllers = {
    'Massa Pão Francês': TextEditingController(),
    'Massa Pão Fofinho': TextEditingController(),
    'Massa Pão Francês Fibras': TextEditingController(),
    'Massa Pão Cervejinha': TextEditingController(),
    'Massa Mini Baguete 40g': TextEditingController(),
    'Massa Mini Baguete 90g': TextEditingController(),
    'Massa Baguete 330g': TextEditingController(),
    'Massa Pão De Queijo Coq': TextEditingController(),
    'Massa Pão Biscoito Queijo': TextEditingController(),
    'Massa Pão De Queijo Trad.': TextEditingController(),
    'Massa Biscoito Polvilho': TextEditingController(),
    'Massa Pão Doce Comprido': TextEditingController(),
    'Massa Rosca Doce': TextEditingController(),
    'Massa Pão Doce Caracol': TextEditingController(),
    'Massa Pão Doce Ferradura': TextEditingController(),
    'Massa Bambino': TextEditingController(),
    'Massa Mini Pão Marta Rocha': TextEditingController(),
    'Massa Pão Tatu': TextEditingController(),
    'Torta Chocomousse': TextEditingController(),
    'Torta Chocolate/Coco': TextEditingController(),
    'Torta Doce De Leite Amendoim': TextEditingController(),
    'Torta Dois Amores': TextEditingController(),
  };

  final Map<String, bool> estoqueInsuficiente = {
    'Massa Pão Francês': false,
    'Massa Pão Fofinho': false,
    'Massa Pão Francês Fibras': false,
    'Massa Pão Cervejinha': false,
    'Massa Mini Baguete 40g': false,
    'Massa Mini Baguete 90g': false,
    'Massa Baguete 330g': false,
    'Massa Pão De Queijo Coq': false,
    'Massa Pão Biscoito Queijo': false,
    'Massa Pão De Queijo Trad.': false,
    'Massa Biscoito Polvilho': false,
    'Massa Pão Doce Comprido': false,
    'Massa Rosca Doce': false,
    'Massa Pão Doce Caracol': false,
    'Massa Pão Doce Ferradura': false,
    'Massa Bambino': false,
    'Massa Mini Pão Marta Rocha': false,
    'Massa Pão Tatu': false,
    'Torta Chocomousse': false,
    'Torta Chocolate/Coco': false,
    'Torta Doce De Leite Amendoim': false,
    'Torta Dois Amores': false,
  };

  // Agora armazenamos o estado completo: valor + se foi editado
  final Map<String, Map<String, dynamic>> _produtoState = {
    'Massa Pão Francês': {'valor': 0.0, 'editado': false, 'carregado': false},
    'Massa Pão Fofinho': {'valor': 0.0, 'editado': false, 'carregado': false},
    'Massa Pão Francês Fibras': {
      'valor': 0.0,
      'editado': false,
      'carregado': false
    },
    'Massa Pão Cervejinha': {
      'valor': 0.0,
      'editado': false,
      'carregado': false
    },
    'Massa Mini Baguete 40g': {
      'valor': 0.0,
      'editado': false,
      'carregado': false
    },
    'Massa Mini Pão Francês': {
      'valor': 0.0,
      'editado': false,
      'carregado': false
    },
    'Massa Mini Baguete 90g': {
      'valor': 0.0,
      'editado': false,
      'carregado': false
    },
    'Massa Baguete 330g': {'valor': 0.0, 'editado': false, 'carregado': false},
    'Massa Pão De Queijo Coq': {
      'valor': 0.0,
      'editado': false,
      'carregado': false
    },
    'Massa Pão Biscoito Queijo': {
      'valor': 0.0,
      'editado': false,
      'carregado': false
    },
    'Massa Pão De Queijo Trad.': {
      'valor': 0.0,
      'editado': false,
      'carregado': false
    },
    'Massa Biscoito Polvilho': {
      'valor': 0.0,
      'editado': false,
      'carregado': false
    },
    'Massa Pão Para Rabanada': {
      'valor': 0.0,
      'editado': false,
      'carregado': false
    },
    'Massa Pão Doce Comprido': {
      'valor': 0.0,
      'editado': false,
      'carregado': false
    },
    'Massa Rosca Doce': {'valor': 0.0, 'editado': false, 'carregado': false},
    'Massa Pão Doce Caracol': {
      'valor': 0.0,
      'editado': false,
      'carregado': false
    },
    'Massa Pão Doce Ferradura': {
      'valor': 0.0,
      'editado': false,
      'carregado': false
    },
    'Massa Bambino': {'valor': 0.0, 'editado': false, 'carregado': false},
    'Massa Mini Pão Marta Rocha': {
      'valor': 0.0,
      'editado': false,
      'carregado': false
    },
    'Massa Pão Tatu': {'valor': 0.0, 'editado': false, 'carregado': false},
    'Torta Chocomousse': {'valor': 0.0, 'editado': false, 'carregado': false},
    'Torta Chocolate/Coco': {
      'valor': 0.0,
      'editado': false,
      'carregado': false
    },
    'Torta Doce De Leite Amendoim': {
      'valor': 0.0,
      'editado': false,
      'carregado': false
    },
    'Torta Dois Amores': {'valor': 0.0, 'editado': false, 'carregado': false},
  };

  double estoqueMaxPaoFrances = 0.0;
  double estoqueMaxPaoFofinho = 0.0;
  double estoqueMaxPaoFrancesFibras = 0.0;
  double estoqueMaxPaoFrancesPanhoca = 0.0;
  double estoqueMaxPaoFrancesComQueijo = 0.0;
  double estoqueMaxBagueteFrancesaQueijo = 0.0;
  double estoqueMaxFrancesa = 0.0;
  double estoqueMaxPaoQueijoTradicional = 0.0;
  double estoqueMaxPaoQueijoCoquetel = 0.0;
  double estoqueMaxBiscoitoQueijo = 0.0;
  double estoqueMaxBiscoitoPolvilho = 0.0;
  double estoqueMaxPaoSamaritano = 0.0;
  double estoqueMaxPaoPizza = 0.0;
  double estoqueMaxPaoTatu = 0.0;
  double estoqueMaxMiniPaoSonho = 0.0;
  double estoqueMaxMiniPaoSonhoChocolate = 0.0;
  double estoqueMaxPaoBambino = 0.0;
  double estoqueMaxMiniMartaRocha = 0.0;
  double estoqueMaxPaoDoceFerradura = 0.0;
  double estoqueMaxPaoDoceCaracol = 0.0;
  double estoqueMaxRoscaCaseira = 0.0;
  double estoqueMaxRoscaCaseiraCoco = 0.0;
  double estoqueMaxRoscaCaseiraPo = 0.0;
  double estoqueMaxRoscaCocoQueijo = 0.0;
  double estoqueMaxSanduicheBahamas = 0.0;
  double estoqueMaxSanduicheFofinho = 0.0;
  double estoqueMaxRabanadaAssada = 0.0;
  double estoqueMaxRoscaFofinhaTemperada = 0.0;
  double estoqueMaxCaseirinho = 0.0;
  double estoqueMaxPaoParaRabanada = 0.0;
  double estoqueMaxPaoDoceComprido = 0.0;
  double estoqueMaxPaoMilho = 0.0;
  double estoqueMaxPaodeAlhodaCasa = 0.0;
  double estoqueMaxPaodeAlhodaCasaPicante = 0.0;
  double estoqueMaxPaodeAlhodaCasaRefri = 0.0;
  double estoqueMaxPaoBagueteFrancesaQueijo = 0.0;
  double estoqueMaxPaoBagueteFrancesa = 0.0;
  double estoqueMaxPaoBagueteFrancesaGergelim = 0.0;
  double estoqueMaxMiniPaoFrancesGergelim = 0.0;
  double estoqueMaxTortaChocomousse = 0.0;
  double estoqueMaxTortaChocolateCoco = 0.0;
  double estoqueMaxTortaDoceDeLeiteAmendoim = 0.0;
  double estoqueMaxTortaDoisAmores = 0.0;
  double vendaMensalPaoFrances = 0.0;
  double vendaMensalPaoFofinho = 0.0;
  double vendaMensalPaoFrancesFibras = 0.0;
  double vendaMensalPaoFrancesPanhoca = 0.0;
  double vendaMensalPaoFrancesComQueijo = 0.0;
  double vendaMensalBagueteFrancesaQueijo = 0.0;
  double vendaMensalFrancesa = 0.0;
  double vendaMensalPaoQueijoTradicional = 0.0;
  double vendaMensalPaoQueijoCoquetel = 0.0;
  double vendaMensalBiscoitoQueijo = 0.0;
  double vendaMensalBiscoitoPolvilho = 0.0;
  double vendaMensalPaoSamaritano = 0.0;
  double vendaMensalPaoPizza = 0.0;
  double vendaMensalPaoTatu = 0.0;
  double vendaMensalMiniPaoSonho = 0.0;
  double vendaMensalMiniPaoSonhoChocolate = 0.0;
  double vendaMensalPaoBambino = 0.0;
  double vendaMensalMiniMartaRocha = 0.0;
  double vendaMensalPaoDoceFerradura = 0.0;
  double vendaMensalPaoDoceCaracol = 0.0;
  double vendaMensalRoscaCaseira = 0.0;
  double vendaMensalRoscaCaseiraCoco = 0.0;
  double vendaMensalRoscaCaseiraPo = 0.0;
  double vendaMensalRoscaCocoQueijo = 0.0;
  double vendaMensalSanduicheBahamas = 0.0;
  double vendaMensalSanduicheFofinho = 0.0;
  double vendaMensalRabanadaAssada = 0.0;
  double vendaMensalRoscaFofinhaTemperada = 0.0;
  double vendaMensalCaseirinho = 0.0;
  double vendaMensalPaoParaRabanada = 0.0;
  double vendaMensalPaoDoceComprido = 0.0;
  double vendaMensalPaoMilho = 0.0;
  double vendaMensalPaodeAlhodaCasa = 0.0;
  double vendaMensalPaodeAlhodaCasaPicante = 0.0;
  double vendaMensalPaodeAlhodaCasaRefri = 0.0;
  double vendaMensalPaoBagueteFrancesaQueijo = 0.0;
  double vendaMensalPaoBagueteFrancesa = 0.0;
  double vendaMensalPaoBagueteFrancesaGergelim = 0.0;
  double vendaMensalMiniPaoFrancesGergelim = 0.0;
  double vendaMensalTortaDoisAmores = 0.0;
  double vendaMensalTortaDoceDeLeiteAmendoim = 0.0;
  double vendaMensalTortaChocolateCoco = 0.0;
  double vendaMensalTortaChocomousse = 0.0;

  String? storeName = '';
  String? userName = '';
  DateTime selectedDate = DateTime.now();
  int intervaloEntrega = 1;
  int? diasDeGiro;

  final List<String> massas = [
    'Massa Pão Francês',
    'Massa Pão Francês Fibras',
    'Massa Pão Cervejinha',
    'Massa Mini Baguete 40g',
    'Massa Mini Baguete 90g',
    'Massa Baguete 330g',
    'Massa Pão De Queijo Coq',
    'Massa Pão Biscoito Queijo',
    'Massa Pão De Queijo Trad.',
    'Massa Biscoito Polvilho',
    'Massa Pão Fofinho',
    'Massa Pão Doce Comprido',
    'Massa Rosca Doce',
    'Massa Pão Doce Caracol',
    'Massa Pão Doce Ferradura',
    'Massa Bambino',
    'Massa Mini Pão Marta Rocha',
    'Massa Pão Tatu',
    'Torta Chocomousse',
    'Torta Chocolate/Coco',
    'Torta Doce De Leite Amendoim',
    'Torta Dois Amores',
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Flag para controlar se estamos atualizando programaticamente
  bool _atualizandoProgramaticamente = false;

  // Flag para controlar se já carregou os dados iniciais
  bool _dadosCarregados = false;

  @override
  void initState() {
    super.initState();
    _inicializarControllers();
    dateController.text = DateFormat('dd/MM/yy').format(selectedDate);
    _loadAllData(); // Carrega dados do Firebase ao iniciar
  }

  void _inicializarControllers() {
    for (String produto in massas) {
      controllers[produto] = TextEditingController();
      resultadoControllers[produto] = TextEditingController();
    }
  }

  // ✅ Carregar tudo de uma vez do Firebase e atualizar automaticamente
  Future<void> _loadAllData() async {
    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();
      if (doc.exists) {
        final data = doc.data() ?? {};

        setState(() {
          // ✅ Carregar dados do usuário
          storeName = data['storeName'] ?? 'Loja não definida';
          userName = data['userName'] ?? 'Usuário não definido';

          // ✅ Carregar dias de giro
          diasDeGiro = data['diasGiro'];

          // ✅ Carregar intervalo de entrega
          final pedidoData = data['pedidoConfig'] ?? {};
          intervaloEntrega = pedidoData['intervaloEntrega'] ?? 1;

          // ✅ Carregar dados de estoque máximo
          final estoqueMaxData = data['estoque'] ?? {};
          estoqueMaxPaoFrances =
              (estoqueMaxData['Pão Francês'] ?? 0).toDouble();
          estoqueMaxPaoFrancesFibras =
              (estoqueMaxData['Pão Francês Fibras'] ?? 0).toDouble();
          estoqueMaxPaoFrancesPanhoca =
              (estoqueMaxData['Pão Francês Panhoca'] ?? 0).toDouble();
          estoqueMaxPaoFrancesComQueijo =
              (estoqueMaxData['Pão Francês com Queijo'] ?? 0).toDouble();
          estoqueMaxPaoBagueteFrancesaQueijo =
              (estoqueMaxData['Pão Baguete Francesa Queijo'] ?? 0).toDouble();
          estoqueMaxPaoBagueteFrancesa =
              (estoqueMaxData['Pão Baguete Francesa'] ?? 0).toDouble();
          estoqueMaxPaoBagueteFrancesaGergelim =
              (estoqueMaxData['Pão Baguete Francesa Gergelim'] ?? 0).toDouble();
          estoqueMaxMiniPaoFrancesGergelim =
              (estoqueMaxData['Mini Pão Francês Gergelim'] ?? 0).toDouble();
          estoqueMaxBagueteFrancesaQueijo =
              (estoqueMaxData['Baguete Francesa Queijo'] ?? 0).toDouble();
          estoqueMaxFrancesa =
              (estoqueMaxData['Baguete Francesa'] ?? 0).toDouble();
          estoqueMaxPaoQueijoTradicional =
              (estoqueMaxData['Pão Queijo Tradicional'] ?? 0).toDouble();
          estoqueMaxPaoQueijoCoquetel =
              (estoqueMaxData['Pão Queijo Coquetel'] ?? 0).toDouble();
          estoqueMaxBiscoitoQueijo =
              (estoqueMaxData['Biscoito Queijo'] ?? 0).toDouble();
          estoqueMaxBiscoitoPolvilho =
              (estoqueMaxData['Biscoito Polvilho'] ?? 0).toDouble();
          estoqueMaxPaoSamaritano =
              (estoqueMaxData['Pão Samaritano'] ?? 0).toDouble();
          estoqueMaxPaoPizza = (estoqueMaxData['Pão Pizza'] ?? 0).toDouble();
          estoqueMaxPaoTatu = (estoqueMaxData['Pão Tatu'] ?? 0).toDouble();
          estoqueMaxMiniPaoSonho =
              (estoqueMaxData['Mini Pão Sonho'] ?? 0).toDouble();
          estoqueMaxMiniPaoSonhoChocolate =
              (estoqueMaxData['Mini Pão Sonho Chocolate'] ?? 0).toDouble();
          estoqueMaxPaoBambino =
              (estoqueMaxData['Pão Bambino'] ?? 0).toDouble();
          estoqueMaxMiniMartaRocha =
              (estoqueMaxData['Mini Marta Rocha'] ?? 0).toDouble();
          estoqueMaxPaoDoceFerradura =
              (estoqueMaxData['Pão Doce Ferradura'] ?? 0).toDouble();
          estoqueMaxPaoDoceCaracol =
              (estoqueMaxData['Pão Doce Caracol'] ?? 0).toDouble();
          estoqueMaxRoscaCaseira =
              (estoqueMaxData['Rosca Caseira'] ?? 0).toDouble();
          estoqueMaxRoscaCaseiraCoco =
              (estoqueMaxData['Rosca Caseira Côco'] ?? 0).toDouble();
          estoqueMaxRoscaCaseiraPo =
              (estoqueMaxData['Rosca Caseira Leite em Pó'] ?? 0).toDouble();
          estoqueMaxRoscaCocoQueijo =
              (estoqueMaxData['Rosca Côco/Queijo'] ?? 0).toDouble();
          estoqueMaxSanduicheBahamas =
              (estoqueMaxData['Sanduíche Bahamas'] ?? 0).toDouble();
          estoqueMaxRabanadaAssada =
              (estoqueMaxData['Rabanada Assada'] ?? 0).toDouble();
          estoqueMaxPaoFofinho =
              (estoqueMaxData['Pão Fofinho'] ?? 0).toDouble();
          estoqueMaxSanduicheFofinho =
              (estoqueMaxData['Sanduíche Fofinho'] ?? 0).toDouble();
          estoqueMaxRoscaFofinhaTemperada =
              (estoqueMaxData['Rosca Fofinha Temperada'] ?? 0).toDouble();
          estoqueMaxCaseirinho = (estoqueMaxData['Caseirinho'] ?? 0).toDouble();
          estoqueMaxPaoParaRabanada =
              (estoqueMaxData['Pão P/ Rabanada'] ?? 0).toDouble();
          estoqueMaxPaoDoceComprido =
              (estoqueMaxData['Pão Doce Comprido'] ?? 0).toDouble();
          estoqueMaxPaoMilho = (estoqueMaxData['Pão Milho'] ?? 0).toDouble();
          estoqueMaxPaodeAlhodaCasa =
              (estoqueMaxData['Pão de Alho da Casa'] ?? 0).toDouble();
          estoqueMaxPaodeAlhodaCasaPicante =
              (estoqueMaxData['Pão de Alho da Casa Picante'] ?? 0).toDouble();
          estoqueMaxPaodeAlhodaCasaRefri =
              (estoqueMaxData['Pão de Alho da Casa Refri.'] ?? 0).toDouble();
          estoqueMaxTortaChocomousse =
              (estoqueMaxData['Torta Chocomousse'] ?? 0).toDouble();
          estoqueMaxTortaChocolateCoco =
              (estoqueMaxData['Torta Chocolate/Coco'] ?? 0).toDouble();
          estoqueMaxTortaDoceDeLeiteAmendoim =
              (estoqueMaxData['Torta Doce De Leite Amendoim'] ?? 0).toDouble();
          estoqueMaxTortaDoisAmores =
              (estoqueMaxData['Torta Dois Amores'] ?? 0).toDouble();

          // ✅ Carregar dados de vendas
          final vendasData = data['vendas'] ?? {};
          vendaMensalPaoFrances = (vendasData['Pão Francês'] ?? 0).toDouble();
          vendaMensalPaoFrancesFibras =
              (vendasData['Pão Francês Fibras'] ?? 0).toDouble();
          vendaMensalPaoFrancesPanhoca =
              (vendasData['Pão Francês Panhoca'] ?? 0).toDouble();
          vendaMensalPaoFrancesComQueijo =
              (vendasData['Pão Francês com Queijo'] ?? 0).toDouble();
          vendaMensalPaoBagueteFrancesaQueijo =
              (vendasData['Pão Baguete Francesa Queijo'] ?? 0).toDouble();
          vendaMensalPaoBagueteFrancesa =
              (vendasData['Pão Baguete Francesa'] ?? 0).toDouble();
          vendaMensalPaoBagueteFrancesaGergelim =
              (vendasData['Pão Baguete Francesa Gergelim'] ?? 0).toDouble();
          vendaMensalMiniPaoFrancesGergelim =
              (vendasData['Mini Pão Francês Gergelim'] ?? 0).toDouble();
          vendaMensalBagueteFrancesaQueijo =
              (vendasData['Baguete Francesa Queijo'] ?? 0).toDouble();
          vendaMensalFrancesa =
              (vendasData['Baguete Francesa'] ?? 0).toDouble();
          vendaMensalPaoQueijoTradicional =
              (vendasData['Pão Queijo Tradicional'] ?? 0).toDouble();
          vendaMensalPaoQueijoCoquetel =
              (vendasData['Pão Queijo Coquetel'] ?? 0).toDouble();
          vendaMensalBiscoitoQueijo =
              (vendasData['Biscoito Queijo'] ?? 0).toDouble();
          vendaMensalBiscoitoPolvilho =
              (vendasData['Biscoito Polvilho'] ?? 0).toDouble();
          vendaMensalPaoSamaritano =
              (vendasData['Pão Samaritano'] ?? 0).toDouble();
          vendaMensalPaoPizza = (vendasData['Pão Pizza'] ?? 0).toDouble();
          vendaMensalPaoTatu = (vendasData['Pão Tatu'] ?? 0).toDouble();
          vendaMensalMiniPaoSonho =
              (vendasData['Mini Pão Sonho'] ?? 0).toDouble();
          vendaMensalMiniPaoSonhoChocolate =
              (vendasData['Mini Pão Sonho Chocolate'] ?? 0).toDouble();
          vendaMensalPaoBambino = (vendasData['Pão Bambino'] ?? 0).toDouble();
          vendaMensalMiniMartaRocha =
              (vendasData['Mini Marta Rocha'] ?? 0).toDouble();
          vendaMensalPaoDoceFerradura =
              (vendasData['Pão Doce Ferradura'] ?? 0).toDouble();
          vendaMensalPaoDoceCaracol =
              (vendasData['Pão Doce Caracol'] ?? 0).toDouble();
          vendaMensalRoscaCaseira =
              (vendasData['Rosca Caseira'] ?? 0).toDouble();
          vendaMensalRoscaCaseiraCoco =
              (vendasData['Rosca Caseira Côco'] ?? 0).toDouble();
          vendaMensalRoscaCaseiraPo =
              (vendasData['Rosca Caseira Leite em Pó'] ?? 0).toDouble();
          vendaMensalRoscaCocoQueijo =
              (vendasData['Rosca Côco/Queijo'] ?? 0).toDouble();
          vendaMensalSanduicheBahamas =
              (vendasData['Sanduíche Bahamas'] ?? 0).toDouble();
          vendaMensalRabanadaAssada =
              (vendasData['Rabanada Assada'] ?? 0).toDouble();
          vendaMensalPaoFofinho = (vendasData['Pão Fofinho'] ?? 0).toDouble();
          vendaMensalSanduicheFofinho =
              (vendasData['Sanduíche Fofinho'] ?? 0).toDouble();
          vendaMensalRoscaFofinhaTemperada =
              (vendasData['Rosca Fofinha Temperada'] ?? 0).toDouble();
          vendaMensalCaseirinho = (vendasData['Caseirinho'] ?? 0).toDouble();
          vendaMensalPaoParaRabanada =
              (vendasData['Pão P/ Rabanada'] ?? 0).toDouble();
          vendaMensalPaoDoceComprido =
              (vendasData['Pão Doce Comprido'] ?? 0).toDouble();
          vendaMensalPaoMilho = (vendasData['Pão Milho'] ?? 0).toDouble();
          vendaMensalPaodeAlhodaCasa =
              (vendasData['Pão de Alho da Casa'] ?? 0).toDouble();
          vendaMensalPaodeAlhodaCasaPicante =
              (vendasData['Pão de Alho da Casa Picante'] ?? 0).toDouble();
          vendaMensalPaodeAlhodaCasaRefri =
              (vendasData['Pão de Alho da Casa Refri.'] ?? 0).toDouble();
          vendaMensalTortaChocomousse =
              (vendasData['Torta Chocomousse'] ?? 0).toDouble();
          vendaMensalTortaChocolateCoco =
              (vendasData['Torta Chocolate/Coco'] ?? 0).toDouble();
          vendaMensalTortaDoceDeLeiteAmendoim =
              (vendasData['Torta Doce De Leite Amendoim'] ?? 0).toDouble();
          vendaMensalTortaDoisAmores =
              (vendasData['Torta Dois Amores'] ?? 0).toDouble();

          // ✅ Carregar estoques atuais
          final estoqueAtualData = data['acerto'] ?? {};
          for (String produto in massas) {
            final estoque = estoqueAtualData[produto];
            if (estoque != null) {
              controllers[produto]!.text = estoque.toString();
            } else {
              controllers[produto]!.text = '0';
            }
          }

          // ✅ Carregar pedidos salvos e estado de edição
          final pedidosSalvosData = data['pedidosSalvos'] ?? {};
          final pedidosEditadosData = data['pedidosEditados'] ?? {};

          for (String produto in massas) {
            final pedido = pedidosSalvosData[produto];
            final editado = pedidosEditadosData[produto] ?? false;

            if (pedido != null) {
              resultadoControllers[produto]!.text = pedido.toString();
              _produtoState[produto]!['valor'] = pedido.toDouble();
              _produtoState[produto]!['editado'] = editado;
              _produtoState[produto]!['carregado'] = true;
            } else {
              resultadoControllers[produto]!.text = '0';
              _produtoState[produto]!['valor'] = 0.0;
              _produtoState[produto]!['editado'] = false;
              _produtoState[produto]!['carregado'] = false;
            }
          }
        });

        // ✅ ATUALIZAÇÃO AUTOMÁTICA: recalcula apenas produtos NÃO editados manualmente
        for (String produto in massas) {
          // Só recalcula se NÃO foi editado manualmente
          if (!_produtoState[produto]!['editado']) {
            _calcularPedidoIndividual(produto, false);
          }
        }

        _dadosCarregados = true;
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
    }
  }

  // ✅ Salvar valores editados pelo usuário no Firebase
  Future<void> _saveUserInputs() async {
    try {
      final pedidosSalvos = {};
      final pedidosEditados = {};
      final estoqueAtual = {};

      for (String produto in massas) {
        if (resultadoControllers[produto]!.text.isNotEmpty) {
          pedidosSalvos[produto] =
              double.tryParse(resultadoControllers[produto]!.text) ?? 0;
          pedidosEditados[produto] = _produtoState[produto]!['editado'];
        }

        if (controllers[produto]!.text.isNotEmpty) {
          estoqueAtual[produto] =
              double.tryParse(controllers[produto]!.text) ?? 0;
        }
      }

      await _firestore.collection('stores').doc(widget.storeName).set({
        'pedidosSalvos': pedidosSalvos,
        'pedidosEditados': pedidosEditados,
        'acerto': estoqueAtual,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('Valores salvos: $pedidosSalvos');
      print('Editados: $pedidosEditados');
    } catch (e) {
      print('Erro ao salvar inputs: $e');
    }
  }

  // ✅ Salvar configurações do pedido
  Future<void> _savePedidoConfig() async {
    try {
      final pedidoConfig = {
        'intervaloEntrega': intervaloEntrega,
      };

      await _firestore.collection('stores').doc(widget.storeName).set({
        'pedidoConfig': pedidoConfig,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Erro ao salvar configurações: $e');
    }
  }

  void _showInsufficientStockAlert(String produto) {
    setState(() {
      estoqueInsuficiente[produto] = true;
    });
  }

  void _calcularPedidoIndividual(String produto, bool isUserAction) {
    // Se foi editado manualmente E não é uma ação do usuário (botão Atualizar), não recalcula
    if (_produtoState[produto]!['editado'] && !isUserAction) {
      return;
    }

    double estoqueAtual =
        double.tryParse(controllers[produto]?.text ?? '0') ?? 0.0;
    double estoqueCalculado = 0.0;
    double resultadoPedido = 0.0;

    if (diasDeGiro == null || diasDeGiro! <= 0) return;

    if (produto == 'Massa Pão Francês') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              (vendaMensalPaoFrances * 1.40 / diasDeGiro! / 10.5));
      resultadoPedido = estoqueCalculado < 0
          ? estoqueMaxPaoFrances / 2
          : (estoqueMaxPaoFrances - estoqueCalculado) / 2;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Massa Pão Fofinho') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              (vendaMensalPaoFofinho +
                  vendaMensalSanduicheFofinho * 0.06 +
                  vendaMensalRoscaFofinhaTemperada * 0.3 +
                  vendaMensalCaseirinho) *
              1.30 /
              diasDeGiro! /
              3.3);
      resultadoPedido = estoqueCalculado < 0
          ? (estoqueMaxPaoFofinho +
                  estoqueMaxSanduicheFofinho +
                  estoqueMaxRoscaFofinhaTemperada +
                  estoqueMaxCaseirinho) /
              6
          : (estoqueMaxPaoFofinho +
                  estoqueMaxSanduicheFofinho +
                  estoqueMaxRoscaFofinhaTemperada +
                  estoqueMaxCaseirinho -
                  estoqueCalculado) /
              6;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Massa Mini Pão Francês') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              ((vendaMensalPaodeAlhodaCasaRefri * 0.24 +
                      vendaMensalMiniPaoFrancesGergelim) *
                  1.20 /
                  diasDeGiro! /
                  3.3));
      resultadoPedido = estoqueCalculado < 0
          ? (estoqueMaxPaodeAlhodaCasaRefri +
                  estoqueMaxMiniPaoFrancesGergelim) /
              6
          : (estoqueMaxPaodeAlhodaCasaRefri +
                  estoqueMaxMiniPaoFrancesGergelim -
                  estoqueCalculado) /
              6;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Massa Baguete 330g') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              ((vendaMensalFrancesa + vendaMensalBagueteFrancesaQueijo) *
                  0.33 *
                  1.20 /
                  diasDeGiro! /
                  3.3));
      resultadoPedido = estoqueCalculado < 0
          ? (estoqueMaxBagueteFrancesaQueijo + estoqueMaxFrancesa) / 6
          : (estoqueMaxBagueteFrancesaQueijo +
                  estoqueMaxFrancesa -
                  estoqueCalculado) /
              6;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Massa Pão Cervejinha') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              (vendaMensalPaoFrancesPanhoca * 1.40 / diasDeGiro! / 3.3));
      resultadoPedido = estoqueCalculado < 0
          ? estoqueMaxPaoFrancesPanhoca / 6
          : (estoqueMaxPaoFrancesPanhoca - estoqueCalculado) / 6;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Massa Pão Francês Fibras') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              (vendaMensalPaoFrancesFibras * 1.40 / diasDeGiro! / 3.3));
      resultadoPedido = estoqueCalculado < 0
          ? estoqueMaxPaoFrancesFibras / 6
          : (estoqueMaxPaoFrancesFibras - estoqueCalculado) / 6;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Massa Mini Baguete 40g') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              (vendaMensalPaoFrancesComQueijo * 1.15 / diasDeGiro! / 3.3));
      resultadoPedido = estoqueCalculado < 0
          ? estoqueMaxPaoFrancesComQueijo / 6
          : (estoqueMaxPaoFrancesComQueijo - estoqueCalculado) / 6;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Massa Mini Baguete 90g') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              ((vendaMensalPaodeAlhodaCasa * 0.27) +
                  (vendaMensalPaodeAlhodaCasaPicante * 0.27) +
                  (vendaMensalSanduicheBahamas * 0.090) +
                  vendaMensalPaoBagueteFrancesaQueijo +
                  vendaMensalPaoBagueteFrancesa +
                  vendaMensalPaoBagueteFrancesaGergelim) *
              1.20 /
              diasDeGiro! /
              3.3);
      resultadoPedido = estoqueCalculado < 0
          ? (estoqueMaxPaodeAlhodaCasa +
                  estoqueMaxSanduicheBahamas +
                  estoqueMaxPaodeAlhodaCasaPicante +
                  estoqueMaxPaoBagueteFrancesaQueijo +
                  estoqueMaxPaoBagueteFrancesa +
                  estoqueMaxPaoBagueteFrancesaGergelim) /
              6
          : ((estoqueMaxPaodeAlhodaCasa +
                      estoqueMaxSanduicheBahamas +
                      estoqueMaxPaodeAlhodaCasaPicante +
                      estoqueMaxPaoBagueteFrancesaQueijo +
                      estoqueMaxPaoBagueteFrancesa +
                      estoqueMaxPaoBagueteFrancesaGergelim) -
                  estoqueCalculado) /
              6;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Massa Pão Para Rabanada') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              ((vendaMensalPaoParaRabanada) +
                  (vendaMensalRabanadaAssada * 0.8) * 1.20 / diasDeGiro! / 30));
      resultadoPedido = estoqueCalculado < 0
          ? (estoqueMaxPaoParaRabanada + estoqueMaxRabanadaAssada) / 6
          : ((estoqueMaxPaoParaRabanada + estoqueMaxRabanadaAssada) -
                  estoqueCalculado) /
              6;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Massa Pão Doce Comprido') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              ((vendaMensalPaoDoceComprido + vendaMensalPaoMilho) *
                  1.15 /
                  diasDeGiro! /
                  3.3));
      resultadoPedido = estoqueCalculado < 0
          ? (estoqueMaxPaoDoceComprido + estoqueMaxPaoMilho) / 6
          : ((estoqueMaxPaoDoceComprido + estoqueMaxPaoMilho) -
                  estoqueCalculado) /
              6;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Massa Rosca Doce') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              ((vendaMensalRoscaCaseira +
                      vendaMensalRoscaCaseiraCoco +
                      vendaMensalRoscaCaseiraPo) *
                  1.20 /
                  diasDeGiro! /
                  3.3));
      resultadoPedido = estoqueCalculado < 0
          ? (estoqueMaxRoscaCaseira +
                  estoqueMaxRoscaCaseiraCoco +
                  estoqueMaxRoscaCaseiraPo) /
              6
          : ((estoqueMaxRoscaCaseira +
                      estoqueMaxRoscaCaseiraCoco +
                      estoqueMaxRoscaCaseiraPo) -
                  estoqueCalculado) /
              6;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Massa Pão Doce Caracol') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              (vendaMensalPaoDoceCaracol * 1.20 / diasDeGiro! / 3.3));
      resultadoPedido = estoqueCalculado < 0
          ? estoqueMaxPaoDoceCaracol / 6
          : (estoqueMaxPaoDoceCaracol - estoqueCalculado) / 6;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Massa Pão Doce Ferradura') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              (vendaMensalPaoDoceFerradura * 1.20 / diasDeGiro! / 3.3));
      resultadoPedido = estoqueCalculado < 0
          ? estoqueMaxPaoDoceFerradura / 6
          : (estoqueMaxPaoDoceFerradura - estoqueCalculado) / 6;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Massa Bambino') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              ((vendaMensalMiniPaoSonho +
                      vendaMensalMiniPaoSonhoChocolate +
                      vendaMensalPaoBambino) *
                  0.5 *
                  1.20 /
                  diasDeGiro! /
                  3.3));
      resultadoPedido = estoqueCalculado < 0
          ? (estoqueMaxMiniPaoSonho +
                  estoqueMaxMiniPaoSonhoChocolate +
                  estoqueMaxPaoBambino) /
              6
          : ((estoqueMaxMiniPaoSonho +
                      estoqueMaxMiniPaoSonhoChocolate +
                      estoqueMaxPaoBambino) -
                  estoqueCalculado) /
              6;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Massa Mini Pão Marta Rocha') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              (vendaMensalMiniMartaRocha * 0.5 + vendaMensalPaoPizza * 0.08) *
              1.20 /
              diasDeGiro! /
              3.3);
      resultadoPedido = estoqueCalculado < 0
          ? (estoqueMaxMiniMartaRocha + estoqueMaxPaoPizza) / 6
          : ((estoqueMaxMiniMartaRocha + estoqueMaxPaoPizza) -
                  estoqueCalculado) /
              6;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Massa Pão Tatu') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega * (vendaMensalPaoTatu * 1.20 / diasDeGiro! / 3.3));
      resultadoPedido = estoqueCalculado < 0
          ? estoqueMaxPaoTatu / 6
          : (estoqueMaxPaoTatu - estoqueCalculado) / 6;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Massa Biscoito Polvilho') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              (vendaMensalBiscoitoPolvilho * 2 / diasDeGiro! / 1.35));
      resultadoPedido = estoqueCalculado < 0
          ? estoqueMaxBiscoitoPolvilho / 6
          : (estoqueMaxBiscoitoPolvilho - estoqueCalculado) / 6;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Massa Pão De Queijo Coq') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              (vendaMensalPaoQueijoCoquetel * 1.50 / diasDeGiro! / 3.3));
      resultadoPedido = estoqueCalculado < 0
          ? estoqueMaxPaoQueijoCoquetel / 6
          : (estoqueMaxPaoQueijoCoquetel - estoqueCalculado) / 6;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Massa Pão Biscoito Queijo') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              (vendaMensalBiscoitoQueijo * 1.42 / diasDeGiro! / 3.3));
      resultadoPedido = estoqueCalculado < 0
          ? estoqueMaxBiscoitoQueijo / 6
          : (estoqueMaxBiscoitoQueijo - estoqueCalculado) / 6;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Massa Pão De Queijo Trad.') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              (vendaMensalPaoQueijoTradicional * 1.42 / diasDeGiro! / 3.3));
      resultadoPedido = estoqueCalculado < 0
          ? estoqueMaxPaoQueijoTradicional / 6
          : (estoqueMaxPaoQueijoTradicional - estoqueCalculado) / 6;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Torta Chocolate/Coco') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              (vendaMensalTortaChocolateCoco * 1.2 / diasDeGiro!));
      resultadoPedido = estoqueCalculado < 0
          ? estoqueMaxTortaChocolateCoco
          : (estoqueMaxTortaChocolateCoco - estoqueCalculado);
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Torta Dois Amores') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega * (vendaMensalTortaDoisAmores * 1.2 / diasDeGiro!));
      resultadoPedido = estoqueCalculado < 0
          ? estoqueMaxTortaDoisAmores
          : (estoqueMaxTortaDoisAmores - estoqueCalculado);
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Torta Doce De Leite Amendoim') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              (vendaMensalTortaDoceDeLeiteAmendoim * 1.2 / diasDeGiro!));
      resultadoPedido = estoqueCalculado < 0
          ? estoqueMaxTortaDoceDeLeiteAmendoim
          : (estoqueMaxTortaDoceDeLeiteAmendoim - estoqueCalculado);
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Torta Chocomousse') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              (vendaMensalTortaChocomousse * 1.2 / diasDeGiro!));
      resultadoPedido = estoqueCalculado < 0
          ? estoqueMaxTortaChocomousse
          : (estoqueMaxTortaChocomousse - estoqueCalculado);
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    }

    resultadoPedido = resultadoPedido.ceilToDouble();
    final novoValor =
        resultadoPedido > 0 ? resultadoPedido.toInt().toString() : '0';

    // Atualizar o estado ANTES de modificar o controller
    setState(() {
      _produtoState[produto]!['valor'] = resultadoPedido;
      if (isUserAction) {
        _produtoState[produto]!['editado'] = false;
      }
      _produtoState[produto]!['carregado'] = true;
    });

    // Setar flag para evitar que o onChanged do TextField marque como editado manualmente
    _atualizandoProgramaticamente = true;

    // Agora atualizar o controller
    resultadoControllers[produto]?.text = novoValor;

    // Resetar flag após um pequeno delay
    Future.delayed(Duration(milliseconds: 100), () {
      _atualizandoProgramaticamente = false;
    });

    // Salvar os novos valores
    _saveUserInputs();
  }

  // ✅ Atualizar TODOS os produtos (ignorando edições manuais)
  void _atualizarTodos() {
    setState(() {
      for (String produto in massas) {
        _produtoState[produto]!['editado'] = false;
        _calcularPedidoIndividual(produto, true);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Todos os produtos atualizados!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ✅ Atualizar um produto individualmente
  void _atualizarProduto(String produto) {
    _calcularPedidoIndividual(produto, true);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('dd/MM/yy').format(picked);
      });
  }

  // ✅ Gerar pedido no Firebase
  void _gerarPedido() async {
    try {
      Map<String, dynamic> pedidos = {};
      massas.forEach((produto) {
        pedidos[produto] =
            double.tryParse(resultadoControllers[produto]?.text ?? '0') ?? 0;
      });

      final pedidoCompleto = {
        'produtos': pedidos,
        'usuario': userName,
        'loja': widget.storeName,
        'data': DateFormat('dd/MM/yy').format(selectedDate),
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('pedidos').add(pedidoCompleto);

      await _firestore.collection('stores').doc(widget.storeName).set({
        'ultimoPedido': pedidoCompleto,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pedido gerado com sucesso'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Erro ao gerar pedido: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar pedido: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff955a97),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/Logo StockOne.png',
              height: 30,
            ),
            const SizedBox(width: 10),
            const Text(
              "PEDIDO",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                fontFamily: 'Lora',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey, Colors.blueGrey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('dd/MM/yy').format(selectedDate),
                    style: const TextStyle(color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.white),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'INTERVALO DE ENTREGA (DIAS):',
                      style: TextStyle(
                        color: Color(0xff240217),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: 50,
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<int>(
                        value: intervaloEntrega,
                        isExpanded: true,
                        alignment: Alignment.center,
                        underline: SizedBox(),
                        onChanged: (int? novoIntervalo) {
                          setState(() {
                            intervaloEntrega = novoIntervalo ?? 1;
                            // Quando muda o intervalo, atualiza apenas os não editados manualmente
                            for (String produto in massas) {
                              if (!_produtoState[produto]!['editado']) {
                                _calcularPedidoIndividual(produto, false);
                              }
                            }
                            _savePedidoConfig();
                          });
                        },
                        items: List.generate(9, (index) => index + 1)
                            .map((days) => DropdownMenuItem(
                                  value: days,
                                  child: Text(
                                    '$days',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color(0xff240217)),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: massas.length,
                  itemBuilder: (context, index) {
                    String produto = massas[index];
                    double estoque =
                        double.tryParse(controllers[produto]?.text ?? '0') ??
                            0.0;
                    String estoqueFormatado = estoque % 1 == 0
                        ? estoque.toInt().toString()
                        : estoque.toStringAsFixed(1);

                    // Verificar se foi editado manualmente
                    bool editadoManual = _produtoState[produto]!['editado'];

                    return Card(
                      color: Colors.white70,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(produto,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                if (editadoManual)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Editado',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.amber[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text('Estoque pct(s): $estoqueFormatado'),
                                SizedBox(width: 10),
                                if (estoqueInsuficiente[produto] == true)
                                  Text('Abaixo do giro',
                                      style: TextStyle(color: Colors.red)),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: resultadoControllers[produto],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'caixa(s)',
                                      border: OutlineInputBorder(),
                                    ),
                                    style: TextStyle(fontSize: 16),
                                    onChanged: (value) {
                                      // Só marca como editado manualmente se não estiver sendo atualizado programaticamente
                                      if (!_atualizandoProgramaticamente &&
                                          value.isNotEmpty) {
                                        setState(() {
                                          _produtoState[produto]!['editado'] =
                                              true;
                                          _produtoState[produto]!['carregado'] =
                                              true;
                                        });
                                        // Salvar imediatamente quando o usuário edita
                                        _saveUserInputs();
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    _atualizarProduto(produto);
                                  },
                                  child: Text('Atualizar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xff955a97),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 5),
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _gerarPedido,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff955a97),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Gerar Pedido",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PedidosSalvosScreen(
                                      storeName: widget.storeName)),
                            );
                            if (result == true) {
                              _loadAllData();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Ver Pedidos",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PedidosSalvosScreen extends StatefulWidget {
  final String storeName;
  const PedidosSalvosScreen({required this.storeName});

  @override
  _PedidosSalvosScreenState createState() => _PedidosSalvosScreenState();
}

class _PedidosSalvosScreenState extends State<PedidosSalvosScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _carregarPedidosSalvos() async {
    final querySnapshot = await _firestore
        .collection('pedidos')
        .where('loja', isEqualTo: widget.storeName)
        .orderBy('timestamp', descending: true)
        .get();
    return querySnapshot.docs;
  }

  Future<void> _deletarPedido(String docId) async {
    try {
      await _firestore.collection('pedidos').doc(docId).delete();
      setState(() {}); // Recarrega a tela
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido deletado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao deletar pedido: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  void _confirmarExclusao(String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja deletar este pedido?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletarPedido(docId);
            },
            child: Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff955a97),
        title: Text('Pedidos Salvos'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        future: _carregarPedidosSalvos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar pedidos'));
          }

          final pedidos = snapshot.data ?? [];
          if (pedidos.isEmpty) {
            return Center(
                child: Text('Nenhum pedido salvo',
                    style: TextStyle(fontSize: 18)));
          }

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index].data();
              final docId = pedidos[index].id;

              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pedido['data'] ?? 'Data não informada',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87),
                      ),
                      SizedBox(height: 6),
                      Text(
                        pedido['loja'] ?? 'Loja não informada',
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Usuário: ${pedido['usuario'] ?? 'Não informado'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmarExclusao(docId)),
                      Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalhesPedidoScreen(
                            pedido: pedido, storeName: widget.storeName),
                      ),
                    );
                    if (result == true) setState(() {});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetalhesPedidoScreen extends StatelessWidget {
  final Map<String, dynamic> pedido;
  final String storeName;

  DetalhesPedidoScreen({
    Key? key,
    required this.pedido,
    required this.storeName,
  }) : super(key: key);

  final Map<String, double> multiplicadores = {
    'Massa Pão Francês': 2,
    'Massa Pão Francês Fibras': 6,
    'Massa Pão Cervejinha': 6,
    'Massa Mini Baguete 40g': 6,
    'Massa Mini Baguete 90g': 6,
    'Massa Baguete 330g': 6,
    'Massa Pão De Queijo Coq': 6,
    'Massa Pão Biscoito Queijo': 6,
    'Massa Pão De Queijo Trad.': 6,
    'Massa Biscoito Polvilho': 6,
    'Massa Pão Doce Comprido': 6,
    'Massa Rosca Doce': 6,
    'Massa Pão Doce Caracol': 6,
    'Massa Pão Doce Ferradura': 6,
    'Massa Bambino': 6,
    'Massa Mini Pão Marta Rocha': 6,
    'Massa Pão Tatu': 6,
    'Massa Pão Fofinho': 6,
    'Torta Chocomousse': 1,
    'Torta Chocolate/Coco': 1,
    'Torta Doce De Leite Amendoim': 1,
    'Torta Dois Amores': 1,
  };

  Future<void> _adicionarPedidoAoEstoqueFirebase(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmar Adição"),
        content: Text("Deseja realmente adicionar este pedido ao estoque?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Confirmar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final produtos = Map<String, dynamic>.from(pedido['produtos']);
    final docRef =
        FirebaseFirestore.instance.collection('stores').doc(storeName);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      Map<String, dynamic> acerto = {};
      if (snapshot.exists && snapshot.data()!.containsKey('acerto')) {
        acerto = Map<String, dynamic>.from(snapshot['acerto']);
      }

      produtos.forEach((produto, quantidade) {
        final multiplicador = multiplicadores[produto] ?? 1;
        final atual = (acerto[produto] ?? 0) as num;
        acerto[produto] = atual + ((quantidade as num) * multiplicador);
      });

      transaction.set(docRef, {'acerto': acerto}, SetOptions(merge: true));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Estoque atualizado em Acerto com sucesso!')),
    );

    Navigator.of(context)
      ..pop()
      ..pop(true);
  }

  Future<void> _sharePedidoPdf(BuildContext context) async {
    final pdf = pw.Document();
    final produtos = Map<String, dynamic>.from(pedido['produtos']);

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Resumo do Pedido')),
          pw.Paragraph(text: '${pedido['loja']}'),
          pw.Paragraph(text: 'Responsável: ${pedido['usuario']}'),
          pw.Paragraph(text: 'Data: ${pedido['data']}'),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Produto', 'Caixas'],
            data: multiplicadores.keys.map((produto) {
              final caixas = produtos[produto] ?? 0;
              return [produto, (caixas as num).toInt()];
            }).toList(),
          ),
        ],
      ),
    );

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final bytes = await pdf.save();

      // Verifica se é Web
      if (kIsWeb) {
        // WEB: Faz download
        final base64 = base64Encode(bytes);
        final anchor = html.AnchorElement(
            href:
                'data:application/octet-stream;charset=utf-16le;base64,$base64')
          ..setAttribute('download',
              'pedido_${pedido['loja']}_${pedido['data']?.replaceAll('/', '') ?? DateTime.now().toString()}.pdf')
          ..click();

        if (context.mounted) Navigator.of(context).pop();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF baixado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // MOBILE: Compartilha
        final dir = await getTemporaryDirectory();
        final file = File(
            '${dir.path}/pedido_${pedido['loja']}_${DateTime.now().millisecondsSinceEpoch}.pdf');
        await file.writeAsBytes(bytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Pedido - ${pedido['loja']} - ${pedido['data']}',
        );

        if (context.mounted) Navigator.of(context).pop();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF gerado e compartilhado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final produtos = Map<String, dynamic>.from(pedido['produtos']);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff955a97),
        title: Text('Detalhe Pedido'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _sharePedidoPdf(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${pedido['loja']}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Responsável: ${pedido['usuario']}',
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Data: ${pedido['data']}',
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 16),
                    Divider(),
                    Text('Produtos:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Table(
                        border: TableBorder.symmetric(
                            inside: BorderSide(color: Colors.grey.shade200)),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            decoration:
                                BoxDecoration(color: Colors.grey.shade100),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('Nome do Produto',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('Caixas',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          ...multiplicadores.keys.map((produto) {
                            final caixas = produtos[produto] ?? 0;
                            return TableRow(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(produto),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    '${(caixas as num).toInt()} caixa(s)',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _adicionarPedidoAoEstoqueFirebase(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff955a97),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Adicionar pedido ao estoque',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuScreen extends StatelessWidget {
  final String storeName;
  const MenuScreen({super.key, required this.storeName});

  // 🔹 Card estilo Android
  Widget _menuCard(
    BuildContext context,
    IconData icon, // novo parâmetro
    String label,
    Widget destination,
    Color color,
  ) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.brown.withOpacity(0.3),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: const Color(0xFF5D4037),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Roboto',
                  color: Color(0xFF5D4037),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2691E),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/Logo StockOne.png', height: 32),
            const SizedBox(width: 8),
            const Text(
              "RELATÓRIOS",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lora',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFE5B4),
              Color(0xFFD29752), // base marrom padaria
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 1, // 1 card por linha (vertical)
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 3, // retangular, moderno
            children: [
              _menuCard(
                context,
                Icons.place,
                'POSICIONAMENTO',
                ReportAberturaScreen(storeName: storeName),
                Colors.white, // verde
              ),
              _menuCard(
                context,
                Icons.check_circle,
                'FECHAMENTO',
                ReportFinalScreen(storeName: storeName),
                Colors.white, // vermelho padaria
              ),
              _menuCard(
                context,
                Icons.build,
                'MANUTENÇÃO',
                ManutencaoEquipamentosScreen(storeName: storeName),
                Colors.white, // cinza
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ManutencaoEquipamentosScreen extends StatefulWidget {
  final String storeName;

  const ManutencaoEquipamentosScreen({super.key, required this.storeName});

  @override
  State<ManutencaoEquipamentosScreen> createState() =>
      _ManutencaoEquipamentosScreenState();
}

class _ManutencaoEquipamentosScreenState
    extends State<ManutencaoEquipamentosScreen> {
  Map<String, dynamic> dadosResumo = {};
  Map<String, bool> equipamentosSelecionados = {};
  Map<String, TextEditingController> defeitosControllers = {};
  late TextEditingController gerenteController;
  late TextEditingController observacoesController;
  late String dataFormatada;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    gerenteController = TextEditingController();
    observacoesController = TextEditingController();

    final dataHoje = DateTime.now();
    dataFormatada =
        "${dataHoje.day.toString().padLeft(2, '0')}/${dataHoje.month.toString().padLeft(2, '0')}/${dataHoje.year}";

    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();
      if (doc.exists) {
        final data = doc.data() ?? {};

        setState(() {
          dadosResumo = {
            'fornos': data['fornos'] ?? [],
            'armarios': data['armarios'] ?? [],
            'esqueletos': data['esqueletos'] ?? [],
            'climaticas': data['climaticas'] ?? [],
            'freezers': data['freezers'] ?? [],
          };

          gerenteController.text = data['gerente'] ?? '';

          for (var tipo in dadosResumo.keys) {
            var lista = dadosResumo[tipo];
            for (int i = 0; i < lista.length; i++) {
              String key = "$tipo-$i";
              equipamentosSelecionados[key] = false;
              defeitosControllers[key] = TextEditingController();
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados: $e");
    }
  }

  Future<void> _salvarGerente() async {
    try {
      await _firestore.collection('stores').doc(widget.storeName).set({
        'gerente': gerenteController.text,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Erro ao salvar gerente: $e');
    }
  }

  Future<void> _compartilharRelatorio() async {
    StringBuffer relatorio = StringBuffer();

    relatorio.writeln("ORDEM DE SERVIÇO");
    relatorio.writeln("");
    relatorio.writeln("${widget.storeName}");
    relatorio.writeln("Data: $dataFormatada");
    relatorio.writeln("Gerência: ${gerenteController.text}");
    relatorio.writeln("");
    relatorio.writeln("Equipamentos:");

    equipamentosSelecionados.entries
        .where((entry) => entry.value)
        .forEach((entry) {
      final key = entry.key;
      final partes = key.split("-");
      final tipo = partes[0];
      final index = int.parse(partes[1]);
      final equipamento = dadosResumo[tipo][index];
      final defeito = defeitosControllers[key]?.text ?? "";

      relatorio.writeln("- ${_tituloEquipamento(tipo, index, equipamento)}");

      // REMOVE photoUrl do PDF
      equipamento.forEach((campo, valor) {
        if (campo != 'photoUrl') {
          relatorio.writeln("   $campo: $valor");
        }
      });

      relatorio.writeln("   Defeito(s): $defeito");
      relatorio.writeln("");
    });

    relatorio.writeln("Observações:");
    relatorio.writeln(observacoesController.text);

    await Share.share(relatorio.toString());
  }

  String _tituloEquipamento(String tipo, int index, Map<String, dynamic> eq) {
    switch (tipo) {
      case 'fornos':
        return "Forno ${index + 1}";
      case 'armarios':
        return "Armário ${index + 1}";
      case 'esqueletos':
        return "Esqueleto ${index + 1}";
      case 'climaticas':
        return "Climática ${index + 1}";
      case 'freezers':
        return "Conservador ${index + 1}";
      default:
        return "Equipamento ${index + 1}";
    }
  }

  @override
  void dispose() {
    gerenteController.dispose();
    observacoesController.dispose();
    for (var controller in defeitosControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const verdeEscuro = Color(0xFF006400);
    const preto = Color(0xff0e0101);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/Logo StockOne.png', height: 32),
            const SizedBox(width: 8),
            const Text(
              "MANUTENÇÃO",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lora',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: dadosResumo.isEmpty
          ? const Center(
              child: Text("Nenhum equipamento cadastrado."),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: DefaultTextStyle(
                style: const TextStyle(fontSize: 19, color: preto),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data: $dataFormatada',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                            color: verdeEscuro)),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Gerência:",
                        labelStyle: TextStyle(fontSize: 23, color: verdeEscuro),
                      ),
                      controller: gerenteController,
                      onChanged: (_) => _salvarGerente(),
                    ),
                    const SizedBox(height: 24),
                    ...dadosResumo.keys.expand((tipo) {
                      var lista = dadosResumo[tipo];
                      return List.generate(lista.length, (index) {
                        String key = "$tipo-$index";
                        final equipamento = lista[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CheckboxListTile(
                              title: Text(
                                _tituloEquipamento(tipo, index, equipamento),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                equipamento.entries
                                    .where((e) => e.key != 'photoUrl')
                                    .map((e) => "${e.key}: ${e.value}")
                                    .join(", "),
                                style: const TextStyle(fontSize: 14),
                              ),
                              value: equipamentosSelecionados[key],
                              onChanged: (value) {
                                setState(() {
                                  equipamentosSelecionados[key] =
                                      value ?? false;
                                });
                              },
                            ),
                            if (equipamentosSelecionados[key] == true)
                              Card(
                                margin: const EdgeInsets.only(
                                    left: 32, right: 8, bottom: 16),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    maxLines: null,
                                    minLines: 3,
                                    controller: defeitosControllers[key],
                                    decoration: const InputDecoration(
                                        labelText: "Defeito(s)"),
                                  ),
                                ),
                              )
                          ],
                        );
                      });
                    }),
                    const SizedBox(height: 16),
                    TextField(
                      maxLines: null,
                      minLines: 3,
                      decoration: InputDecoration(
                        labelText: "Observações:",
                        labelStyle: TextStyle(fontSize: 23, color: verdeEscuro),
                      ),
                      controller: observacoesController,
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _compartilharRelatorio,
                        icon: const Icon(Icons.share),
                        label: const Text(
                          'Compartilhar',
                          style: TextStyle(fontSize: 19),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class ReportAberturaScreen extends StatefulWidget {
  final String storeName;
  const ReportAberturaScreen({super.key, required this.storeName});
  @override
  State<ReportAberturaScreen> createState() => _ReportAberturaScreenState();
}

class _ReportAberturaScreenState extends State<ReportAberturaScreen> {
  late TextEditingController crachaController;
  late TextEditingController gerenteController;
  late TextEditingController encarregadoController;
  int colaboradoresAtivos = 0;
  int sobrasGeladeira = 0;
  late String userName;
  late String dataFormatada;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    crachaController = TextEditingController();
    gerenteController = TextEditingController();
    encarregadoController = TextEditingController();
    _carregarPreferencias();
    final dataHoje = DateTime.now();
    dataFormatada =
        "${dataHoje.day.toString().padLeft(2, '0')}/${dataHoje.month.toString().padLeft(2, '0')}/${dataHoje.year}";
  }

  Future<void> _carregarPreferencias() async {
    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        setState(() {
          crachaController.text = data['cracha'] ?? '';
          gerenteController.text = data['gerente'] ?? '';
          encarregadoController.text = data['encarregado'] ?? '';
          userName = data['userName'] ?? '';
          colaboradoresAtivos = data['colaboradoresAtivos'] ?? 0;
          sobrasGeladeira = data['sobrasGeladeira'] ?? 0;
        });
      }
    } catch (e) {
      print('Erro ao carregar preferências: $e');
    }
  }

  Future<void> _salvarPreferencias() async {
    try {
      await _firestore.collection('stores').doc(widget.storeName).set({
        'cracha': crachaController.text,
        'gerente': gerenteController.text,
        'encarregado': encarregadoController.text,
        'colaboradoresAtivos': colaboradoresAtivos,
        'sobrasGeladeira': sobrasGeladeira,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Erro ao salvar preferências: $e');
    }
  }

  Future<void> _compartilharRelatorioComImagens() async {
    String texto = """ BOM DIA A TODOS!

*Posicionamento: ${widget.storeName}
*Data: $dataFormatada
*Técnico: $userName
*Crachá: ${crachaController.text}
*Gerência: ${gerenteController.text}
*Encarregado: ${encarregadoController.text}
*Colaboradores ativos: $colaboradoresAtivos
*Sobras Pão Francês: $sobrasGeladeira telas
""";

    await Share.share(texto.trim(), subject: 'Relatório Abertura');
  }

  @override
  void dispose() {
    crachaController.dispose();
    gerenteController.dispose();
    encarregadoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const verdeEscuro = Color(0xFF006400);
    const preto = Color(0xff0e0101);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: verdeEscuro,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/Logo StockOne.png', height: 32),
            const SizedBox(width: 8),
            const Text(
              "POSICIONAMENTO",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lora',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: const TextStyle(fontSize: 19, color: preto),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Data: $dataFormatada',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                  color: verdeEscuro,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                decoration: const InputDecoration(
                  labelText: "Gerência:",
                  labelStyle: TextStyle(fontSize: 23, color: verdeEscuro),
                ),
                controller: gerenteController,
                onChanged: (_) => _salvarPreferencias(),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: "Encarregado(s):",
                  labelStyle: TextStyle(fontSize: 23, color: verdeEscuro),
                ),
                controller: encarregadoController,
                onChanged: (_) => _salvarPreferencias(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: colaboradoresAtivos,
                decoration: const InputDecoration(
                  labelText: 'Colaboradores ativos:',
                  labelStyle: TextStyle(fontSize: 23, color: verdeEscuro),
                ),
                items: List.generate(16, (index) => index)
                    .map((v) =>
                        DropdownMenuItem(value: v, child: Text(v.toString())))
                    .toList(),
                onChanged: (value) {
                  setState(() => colaboradoresAtivos = value ?? 0);
                  _salvarPreferencias();
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: "Crachá:",
                  labelStyle: TextStyle(fontSize: 23, color: verdeEscuro),
                ),
                controller: crachaController,
                onChanged: (_) => _salvarPreferencias(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: sobrasGeladeira,
                decoration: const InputDecoration(
                  labelText: 'Sobras Pão Francês (telas):',
                  labelStyle: TextStyle(fontSize: 23, color: verdeEscuro),
                ),
                items: List.generate(31, (index) => index)
                    .map((v) =>
                        DropdownMenuItem(value: v, child: Text(v.toString())))
                    .toList(),
                onChanged: (value) {
                  setState(() => sobrasGeladeira = value ?? 0);
                  _salvarPreferencias();
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verdeEscuro,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _compartilharRelatorioComImagens,
                  icon: const Icon(Icons.share),
                  label: const Text(
                    'Compartilhar',
                    style: TextStyle(fontSize: 19),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportFinalScreen extends StatefulWidget {
  final String storeName;
  const ReportFinalScreen({super.key, required this.storeName});

  @override
  State<ReportFinalScreen> createState() => _ReportFinalScreenState();
}

class _ReportFinalScreenState extends State<ReportFinalScreen> {
  static const verdeEscuro = Color(0xFF006400);
  static const vermelhoEscuro = Color(0xFF8B0000);

  TimeOfDay horarioSaida = TimeOfDay.now();

  late TextEditingController crachaController;
  late TextEditingController gerenteController;
  late TextEditingController encarregadoController;
  late TextEditingController giroMedioController;

  String resultadoInteiro = '';
  String vendamediadiaria = '';
  String userName = '';
  int colaboradoresAtivos = 0;
  late String dataFormatada;
  late String dataParaArquivo;

  List<String> rotinaOpcoes = [
    'rotina',
    'inauguração',
    'cobrir falta de funcionários',
    'outros',
  ];
  List<String> rotinaSelecionadas = [];
  String rotinaOutros = '';
  String trabalhoRealizado = '';
  String giroMedio = '';
  String qtdRetirada = '';
  String lotesRetirados = '';
  String qtdSobra = '';
  String rabanadaassada = '';
  String paopararabanada = '';
  String paodealhodacasapicante = '';
  String paodealhodacasa = '';

  final List<String> produtos = [
    'Pão Francês',
    'Pão Francês integral',
    'Pão Francês Panhoca',
    'Pão Francês com Queijo',
    'Pão Baguete Francesa Queijo',
    'Pão Baguete Francesa',
    'Pão Baguete Francesa Gergelim',
    'Mini Pão Francês Gergelim',
    'Baguete Francesa Queijo',
    'Baguete Francesa',
    'Pão Queijo Tradicional',
    'Pão Queijo Coquetel',
    'Biscoito Queijo',
    'Biscoito Polvilho',
    'Pão Samaritano',
    'Pão Pizza',
    'Pão Tatu',
    'Mini Pão Sonho',
    'Mini Pão Sonho Chocolate',
    'Pão Bambino',
    'Mini Marta Rocha',
    'Pão Doce Ferradura',
    'Pão Doce Caracol',
    'Rosca Caseira',
    'Rosca Caseira Côco',
    'Rosca Caseira Leite em Pó',
    'Rosca Côco/Queijo',
    'Sanduíche Bahamas',
    'Rabanada Assada',
    'Pão Fofinho',
    'Sanduíche Fofinho',
    'Rosca Fofinha Temperada',
    'Caseirinho',
    'Pão P/ Rabanada',
    'Pão Doce Comprido',
    'Pão Milho',
    'Pão de Alho da Casa',
    'Pão de Alho da Casa Picante',
  ];

  final motivos = [
    'aguardando fermentação',
    'não foi retirado',
    'aguardando acabamento',
    'ruptura em estoque',
    'aguardando forneamento',
    'outros',
  ];

  late Map<String, bool> rupturasSelecionadas;
  late Map<String, String> motivosSelecionados;
  late Map<String, String> outrosMotivos;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    crachaController = TextEditingController();
    gerenteController = TextEditingController();
    encarregadoController = TextEditingController();
    giroMedioController = TextEditingController();

    rupturasSelecionadas = {for (var p in produtos) p: false};
    motivosSelecionados = {for (var p in produtos) p: motivos[0]};
    outrosMotivos = {for (var p in produtos) p: ''};

    final dataHoje = DateTime.now();
    dataFormatada =
        "${dataHoje.day.toString().padLeft(2, '0')}/${dataHoje.month.toString().padLeft(2, '0')}/${dataHoje.year}";
    dataParaArquivo =
        "${dataHoje.year}-${dataHoje.month.toString().padLeft(2, '0')}-${dataHoje.day.toString().padLeft(2, '0')}";

    _carregarPreferencias();
  }

  Future<void> _carregarPreferencias() async {
    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        final relatorioData = data['relatorioFinal'] ?? {};

        final fetchedCracha = data['cracha'] ?? '';
        final fetchedGerente = data['gerente'] ?? '';
        final fetchedEncarregado = data['encarregado'] ?? '';

        final fetchedColaboradores = relatorioData['colaboradoresAtivos'] ?? 0;
        final fetchedRotinaSelecionadas =
            List<String>.from(relatorioData['rotinaSelecionadas'] ?? []);
        final fetchedRotinaOutros = relatorioData['rotinaOutros'] ?? '';
        final fetchedTrabalhoRealizado =
            relatorioData['trabalhoRealizado'] ?? '';
        final fetchedGiroMedio = relatorioData['giroMedio'] ?? '';
        final fetchedQtdRetirada = relatorioData['qtdRetirada'] ?? '';
        final fetchedLotesRetirados = relatorioData['lotesRetirados'] ?? '';
        final fetchedrabanadaassada = relatorioData['rabanadaassada'] ?? '';
        final fetchedpaopararabanada = relatorioData['paopararabanada'] ?? '';
        final fetchedpaodealhodacasa = relatorioData['paodealhodacasa'] ?? '';
        final fetchedpaodealhodacasapicante =
            relatorioData['paodealhodacasapicante'] ?? '';
        final fetchedQtdSobra = relatorioData['qtdSobra'] ?? '';
        final fetchedUserName = data['userName'] ?? '';

        final vendasData = data['vendas'] ?? {};
        final vendaMensalPaoFrances =
            (vendasData['Pão Francês'] ?? 0).toDouble();
        final diasDeGiro = data['diasGiro'] ?? 1;
        final resultado = (diasDeGiro != 0)
            ? (vendaMensalPaoFrances / diasDeGiro / 0.07)
            : 0.0;
        final calcResultadoInteiro = resultado.ceil().toString();

        final rupturasData = relatorioData['rupturas'] ?? {};

        setState(() {
          crachaController.text = fetchedCracha;
          gerenteController.text = fetchedGerente;
          encarregadoController.text = fetchedEncarregado;

          colaboradoresAtivos = fetchedColaboradores;
          rotinaSelecionadas = fetchedRotinaSelecionadas;
          rotinaOutros = fetchedRotinaOutros;
          trabalhoRealizado = fetchedTrabalhoRealizado;
          giroMedio = fetchedGiroMedio;
          qtdRetirada = fetchedQtdRetirada;
          lotesRetirados = fetchedLotesRetirados;
          qtdSobra = fetchedQtdSobra;
          userName = fetchedUserName;
          paopararabanada = fetchedpaopararabanada;
          rabanadaassada = fetchedrabanadaassada;
          paodealhodacasapicante = fetchedpaodealhodacasapicante;
          paodealhodacasa = fetchedpaodealhodacasa;

          resultadoInteiro = calcResultadoInteiro;
          giroMedioController.text = giroMedio;

          final parsedGiro = double.tryParse(giroMedio);
          if (parsedGiro != null && parsedGiro > 0) {
            vendamediadiaria = (parsedGiro / 0.07).toStringAsFixed(0);
          } else {
            vendamediadiaria = '';
          }

          for (var produto in produtos) {
            final produtoData = rupturasData[produto] ?? {};
            rupturasSelecionadas[produto] = produtoData['selecionado'] ?? false;
            motivosSelecionados[produto] = produtoData['motivo'] ?? motivos[0];
            outrosMotivos[produto] = produtoData['outroMotivo'] ?? '';
          }
        });
      }
    } catch (e) {
      print('Erro ao carregar preferências: $e');
    }
  }

  Future<void> _salvarPreferencias() async {
    try {
      await _firestore.collection('stores').doc(widget.storeName).set({
        'cracha': crachaController.text,
        'gerente': gerenteController.text,
        'encarregado': encarregadoController.text,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final rupturasData = <String, dynamic>{};
      for (var produto in produtos) {
        rupturasData[produto] = {
          'selecionado': rupturasSelecionadas[produto] ?? false,
          'motivo': motivosSelecionados[produto] ?? motivos[0],
          'outroMotivo': outrosMotivos[produto] ?? '',
        };
      }

      final relatorioData = {
        'colaboradoresAtivos': colaboradoresAtivos,
        'rotinaSelecionadas': rotinaSelecionadas,
        'rotinaOutros': rotinaOutros,
        'trabalhoRealizado': trabalhoRealizado,
        'giroMedio': giroMedio,
        'qtdRetirada': qtdRetirada,
        'lotesRetirados': lotesRetirados,
        'qtdSobra': qtdSobra,
        'resultadoInteiro': resultadoInteiro,
        'rupturas': rupturasData,
        'rabanadaassada': rabanadaassada,
        'paopararabanada': paopararabanada,
        'paodealhodacasa': paodealhodacasa,
        'paodealhodacasapicante': paodealhodacasapicante,
      };

      await _firestore.collection('stores').doc(widget.storeName).set({
        'relatorioFinal': relatorioData,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Erro ao salvar preferências: $e');
    }
  }

  String _gerarTextoRelatorio() {
    final buffer = StringBuffer();
    buffer.writeln('BOA TARDE A TODOS!');
    buffer.writeln();
    buffer.writeln('*Término de visita: ${widget.storeName}');
    buffer.writeln('*Data: $dataFormatada');
    buffer.writeln('*Horário: ${horarioSaida.format(context)}');
    buffer.writeln('*Técnico(s): $userName');
    buffer.writeln('*Crachá: ${crachaController.text}');
    buffer.writeln('*Gerência: ${gerenteController.text}');
    buffer.writeln('*Encarregado: ${encarregadoController.text}');
    buffer.writeln('*Colaboradores no dia: $colaboradoresAtivos');
    buffer.writeln('*Venda Pão Francês/dia:');
    buffer.writeln('$resultadoInteiro unidades');
    buffer.writeln();
    buffer.writeln('*Motivo:');
    buffer.writeln();

    if (rotinaSelecionadas.isNotEmpty) {
      buffer.write(rotinaSelecionadas.join(', '));
      if (rotinaSelecionadas.contains('outros') && rotinaOutros.isNotEmpty) {
        buffer.write(' ($rotinaOutros)');
      }
    } else {
      buffer.write('Nenhum motivo selecionado');
    }
    buffer.writeln();
    buffer.writeln();
    buffer.writeln('*Trabalho Realizado No Setor:');
    buffer.writeln();
    buffer.writeln(
        trabalhoRealizado.isEmpty ? 'Não informado' : trabalhoRealizado);
    buffer.writeln();
    buffer.writeln('*Vendas Do Dia Anterior:');
    buffer.writeln();
    buffer.writeln('#Pão Francês:');
    buffer.writeln(
        '${vendamediadiaria.isEmpty ? '0' : vendamediadiaria} unidades');
    buffer.writeln('#Pão de Queijo Tradicional:');
    buffer.writeln('${qtdRetirada.isEmpty ? '0' : qtdRetirada} Kilos');
    buffer.writeln('#Pão de Queijo Coquetel:');
    buffer.writeln('${lotesRetirados.isEmpty ? '0' : lotesRetirados} Kilos');
    buffer.writeln('#Biscoito de Queijo:');
    buffer.writeln('${qtdSobra.isEmpty ? '0' : qtdSobra} Kilos');
    buffer.writeln();
    buffer.writeln('*Rupturas:');
    buffer.writeln();
    buffer.write(_formatarRupturas());

    return buffer.toString().trim();
  }

  String _formatarRupturas() {
    final buffer = StringBuffer();
    bool hasRuptura = false;

    for (var produto in produtos) {
      if (rupturasSelecionadas[produto] == true) {
        hasRuptura = true;
        final motivo = motivosSelecionados[produto];
        if (motivo == 'outros') {
          final outroMotivo = (outrosMotivos[produto]?.isNotEmpty == true)
              ? outrosMotivos[produto]
              : 'outros';
          buffer.writeln(' - $produto (Motivo: $outroMotivo)');
        } else {
          buffer.writeln(' - $produto (Motivo: $motivo)');
        }
      }
    }

    if (!hasRuptura) {
      buffer.writeln('Nenhuma ruptura registrada');
    }
    return buffer.toString();
  }

  Future<void> _copiarTexto() async {
    final texto = _gerarTextoRelatorio();
    await Clipboard.setData(ClipboardData(text: texto));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Texto copiado para a área de transferência!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _arquivarRelatorio() async {
    final texto = _gerarTextoRelatorio();

    try {
      await _firestore
          .collection('relatorios')
          .doc('lojas')
          .collection('lojas')
          .doc(widget.storeName)
          .collection('datas')
          .doc(dataParaArquivo)
          .set({
        'loja': widget.storeName,
        'data': dataParaArquivo,
        'dataFormatada': dataFormatada,
        'horario': horarioSaida.format(context),
        'textoCompleto': texto,
        'tecnico': userName,
        'cracha': crachaController.text,
        'gerente': gerenteController.text,
        'encarregado': encarregadoController.text,
        'colaboradoresAtivos': colaboradoresAtivos,
        'resultadoInteiro': resultadoInteiro,
        'rotinaSelecionadas': rotinaSelecionadas,
        'rotinaOutros': rotinaOutros,
        'trabalhoRealizado': trabalhoRealizado,
        'giroMedio': giroMedio,
        'qtdRetirada': qtdRetirada,
        'lotesRetirados': lotesRetirados,
        'qtdSobra': qtdSobra,
        'vendamediadiaria': vendamediadiaria,
        'rabanadaassada': rabanadaassada,
        'paopararabanada': paopararabanada,
        'paodealhodacasa': paodealhodacasa,
        'paodealhodacasapicante': paodealhodacasapicante,
        'rupturas': _salvarRupturasParaFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Relatório arquivado com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Erro ao arquivar relatório: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao arquivar: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Map<String, dynamic> _salvarRupturasParaFirestore() {
    final rupturasData = <String, dynamic>{};
    for (var produto in produtos) {
      rupturasData[produto] = {
        'selecionado': rupturasSelecionadas[produto] ?? false,
        'motivo': motivosSelecionados[produto] ?? motivos[0],
        'outroMotivo': outrosMotivos[produto] ?? '',
      };
    }
    return rupturasData;
  }

  Future<void> _compartilharRelatorioFinal() async {
    final texto = _gerarTextoRelatorio();
    await Share.share(texto, subject: 'Relatório Final');
  }

  void _toggleRotina(String item, bool checked) {
    setState(() {
      if (checked) {
        if (!rotinaSelecionadas.contains(item)) {
          rotinaSelecionadas.add(item);
        }
      } else {
        rotinaSelecionadas.remove(item);
      }
      _salvarPreferencias();
    });
  }

  @override
  void dispose() {
    crachaController.dispose();
    gerenteController.dispose();
    encarregadoController.dispose();
    giroMedioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: vermelhoEscuro,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/Logo StockOne.png', height: 32),
            const SizedBox(width: 8),
            const Text(
              "FECHAMENTO",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lora',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: const TextStyle(fontSize: 19, color: vermelhoEscuro),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: const Text('Horário Saída'),
                trailing: Text(horarioSaida.format(context),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () async {
                  final picked = await showTimePicker(
                      context: context, initialTime: horarioSaida);
                  if (picked != null) {
                    setState(() {
                      horarioSaida = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Data: $dataFormatada',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                    color: verdeEscuro),
              ),
              const SizedBox(height: 32),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Gerência:',
                  labelStyle: TextStyle(fontSize: 23, color: verdeEscuro),
                ),
                controller: gerenteController,
                onChanged: (_) => _salvarPreferencias(),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Encarregado (s):',
                  labelStyle: TextStyle(fontSize: 23, color: verdeEscuro),
                ),
                controller: encarregadoController,
                onChanged: (_) => _salvarPreferencias(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: colaboradoresAtivos,
                decoration: const InputDecoration(
                  labelText: 'Colaboradores no dia:',
                  labelStyle: TextStyle(fontSize: 23, color: verdeEscuro),
                ),
                items: List.generate(16, (index) => index)
                    .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(v.toString()),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => colaboradoresAtivos = value ?? 0);
                  _salvarPreferencias();
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Crachá:',
                  labelStyle: TextStyle(fontSize: 23, color: verdeEscuro),
                ),
                controller: crachaController,
                onChanged: (_) => _salvarPreferencias(),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Venda Média Pão Francês/Dia:',
                          style: TextStyle(fontSize: 23, color: verdeEscuro),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: resultadoInteiro.isNotEmpty
                                    ? resultadoInteiro
                                    : '0',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const TextSpan(
                                text: ' unidades',
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xff0c0c0c)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Motivo:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                    color: verdeEscuro),
              ),
              ...rotinaOpcoes.map((item) {
                if (item == 'outros') {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        title: Text(item),
                        value: rotinaSelecionadas.contains(item),
                        onChanged: (v) {
                          _toggleRotina(item, v ?? false);
                        },
                      ),
                      if (rotinaSelecionadas.contains(item))
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            decoration: const InputDecoration(
                                labelText: 'Descrever outros'),
                            onChanged: (v) {
                              setState(() {
                                rotinaOutros = v;
                              });
                              _salvarPreferencias();
                            },
                            controller: TextEditingController(
                                text: rotinaOutros)
                              ..selection = TextSelection.fromPosition(
                                  TextPosition(offset: rotinaOutros.length)),
                          ),
                        ),
                    ],
                  );
                }
                return CheckboxListTile(
                  title: Text(item),
                  value: rotinaSelecionadas.contains(item),
                  onChanged: (v) {
                    _toggleRotina(item, v ?? false);
                  },
                );
              }).toList(),
              const SizedBox(height: 20),
              const Text(
                'Trabalho Realizado no Setor:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                    color: verdeEscuro),
              ),
              TextField(
                maxLines: null,
                minLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Descreva o trabalho realizado',
                ),
                controller: TextEditingController(text: trabalhoRealizado)
                  ..selection = TextSelection.fromPosition(
                      TextPosition(offset: trabalhoRealizado.length)),
                onChanged: (v) {
                  trabalhoRealizado = v;
                  _salvarPreferencias();
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Vendas do Dia Anterior:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                    color: verdeEscuro),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Pão Francês (kg)',
                        labelStyle: TextStyle(fontSize: 16),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: giroMedioController,
                      onChanged: (v) {
                        giroMedio = v;
                        final valor = double.tryParse(giroMedio);
                        if (valor != null && valor > 0) {
                          final convertido = (valor / 0.07).toStringAsFixed(0);
                          setState(() {
                            vendamediadiaria = convertido;
                          });
                        } else {
                          setState(() {
                            vendamediadiaria = '';
                          });
                        }
                        _salvarPreferencias();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Text(
                        vendamediadiaria.isNotEmpty
                            ? '$vendamediadiaria unid'
                            : '0 unid',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Pão de Queijo Tradicional (Kg)',
                  labelStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: qtdRetirada)
                  ..selection = TextSelection.fromPosition(
                      TextPosition(offset: qtdRetirada.length)),
                onChanged: (v) {
                  qtdRetirada = v;
                  _salvarPreferencias();
                },
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Pão de Queijo Coquetel (Kg)',
                  labelStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: lotesRetirados)
                  ..selection = TextSelection.fromPosition(
                      TextPosition(offset: lotesRetirados.length)),
                onChanged: (v) {
                  lotesRetirados = v;
                  _salvarPreferencias();
                },
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Biscoito de Queijo (Kg)',
                  labelStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: qtdSobra)
                  ..selection = TextSelection.fromPosition(
                      TextPosition(offset: qtdSobra.length)),
                onChanged: (v) {
                  qtdSobra = v;
                  _salvarPreferencias();
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Rupturas:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                    color: verdeEscuro),
              ),
              Column(
                children: produtos.map((produto) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        title: Text(produto),
                        value: rupturasSelecionadas[produto],
                        onChanged: (v) {
                          setState(() {
                            rupturasSelecionadas[produto] = v ?? false;
                            if (v == false) {
                              motivosSelecionados[produto] = motivos[0];
                              outrosMotivos[produto] = '';
                            }
                            _salvarPreferencias();
                          });
                        },
                      ),
                      if (rupturasSelecionadas[produto] == true)
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 32.0, bottom: 10),
                          child: DropdownButtonFormField<String>(
                            value: motivosSelecionados[produto],
                            decoration: InputDecoration(
                              labelText: 'Motivo ($produto)',
                              labelStyle: const TextStyle(
                                  fontSize: 19, color: verdeEscuro),
                            ),
                            style: const TextStyle(
                                fontSize: 19, color: vermelhoEscuro),
                            items: motivos
                                .map((m) => DropdownMenuItem(
                                      value: m,
                                      child: Text(m,
                                          style: const TextStyle(
                                              fontSize: 19,
                                              color: vermelhoEscuro)),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                motivosSelecionados[produto] = value!;
                                _salvarPreferencias();
                              });
                            },
                          ),
                        ),
                      if (motivosSelecionados[produto] == 'outros' &&
                          rupturasSelecionadas[produto] == true)
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 32.0, bottom: 10),
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Descreva o motivo',
                            ),
                            onChanged: (v) {
                              outrosMotivos[produto] = v;
                              _salvarPreferencias();
                            },
                            controller: TextEditingController(
                                text: outrosMotivos[produto])
                              ..selection = TextSelection.fromPosition(
                                  TextPosition(
                                      offset:
                                          outrosMotivos[produto]?.length ?? 0)),
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.share),
                      label: const Text('Compartilhar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: vermelhoEscuro,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      onPressed: _compartilharRelatorioFinal,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.archive),
                      label: const Text('Arquivar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: verdeEscuro,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      onPressed: _arquivarRelatorio,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy),
                      label: const Text('Copiar texto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      onPressed: _copiarTexto,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FoldedCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.shade700 // cor da dobra
      ..style = PaintingStyle.fill;

    final path = Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // borda da dobra
    final borderPaint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ReceituarioScreen extends StatelessWidget {
  const ReceituarioScreen({super.key});

  // 🔹 Recebe o context como parâmetro
  Widget _padariaCard(BuildContext context, String label, Widget destination) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      borderRadius: BorderRadius.circular(16),
      splashColor: Colors.brown.withOpacity(0.3),
      child: Stack(
        children: [
          // Card principal
          Container(
            decoration: BoxDecoration(
              color: const Color(0xffffffff),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xff131212), // cor da borda
                width: 2, // espessura da borda
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 0.1),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Nunito ExtraBold',
                    color: Color(0xFF5D4037),
                  ),
                ),
              ],
            ),
          ),

          // Dobra no canto superior direito (todos os cards terão)
          Positioned(
            right: 0,
            top: 0,
            child: CustomPaint(
              size: const Size(30, 30), // tamanho da dobra
              painter: FoldedCornerPainter(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> paes = [
      {'label': "Baguete Francesa", 'screen': const BagueteFrancesaScreen()},
      {
        'label': "Baguete Francesa C/ Queijo",
        'screen': const BagueteFrancesaCQueijoScreen()
      },
      {'label': "Biscoito Polvilho", 'screen': const BiscoitoPolvilhoScreen()},
      {'label': "Biscoito Queijo ", 'screen': const BiscoitoQueijoScreen()},
      {
        'label': "Mini Pão Marta Rocha",
        'screen': const MiniPaoMartaRochaScreen()
      },
      {'label': "Mini Pão Sonho", 'screen': const MiniPaoSonhoScreen()},
      {
        'label': "Mini Pão Sonho Chocolate",
        'screen': const MiniPaoSonhoChocolateScreen()
      },
      {
        'label': "Pão Bambino              ",
        'screen': const PaoBambinoScreen()
      },
      {'label': "Pão Baguete Francesa", 'screen': const paobaguete()},
      {
        'label': "Pão Baguete Francesa C/ Gergelim",
        'screen': const PaoBagueteFrancesaCGergelimScreen()
      },
      {
        'label': "Pão Baguete Francesa C/ Queijo",
        'screen': const PaoBagueteFrancesaCQueijoScreen()
      },
      {'label': "Pão Caseirinho", 'screen': const PaoCaseirinhoScreen()},
      {'label': "Pão De Alho Da Casa", 'screen': const PaoDeAlhoDaCasaScreen()},
      {
        'label': "Pão De Alho Da Casa Picante",
        'screen': const PaoDeAlhoDaCasaPicanteScreen()
      },
      {
        'label': "Pão De Queijo Coquetel",
        'screen': const PaoDeQueijoCoquetelScreen()
      },
      {
        'label': "Pão De Queijo Tradicional",
        'screen': const PaoDeQueijoTradicionalScreen()
      },
      {'label': "Pão Doce Caracol", 'screen': const PaoDoceCaracolScreen()},
      {'label': "Pão Doce Ferradura", 'screen': const PaoDoceFerraduraScreen()},
      {'label': "Pão Fofinho        ", 'screen': const PaoFofinhoScreen()},
      {'label': "Pão Francês        ", 'screen': const PaoFrancesScreen()},
      {
        'label': "Pão Francês C/ Queijo",
        'screen': const PaoFrancesCQueijoScreen()
      },
      {'label': "Pão Francês Fibras", 'screen': const integral()},
      {'label': "Pão Francês Panhoca", 'screen': const panhoca()},
      {'label': "Pão Milho          ", 'screen': const PaoMilhoScreen()},
      {'label': "Pão Para Rabanada", 'screen': const PaoParaRabanadaScreen()},
      {'label': "Pão Pizza          ", 'screen': const PaoPizzaScreen()},
      {'label': "Pão Samaritano", 'screen': const PaoSamaritanoScreen()},
      {'label': "Pão Tatu           ", 'screen': const PaoTatuScreen()},
      {'label': "Rabanada Assada", 'screen': const RabanadaAssadaScreen()},
      {'label': "Rosca Caseira", 'screen': const RoscaCaseiraScreen()},
      {'label': "Rosca Caseira Côco", 'screen': const RoscaCaseiraCocoScreen()},
      {
        'label': "Rosca Caseira Leite em Pó",
        'screen': const RoscaCaseiraLeiteEmPoScreen()
      },
      {
        'label': "Rosca Côco E Queijo",
        'screen': const RoscaCocoEQueijoScreen()
      },
      {
        'label': "Rosca Fofinha Temperada",
        'screen': const RoscaFofinhaTemperadaScreen()
      },
      {'label': "Sanduíche Bahamas", 'screen': const SanduicheBahamasScreen()},
      {'label': "Sanduíche Fofinho", 'screen': const SanduicheFofinhoScreen()},
      {'label': "Torrada Comum", 'screen': const TorradaComumScreen()},
      {'label': "Torrada De Alho", 'screen': const TorradaDeAlhoScreen()},
      {
        'label': "Torrada De Alho Picante",
        'screen': const TorradaDeAlhoPicanteScreen()
      },
      {'label': "Torrada Fibras", 'screen': const TorradaIntegralScreen()},
      {
        'label': "Torrada Fibras De Alho",
        'screen': const TorradaIntegralDeAlhoScreen()
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2691E),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/Logo StockOne.png', height: 32),
            const SizedBox(width: 8),
            const Text(
              "RECEITUÁRIO",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lora',
                color: Colors.white,
              ),
            ),
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
              Color(0xFFD29752), // marrom padaria (seu antigo fundo)
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            itemCount: paes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) {
              final pao = paes[index];
              return _padariaCard(context, pao['label'], pao['screen']);
            },
          ),
        ),
      ),
    );
  }
}

class Documentos extends StatefulWidget {
  const Documentos({super.key});

  @override
  State<Documentos> createState() => _DocumentosState();
}

class _DocumentosState extends State<Documentos> {
  final List<bool> _selectedItems = [];
  bool _selectionMode = false;

  final List<Map<String, dynamic>> paes = [
    {
      'label': 'Baixas Motivo (8,9,49)',
      'url':
          'https://firebasestorage.googleapis.com/v0/b/stockone-1c804.firebasestorage.app/o/requisi%C3%A7%C3%A3o%20motivos%208%2C9%2C49.pdf?alt=media&token=3b549708-5853-4831-af61-432ee5717b79'
    },
    {
      'label': 'Baixas Motivo (23,71)',
      'url':
          'https://firebasestorage.googleapis.com/v0/b/stockone-1c804.firebasestorage.app/o/requisi%C3%A7%C3%A3o%20motivos%2071%20e%2023.pdf?alt=media&token=0a17349a-699b-492d-84d7-4107d409a6a4'
    },
    {
      'label': 'Etiqueta Validade',
      'url':
          'https://firebasestorage.googleapis.com/v0/b/stockone-1c804.firebasestorage.app/o/ETIQUETA%20DE%20VALIDADE%20%20PADARIA.pdf?alt=media&token=f5ec2a1e-e9bb-48ea-b7b9-cf5506a9a05b'
    },
    {
      'label': 'Validade Insumos',
      'url':
          'https://firebasestorage.googleapis.com/v0/b/stockone-1c804.firebasestorage.app/o/Validade%20insumos.pdf?alt=media&token=402e7150-c245-4b47-80a1-badd9f60333d'
    },
    {
      'label': 'Catálogo de Códigos CX-OPERADOR',
      'url':
          'https://firebasestorage.googleapis.com/v0/b/stockone-1c804.firebasestorage.app/o/Cat%C3%A1golo%20c%C3%B3digos%20cx-operador.pdf?alt=media&token=c9988046-404d-478a-933c-838128f920ba'
    },
    {
      'label': 'Última atualização baixas',
      'url':
          'https://firebasestorage.googleapis.com/v0/b/stockone-1c804.firebasestorage.app/o/baixas%20padaria%2C%20inclus%C3%A3o%20e%20perda%20d%C3%A1gua.pdf?alt=media&token=9f38b83f-decc-4a6e-b749-6c2aacc44e89'
    },
    {
      'label': 'Códigos de venda',
      'url':
          'https://firebasestorage.googleapis.com/v0/b/stockone-1c804.firebasestorage.app/o/Codigos.pdf?alt=media&token=6d26f3f6-0f68-41f8-83f6-2536174f8fdd'
    },
    {
      'label': 'Apostila',
      'url':
          'https://firebasestorage.googleapis.com/v0/b/stockone-1c804.firebasestorage.app/o/Apostila%20Marquespan%20ZM.pdf?alt=media&token=87d824bc-dd44-4e8e-acb5-d396dbbf511d'
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedItems.addAll(List.filled(paes.length, false));
  }

  // ---------------------------------------------------------------------------
  // VISUALIZAR DOCUMENTO
  // ---------------------------------------------------------------------------
  void _viewDocument(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o documento')),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // DOWNLOAD (continua igual)
  // ---------------------------------------------------------------------------
  void _downloadDocument(
      BuildContext context, String url, String fileName) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download iniciado: $fileName')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao baixar: $fileName')),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // FUNÇÃO NOVA — BAIXA E COMPARTILHA O PDF REAL
  // ---------------------------------------------------------------------------
  void _shareDocument(String url, String title) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$title.pdf';

      // Baixar o PDF
      final response = await Dio().download(url, filePath);

      if (response.statusCode == 200) {
        await Share.shareXFiles([XFile(filePath)], text: title);
      }
    } catch (e) {
      print('Erro ao compartilhar PDF real: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // MULTIPLOS DOCUMENTOS — TAMBÉM COMPARTILHA PDF REAL
  // ---------------------------------------------------------------------------
  void _shareSelectedDocuments() async {
    try {
      final tempDir = await getTemporaryDirectory();
      List<XFile> arquivos = [];

      final selectedDocs = paes
          .asMap()
          .entries
          .where((entry) => _selectedItems[entry.key])
          .toList();

      for (final doc in selectedDocs) {
        final label = doc.value['label'];
        final url = doc.value['url'];
        final filePath = '${tempDir.path}/$label.pdf';

        final response = await Dio().download(url, filePath);
        if (response.statusCode == 200) {
          arquivos.add(XFile(filePath));
        }
      }

      if (arquivos.isNotEmpty) {
        await Share.shareXFiles(arquivos, text: 'Documentos selecionados');
      }
    } catch (e) {
      print('Erro ao compartilhar vários PDFs: $e');
    }

    _exitSelectionMode();
  }

  // ---------------------------------------------------------------------------
  // DOWNLOAD MULTIPLO — continua igual
  // ---------------------------------------------------------------------------
  void _downloadSelectedDocuments() {
    final selectedDocs = paes
        .asMap()
        .entries
        .where((entry) => _selectedItems[entry.key])
        .map((entry) => entry.value)
        .toList();

    if (selectedDocs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Iniciando download de ${selectedDocs.length} documentos')),
      );

      for (final doc in selectedDocs) {
        _downloadDocument(context, doc['url'], doc['label']);
      }
    }
    _exitSelectionMode();
  }

  // ---------------------------------------------------------------------------
  // SAIR DO MODO DE SELEÇÃO
  // ---------------------------------------------------------------------------
  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedItems.fillRange(0, _selectedItems.length, false);
    });
  }

  // ---------------------------------------------------------------------------
  // MODAL DE OPÇÕES
  // ---------------------------------------------------------------------------
  void _showOptionsModal(BuildContext context, String label, String url) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
                fontFamily: 'Nunito ExtraBold',
              ),
              textAlign: TextAlign.center,
            ),
            _buildOptionButton(
              context,
              icon: Icons.download,
              text: 'Baixar',
              onTap: () => _downloadDocument(context, url, label),
            ),
            _buildOptionButton(
              context,
              icon: Icons.share,
              text: 'Compartilhar',
              onTap: () => _shareDocument(url, label),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFD2691E),
                  fontFamily: 'Nunito ExtraBold',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFD2691E)),
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Nunito ExtraBold',
          color: Color(0xFF5D4037),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  // ---------------------------------------------------------------------------
  // CARD
  // ---------------------------------------------------------------------------
  Widget _padariaCard(
    BuildContext context,
    int index,
    String label,
    String url,
  ) {
    final bool selected = _selectedItems[index];

    return InkWell(
      onTap: () {
        if (_selectionMode) {
          setState(() => _selectedItems[index] = !selected);
        } else {
          _showOptionsModal(context, label, url);
        }
      },
      onLongPress: () {
        setState(() {
          _selectionMode = true;
          _selectedItems[index] = true;
        });
      },
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          // ---- CARD EM FORMA DE PAPEL ----
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFFFF7E6) // papel selecionado
                  : const Color(0xFFFFFCF6), // papel normal
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? const Color(0xFFD2691E)
                    : const Color(0xFFB9B5AA),
                width: selected ? 3 : 2,
              ),
              boxShadow: [
                // sombra leve igual folha solta na mesa
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selected)
                  const Icon(Icons.check_circle,
                      color: Color(0xFFD2691E), size: 22),

                const SizedBox(height: 10),

                // ---- Texto do nome do documento ----
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Nunito ExtraBold',
                        color: Color(0xFF5D4037),
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ---- DOBRA NO CANTO SUPERIOR DIREITO ----
          Positioned(
            right: 0,
            top: 0,
            child: ClipPath(
              clipper: _FoldedClipper(),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFEADBC8), // cor estilo papel dobrado
                ),
              ),
            ),
          ),

          // Linha diagonal da dobra (estilo folha real)
          Positioned(
            right: 3,
            top: 3,
            child: Transform.rotate(
              angle: -0.75,
              child: Container(
                width: 40,
                height: 1.2,
                color: const Color(0xFFB9A999),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2691E),
        centerTitle: true,
        title: _selectionMode
            ? Text(
                '${_selectedItems.where((s) => s).length} selecionados',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lora',
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/Logo StockOne.png', height: 32),
                  const SizedBox(width: 8),
                  const Text(
                    "DOCUMENTOS",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lora',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
        leading: _selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
                tooltip: 'Cancelar seleção',
              )
            : null,
        actions: _selectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _downloadSelectedDocuments,
                  tooltip: 'Baixar selecionados',
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: _shareSelectedDocuments,
                  tooltip: 'Compartilhar selecionados',
                ),
              ]
            : null,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFE5B4),
              Color(0xFFD29752),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            itemCount: paes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) {
              final pao = paes[index];
              return _padariaCard(context, index, pao['label'], pao['url']);
            },
          ),
        ),
      ),
    );
  }
}

class _FoldedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) => false;
}

// Painter para dobra
class _FoldedCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    final linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final linePath = Path();
    linePath.moveTo(size.width, 0);
    linePath.lineTo(0, size.height);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PaoFrancesScreen extends StatelessWidget {
  const PaoFrancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 1.0,
              maxScale: 5.0,
              scaleFactor: 50.0, // sensibilidade média
              child: Image.asset(
                'assets/images/paofrances.jpg',
                fit: BoxFit.fitWidth,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class integral extends StatelessWidget {
  const integral({super.key});

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
                'assets/images/paofrancesfibras.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class panhoca extends StatelessWidget {
  const panhoca({super.key});

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
                'assets/images/panhoca.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class paobaguete extends StatelessWidget {
  const paobaguete({super.key});

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
                'assets/images/paobaguete.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class PaoBagueteFrancesaCGergelimScreen extends StatelessWidget {
  const PaoBagueteFrancesaCGergelimScreen({super.key});
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
                'assets/images/paobaguetefrancesagergelim.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class PaoBagueteFrancesaCQueijoScreen extends StatelessWidget {
  const PaoBagueteFrancesaCQueijoScreen({super.key});

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
                'assets/images/paobaguetefrancesaqueijo.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class RoscaCaseiraCocoScreen extends StatelessWidget {
  const RoscaCaseiraCocoScreen({super.key});
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
                'assets/images/roscacaseiracoco.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class RoscaCaseiraScreen extends StatelessWidget {
  const RoscaCaseiraScreen({super.key});
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
                'assets/images/roscacaseira.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class MiniPaoMartaRochaScreen extends StatelessWidget {
  const MiniPaoMartaRochaScreen({super.key});

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
                'assets/images/minipaomartarocha.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class PaoBambinoScreen extends StatelessWidget {
  const PaoBambinoScreen({super.key});
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
                'assets/images/paobambino.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class MiniPaoSonhoScreen extends StatelessWidget {
  const MiniPaoSonhoScreen({super.key});
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
                'assets/images/minipaosonho.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class MiniPaoSonhoChocolateScreen extends StatelessWidget {
  const MiniPaoSonhoChocolateScreen({super.key});

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
                'assets/images/minipaosonhochocolate.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class RoscaFofinhaTemperadaScreen extends StatelessWidget {
  const RoscaFofinhaTemperadaScreen({super.key});

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
                'assets/images/roscafofinhatemperada.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class PaoCaseirinhoScreen extends StatelessWidget {
  const PaoCaseirinhoScreen({super.key});

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
                'assets/images/paocaseirinho.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class PaoTatuScreen extends StatelessWidget {
  const PaoTatuScreen({super.key});

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
                'assets/images/paotatu.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class PaoMilhoScreen extends StatelessWidget {
  const PaoMilhoScreen({super.key});
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
                'assets/images/paomilho.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class PaoDoceCompridoScreen extends StatelessWidget {
  const PaoDoceCompridoScreen({super.key});
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
                'assets/images/paodocecomprido.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class PaoDoceFerraduraScreen extends StatelessWidget {
  const PaoDoceFerraduraScreen({super.key});

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
                'assets/images/paodoceferradura.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class PaoDoceCaracolScreen extends StatelessWidget {
  const PaoDoceCaracolScreen({super.key});
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
                'assets/images/paodocecaracol.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class TorradaIntegralDeAlhoScreen extends StatelessWidget {
  const TorradaIntegralDeAlhoScreen({super.key});
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
                'assets/images/torradafibrasdealho.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class TorradaIntegralScreen extends StatelessWidget {
  const TorradaIntegralScreen({super.key});
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
                'assets/images/torradafibras.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class TorradaDeAlhoScreen extends StatelessWidget {
  const TorradaDeAlhoScreen({super.key});

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
                'assets/images/torradadealho.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class TorradaDeAlhoPicanteScreen extends StatelessWidget {
  const TorradaDeAlhoPicanteScreen({super.key});

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
                'assets/images/torradadealhopicante.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class TorradaComumScreen extends StatelessWidget {
  const TorradaComumScreen({super.key});

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
                'assets/images/torradacomum.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class PaoDeAlhoDaCasaPicanteScreen extends StatelessWidget {
  const PaoDeAlhoDaCasaPicanteScreen({super.key});

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
                'assets/images/paodealhodacasapicante.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class PaoDeAlhoDaCasaScreen extends StatelessWidget {
  const PaoDeAlhoDaCasaScreen({super.key});

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
                'assets/images/paodealhodacasa.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class PaoFrancesCQueijoScreen extends StatelessWidget {
  const PaoFrancesCQueijoScreen({super.key});

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
                'assets/images/paofrancesqueijo.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class MiniPaoFrancesCGergelimScreen extends StatelessWidget {
  const MiniPaoFrancesCGergelimScreen({super.key});

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
                'assets/images/minipaofrancesgergelim.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class BagueteFrancesaCQueijoScreen extends StatelessWidget {
  const BagueteFrancesaCQueijoScreen({super.key});

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
                'assets/images/baguetefrancesaqueijo.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class BagueteFrancesaScreen extends StatelessWidget {
  const BagueteFrancesaScreen({super.key});

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
                'assets/images/baguetefrancesa.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class PaoFofinhoScreen extends StatelessWidget {
  const PaoFofinhoScreen({super.key});

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
                'assets/images/paofofinho.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class ProfiterolesDoceDeLeiteScreen extends StatelessWidget {
  const ProfiterolesDoceDeLeiteScreen({super.key});

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
                'assets/images/profiterolesdocedeleite.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class ProfiterolesBrigadeiroBrancoScreen extends StatelessWidget {
  const ProfiterolesBrigadeiroBrancoScreen({super.key});
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
                'assets/images/profiterolesbrigadeirobranco.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class ProfiterolesBrigadeiroScreen extends StatelessWidget {
  const ProfiterolesBrigadeiroScreen({super.key});

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
                'assets/images/profiterolesbrigadeiro.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class BiscoitoPolvilhoScreen extends StatelessWidget {
  const BiscoitoPolvilhoScreen({super.key});
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
                'assets/images/biscoitopolvilho.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class BiscoitoQueijoScreen extends StatelessWidget {
  const BiscoitoQueijoScreen({super.key});

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
                'assets/images/biscoitodequeijo.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class PaoDeQueijoCoquetelScreen extends StatelessWidget {
  const PaoDeQueijoCoquetelScreen({super.key});
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
                'assets/images/paodequeijocoquetel.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class PaoDeQueijoTradicionalScreen extends StatelessWidget {
  const PaoDeQueijoTradicionalScreen({super.key});
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
                'assets/images/paodequeijotradicional.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class SanduicheBahamasScreen extends StatelessWidget {
  const SanduicheBahamasScreen({super.key});
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
                'assets/images/sanduichebahamas.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class SanduicheFofinhoScreen extends StatelessWidget {
  const SanduicheFofinhoScreen({super.key});

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
                'assets/images/sanduichefofinho.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class PaoPizzaScreen extends StatelessWidget {
  const PaoPizzaScreen({super.key});
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
                'assets/images/paopizza.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class PaoSamaritanoScreen extends StatelessWidget {
  const PaoSamaritanoScreen({super.key});
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
                'assets/images/paosamaritano.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class RabanadaAssadaScreen extends StatelessWidget {
  const RabanadaAssadaScreen({super.key});
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
                'assets/images/rabanadaassada.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class PaoParaRabanadaScreen extends StatelessWidget {
  const PaoParaRabanadaScreen({super.key});
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
                'assets/images/paopararabanada.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class RoscaCocoEQueijoScreen extends StatelessWidget {
  const RoscaCocoEQueijoScreen({super.key});
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
                'assets/images/roscacocoequeijo.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class RoscaCaseiraLeiteEmPoScreen extends StatelessWidget {
  const RoscaCaseiraLeiteEmPoScreen({super.key});

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
                'assets/images/roscacaseiraleiteempo.jpg',
                fit: BoxFit.fitWidth, // ajusta a largura da imagem à tela
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),

          // Botão de voltar sobre a imagem
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
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

class Equipamentos extends StatelessWidget {
  final String storeName;
  const Equipamentos({super.key, required this.storeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0x76153555),
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/Logo StockOne.png', height: 32),
              const SizedBox(width: 8),
              const Text(
                "EQUIPAMENTOS",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lora',
                  color: Colors.white,
                ),
              ),
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0x76153555),
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 38), // dobro
                    textStyle: const TextStyle(fontSize: 22), // dobro do texto
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Cadastro(storeName: storeName),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add,
                      size: 26, color: Colors.white), // ícone Cadastro
                  label: const Text(
                    'Cadastro',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24), // mais espaço
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0x97095195),
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 38),
                    textStyle: const TextStyle(fontSize: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Limpeza()),
                    );
                  },
                  icon: const Icon(Icons.cleaning_services,
                      size: 26, color: Colors.white), // ícone Limpeza
                  label: const Text(
                    'Limpeza',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class Cadastro extends StatelessWidget {
  final String storeName;
  const Cadastro({super.key, required this.storeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0x76153555),
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/Logo StockOne.png', height: 32),
              const SizedBox(width: 8),
              const Text(
                "CADASTRO",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lora',
                  color: Colors.white,
                ),
              ),
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0x97095195),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    textStyle: const TextStyle(fontSize: 19),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Forno(storeName: storeName),
                      ),
                    );
                  },
                  child: const Text(
                    'Fornos',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0x97095195),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    textStyle: const TextStyle(fontSize: 19),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Armarios(storeName: storeName),
                      ),
                    );
                  },
                  child: const Text(
                    'Armários e Esqueletos',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0x97095195),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    textStyle: const TextStyle(fontSize: 19),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Climatica(storeName: storeName),
                      ),
                    );
                  },
                  child: const Text(
                    'Climática',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0x97095195),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    textStyle: const TextStyle(fontSize: 19),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Freezer(storeName: storeName),
                      ),
                    );
                  },
                  child: const Text(
                    'Conservadores',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0x97095195),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    textStyle: const TextStyle(fontSize: 19),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Assadeiras(storeName: storeName),
                      ),
                    );
                  },
                  child: const Text(
                    'Assadeiras',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0x97095195),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    textStyle: const TextStyle(fontSize: 19),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ResumoEquipamentos(storeName: storeName),
                      ),
                    );
                  },
                  child: const Text(
                    'Resumo',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class Forno extends StatefulWidget {
  final String storeName;
  const Forno({super.key, required this.storeName});

  @override
  _FornoState createState() => _FornoState();
}

class _FornoState extends State<Forno> {
  int quantidadeFornos = 0;

  List<TextEditingController> modeloControllers = [];
  List<String> tiposForno = [];
  List<int> suportesForno = [];
  List<String?> fotosForno = [];

  /// progresso de upload por forno
  Map<int, double> uploadProgress = {};

  final List<String> tipos = ['Elétrico', 'Gás'];
  final List<int> suportes = [1, 2, 3, 4, 5, 6, 7, 8];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _criarFornoControllers(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFornoData();
    });
  }

  @override
  void dispose() {
    for (var c in modeloControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ===================== CONTROLLERS =====================

  void _criarFornoControllers(int quantidade) {
    for (var c in modeloControllers) {
      c.dispose();
    }
    modeloControllers =
        List.generate(quantidade, (_) => TextEditingController());
    tiposForno = List.generate(quantidade, (_) => '');
    suportesForno = List.generate(quantidade, (_) => 0);
    fotosForno = List.generate(quantidade, (_) => null);
  }

  // ===================== FOTO =====================

  Future<void> _selecionarFoto(int index) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024, // ✅ garante 1024px (Android + Web)
      imageQuality: 70, // ✅ reduz tamanho
    );

    if (image == null) return;

    final ref = FirebaseStorage.instance.ref(
      'stores/${widget.storeName}/fornos/forno_$index.jpg',
    );

    UploadTask task;

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      task = ref.putData(bytes);
    } else {
      task = ref.putFile(File(image.path));
    }

    task.snapshotEvents.listen((event) {
      final progress = event.bytesTransferred / event.totalBytes;
      setState(() {
        uploadProgress[index] = progress;
      });
    });

    final snapshot = await task;
    final url = await snapshot.ref.getDownloadURL();

    setState(() {
      fotosForno[index] = url;
      uploadProgress.remove(index);
    });

    _saveFornoData();
  }

  Future<void> _excluirFoto(int index) async {
    final url = fotosForno[index];
    if (url == null) return;

    try {
      await FirebaseStorage.instance.refFromURL(url).delete();
    } catch (_) {}

    setState(() {
      fotosForno[index] = null;
    });

    _saveFornoData();
  }

  // ===================== VISUALIZAR FOTO =====================

  void _visualizarFoto(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  void _abrirMenuFoto(int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Visualizar'),
              onTap: () {
                Navigator.pop(context);
                final url = fotosForno[index];
                if (url != null) {
                  _visualizarFoto(url);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Trocar foto'),
              onTap: () {
                Navigator.pop(context);
                _selecionarFoto(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Excluir foto'),
              onTap: () {
                Navigator.pop(context);
                _excluirFoto(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===================== FIRESTORE =====================

  Future<void> _saveFornoData() async {
    final List<Map<String, dynamic>> fornoList = [];

    for (int i = 0; i < quantidadeFornos; i++) {
      fornoList.add({
        'modelo': modeloControllers[i].text,
        'tipo': tiposForno[i],
        'suportes': suportesForno[i],
        'photoUrl': fotosForno[i],
      });
    }

    await _firestore.collection('stores').doc(widget.storeName).set({
      'storeName': widget.storeName,
      'fornos': fornoList,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _loadFornoData() async {
    final doc =
        await _firestore.collection('stores').doc(widget.storeName).get();

    if (!doc.exists) return;

    final List<dynamic> fornos = doc.data()?['fornos'] ?? [];

    setState(() {
      quantidadeFornos = fornos.length;
      _criarFornoControllers(quantidadeFornos);

      for (int i = 0; i < quantidadeFornos; i++) {
        modeloControllers[i].text = fornos[i]['modelo'] ?? '';
        tiposForno[i] = fornos[i]['tipo'] ?? '';
        suportesForno[i] = fornos[i]['suportes'] ?? 0;
        fotosForno[i] = fornos[i]['photoUrl'];
      }
    });
  }

  void _adicionarForno() {
    setState(() {
      quantidadeFornos++;
      modeloControllers.add(TextEditingController());
      tiposForno.add('');
      suportesForno.add(0);
      fotosForno.add(null);
    });
    _saveFornoData();
  }

  void _removerForno(int index) {
    setState(() {
      quantidadeFornos--;
      modeloControllers[index].dispose();
      modeloControllers.removeAt(index);
      tiposForno.removeAt(index);
      suportesForno.removeAt(index);
      fotosForno.removeAt(index);
    });
    _saveFornoData();
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fornos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...List.generate(quantidadeFornos, (index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Forno ${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  fotosForno[index] == null
                                      ? Icons.add_a_photo
                                      : Icons.photo,
                                ),
                                onPressed: fotosForno[index] == null
                                    ? () => _selecionarFoto(index)
                                    : () => _abrirMenuFoto(index),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removerForno(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (uploadProgress[index] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(
                            value: uploadProgress[index],
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: modeloControllers[index],
                        decoration: const InputDecoration(
                          labelText: 'Modelo',
                        ),
                        onChanged: (_) => _saveFornoData(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: tiposForno[index].isNotEmpty
                                  ? tiposForno[index]
                                  : null,
                              hint: const Text('Tipo'),
                              items: tipos
                                  .map((t) => DropdownMenuItem(
                                        value: t,
                                        child: Text(t),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  tiposForno[index] = value ?? '';
                                  _saveFornoData();
                                });
                              },
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              isExpanded: true,
                              value: suportesForno[index] > 0
                                  ? suportesForno[index]
                                  : null,
                              items: suportes
                                  .map((s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s.toString()),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  suportesForno[index] = value ?? 0;
                                  _saveFornoData();
                                });
                              },
                              decoration: const InputDecoration(
                                  labelText: 'Suportes',
                                  border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            Center(
              child: IconButton(
                icon:
                    const Icon(Icons.add_circle, color: Colors.green, size: 36),
                onPressed: _adicionarForno,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Armarios extends StatefulWidget {
  final String storeName;
  const Armarios({super.key, required this.storeName});

  @override
  State<Armarios> createState() => _ArmariosState();
}

class _ArmariosState extends State<Armarios> {
  int quantidadeArmarios = 0;
  int quantidadeEsqueletos = 0;

  List<String> tiposArmario = [];
  List<int> suportesArmario = [];
  List<String?> fotosArmario = [];

  List<String> tiposEsqueleto = [];
  List<int> suportesEsqueleto = [];
  List<String?> fotosEsqueleto = [];

  // Mapas para controlar o progresso de upload
  Map<String, double> uploadProgress = {}; // Chave: 'armario_0', 'esqueleto_1'

  final List<String> tiposMaterial = ['Inox', 'Alumínio', 'Epoxi'];
  final List<int> suportes = List.generate(20, (index) => index + 1);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    criarControllers(0, 0);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void criarControllers(int qtdArmarios, int qtdEsqueletos) {
    fotosArmario = List.generate(qtdArmarios, (_) => null);
    fotosEsqueleto = List.generate(qtdEsqueletos, (_) => null);
  }

  // ===================== FOTO - COM PARÂMETROS IGUAIS À TELA FORNO =====================
  Future<void> _selecionarFoto(bool isArmario, int index) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024, // ✅ mesma compressão da tela FornoMM
      imageQuality: 70, // ✅ mesma qualidade
    );

    if (image == null) return;

    final chave = isArmario ? 'armario_$index' : 'esqueleto_$index';
    final ref = _storage.ref().child(
          'stores/${widget.storeName}/${isArmario ? 'armarios' : 'esqueletos'}/$chave.jpg',
        );

    UploadTask task;

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      task = ref.putData(bytes);
    } else {
      task = ref.putFile(File(image.path));
    }

    // ✅ LISTENER PARA BARRA DE PROGRESSO
    task.snapshotEvents.listen((event) {
      final progress = event.bytesTransferred / event.totalBytes;
      setState(() {
        uploadProgress[chave] = progress;
      });
    });

    // ✅ UPLOAD CONTINUA EM BACKGROUND (não usa await diretamente)
    task.then((snapshot) async {
      final url = await snapshot.ref.getDownloadURL();

      setState(() {
        if (isArmario) {
          fotosArmario[index] = url;
        } else {
          fotosEsqueleto[index] = url;
        }
        uploadProgress.remove(chave);
      });

      _saveData();
    }).catchError((error) {
      print('Erro no upload: $error');
      setState(() {
        uploadProgress.remove(chave);
      });
    });
  }

  Future<void> _excluirFoto(bool isArmario, int index) async {
    final url = isArmario ? fotosArmario[index] : fotosEsqueleto[index];
    if (url == null) return;

    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {}

    setState(() {
      if (isArmario) {
        fotosArmario[index] = null;
      } else {
        fotosEsqueleto[index] = null;
      }
    });
    _saveData();
  }

  // ===================== VISUALIZAR FOTO (IGUAL FORNOMM) =====================
  void _visualizarFoto(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // ===================== MENU FOTO (IGUAL FORNOMM) =====================
  void _abrirMenuFoto(bool isArmario, int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Visualizar'),
              onTap: () {
                Navigator.pop(context);
                final url =
                    isArmario ? fotosArmario[index] : fotosEsqueleto[index];
                if (url != null) {
                  _visualizarFoto(url);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Trocar foto'),
              onTap: () {
                Navigator.pop(context);
                _selecionarFoto(isArmario, index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Excluir foto'),
              onTap: () {
                Navigator.pop(context);
                _excluirFoto(isArmario, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===================== FIRESTORE =====================
  Future<void> _saveData() async {
    try {
      final armariosData = List.generate(
        quantidadeArmarios,
        (i) => {
          'tipo': tiposArmario[i],
          'suportes': suportesArmario[i],
          'photoUrl': fotosArmario[i],
        },
      );

      final esqueletosData = List.generate(
        quantidadeEsqueletos,
        (i) => {
          'tipo': tiposEsqueleto[i],
          'suportes': suportesEsqueleto[i],
          'photoUrl': fotosEsqueleto[i],
        },
      );

      await _firestore.collection('stores').doc(widget.storeName).set({
        'storeName': widget.storeName,
        'armarios': armariosData,
        'esqueletos': esqueletosData,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Erro ao salvar armários/esqueletos: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();
      if (!doc.exists) return;

      final data = doc.data() ?? {};
      final List armarioList = (data['armarios'] as List?) ?? [];
      final List esqueletoList = (data['esqueletos'] as List?) ?? [];

      setState(() {
        quantidadeArmarios = armarioList.length;
        quantidadeEsqueletos = esqueletoList.length;

        tiposArmario = armarioList
            .map<String>((e) => (e as Map)['tipo']?.toString() ?? '')
            .toList();
        suportesArmario = armarioList
            .map<int>((e) => (e as Map)['suportes'] as int? ?? 0)
            .toList();
        fotosArmario = armarioList
            .map<String?>((e) => (e as Map)['photoUrl'] as String?)
            .toList();

        tiposEsqueleto = esqueletoList
            .map<String>((e) => (e as Map)['tipo']?.toString() ?? '')
            .toList();
        suportesEsqueleto = esqueletoList
            .map<int>((e) => (e as Map)['suportes'] as int? ?? 0)
            .toList();
        fotosEsqueleto = esqueletoList
            .map<String?>((e) => (e as Map)['photoUrl'] as String?)
            .toList();
      });
    } catch (e) {
      debugPrint('Erro ao carregar armários/esqueletos: $e');
    }
  }

  // ===================== AÇÕES =====================
  void _adicionarArmario() {
    setState(() {
      quantidadeArmarios++;
      tiposArmario.add('');
      suportesArmario.add(0);
      fotosArmario.add(null);
    });
    _saveData();
  }

  void _removerArmario(int index) {
    setState(() {
      quantidadeArmarios--;
      tiposArmario.removeAt(index);
      suportesArmario.removeAt(index);
      fotosArmario.removeAt(index);
    });
    _saveData();
  }

  void _adicionarEsqueleto() {
    setState(() {
      quantidadeEsqueletos++;
      tiposEsqueleto.add('');
      suportesEsqueleto.add(0);
      fotosEsqueleto.add(null);
    });
    _saveData();
  }

  void _removerEsqueleto(int index) {
    setState(() {
      quantidadeEsqueletos--;
      tiposEsqueleto.removeAt(index);
      suportesEsqueleto.removeAt(index);
      fotosEsqueleto.removeAt(index);
    });
    _saveData();
  }

  // ===================== CARD =====================
  Widget _buildCard({
    required String title,
    required String tipo,
    required int suporte,
    required String? photoUrl,
    required String uploadKey,
    required void Function(String?) onTipoChanged,
    required void Function(int?) onSuporteChanged,
    required VoidCallback onRemove,
    required VoidCallback onPhotoTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        photoUrl == null ? Icons.add_a_photo : Icons.photo,
                      ),
                      onPressed: onPhotoTap,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onRemove,
                    ),
                  ],
                ),
              ],
            ),

            // ✅ BARRA DE PROGRESSO (IGUAL FORNOMM)
            if (uploadProgress.containsKey(uploadKey))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LinearProgressIndicator(
                  value: uploadProgress[uploadKey],
                ),
              ),

            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: tipo.isNotEmpty ? tipo : null,
                    items: tiposMaterial
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: onTipoChanged,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de material',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    isExpanded: true,
                    value: suporte > 0 ? suporte : null,
                    items: suportes
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.toString()),
                            ))
                        .toList(),
                    onChanged: onSuporteChanged,
                    decoration: const InputDecoration(
                      labelText: 'Suportes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Armários e Esqueletos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Armários:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...List.generate(quantidadeArmarios, (index) {
              return _buildCard(
                title: 'Armário ${index + 1}',
                tipo: tiposArmario[index],
                suporte: suportesArmario[index],
                photoUrl: fotosArmario[index],
                uploadKey: 'armario_$index',
                onTipoChanged: (v) {
                  setState(() => tiposArmario[index] = v ?? '');
                  _saveData();
                },
                onSuporteChanged: (v) {
                  setState(() => suportesArmario[index] = v ?? 0);
                  _saveData();
                },
                onRemove: () => _removerArmario(index),
                onPhotoTap: () => fotosArmario[index] == null
                    ? _selecionarFoto(true, index)
                    : _abrirMenuFoto(true, index),
              );
            }),
            Center(
              child: IconButton(
                icon:
                    const Icon(Icons.add_circle, size: 36, color: Colors.green),
                onPressed: _adicionarArmario,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Esqueletos:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...List.generate(quantidadeEsqueletos, (index) {
              return _buildCard(
                title: 'Esqueleto ${index + 1}',
                tipo: tiposEsqueleto[index],
                suporte: suportesEsqueleto[index],
                photoUrl: fotosEsqueleto[index],
                uploadKey: 'esqueleto_$index',
                onTipoChanged: (v) {
                  setState(() => tiposEsqueleto[index] = v ?? '');
                  _saveData();
                },
                onSuporteChanged: (v) {
                  setState(() => suportesEsqueleto[index] = v ?? 0);
                  _saveData();
                },
                onRemove: () => _removerEsqueleto(index),
                onPhotoTap: () => fotosEsqueleto[index] == null
                    ? _selecionarFoto(false, index)
                    : _abrirMenuFoto(false, index),
              );
            }),
            Center(
              child: IconButton(
                icon:
                    const Icon(Icons.add_circle, size: 36, color: Colors.green),
                onPressed: _adicionarEsqueleto,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Assadeiras extends StatefulWidget {
  final String storeName;
  const Assadeiras({super.key, required this.storeName});

  @override
  State<Assadeiras> createState() => _AssadeirasState();
}

class _AssadeirasState extends State<Assadeiras> {
  int quantidadeEsteiras = 0;
  int quantidadeAssadeiras = 0;

  List<String> tiposEsteiras = [];
  List<int> quantidadesEsteiras = [];
  List<String?> fotosEsteiras = [];

  List<String> tiposAssadeiras = [];
  List<int> quantidadesAssadeiras = [];
  List<String?> fotosAssadeiras = [];

  // Mapas para controle de progresso
  Map<String, double> uploadProgress = {}; // 'esteira_0', 'assadeira_1'

  final List<String> tiposMaterial = [
    'Alumínio',
    'Inox',
    'Flandre',
    'Ferro Fundido'
  ];
  final List<int> quantidades = List.generate(120, (index) => index + 1);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    criarEsteiraAssadeiraControllers(0, 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void criarEsteiraAssadeiraControllers(int qtdEsteiras, int qtdAssadeiras) {
    fotosEsteiras = List.generate(qtdEsteiras, (_) => null);
    fotosAssadeiras = List.generate(qtdAssadeiras, (_) => null);
  }

  // ===================== FOTO - COM PARÂMETROS IGUAIS =====================
  Future<void> _selecionarFoto(bool isEsteira, int index) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 70,
    );

    if (image == null) return;

    final chave = isEsteira ? 'esteira_$index' : 'assadeira_$index';
    final ref = _storage.ref().child(
          'stores/${widget.storeName}/${isEsteira ? 'esteiras' : 'assadeiras'}/$chave.jpg',
        );

    UploadTask task;

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      task = ref.putData(bytes);
    } else {
      task = ref.putFile(File(image.path));
    }

    // ✅ BARRA DE PROGRESSO
    task.snapshotEvents.listen((event) {
      final progress = event.bytesTransferred / event.totalBytes;
      setState(() {
        uploadProgress[chave] = progress;
      });
    });

    // ✅ UPLOAD EM BACKGROUND
    task.then((snapshot) async {
      final url = await snapshot.ref.getDownloadURL();
      setState(() {
        if (isEsteira) {
          fotosEsteiras[index] = url;
        } else {
          fotosAssadeiras[index] = url;
        }
        uploadProgress.remove(chave);
      });
      _saveData();
    }).catchError((error) {
      print('Erro no upload: $error');
      setState(() {
        uploadProgress.remove(chave);
      });
    });
  }

  Future<void> _excluirFoto(bool isEsteira, int index) async {
    final url = isEsteira ? fotosEsteiras[index] : fotosAssadeiras[index];
    if (url == null) return;

    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {}

    setState(() {
      if (isEsteira) {
        fotosEsteiras[index] = null;
      } else {
        fotosAssadeiras[index] = null;
      }
    });
    _saveData();
  }

  // ===================== VISUALIZAR FOTO =====================
  void _visualizarFoto(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // ===================== MENU FOTO =====================
  void _abrirMenuFoto(bool isEsteira, int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Visualizar'),
              onTap: () {
                Navigator.pop(context);
                final url =
                    isEsteira ? fotosEsteiras[index] : fotosAssadeiras[index];
                if (url != null) {
                  _visualizarFoto(url);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Trocar foto'),
              onTap: () {
                Navigator.pop(context);
                _selecionarFoto(isEsteira, index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Excluir foto'),
              onTap: () {
                Navigator.pop(context);
                _excluirFoto(isEsteira, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===================== FIRESTORE =====================
  Future<void> _saveData() async {
    try {
      final esteirasData = List.generate(
        quantidadeEsteiras,
        (i) => {
          'tipo': tiposEsteiras[i],
          'quantidade': quantidadesEsteiras[i],
          'photoUrl': fotosEsteiras[i],
        },
      );

      final assadeirasData = List.generate(
        quantidadeAssadeiras,
        (i) => {
          'tipo': tiposAssadeiras[i],
          'quantidade': quantidadesAssadeiras[i],
          'photoUrl': fotosAssadeiras[i],
        },
      );

      await _firestore.collection('stores').doc(widget.storeName).set({
        'storeName': widget.storeName,
        'esteiras': esteirasData,
        'assadeiras': assadeirasData,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Erro ao salvar esteiras/assadeiras: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();
      if (!doc.exists) return;

      final data = doc.data() ?? {};
      final List esteirasList = (data['esteiras'] as List?) ?? [];
      final List assadeirasList = (data['assadeiras'] as List?) ?? [];

      setState(() {
        quantidadeEsteiras = esteirasList.length;
        quantidadeAssadeiras = assadeirasList.length;

        tiposEsteiras = esteirasList
            .map<String>((e) => (e as Map)['tipo']?.toString() ?? '')
            .toList();
        quantidadesEsteiras = esteirasList
            .map<int>((e) => (e as Map)['quantidade'] as int? ?? 0)
            .toList();
        fotosEsteiras = esteirasList
            .map<String?>((e) => (e as Map)['photoUrl'] as String?)
            .toList();

        tiposAssadeiras = assadeirasList
            .map<String>((e) => (e as Map)['tipo']?.toString() ?? '')
            .toList();
        quantidadesAssadeiras = assadeirasList
            .map<int>((e) => (e as Map)['quantidade'] as int? ?? 0)
            .toList();
        fotosAssadeiras = assadeirasList
            .map<String?>((e) => (e as Map)['photoUrl'] as String?)
            .toList();
      });
    } catch (e) {
      debugPrint('Erro ao carregar esteiras/assadeiras: $e');
    }
  }

  // ===================== AÇÕES =====================
  void _adicionarEsteira() {
    setState(() {
      quantidadeEsteiras++;
      tiposEsteiras.add('');
      quantidadesEsteiras.add(0);
      fotosEsteiras.add(null);
    });
    _saveData();
  }

  void _removerEsteira(int index) {
    setState(() {
      quantidadeEsteiras--;
      tiposEsteiras.removeAt(index);
      quantidadesEsteiras.removeAt(index);
      fotosEsteiras.removeAt(index);
    });
    _saveData();
  }

  void _adicionarAssadeira() {
    setState(() {
      quantidadeAssadeiras++;
      tiposAssadeiras.add('');
      quantidadesAssadeiras.add(0);
      fotosAssadeiras.add(null);
    });
    _saveData();
  }

  void _removerAssadeira(int index) {
    setState(() {
      quantidadeAssadeiras--;
      tiposAssadeiras.removeAt(index);
      quantidadesAssadeiras.removeAt(index);
      fotosAssadeiras.removeAt(index);
    });
    _saveData();
  }

  // ===================== CARD =====================
  Widget _buildCard({
    required String title,
    required String tipo,
    required int quantidade,
    required String? photoUrl,
    required String uploadKey,
    required void Function(String?) onTipoChanged,
    required void Function(int?) onQtdChanged,
    required VoidCallback onRemove,
    required VoidCallback onPhotoTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                          photoUrl == null ? Icons.add_a_photo : Icons.photo),
                      onPressed: onPhotoTap,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onRemove,
                    ),
                  ],
                ),
              ],
            ),

            // ✅ BARRA DE PROGRESSO
            if (uploadProgress.containsKey(uploadKey))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LinearProgressIndicator(
                  value: uploadProgress[uploadKey],
                ),
              ),

            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: tipo.isNotEmpty ? tipo : null,
              hint: const Text('Tipo de material'),
              items: tiposMaterial
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: onTipoChanged,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: quantidade > 0 ? quantidade : null,
              hint: const Text('Quantidade'),
              items: quantidades
                  .map((q) =>
                      DropdownMenuItem(value: q, child: Text(q.toString())))
                  .toList(),
              onChanged: onQtdChanged,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Esteiras e Assadeiras')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Esteiras:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...List.generate(quantidadeEsteiras, (index) {
              return _buildCard(
                title: 'Esteira ${index + 1}',
                tipo: tiposEsteiras[index],
                quantidade: quantidadesEsteiras[index],
                photoUrl: fotosEsteiras[index],
                uploadKey: 'esteira_$index',
                onTipoChanged: (v) {
                  setState(() => tiposEsteiras[index] = v ?? '');
                  _saveData();
                },
                onQtdChanged: (v) {
                  setState(() => quantidadesEsteiras[index] = v ?? 0);
                  _saveData();
                },
                onRemove: () => _removerEsteira(index),
                onPhotoTap: () => fotosEsteiras[index] == null
                    ? _selecionarFoto(true, index)
                    : _abrirMenuFoto(true, index),
              );
            }),
            Center(
              child: IconButton(
                icon:
                    const Icon(Icons.add_circle, size: 36, color: Colors.green),
                onPressed: _adicionarEsteira,
              ),
            ),
            const SizedBox(height: 30),
            const Text('Assadeiras:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...List.generate(quantidadeAssadeiras, (index) {
              return _buildCard(
                title: 'Assadeira ${index + 1}',
                tipo: tiposAssadeiras[index],
                quantidade: quantidadesAssadeiras[index],
                photoUrl: fotosAssadeiras[index],
                uploadKey: 'assadeira_$index',
                onTipoChanged: (v) {
                  setState(() => tiposAssadeiras[index] = v ?? '');
                  _saveData();
                },
                onQtdChanged: (v) {
                  setState(() => quantidadesAssadeiras[index] = v ?? 0);
                  _saveData();
                },
                onRemove: () => _removerAssadeira(index),
                onPhotoTap: () => fotosAssadeiras[index] == null
                    ? _selecionarFoto(false, index)
                    : _abrirMenuFoto(false, index),
              );
            }),
            Center(
              child: IconButton(
                icon:
                    const Icon(Icons.add_circle, size: 36, color: Colors.green),
                onPressed: _adicionarAssadeira,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Climatica extends StatefulWidget {
  final String storeName;
  const Climatica({super.key, required this.storeName});

  @override
  _ClimaticaState createState() => _ClimaticaState();
}

class _ClimaticaState extends State<Climatica> {
  int quantidadeClimaticas = 0;
  List<TextEditingController> modeloControllers = [];
  List<int> suportesClimatica = [];
  List<String?> fotosClimatica = [];

  // Mapa para controle de progresso
  Map<int, double> uploadProgress = {};

  final List<int> suportes = List.generate(40, (index) => index + 1);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    criarClimaticaControllers(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClimaticaData();
    });
  }

  @override
  void dispose() {
    for (var c in modeloControllers) c.dispose();
    super.dispose();
  }

  void criarClimaticaControllers(int quantidade) {
    for (var c in modeloControllers) c.dispose();
    modeloControllers =
        List.generate(quantidade, (_) => TextEditingController());
    suportesClimatica = List.generate(quantidade, (_) => 0);
    fotosClimatica = List.generate(quantidade, (_) => null);
  }

  // ===================== FOTO - COM PARÂMETROS IGUAIS =====================
  Future<void> _selecionarFoto(int index) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 70,
    );

    if (image == null) return;

    final ref = _storage.ref().child(
          'stores/${widget.storeName}/climaticas/climatica_$index.jpg',
        );

    UploadTask task;

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      task = ref.putData(bytes);
    } else {
      task = ref.putFile(File(image.path));
    }

    // ✅ BARRA DE PROGRESSO
    task.snapshotEvents.listen((event) {
      final progress = event.bytesTransferred / event.totalBytes;
      setState(() {
        uploadProgress[index] = progress;
      });
    });

    // ✅ UPLOAD EM BACKGROUND
    task.then((snapshot) async {
      final url = await snapshot.ref.getDownloadURL();
      setState(() {
        fotosClimatica[index] = url;
        uploadProgress.remove(index);
      });
      _saveClimaticaData();
    }).catchError((error) {
      print('Erro no upload: $error');
      setState(() {
        uploadProgress.remove(index);
      });
    });
  }

  Future<void> _excluirFoto(int index) async {
    final url = fotosClimatica[index];
    if (url == null) return;

    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {}

    setState(() => fotosClimatica[index] = null);
    _saveClimaticaData();
  }

  // ===================== VISUALIZAR FOTO =====================
  void _visualizarFoto(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // ===================== MENU FOTO =====================
  void _abrirMenuFoto(int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Visualizar'),
              onTap: () {
                Navigator.pop(context);
                final url = fotosClimatica[index];
                if (url != null) {
                  _visualizarFoto(url);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Trocar foto'),
              onTap: () {
                Navigator.pop(context);
                _selecionarFoto(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Excluir foto'),
              onTap: () {
                Navigator.pop(context);
                _excluirFoto(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===================== FIRESTORE =====================
  Future<void> _saveClimaticaData() async {
    List<Map<String, dynamic>> climaticaList = [];

    for (int i = 0; i < quantidadeClimaticas; i++) {
      climaticaList.add({
        'modelo': modeloControllers[i].text,
        'suportes': suportesClimatica[i],
        'photoUrl': fotosClimatica[i],
      });
    }

    await _firestore.collection('stores').doc(widget.storeName).set({
      'storeName': widget.storeName,
      'climaticas': climaticaList,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _loadClimaticaData() async {
    final doc =
        await _firestore.collection('stores').doc(widget.storeName).get();

    if (!doc.exists) return;

    final climaticas = doc.data()?['climaticas'] ?? [];

    setState(() {
      quantidadeClimaticas = climaticas.length;
      criarClimaticaControllers(quantidadeClimaticas);

      for (int i = 0; i < quantidadeClimaticas; i++) {
        modeloControllers[i].text = climaticas[i]['modelo'] ?? '';
        suportesClimatica[i] = climaticas[i]['suportes'] ?? 0;
        fotosClimatica[i] = climaticas[i]['photoUrl'];
      }
    });
  }

  void _adicionarClimatica() {
    setState(() {
      quantidadeClimaticas++;
      modeloControllers.add(TextEditingController());
      suportesClimatica.add(0);
      fotosClimatica.add(null);
    });
    _saveClimaticaData();
  }

  void _removerClimatica(int index) {
    setState(() {
      quantidadeClimaticas--;
      modeloControllers[index].dispose();
      modeloControllers.removeAt(index);
      suportesClimatica.removeAt(index);
      fotosClimatica.removeAt(index);
    });
    _saveClimaticaData();
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Climáticas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...List.generate(quantidadeClimaticas, (index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Climatica ${index + 1}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  fotosClimatica[index] == null
                                      ? Icons.add_a_photo
                                      : Icons.photo,
                                ),
                                onPressed: fotosClimatica[index] == null
                                    ? () => _selecionarFoto(index)
                                    : () => _abrirMenuFoto(index),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removerClimatica(index),
                              ),
                            ],
                          )
                        ],
                      ),

                      // ✅ BARRA DE PROGRESSO
                      if (uploadProgress.containsKey(index))
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: LinearProgressIndicator(
                            value: uploadProgress[index],
                          ),
                        ),

                      const SizedBox(height: 12),
                      TextField(
                        controller: modeloControllers[index],
                        decoration: const InputDecoration(labelText: 'Modelo'),
                        onChanged: (_) => _saveClimaticaData(),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        value: suportesClimatica[index] > 0
                            ? suportesClimatica[index]
                            : null,
                        items: suportes
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.toString()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            suportesClimatica[index] = value ?? 0;
                            _saveClimaticaData();
                          });
                        },
                        decoration: const InputDecoration(
                            labelText: 'Suportes',
                            border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
              );
            }),
            Center(
              child: IconButton(
                icon:
                    const Icon(Icons.add_circle, color: Colors.green, size: 36),
                onPressed: _adicionarClimatica,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Freezer extends StatefulWidget {
  final String storeName;
  const Freezer({super.key, required this.storeName});

  @override
  State<Freezer> createState() => _FreezerState();
}

class _FreezerState extends State<Freezer> {
  int quantidadeFreezers = 0;
  List<TextEditingController> modeloControllers = [];
  List<TextEditingController> volumeControllers = [];
  List<String> tiposFreezer = [];
  List<String?> fotosFreezer = [];

  // Mapa para controle de progresso
  Map<int, double> uploadProgress = {};

  final List<String> tipos = ['Vertical', 'Horizontal'];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    criarFreezerControllers(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFreezerData();
    });
  }

  @override
  void dispose() {
    for (var c in modeloControllers) c.dispose();
    for (var c in volumeControllers) c.dispose();
    super.dispose();
  }

  void criarFreezerControllers(int quantidade) {
    for (var c in modeloControllers) c.dispose();
    for (var c in volumeControllers) c.dispose();

    modeloControllers =
        List.generate(quantidade, (_) => TextEditingController());
    volumeControllers =
        List.generate(quantidade, (_) => TextEditingController());
    tiposFreezer = List.generate(quantidade, (_) => '');
    fotosFreezer = List.generate(quantidade, (_) => null);
  }

  // ===================== FOTO - COM PARÂMETROS IGUAIS =====================
  Future<void> _selecionarFoto(int index) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 70,
    );

    if (image == null) return;

    final ref = _storage.ref().child(
          'stores/${widget.storeName}/freezers/freezer_$index.jpg',
        );

    UploadTask task;

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      task = ref.putData(bytes);
    } else {
      task = ref.putFile(File(image.path));
    }

    // ✅ BARRA DE PROGRESSO
    task.snapshotEvents.listen((event) {
      final progress = event.bytesTransferred / event.totalBytes;
      setState(() {
        uploadProgress[index] = progress;
      });
    });

    // ✅ UPLOAD EM BACKGROUND
    task.then((snapshot) async {
      final url = await snapshot.ref.getDownloadURL();
      setState(() {
        fotosFreezer[index] = url;
        uploadProgress.remove(index);
      });
      _saveFreezerData();
    }).catchError((error) {
      print('Erro no upload: $error');
      setState(() {
        uploadProgress.remove(index);
      });
    });
  }

  Future<void> _excluirFoto(int index) async {
    final url = fotosFreezer[index];
    if (url == null) return;

    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {}

    setState(() => fotosFreezer[index] = null);
    _saveFreezerData();
  }

  // ===================== VISUALIZAR FOTO =====================
  void _visualizarFoto(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // ===================== MENU FOTO =====================
  void _abrirMenuFoto(int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Visualizar'),
              onTap: () {
                Navigator.pop(context);
                final url = fotosFreezer[index];
                if (url != null) {
                  _visualizarFoto(url);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Trocar foto'),
              onTap: () {
                Navigator.pop(context);
                _selecionarFoto(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Excluir foto'),
              onTap: () {
                Navigator.pop(context);
                _excluirFoto(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===================== FIRESTORE =====================
  Future<void> _saveFreezerData() async {
    List<Map<String, dynamic>> freezerList = [];

    for (int i = 0; i < quantidadeFreezers; i++) {
      freezerList.add({
        'modelo': modeloControllers[i].text,
        'volume': volumeControllers[i].text,
        'tipo': tiposFreezer[i],
        'photoUrl': fotosFreezer[i],
      });
    }

    await _firestore.collection('stores').doc(widget.storeName).set({
      'storeName': widget.storeName,
      'freezers': freezerList,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _loadFreezerData() async {
    final doc =
        await _firestore.collection('stores').doc(widget.storeName).get();

    if (!doc.exists) return;

    final freezers = doc.data()?['freezers'] ?? [];

    setState(() {
      quantidadeFreezers = freezers.length;
      criarFreezerControllers(quantidadeFreezers);

      for (int i = 0; i < quantidadeFreezers; i++) {
        modeloControllers[i].text = freezers[i]['modelo'] ?? '';
        volumeControllers[i].text = freezers[i]['volume'] ?? '';
        tiposFreezer[i] = freezers[i]['tipo'] ?? '';
        fotosFreezer[i] = freezers[i]['photoUrl'];
      }
    });
  }

  void _adicionarFreezer() {
    setState(() {
      quantidadeFreezers++;
      modeloControllers.add(TextEditingController());
      volumeControllers.add(TextEditingController());
      tiposFreezer.add('');
      fotosFreezer.add(null);
    });
    _saveFreezerData();
  }

  void _removerFreezer(int index) {
    setState(() {
      quantidadeFreezers--;
      modeloControllers[index].dispose();
      volumeControllers[index].dispose();
      modeloControllers.removeAt(index);
      volumeControllers.removeAt(index);
      tiposFreezer.removeAt(index);
      fotosFreezer.removeAt(index);
    });
    _saveFreezerData();
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conservadores')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...List.generate(quantidadeFreezers, (index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Conservador ${index + 1}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  fotosFreezer[index] == null
                                      ? Icons.add_a_photo
                                      : Icons.photo,
                                ),
                                onPressed: fotosFreezer[index] == null
                                    ? () => _selecionarFoto(index)
                                    : () => _abrirMenuFoto(index),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removerFreezer(index),
                              ),
                            ],
                          )
                        ],
                      ),

                      // ✅ BARRA DE PROGRESSO
                      if (uploadProgress.containsKey(index))
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: LinearProgressIndicator(
                            value: uploadProgress[index],
                          ),
                        ),

                      const SizedBox(height: 12),
                      TextField(
                        controller: modeloControllers[index],
                        decoration: const InputDecoration(
                            labelText: 'Modelo', border: OutlineInputBorder()),
                        onChanged: (_) => _saveFreezerData(),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: volumeControllers[index],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Volume (litros)',
                            border: OutlineInputBorder()),
                        onChanged: (_) => _saveFreezerData(),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: tiposFreezer[index].isNotEmpty
                            ? tiposFreezer[index]
                            : null,
                        items: tipos
                            .map((tipo) => DropdownMenuItem(
                                value: tipo, child: Text(tipo)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            tiposFreezer[index] = value ?? '';
                            _saveFreezerData();
                          });
                        },
                        decoration: const InputDecoration(
                            labelText: 'Tipo', border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
              );
            }),
            Center(
              child: IconButton(
                icon:
                    const Icon(Icons.add_circle, size: 36, color: Colors.green),
                onPressed: _adicionarFreezer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResumoEquipamentos extends StatefulWidget {
  final String storeName;
  const ResumoEquipamentos({super.key, required this.storeName});

  @override
  State<ResumoEquipamentos> createState() => _ResumoEquipamentosState();
}

class _ResumoEquipamentosState extends State<ResumoEquipamentos> {
  Map<String, dynamic> dadosResumo = {};
  bool isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _carregarTodosDados();
  }

  Future<void> _carregarTodosDados() async {
    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();
      if (doc.exists) {
        final data = doc.data() ?? {};

        if (mounted) {
          setState(() {
            dadosResumo = {
              'fornos': data['fornos'] ?? [],
              'armarios': data['armarios'] ?? [],
              'esqueletos': data['esqueletos'] ?? [],
              'esteiras': data['esteiras'] ?? [],
              'assadeiras': data['assadeiras'] ?? [],
              'climaticas': data['climaticas'] ?? [],
              'freezers': data['freezers'] ?? [],
            };
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<Uint8List> _gerarPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) {
          final List<pw.Widget> widgets = [];

          widgets.add(
            pw.Center(
              child: pw.Text(
                'Inventário de Equipamentos - ${widget.storeName}',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
            ),
          );
          widgets.add(pw.SizedBox(height: 20));

          void addSection(
              String title, List lista, String Function(int, Map) fn) {
            if (lista.isEmpty) return;

            widgets.add(
              pw.Text(
                title,
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            );

            for (int i = 0; i < lista.length; i++) {
              final item = lista[i];
              widgets.add(
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Bullet(text: fn(i, item)),
                    if (item['photoUrl'] != null)
                      pw.UrlLink(
                        destination: item['photoUrl'],
                        child: pw.Text(
                          'Ver foto',
                          style: pw.TextStyle(
                            color: PdfColors.blue,
                            decoration: pw.TextDecoration.underline,
                          ),
                        ),
                      ),
                    pw.SizedBox(height: 4),
                  ],
                ),
              );
            }

            widgets.add(pw.SizedBox(height: 10));
          }

          addSection(
            'Fornos:',
            dadosResumo['fornos'],
            (i, f) =>
                'Forno ${i + 1} - Modelo: ${f['modelo'] ?? 'N/I'}, Tipo: ${f['tipo'] ?? 'N/I'}, Suportes: ${f['suportes'] ?? 0}',
          );

          addSection(
            'Armários:',
            dadosResumo['armarios'],
            (i, a) =>
                'Armário ${i + 1} - Tipo: ${a['tipo'] ?? 'N/I'}, Suportes: ${a['suportes'] ?? 0}',
          );

          addSection(
            'Esqueletos:',
            dadosResumo['esqueletos'],
            (i, e) =>
                'Esqueleto ${i + 1} - Tipo: ${e['tipo'] ?? 'N/I'}, Suportes: ${e['suportes'] ?? 0}',
          );

          addSection(
            'Esteiras:',
            dadosResumo['esteiras'],
            (i, e) =>
                'Esteira ${i + 1} - Tipo: ${e['tipo'] ?? 'N/I'}, Quantidade: ${e['quantidade'] ?? 0}',
          );

          addSection(
            'Assadeiras:',
            dadosResumo['assadeiras'],
            (i, a) =>
                'Assadeira ${i + 1} - Tipo: ${a['tipo'] ?? 'N/I'}, Quantidade: ${a['quantidade'] ?? 0}',
          );

          addSection(
            'Climáticas:',
            dadosResumo['climaticas'],
            (i, c) =>
                'Climática ${i + 1} - Modelo: ${c['modelo'] ?? 'N/I'}, Suportes: ${c['suportes'] ?? 0}',
          );

          addSection(
            'Conservadores:',
            dadosResumo['freezers'],
            (i, f) =>
                'Conservador ${i + 1} - Modelo: ${f['modelo'] ?? 'N/I'}, Volume: ${f['volume'] ?? 'N/I'}L, Tipo: ${f['tipo'] ?? 'N/I'}',
          );

          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _compartilharPdf() async {
    final pdfBytes = await _gerarPdf();
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: "Inventário Equipamentos_${widget.storeName}.pdf",
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(String title, String subtitle, {String? photoUrl}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[50],
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (photoUrl != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(),
                        body: Center(
                          child: InteractiveViewer(
                            child: CachedNetworkImage(
                              imageUrl: photoUrl,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: photoUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.white70),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
            if (photoUrl != null) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> buildItems(
      String key, String Function(Map) detailsFn) {
    final list = dadosResumo[key] ?? [];
    return List<Map<String, dynamic>>.from(list.map((item) => {
          'nome': (item['modelo'] != null &&
                  item['modelo'].toString().trim().isNotEmpty)
              ? item['modelo']
              : (item['tipo'] != null &&
                      item['tipo'].toString().trim().isNotEmpty)
                  ? item['tipo']
                  : 'Não informado',
          'detalhes': detailsFn(item),
          'photoUrl': item['photoUrl'],
        }));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final hasData = dadosResumo.isNotEmpty &&
        dadosResumo.values.any((value) => value != null && value.isNotEmpty);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventário'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _compartilharPdf,
          ),
        ],
      ),
      body: !hasData
          ? const Center(
              child: Text('Nenhum dado cadastrado',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dadosResumo['fornos'] != null &&
                      dadosResumo['fornos'].isNotEmpty)
                    _buildSection(
                      'Fornos (${dadosResumo['fornos'].length})',
                      buildItems(
                              'fornos',
                              (item) =>
                                  'Modelo: ${item['modelo'] ?? 'N/I'}, Tipo: ${item['tipo'] ?? 'N/I'}, Suportes: ${item['suportes'] ?? 0}')
                          .map((e) => _buildItemCard(e['nome'], e['detalhes'],
                              photoUrl: e['photoUrl']))
                          .toList(),
                    ),
                  if (dadosResumo['armarios'] != null &&
                      dadosResumo['armarios'].isNotEmpty)
                    _buildSection(
                      'Armários (${dadosResumo['armarios'].length})',
                      buildItems(
                              'armarios',
                              (item) =>
                                  'Tipo: ${item['tipo'] ?? 'N/I'}, Suportes: ${item['suportes'] ?? 0}')
                          .map((e) => _buildItemCard(e['nome'], e['detalhes'],
                              photoUrl: e['photoUrl']))
                          .toList(),
                    ),
                  if (dadosResumo['esqueletos'] != null &&
                      dadosResumo['esqueletos'].isNotEmpty)
                    _buildSection(
                      'Esqueletos (${dadosResumo['esqueletos'].length})',
                      buildItems(
                              'esqueletos',
                              (item) =>
                                  'Tipo: ${item['tipo'] ?? 'N/I'}, Suportes: ${item['suportes'] ?? 0}')
                          .map((e) => _buildItemCard(e['nome'], e['detalhes'],
                              photoUrl: e['photoUrl']))
                          .toList(),
                    ),
                  if (dadosResumo['esteiras'] != null &&
                      (dadosResumo['esteiras'] as List).isNotEmpty)
                    _buildSection(
                      'Esteiras (${dadosResumo['esteiras'].length})',
                      buildItems(
                              'esteiras',
                              (item) =>
                                  'Tipo: ${item['tipo'] ?? 'N/I'}, Quantidade: ${item['quantidade'] ?? 0}')
                          .map((e) => _buildItemCard(e['nome'], e['detalhes'],
                              photoUrl: e['photoUrl']))
                          .toList(),
                    ),
                  if (dadosResumo['assadeiras'] != null &&
                      (dadosResumo['assadeiras'] as List).isNotEmpty)
                    _buildSection(
                      'Assadeiras (${dadosResumo['assadeiras'].length})',
                      buildItems(
                              'assadeiras',
                              (item) =>
                                  'Tipo: ${item['tipo'] ?? 'N/I'}, Quantidade: ${item['quantidade'] ?? 0}')
                          .map((e) => _buildItemCard(e['nome'], e['detalhes'],
                              photoUrl: e['photoUrl']))
                          .toList(),
                    ),
                  if (dadosResumo['climaticas'] != null &&
                      dadosResumo['climaticas'].isNotEmpty)
                    _buildSection(
                      'Climáticas (${dadosResumo['climaticas'].length})',
                      buildItems(
                              'climaticas',
                              (item) =>
                                  'Modelo: ${item['modelo'] ?? 'N/I'}, Suportes: ${item['suportes'] ?? 0}')
                          .map((e) => _buildItemCard(e['nome'], e['detalhes'],
                              photoUrl: e['photoUrl']))
                          .toList(),
                    ),
                  if (dadosResumo['freezers'] != null &&
                      dadosResumo['freezers'].isNotEmpty)
                    _buildSection(
                      'Conservadores (${dadosResumo['freezers'].length})',
                      buildItems(
                              'freezers',
                              (item) =>
                                  'Modelo: ${item['modelo'] ?? 'N/I'}, Volume: ${item['volume'] ?? 'N/I'}L, Tipo: ${item['tipo'] ?? 'N/I'}')
                          .map((e) => _buildItemCard(e['nome'], e['detalhes'],
                              photoUrl: e['photoUrl']))
                          .toList(),
                    ),
                ],
              ),
            ),
    );
  }
}

class Limpeza extends StatelessWidget {
  const Limpeza({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0x97095195),
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/Logo StockOne.png', height: 32),
              const SizedBox(width: 8),
              const Text(
                "LIMPEZA",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lora',
                  color: Colors.white,
                ),
              ),
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0x97095195),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    textStyle: const TextStyle(fontSize: 19),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const fornos()),
                    );
                  },
                  child: const Text(
                    'Fornos',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0x97095195),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    textStyle: const TextStyle(fontSize: 19),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const armarios()),
                    );
                  },
                  child: const Text(
                    'Armários e Esqueletos',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0x97095195),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    textStyle: const TextStyle(fontSize: 19),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const climatica()),
                    );
                  },
                  child: const Text(
                    'Climática',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0x97095195),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    textStyle: const TextStyle(fontSize: 19),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const freezers()),
                    );
                  },
                  child: const Text(
                    'Conservadores',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0x97095195),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    textStyle: const TextStyle(fontSize: 19),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const latas()),
                    );
                  },
                  child: const Text(
                    'Assadeiras',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class fornos extends StatelessWidget {
  const fornos({super.key});

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
                'assets/images/fornos.jpg',
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

class armarios extends StatelessWidget {
  const armarios({super.key});

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
                'assets/images/armarios.jpg',
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

class climatica extends StatelessWidget {
  const climatica({super.key});

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
                'assets/images/climatica.jpg',
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

class freezers extends StatelessWidget {
  const freezers({super.key});

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
                'assets/images/freezers.jpg',
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

class latas extends StatelessWidget {
  const latas({super.key});

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
                'assets/images/latas.jpg',
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

class Comodatos extends StatefulWidget {
  const Comodatos({super.key});

  @override
  State<Comodatos> createState() => _ComodatosState();
}

class _ComodatosState extends State<Comodatos> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _storeKeys = {};

  bool isLoading = true;
  List<Map<String, dynamic>> lojasResumo = [];

  @override
  void initState() {
    super.initState();
    _carregarTodosDados();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _numeroLoja(String nome) {
    final match = RegExp(r'\d+').firstMatch(nome);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  Future<void> _carregarTodosDados() async {
    try {
      final snapshot = await _firestore.collection('stores').get();
      final List<Map<String, dynamic>> temp = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        temp.add({
          'storeName': doc.id,
          'dados': {
            'fornos': data['fornos'] ?? [],
            'armarios': data['armarios'] ?? [],
            'esqueletos': data['esqueletos'] ?? [],
            'esteiras': data['esteiras'] ?? [],
            'assadeiras': data['assadeiras'] ?? [],
            'climaticas': data['climaticas'] ?? [],
            'freezers': data['freezers'] ?? [],
          }
        });
      }

      temp.sort(
        (a, b) =>
            _numeroLoja(a['storeName']).compareTo(_numeroLoja(b['storeName'])),
      );

      if (mounted) {
        setState(() {
          lojasResumo = temp;
          isLoading = false;
          for (int i = 0; i < lojasResumo.length; i++) {
            _storeKeys[i] = GlobalKey();
          }
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ===================== PDF =====================
  Future<Uint8List> _gerarPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) {
          final List<pw.Widget> widgets = [];

          for (final loja in lojasResumo) {
            final dadosResumo = loja['dados'];

            widgets.add(
              pw.Center(
                child: pw.Text(
                  'Comodatos - ${loja['storeName']}',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            );

            widgets.add(pw.SizedBox(height: 20));

            void addSection(
                String title, List lista, String Function(int, Map) fn) {
              if (lista.isEmpty) return;

              widgets.add(
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              );

              for (int i = 0; i < lista.length; i++) {
                final item = lista[i];
                widgets.add(
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Bullet(text: fn(i, item)),
                      if (item['photoUrl'] != null)
                        pw.Text(
                          'Foto disponível: ${item['photoUrl']}',
                          style: pw.TextStyle(color: PdfColors.blue),
                        ),
                      pw.SizedBox(height: 4),
                    ],
                  ),
                );
              }

              widgets.add(pw.SizedBox(height: 12));
            }

            addSection(
              'Fornos:',
              dadosResumo['fornos'],
              (i, f) =>
                  'Forno ${i + 1} - Modelo: ${f['modelo'] ?? 'N/I'}, Tipo: ${f['tipo'] ?? 'N/I'}, Suportes: ${f['suportes'] ?? 0}',
            );

            addSection(
              'Armários:',
              dadosResumo['armarios'],
              (i, a) =>
                  'Armário ${i + 1} - Tipo: ${a['tipo'] ?? 'N/I'}, Suportes: ${a['suportes'] ?? 0}',
            );

            addSection(
              'Esqueletos:',
              dadosResumo['esqueletos'],
              (i, e) =>
                  'Esqueleto ${i + 1} - Tipo: ${e['tipo'] ?? 'N/I'}, Suportes: ${e['suportes'] ?? 0}',
            );

            addSection(
              'Esteiras:',
              dadosResumo['esteiras'],
              (i, e) =>
                  'Esteira ${i + 1} - Tipo: ${e['tipo'] ?? 'N/I'}, Quantidade: ${e['quantidade'] ?? 0}',
            );

            addSection(
              'Assadeiras:',
              dadosResumo['assadeiras'],
              (i, a) =>
                  'Assadeira ${i + 1} - Tipo: ${a['tipo'] ?? 'N/I'}, Quantidade: ${a['quantidade'] ?? 0}',
            );

            addSection(
              'Climáticas:',
              dadosResumo['climaticas'],
              (i, c) =>
                  'Climática ${i + 1} - Modelo: ${c['modelo'] ?? 'N/I'}, Suportes: ${c['suportes'] ?? 0}',
            );

            addSection(
              'Conservadores:',
              dadosResumo['freezers'],
              (i, f) =>
                  'Conservador ${i + 1} - Modelo: ${f['modelo'] ?? 'N/I'}, Volume: ${f['volume'] ?? 'N/I'}L, Tipo: ${f['tipo'] ?? 'N/I'}',
            );

            widgets.add(pw.SizedBox(height: 30));
          }

          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _compartilharPdf() async {
    final bytes = await _gerarPdf();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Comodatos_Bahamas.pdf',
    );
  }

  // ===================== UI =====================
  Widget _buildSection(String title, List<Widget> children) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(String title, String subtitle, {String? photoUrl}) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: Colors.grey[50],
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (photoUrl != null)
                GestureDetector(
                  onTap: () => _abrirFoto(photoUrl),
                  child: CachedNetworkImage(
                    imageUrl: photoUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.white70),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
              if (photoUrl != null) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style:
                            TextStyle(color: Colors.grey[700], fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirFoto(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text('Foto'),
            actions: [
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () async {
                  if (kIsWeb) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Download Web não implementado. Use mobile para salvar.'),
                      ),
                    );
                  } else {
                    await _baixarImagemLocal(url);
                  }
                },
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: url,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _baixarImagemLocal(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download iniciado')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível iniciar o download')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao baixar imagem')),
      );
    }
  }

  void _scrollToStore(int index) {
    if (_storeKeys.containsKey(index)) {
      final keyContext = _storeKeys[index]!.currentContext;
      if (keyContext != null) {
        Scrollable.ensureVisible(
          keyContext,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comodatos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              icon: const Icon(Icons.share), onPressed: _compartilharPdf),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(24, 24, 48, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(lojasResumo.length, (i) {
                final loja = lojasResumo[i];
                final dadosResumo = loja['dados'];
                return Container(
                  key: _storeKeys[i],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        loja['storeName'],
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (dadosResumo['fornos'].isNotEmpty)
                        _buildSection(
                          'Fornos (${dadosResumo['fornos'].length})',
                          List.generate(dadosResumo['fornos'].length, (j) {
                            final f = dadosResumo['fornos'][j];
                            return _buildItemCard(
                              'Forno ${j + 1}',
                              'Modelo: ${f['modelo']}, Tipo: ${f['tipo']}, Suportes: ${f['suportes']}',
                              photoUrl: f['photoUrl'],
                            );
                          }),
                        ),
                      if (dadosResumo['armarios'].isNotEmpty)
                        _buildSection(
                          'Armários (${dadosResumo['armarios'].length})',
                          List.generate(dadosResumo['armarios'].length, (j) {
                            final a = dadosResumo['armarios'][j];
                            return _buildItemCard(
                              'Armário ${j + 1}',
                              'Tipo: ${a['tipo']}, Suportes: ${a['suportes']}',
                              photoUrl: a['photoUrl'],
                            );
                          }),
                        ),
                      if (dadosResumo['esqueletos'].isNotEmpty)
                        _buildSection(
                          'Esqueletos (${dadosResumo['esqueletos'].length})',
                          List.generate(dadosResumo['esqueletos'].length, (j) {
                            final e = dadosResumo['esqueletos'][j];
                            return _buildItemCard(
                              'Esqueleto ${j + 1}',
                              'Tipo: ${e['tipo']}, Suportes: ${e['suportes']}',
                              photoUrl: e['photoUrl'],
                            );
                          }),
                        ),
                      if (dadosResumo['esteiras'].isNotEmpty)
                        _buildSection(
                          'Esteiras (${dadosResumo['esteiras'].length})',
                          List.generate(dadosResumo['esteiras'].length, (j) {
                            final e = dadosResumo['esteiras'][j];
                            return _buildItemCard(
                              'Esteira ${j + 1}',
                              'Tipo: ${e['tipo']}, Quantidade: ${e['quantidade']}',
                              photoUrl: e['photoUrl'],
                            );
                          }),
                        ),
                      if (dadosResumo['assadeiras'].isNotEmpty)
                        _buildSection(
                          'Assadeiras (${dadosResumo['assadeiras'].length})',
                          List.generate(dadosResumo['assadeiras'].length, (j) {
                            final a = dadosResumo['assadeiras'][j];
                            return _buildItemCard(
                              'Assadeira ${j + 1}',
                              'Tipo: ${a['tipo']}, Quantidade: ${a['quantidade']}',
                              photoUrl: a['photoUrl'],
                            );
                          }),
                        ),
                      if (dadosResumo['climaticas'].isNotEmpty)
                        _buildSection(
                          'Climáticas (${dadosResumo['climaticas'].length})',
                          List.generate(dadosResumo['climaticas'].length, (j) {
                            final c = dadosResumo['climaticas'][j];
                            return _buildItemCard(
                              'Climática ${j + 1}',
                              'Modelo: ${c['modelo']}, Suportes: ${c['suportes']}',
                              photoUrl: c['photoUrl'],
                            );
                          }),
                        ),
                      if (dadosResumo['freezers'].isNotEmpty)
                        _buildSection(
                          'Conservadores (${dadosResumo['freezers'].length})',
                          List.generate(dadosResumo['freezers'].length, (j) {
                            final f = dadosResumo['freezers'][j];
                            return _buildItemCard(
                              'Conservador ${j + 1}',
                              'Modelo: ${f['modelo']}, Volume: ${f['volume']}L, Tipo: ${f['tipo']}',
                              photoUrl: f['photoUrl'],
                            );
                          }),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              }),
            ),
          ),
          Positioned(
            right: 0,
            top: 24,
            bottom: 24,
            child: Container(
              width: 40,
              color: Colors.transparent,
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(100, (i) {
                    return GestureDetector(
                      onTap: () {
                        final lojaIndex =
                            ((i / 100) * lojasResumo.length).floor();
                        _scrollToStore(
                            lojaIndex.clamp(0, lojasResumo.length - 1));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Martminas extends StatelessWidget {
  const Martminas({super.key});

  // 🔹 Card estilo Android
  Widget _menuCard(
    BuildContext context,
    IconData icon, // novo parâmetro
    String label,
    Widget destination,
    Color color,
  ) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.brown.withOpacity(0.3),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: const Color(0xFF5D4037),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Roboto',
                  color: Color(0xFF5D4037),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Botão físico de voltar: fecha o app ou navega para outra tela se quiser
        return true; // true permite o comportamento padrão (fecha o app)
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFD2691E),
          centerTitle: true,
          automaticallyImplyLeading:
              false, // se quiser ícone custom, use leading
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RedeScreen()),
              ); // volta para a tela anterior
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/Logo StockOne.png', height: 32),
              const SizedBox(width: 8),
              Image.asset(
                'assets/images/martminas2.jpg',
                height: 40,
              ), // imagem no lugar do texto
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
                Color(0xFFD29752), // base marrom padaria
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 1, // 1 card por linha
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 3,
              children: [
                _menuCard(
                  context,
                  Icons.menu_book,
                  'COMODATOS',
                  Comodatosmm(),
                  Colors.white,
                ),
                _menuCard(
                  context,
                  Icons.menu_book,
                  'ATENDIMENTO',
                  StoreSelectionMM(),
                  Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Comodatosmm extends StatefulWidget {
  const Comodatosmm({super.key});

  @override
  State<Comodatosmm> createState() => _ComodatosmmState();
}

class _ComodatosmmState extends State<Comodatosmm> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _storeKeys = {};

  bool isLoading = true;
  List<Map<String, dynamic>> lojasResumo = [];

  @override
  void initState() {
    super.initState();
    _carregarTodosDados();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _numeroLoja(String nome) {
    final match = RegExp(r'\d+').firstMatch(nome);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  Future<void> _carregarTodosDados() async {
    try {
      final snapshot = await _firestore.collection('storesmm').get();
      final List<Map<String, dynamic>> temp = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        temp.add({
          'storeId': doc.id,
          'storeName': data['storeName'] ?? doc.id,
          'dados': {
            'fornos': data['fornos'] ?? [],
            'armarios': data['armarios'] ?? [],
            'esqueletos': data['esqueletos'] ?? [],
            'esteiras': data['esteiras'] ?? [],
            'assadeiras': data['assadeiras'] ?? [],
            'climaticas': data['climaticas'] ?? [],
            'freezers': data['freezers'] ?? [],
          },
        });
      }

      temp.sort(
        (a, b) =>
            _numeroLoja(a['storeName']).compareTo(_numeroLoja(b['storeName'])),
      );

      if (mounted) {
        setState(() {
          lojasResumo = temp;
          isLoading = false;
          _storeKeys.clear();
          for (int i = 0; i < lojasResumo.length; i++) {
            _storeKeys[i] = GlobalKey();
          }
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados MM: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ===================== PDF =====================
  Future<Uint8List> _gerarPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) {
          final List<pw.Widget> widgets = [];

          for (final loja in lojasResumo) {
            final dadosResumo = loja['dados'];

            widgets.add(
              pw.Center(
                child: pw.Text(
                  'Comodatos - ${loja['storeName']}',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            );

            widgets.add(pw.SizedBox(height: 20));

            void addSection(
                String title, List lista, String Function(int, Map) fn) {
              if (lista.isEmpty) return;

              widgets.add(
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              );

              for (int i = 0; i < lista.length; i++) {
                final item = lista[i];
                widgets.add(
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Bullet(text: fn(i, item)),
                      if (item['photoUrl'] != null)
                        pw.Text('Foto disponível',
                            style: pw.TextStyle(color: PdfColors.blue)),
                      pw.SizedBox(height: 4),
                    ],
                  ),
                );
              }

              widgets.add(pw.SizedBox(height: 12));
            }

            addSection(
              'Fornos:',
              dadosResumo['fornos'],
              (i, f) =>
                  'Forno ${i + 1} - Modelo: ${f['modelo'] ?? 'N/I'}, Tipo: ${f['tipo'] ?? 'N/I'}, Suportes: ${f['suportes'] ?? 0}',
            );

            addSection(
              'Armários:',
              dadosResumo['armarios'],
              (i, a) =>
                  'Armário ${i + 1} - Tipo: ${a['tipo'] ?? 'N/I'}, Suportes: ${a['suportes'] ?? 0}',
            );

            addSection(
              'Esqueletos:',
              dadosResumo['esqueletos'],
              (i, e) =>
                  'Esqueleto ${i + 1} - Tipo: ${e['tipo'] ?? 'N/I'}, Suportes: ${e['suportes'] ?? 0}',
            );

            addSection(
              'Esteiras:',
              dadosResumo['esteiras'],
              (i, e) =>
                  'Esteira ${i + 1} - Tipo: ${e['tipo'] ?? 'N/I'}, Quantidade: ${e['quantidade'] ?? 0}',
            );

            addSection(
              'Assadeiras:',
              dadosResumo['assadeiras'],
              (i, a) =>
                  'Assadeira ${i + 1} - Tipo: ${a['tipo'] ?? 'N/I'}, Quantidade: ${a['quantidade'] ?? 0}',
            );

            addSection(
              'Climáticas:',
              dadosResumo['climaticas'],
              (i, c) =>
                  'Climática ${i + 1} - Modelo: ${c['modelo'] ?? 'N/I'}, Suportes: ${c['suportes'] ?? 0}',
            );

            addSection(
              'Conservadores:',
              dadosResumo['freezers'],
              (i, f) =>
                  'Conservador ${i + 1} - Modelo: ${f['modelo'] ?? 'N/I'}, Volume: ${f['volume'] ?? 'N/I'}L, Tipo: ${f['tipo'] ?? 'N/I'}',
            );

            widgets.add(pw.SizedBox(height: 30));
          }

          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _compartilharPdf() async {
    final bytes = await _gerarPdf();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Comodatos_MartMinas.pdf',
    );
  }

  // ===================== Download Mobile =====================
  Future<void> _baixarImagemLocal(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download iniciado')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível iniciar o download')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao baixar imagem')),
      );
    }
  }

  // ===================== Item Card =====================
  Widget _buildItemCard(String title, String subtitle, {String? photoUrl}) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: Colors.grey[50],
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (photoUrl != null)
                GestureDetector(
                  onTap: () => _abrirFoto(photoUrl),
                  child: CachedNetworkImage(
                    imageUrl: photoUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.white70),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
              if (photoUrl != null) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style:
                            TextStyle(color: Colors.grey[700], fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== Abrir Foto =====================
  void _abrirFoto(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text('Foto'),
            actions: [
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () async {
                  if (!kIsWeb) {
                    await _baixarImagemLocal(url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Download de imagens Web não implementado'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: url,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===================== Scroll =====================
  void _scrollToStore(int index) {
    if (_storeKeys.containsKey(index)) {
      final keyContext = _storeKeys[index]!.currentContext;
      if (keyContext != null) {
        Scrollable.ensureVisible(
          keyContext,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  // ===================== Build =====================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comodatos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              icon: const Icon(Icons.share), onPressed: _compartilharPdf),
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(24, 24, 48, 24),
        itemCount: lojasResumo.length,
        itemBuilder: (context, i) {
          final loja = lojasResumo[i];
          final dadosResumo = loja['dados'];

          return Container(
            key: _storeKeys[i],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  loja['storeName'],
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (dadosResumo['fornos'].isNotEmpty)
                  _buildItemSection(
                      'Fornos',
                      dadosResumo['fornos'],
                      (j, f) =>
                          'Modelo: ${f['modelo']}, Tipo: ${f['tipo']}, Suportes: ${f['suportes']}'),
                if (dadosResumo['armarios'].isNotEmpty)
                  _buildItemSection(
                      'Armários',
                      dadosResumo['armarios'],
                      (j, a) =>
                          'Tipo: ${a['tipo']}, Suportes: ${a['suportes']}'),
                if (dadosResumo['esqueletos'].isNotEmpty)
                  _buildItemSection(
                      'Esqueletos',
                      dadosResumo['esqueletos'],
                      (j, e) =>
                          'Tipo: ${e['tipo']}, Suportes: ${e['suportes']}'),
                if (dadosResumo['esteiras'].isNotEmpty)
                  _buildItemSection(
                      'Esteiras',
                      dadosResumo['esteiras'],
                      (j, e) =>
                          'Tipo: ${e['tipo']}, Quantidade: ${e['quantidade']}'),
                if (dadosResumo['assadeiras'].isNotEmpty)
                  _buildItemSection(
                      'Assadeiras',
                      dadosResumo['assadeiras'],
                      (j, a) =>
                          'Tipo: ${a['tipo']}, Quantidade: ${a['quantidade']}'),
                if (dadosResumo['climaticas'].isNotEmpty)
                  _buildItemSection(
                      'Climáticas',
                      dadosResumo['climaticas'],
                      (j, c) =>
                          'Modelo: ${c['modelo']}, Suportes: ${c['suportes']}'),
                if (dadosResumo['freezers'].isNotEmpty)
                  _buildItemSection(
                      'Conservadores',
                      dadosResumo['freezers'],
                      (j, f) =>
                          'Modelo: ${f['modelo']}, Volume: ${f['volume']}L, Tipo: ${f['tipo']}'),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper para gerar seções rapidamente
  Widget _buildItemSection(
      String title, List items, String Function(int, Map) subtitleFn) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, j) {
                  final item = items[j];
                  return _buildItemCard('$title ${j + 1}', subtitleFn(j, item),
                      photoUrl: item['photoUrl']);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StoreSelectionMM extends StatefulWidget {
  const StoreSelectionMM({Key? key}) : super(key: key);

  @override
  _StoreSelectionMMState createState() => _StoreSelectionMMState();
}

class _StoreSelectionMMState extends State<StoreSelectionMM> {
  final List<Map<String, String>> stores = [
    {'id': 'leopoldina', 'name': 'Leopoldina'},
    {'id': 'juiz_fora_jk', 'name': 'Juiz de Fora JK'},
    {'id': 'juiz_fora_st', 'name': 'Juiz de Fora ST'},
  ];

  List<String> favoriteStores = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteStores = prefs.getStringList('favoriteStores') ?? [];
    });
  }

  Future<void> _toggleFavorite(String storeId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoriteStores.contains(storeId)) {
        favoriteStores.remove(storeId);
      } else {
        favoriteStores.add(storeId);
      }
    });
    await prefs.setStringList('favoriteStores', favoriteStores);
  }

  Future<void> _onStoreSelected(
    BuildContext context,
    String storeId,
    String storeName,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('selectedStoreId', storeId);
    await prefs.setString('selectedStoreName', storeName);

    final storeRef = _firestore.collection('storesmm').doc(storeId);

    final doc = await storeRef.get();
    if (!doc.exists) {
      await storeRef.set({
        'storeId': storeId,
        'storeName': storeName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TelaPrincipal(
          storeId: storeId,
          storeName: storeName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedStores = [
      ...stores.where((s) => favoriteStores.contains(s['id']!)),
      ...stores.where((s) => !favoriteStores.contains(s['id']!)),
    ];

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Martminas()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey.shade700,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => Martminas()),
              );
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/Logo StockOne.png', height: 32),
              const SizedBox(width: 8),
              const Text(
                "ATENDIMENTO",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lora',
                ),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEFEFEF), Color(0xFFFDFDFD)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  "SELECIONE A LOJA:",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown,
                    fontFamily: 'Lora',
                  ),
                ),
                const SizedBox(height: 30),
                ...sortedStores.map((store) {
                  final storeId = store['id']!;
                  final storeName = store['name']!;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.store),
                            label: Text(storeName),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown.shade300,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            onPressed: () => _onStoreSelected(
                              context,
                              storeId,
                              storeName,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            favoriteStores.contains(storeId)
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () => _toggleFavorite(storeId),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  final String storeId;
  final String storeName;

  const TelaPrincipal({
    Key? key,
    required this.storeId,
    required this.storeName,
  }) : super(key: key);

  @override
  _TelaPrincipalState createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const StoreSelectionMM()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8F0),
        appBar: AppBar(
          backgroundColor: const Color(0xFFD2691E),
          elevation: 4,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const StoreSelectionMM()),
                (route) => false,
              );
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/StockOnesf.png', height: 50),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFE5B4),
                Color(0xFFD29752),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  widget.storeName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      _padariaCard(
                        Icons.kitchen,
                        "Equipamentos",
                        Colors.brown.shade400,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EquipamentosMM(
                                storeId: widget.storeId,
                                storeName: widget.storeName,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _padariaCard(
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withOpacity(0.3),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                  color: Color(0xFF5D4037),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EquipamentosMM extends StatelessWidget {
  final String storeId;
  final String storeName;

  const EquipamentosMM({
    Key? key,
    required this.storeId,
    required this.storeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0x76153555),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/Logo StockOne.png', height: 32),
            const SizedBox(width: 8),
            const Text(
              "EQUIPAMENTOS",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lora',
                color: Colors.white,
              ),
            ),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// 🔹 CADASTRO
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0x76153555),
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 38,
                  ),
                  textStyle: const TextStyle(fontSize: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CadastroMM(
                        storeId: storeId,
                        storeName: storeName,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.person_add,
                  size: 26,
                  color: Colors.white,
                ),
                label: const Text(
                  'Cadastro',
                  style: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 24),

              /// 🔹 LIMPEZA
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0x97095195),
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 38,
                  ),
                  textStyle: const TextStyle(fontSize: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Limpeza()),
                  );
                },
                icon: const Icon(
                  Icons.cleaning_services,
                  size: 26,
                  color: Colors.white,
                ),
                label: const Text(
                  'Limpeza',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CadastroMM extends StatelessWidget {
  final String storeId;
  final String storeName;

  const CadastroMM({
    Key? key,
    required this.storeId,
    required this.storeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0x76153555),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/Logo StockOne.png', height: 32),
            const SizedBox(width: 8),
            const Text(
              "CADASTRO",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lora',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFE5B4),
              Color(0xFFD29752),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _botao(
                'Fornos',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FornoMM(
                      storeId: storeId,
                      storeName: storeName,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _botao(
                'Climática',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClimaticaMM(
                      storeId: storeId,
                      storeName: storeName,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _botao(
                'Conservadores',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FreezerMM(
                      storeId: storeId,
                      storeName: storeName,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _botao(
                'Assadeiras',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AssadeirasMM(
                      storeId: storeId,
                      storeName: storeName,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _botao(
                'Armários e Esqueletos',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArmariosMM(
                      storeId: storeId,
                      storeName: storeName,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _botao(
                'Resumo',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResumoEquipamentosMM(
                      storeId: storeId,
                      storeName: storeName,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _botao(String label, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0x97095195),
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 24,
        ),
        textStyle: const TextStyle(fontSize: 19),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class FornoMM extends StatefulWidget {
  final String storeId;
  final String storeName;

  const FornoMM({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  @override
  _FornoMMState createState() => _FornoMMState();
}

class _FornoMMState extends State<FornoMM> {
  int quantidadeFornos = 0;

  List<TextEditingController> modeloControllers = [];
  List<String> tiposForno = [];
  List<int> suportesForno = [];
  List<String?> fotosForno = [];

  /// progresso de upload por forno
  Map<int, double> uploadProgress = {};

  final List<String> tipos = ['Elétrico', 'Gás'];
  final List<int> suportes = [1, 2, 3, 4, 5, 6, 7, 8];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _criarFornoControllers(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFornoData();
    });
  }

  @override
  void dispose() {
    for (var c in modeloControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ===================== CONTROLLERS =====================

  void _criarFornoControllers(int quantidade) {
    for (var c in modeloControllers) {
      c.dispose();
    }
    modeloControllers =
        List.generate(quantidade, (_) => TextEditingController());
    tiposForno = List.generate(quantidade, (_) => '');
    suportesForno = List.generate(quantidade, (_) => 0);
    fotosForno = List.generate(quantidade, (_) => null);
  }

  // ===================== FOTO =====================

  Future<void> _selecionarFoto(int index) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024, // ✅ garante 1024px (Android + Web)
      imageQuality: 70, // ✅ reduz tamanho
    );

    if (image == null) return;

    final ref = FirebaseStorage.instance.ref(
      'MM/stores/${widget.storeId}/fornos/forno_$index.jpg',
    );

    UploadTask task;

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      task = ref.putData(bytes);
    } else {
      task = ref.putFile(File(image.path));
    }

    task.snapshotEvents.listen((event) {
      final progress = event.bytesTransferred / event.totalBytes;
      setState(() {
        uploadProgress[index] = progress;
      });
    });

    final snapshot = await task;
    final url = await snapshot.ref.getDownloadURL();

    setState(() {
      fotosForno[index] = url;
      uploadProgress.remove(index);
    });

    _saveFornoData();
  }

  Future<void> _excluirFoto(int index) async {
    final url = fotosForno[index];
    if (url == null) return;

    try {
      await FirebaseStorage.instance.refFromURL(url).delete();
    } catch (_) {}

    setState(() {
      fotosForno[index] = null;
    });

    _saveFornoData();
  }

  // ===================== VISUALIZAR FOTO =====================

  void _visualizarFoto(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  void _abrirMenuFoto(int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Visualizar'),
              onTap: () {
                Navigator.pop(context);
                final url = fotosForno[index];
                if (url != null) {
                  _visualizarFoto(url);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Trocar foto'),
              onTap: () {
                Navigator.pop(context);
                _selecionarFoto(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Excluir foto'),
              onTap: () {
                Navigator.pop(context);
                _excluirFoto(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===================== FIRESTORE =====================

  Future<void> _saveFornoData() async {
    final List<Map<String, dynamic>> fornoList = [];

    for (int i = 0; i < quantidadeFornos; i++) {
      fornoList.add({
        'modelo': modeloControllers[i].text,
        'tipo': tiposForno[i],
        'suportes': suportesForno[i],
        'photoUrl': fotosForno[i],
      });
    }

    await _firestore.collection('storesmm').doc(widget.storeId).set({
      'storeName': widget.storeName,
      'fornos': fornoList,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _loadFornoData() async {
    final doc =
        await _firestore.collection('storesmm').doc(widget.storeId).get();

    if (!doc.exists) return;

    final List<dynamic> fornos = doc.data()?['fornos'] ?? [];

    setState(() {
      quantidadeFornos = fornos.length;
      _criarFornoControllers(quantidadeFornos);

      for (int i = 0; i < quantidadeFornos; i++) {
        modeloControllers[i].text = fornos[i]['modelo'] ?? '';
        tiposForno[i] = fornos[i]['tipo'] ?? '';
        suportesForno[i] = fornos[i]['suportes'] ?? 0;
        fotosForno[i] = fornos[i]['photoUrl'];
      }
    });
  }

  void _adicionarForno() {
    setState(() {
      quantidadeFornos++;
      modeloControllers.add(TextEditingController());
      tiposForno.add('');
      suportesForno.add(0);
      fotosForno.add(null);
    });
    _saveFornoData();
  }

  void _removerForno(int index) {
    setState(() {
      quantidadeFornos--;
      modeloControllers[index].dispose();
      modeloControllers.removeAt(index);
      tiposForno.removeAt(index);
      suportesForno.removeAt(index);
      fotosForno.removeAt(index);
    });
    _saveFornoData();
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fornos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...List.generate(quantidadeFornos, (index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Forno ${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  fotosForno[index] == null
                                      ? Icons.add_a_photo
                                      : Icons.photo,
                                ),
                                onPressed: fotosForno[index] == null
                                    ? () => _selecionarFoto(index)
                                    : () => _abrirMenuFoto(index),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removerForno(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (uploadProgress[index] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(
                            value: uploadProgress[index],
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: modeloControllers[index],
                        decoration: const InputDecoration(
                          labelText: 'Modelo',
                        ),
                        onChanged: (_) => _saveFornoData(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: tiposForno[index].isNotEmpty
                                  ? tiposForno[index]
                                  : null,
                              hint: const Text('Tipo'),
                              items: tipos
                                  .map((t) => DropdownMenuItem(
                                        value: t,
                                        child: Text(t),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  tiposForno[index] = value ?? '';
                                  _saveFornoData();
                                });
                              },
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              isExpanded: true,
                              value: suportesForno[index] > 0
                                  ? suportesForno[index]
                                  : null,
                              items: suportes
                                  .map((s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s.toString()),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  suportesForno[index] = value ?? 0;
                                  _saveFornoData();
                                });
                              },
                              decoration: const InputDecoration(
                                  labelText: 'Suportes',
                                  border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            Center(
              child: IconButton(
                icon:
                    const Icon(Icons.add_circle, color: Colors.green, size: 36),
                onPressed: _adicionarForno,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArmariosMM extends StatefulWidget {
  final String storeId;
  final String storeName;

  const ArmariosMM({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  @override
  State<ArmariosMM> createState() => _ArmariosMMState();
}

class _ArmariosMMState extends State<ArmariosMM> {
  int quantidadeArmarios = 0;
  int quantidadeEsqueletos = 0;

  List<String> tiposArmario = [];
  List<int> suportesArmario = [];
  List<String?> fotosArmario = [];

  List<String> tiposEsqueleto = [];
  List<int> suportesEsqueleto = [];
  List<String?> fotosEsqueleto = [];

  // Mapas para controlar o progresso de upload
  Map<String, double> uploadProgress = {}; // Chave: 'armario_0', 'esqueleto_1'

  final List<String> tiposMaterial = ['Inox', 'Alumínio', 'Epoxi'];
  final List<int> suportes = List.generate(20, (index) => index + 1);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    criarControllers(0, 0);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void criarControllers(int qtdArmarios, int qtdEsqueletos) {
    fotosArmario = List.generate(qtdArmarios, (_) => null);
    fotosEsqueleto = List.generate(qtdEsqueletos, (_) => null);
  }

  // ===================== FOTO - COM PARÂMETROS IGUAIS À TELA FORNO =====================
  Future<void> _selecionarFoto(bool isArmario, int index) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024, // ✅ mesma compressão da tela FornoMM
      imageQuality: 70, // ✅ mesma qualidade
    );

    if (image == null) return;

    final chave = isArmario ? 'armario_$index' : 'esqueleto_$index';
    final ref = _storage.ref().child(
          'MM/stores/${widget.storeId}/${isArmario ? 'armarios' : 'esqueletos'}/$chave.jpg',
        );

    UploadTask task;

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      task = ref.putData(bytes);
    } else {
      task = ref.putFile(File(image.path));
    }

    // ✅ LISTENER PARA BARRA DE PROGRESSO
    task.snapshotEvents.listen((event) {
      final progress = event.bytesTransferred / event.totalBytes;
      setState(() {
        uploadProgress[chave] = progress;
      });
    });

    // ✅ UPLOAD CONTINUA EM BACKGROUND (não usa await diretamente)
    task.then((snapshot) async {
      final url = await snapshot.ref.getDownloadURL();

      setState(() {
        if (isArmario) {
          fotosArmario[index] = url;
        } else {
          fotosEsqueleto[index] = url;
        }
        uploadProgress.remove(chave);
      });

      _saveData();
    }).catchError((error) {
      print('Erro no upload: $error');
      setState(() {
        uploadProgress.remove(chave);
      });
    });
  }

  Future<void> _excluirFoto(bool isArmario, int index) async {
    final url = isArmario ? fotosArmario[index] : fotosEsqueleto[index];
    if (url == null) return;

    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {}

    setState(() {
      if (isArmario) {
        fotosArmario[index] = null;
      } else {
        fotosEsqueleto[index] = null;
      }
    });
    _saveData();
  }

  // ===================== VISUALIZAR FOTO (IGUAL FORNOMM) =====================
  void _visualizarFoto(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // ===================== MENU FOTO (IGUAL FORNOMM) =====================
  void _abrirMenuFoto(bool isArmario, int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Visualizar'),
              onTap: () {
                Navigator.pop(context);
                final url =
                    isArmario ? fotosArmario[index] : fotosEsqueleto[index];
                if (url != null) {
                  _visualizarFoto(url);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Trocar foto'),
              onTap: () {
                Navigator.pop(context);
                _selecionarFoto(isArmario, index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Excluir foto'),
              onTap: () {
                Navigator.pop(context);
                _excluirFoto(isArmario, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===================== FIRESTORE =====================
  Future<void> _saveData() async {
    try {
      final armariosData = List.generate(
        quantidadeArmarios,
        (i) => {
          'tipo': tiposArmario[i],
          'suportes': suportesArmario[i],
          'photoUrl': fotosArmario[i],
        },
      );

      final esqueletosData = List.generate(
        quantidadeEsqueletos,
        (i) => {
          'tipo': tiposEsqueleto[i],
          'suportes': suportesEsqueleto[i],
          'photoUrl': fotosEsqueleto[i],
        },
      );

      await _firestore.collection('storesmm').doc(widget.storeId).set({
        'storeName': widget.storeName,
        'armarios': armariosData,
        'esqueletos': esqueletosData,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Erro ao salvar armários/esqueletos: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      final doc =
          await _firestore.collection('storesmm').doc(widget.storeId).get();
      if (!doc.exists) return;

      final data = doc.data() ?? {};
      final List armarioList = (data['armarios'] as List?) ?? [];
      final List esqueletoList = (data['esqueletos'] as List?) ?? [];

      setState(() {
        quantidadeArmarios = armarioList.length;
        quantidadeEsqueletos = esqueletoList.length;

        tiposArmario = armarioList
            .map<String>((e) => (e as Map)['tipo']?.toString() ?? '')
            .toList();
        suportesArmario = armarioList
            .map<int>((e) => (e as Map)['suportes'] as int? ?? 0)
            .toList();
        fotosArmario = armarioList
            .map<String?>((e) => (e as Map)['photoUrl'] as String?)
            .toList();

        tiposEsqueleto = esqueletoList
            .map<String>((e) => (e as Map)['tipo']?.toString() ?? '')
            .toList();
        suportesEsqueleto = esqueletoList
            .map<int>((e) => (e as Map)['suportes'] as int? ?? 0)
            .toList();
        fotosEsqueleto = esqueletoList
            .map<String?>((e) => (e as Map)['photoUrl'] as String?)
            .toList();
      });
    } catch (e) {
      debugPrint('Erro ao carregar armários/esqueletos: $e');
    }
  }

  // ===================== AÇÕES =====================
  void _adicionarArmario() {
    setState(() {
      quantidadeArmarios++;
      tiposArmario.add('');
      suportesArmario.add(0);
      fotosArmario.add(null);
    });
    _saveData();
  }

  void _removerArmario(int index) {
    setState(() {
      quantidadeArmarios--;
      tiposArmario.removeAt(index);
      suportesArmario.removeAt(index);
      fotosArmario.removeAt(index);
    });
    _saveData();
  }

  void _adicionarEsqueleto() {
    setState(() {
      quantidadeEsqueletos++;
      tiposEsqueleto.add('');
      suportesEsqueleto.add(0);
      fotosEsqueleto.add(null);
    });
    _saveData();
  }

  void _removerEsqueleto(int index) {
    setState(() {
      quantidadeEsqueletos--;
      tiposEsqueleto.removeAt(index);
      suportesEsqueleto.removeAt(index);
      fotosEsqueleto.removeAt(index);
    });
    _saveData();
  }

  // ===================== CARD =====================
  Widget _buildCard({
    required String title,
    required String tipo,
    required int suporte,
    required String? photoUrl,
    required String uploadKey,
    required void Function(String?) onTipoChanged,
    required void Function(int?) onSuporteChanged,
    required VoidCallback onRemove,
    required VoidCallback onPhotoTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        photoUrl == null ? Icons.add_a_photo : Icons.photo,
                      ),
                      onPressed: onPhotoTap,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onRemove,
                    ),
                  ],
                ),
              ],
            ),

            // ✅ BARRA DE PROGRESSO (IGUAL FORNOMM)
            if (uploadProgress.containsKey(uploadKey))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LinearProgressIndicator(
                  value: uploadProgress[uploadKey],
                ),
              ),

            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: tipo.isNotEmpty ? tipo : null,
                    items: tiposMaterial
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: onTipoChanged,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de material',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    isExpanded: true,
                    value: suporte > 0 ? suporte : null,
                    items: suportes
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.toString()),
                            ))
                        .toList(),
                    onChanged: onSuporteChanged,
                    decoration: const InputDecoration(
                      labelText: 'Suportes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Armários e Esqueletos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Armários:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...List.generate(quantidadeArmarios, (index) {
              return _buildCard(
                title: 'Armário ${index + 1}',
                tipo: tiposArmario[index],
                suporte: suportesArmario[index],
                photoUrl: fotosArmario[index],
                uploadKey: 'armario_$index',
                onTipoChanged: (v) {
                  setState(() => tiposArmario[index] = v ?? '');
                  _saveData();
                },
                onSuporteChanged: (v) {
                  setState(() => suportesArmario[index] = v ?? 0);
                  _saveData();
                },
                onRemove: () => _removerArmario(index),
                onPhotoTap: () => fotosArmario[index] == null
                    ? _selecionarFoto(true, index)
                    : _abrirMenuFoto(true, index),
              );
            }),
            Center(
              child: IconButton(
                icon:
                    const Icon(Icons.add_circle, size: 36, color: Colors.green),
                onPressed: _adicionarArmario,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Esqueletos:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...List.generate(quantidadeEsqueletos, (index) {
              return _buildCard(
                title: 'Esqueleto ${index + 1}',
                tipo: tiposEsqueleto[index],
                suporte: suportesEsqueleto[index],
                photoUrl: fotosEsqueleto[index],
                uploadKey: 'esqueleto_$index',
                onTipoChanged: (v) {
                  setState(() => tiposEsqueleto[index] = v ?? '');
                  _saveData();
                },
                onSuporteChanged: (v) {
                  setState(() => suportesEsqueleto[index] = v ?? 0);
                  _saveData();
                },
                onRemove: () => _removerEsqueleto(index),
                onPhotoTap: () => fotosEsqueleto[index] == null
                    ? _selecionarFoto(false, index)
                    : _abrirMenuFoto(false, index),
              );
            }),
            Center(
              child: IconButton(
                icon:
                    const Icon(Icons.add_circle, size: 36, color: Colors.green),
                onPressed: _adicionarEsqueleto,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClimaticaMM extends StatefulWidget {
  final String storeId;
  final String storeName;

  const ClimaticaMM({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  @override
  _ClimaticaMMState createState() => _ClimaticaMMState();
}

class _ClimaticaMMState extends State<ClimaticaMM> {
  int quantidadeClimaticas = 0;
  List<TextEditingController> modeloControllers = [];
  List<int> suportesClimatica = [];
  List<String?> fotosClimatica = [];

  // Mapa para controle de progresso
  Map<int, double> uploadProgress = {};

  final List<int> suportes = List.generate(40, (index) => index + 1);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    criarClimaticaControllers(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClimaticaData();
    });
  }

  @override
  void dispose() {
    for (var c in modeloControllers) c.dispose();
    super.dispose();
  }

  void criarClimaticaControllers(int quantidade) {
    for (var c in modeloControllers) c.dispose();
    modeloControllers =
        List.generate(quantidade, (_) => TextEditingController());
    suportesClimatica = List.generate(quantidade, (_) => 0);
    fotosClimatica = List.generate(quantidade, (_) => null);
  }

  // ===================== FOTO - COM PARÂMETROS IGUAIS =====================
  Future<void> _selecionarFoto(int index) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 70,
    );

    if (image == null) return;

    final ref = _storage.ref().child(
          'MM/stores/${widget.storeId}/climaticas/climatica_$index.jpg',
        );

    UploadTask task;

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      task = ref.putData(bytes);
    } else {
      task = ref.putFile(File(image.path));
    }

    // ✅ BARRA DE PROGRESSO
    task.snapshotEvents.listen((event) {
      final progress = event.bytesTransferred / event.totalBytes;
      setState(() {
        uploadProgress[index] = progress;
      });
    });

    // ✅ UPLOAD EM BACKGROUND
    task.then((snapshot) async {
      final url = await snapshot.ref.getDownloadURL();
      setState(() {
        fotosClimatica[index] = url;
        uploadProgress.remove(index);
      });
      _saveClimaticaData();
    }).catchError((error) {
      print('Erro no upload: $error');
      setState(() {
        uploadProgress.remove(index);
      });
    });
  }

  Future<void> _excluirFoto(int index) async {
    final url = fotosClimatica[index];
    if (url == null) return;

    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {}

    setState(() => fotosClimatica[index] = null);
    _saveClimaticaData();
  }

  // ===================== VISUALIZAR FOTO =====================
  void _visualizarFoto(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // ===================== MENU FOTO =====================
  void _abrirMenuFoto(int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Visualizar'),
              onTap: () {
                Navigator.pop(context);
                final url = fotosClimatica[index];
                if (url != null) {
                  _visualizarFoto(url);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Trocar foto'),
              onTap: () {
                Navigator.pop(context);
                _selecionarFoto(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Excluir foto'),
              onTap: () {
                Navigator.pop(context);
                _excluirFoto(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===================== FIRESTORE =====================
  Future<void> _saveClimaticaData() async {
    List<Map<String, dynamic>> climaticaList = [];

    for (int i = 0; i < quantidadeClimaticas; i++) {
      climaticaList.add({
        'modelo': modeloControllers[i].text,
        'suportes': suportesClimatica[i],
        'photoUrl': fotosClimatica[i],
      });
    }

    await _firestore.collection('storesmm').doc(widget.storeId).set({
      'storeName': widget.storeName,
      'climaticas': climaticaList,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _loadClimaticaData() async {
    final doc =
        await _firestore.collection('storesmm').doc(widget.storeId).get();

    if (!doc.exists) return;

    final climaticas = doc.data()?['climaticas'] ?? [];

    setState(() {
      quantidadeClimaticas = climaticas.length;
      criarClimaticaControllers(quantidadeClimaticas);

      for (int i = 0; i < quantidadeClimaticas; i++) {
        modeloControllers[i].text = climaticas[i]['modelo'] ?? '';
        suportesClimatica[i] = climaticas[i]['suportes'] ?? 0;
        fotosClimatica[i] = climaticas[i]['photoUrl'];
      }
    });
  }

  void _adicionarClimatica() {
    setState(() {
      quantidadeClimaticas++;
      modeloControllers.add(TextEditingController());
      suportesClimatica.add(0);
      fotosClimatica.add(null);
    });
    _saveClimaticaData();
  }

  void _removerClimatica(int index) {
    setState(() {
      quantidadeClimaticas--;
      modeloControllers[index].dispose();
      modeloControllers.removeAt(index);
      suportesClimatica.removeAt(index);
      fotosClimatica.removeAt(index);
    });
    _saveClimaticaData();
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Climáticas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...List.generate(quantidadeClimaticas, (index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Climatica ${index + 1}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  fotosClimatica[index] == null
                                      ? Icons.add_a_photo
                                      : Icons.photo,
                                ),
                                onPressed: fotosClimatica[index] == null
                                    ? () => _selecionarFoto(index)
                                    : () => _abrirMenuFoto(index),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removerClimatica(index),
                              ),
                            ],
                          )
                        ],
                      ),

                      // ✅ BARRA DE PROGRESSO
                      if (uploadProgress.containsKey(index))
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: LinearProgressIndicator(
                            value: uploadProgress[index],
                          ),
                        ),

                      const SizedBox(height: 12),
                      TextField(
                        controller: modeloControllers[index],
                        decoration: const InputDecoration(labelText: 'Modelo'),
                        onChanged: (_) => _saveClimaticaData(),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        value: suportesClimatica[index] > 0
                            ? suportesClimatica[index]
                            : null,
                        items: suportes
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.toString()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            suportesClimatica[index] = value ?? 0;
                            _saveClimaticaData();
                          });
                        },
                        decoration: const InputDecoration(
                            labelText: 'Suportes',
                            border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
              );
            }),
            Center(
              child: IconButton(
                icon:
                    const Icon(Icons.add_circle, color: Colors.green, size: 36),
                onPressed: _adicionarClimatica,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FreezerMM extends StatefulWidget {
  final String storeId;
  final String storeName;
  const FreezerMM({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  @override
  State<FreezerMM> createState() => _FreezerMMState();
}

class _FreezerMMState extends State<FreezerMM> {
  int quantidadeFreezers = 0;
  List<TextEditingController> modeloControllers = [];
  List<TextEditingController> volumeControllers = [];
  List<String> tiposFreezer = [];
  List<String?> fotosFreezer = [];

  // Mapa para controle de progresso
  Map<int, double> uploadProgress = {};

  final List<String> tipos = ['Vertical', 'Horizontal'];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    criarFreezerControllers(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFreezerData();
    });
  }

  @override
  void dispose() {
    for (var c in modeloControllers) c.dispose();
    for (var c in volumeControllers) c.dispose();
    super.dispose();
  }

  void criarFreezerControllers(int quantidade) {
    for (var c in modeloControllers) c.dispose();
    for (var c in volumeControllers) c.dispose();

    modeloControllers =
        List.generate(quantidade, (_) => TextEditingController());
    volumeControllers =
        List.generate(quantidade, (_) => TextEditingController());
    tiposFreezer = List.generate(quantidade, (_) => '');
    fotosFreezer = List.generate(quantidade, (_) => null);
  }

  // ===================== FOTO - COM PARÂMETROS IGUAIS =====================
  Future<void> _selecionarFoto(int index) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 70,
    );

    if (image == null) return;

    final ref = _storage.ref().child(
          'MM/stores/${widget.storeId}/freezers/freezer_$index.jpg',
        );

    UploadTask task;

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      task = ref.putData(bytes);
    } else {
      task = ref.putFile(File(image.path));
    }

    // ✅ BARRA DE PROGRESSO
    task.snapshotEvents.listen((event) {
      final progress = event.bytesTransferred / event.totalBytes;
      setState(() {
        uploadProgress[index] = progress;
      });
    });

    // ✅ UPLOAD EM BACKGROUND
    task.then((snapshot) async {
      final url = await snapshot.ref.getDownloadURL();
      setState(() {
        fotosFreezer[index] = url;
        uploadProgress.remove(index);
      });
      _saveFreezerData();
    }).catchError((error) {
      print('Erro no upload: $error');
      setState(() {
        uploadProgress.remove(index);
      });
    });
  }

  Future<void> _excluirFoto(int index) async {
    final url = fotosFreezer[index];
    if (url == null) return;

    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {}

    setState(() => fotosFreezer[index] = null);
    _saveFreezerData();
  }

  // ===================== VISUALIZAR FOTO =====================
  void _visualizarFoto(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // ===================== MENU FOTO =====================
  void _abrirMenuFoto(int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Visualizar'),
              onTap: () {
                Navigator.pop(context);
                final url = fotosFreezer[index];
                if (url != null) {
                  _visualizarFoto(url);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Trocar foto'),
              onTap: () {
                Navigator.pop(context);
                _selecionarFoto(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Excluir foto'),
              onTap: () {
                Navigator.pop(context);
                _excluirFoto(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===================== FIRESTORE =====================
  Future<void> _saveFreezerData() async {
    List<Map<String, dynamic>> freezerList = [];

    for (int i = 0; i < quantidadeFreezers; i++) {
      freezerList.add({
        'modelo': modeloControllers[i].text,
        'volume': volumeControllers[i].text,
        'tipo': tiposFreezer[i],
        'photoUrl': fotosFreezer[i],
      });
    }

    await _firestore.collection('storesmm').doc(widget.storeId).set({
      'storeName': widget.storeName,
      'freezers': freezerList,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _loadFreezerData() async {
    final doc =
        await _firestore.collection('storesmm').doc(widget.storeId).get();

    if (!doc.exists) return;

    final freezers = doc.data()?['freezers'] ?? [];

    setState(() {
      quantidadeFreezers = freezers.length;
      criarFreezerControllers(quantidadeFreezers);

      for (int i = 0; i < quantidadeFreezers; i++) {
        modeloControllers[i].text = freezers[i]['modelo'] ?? '';
        volumeControllers[i].text = freezers[i]['volume'] ?? '';
        tiposFreezer[i] = freezers[i]['tipo'] ?? '';
        fotosFreezer[i] = freezers[i]['photoUrl'];
      }
    });
  }

  void _adicionarFreezer() {
    setState(() {
      quantidadeFreezers++;
      modeloControllers.add(TextEditingController());
      volumeControllers.add(TextEditingController());
      tiposFreezer.add('');
      fotosFreezer.add(null);
    });
    _saveFreezerData();
  }

  void _removerFreezer(int index) {
    setState(() {
      quantidadeFreezers--;
      modeloControllers[index].dispose();
      volumeControllers[index].dispose();
      modeloControllers.removeAt(index);
      volumeControllers.removeAt(index);
      tiposFreezer.removeAt(index);
      fotosFreezer.removeAt(index);
    });
    _saveFreezerData();
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conservadores')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...List.generate(quantidadeFreezers, (index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Conservador ${index + 1}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  fotosFreezer[index] == null
                                      ? Icons.add_a_photo
                                      : Icons.photo,
                                ),
                                onPressed: fotosFreezer[index] == null
                                    ? () => _selecionarFoto(index)
                                    : () => _abrirMenuFoto(index),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removerFreezer(index),
                              ),
                            ],
                          )
                        ],
                      ),

                      // ✅ BARRA DE PROGRESSO
                      if (uploadProgress.containsKey(index))
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: LinearProgressIndicator(
                            value: uploadProgress[index],
                          ),
                        ),

                      const SizedBox(height: 12),
                      TextField(
                        controller: modeloControllers[index],
                        decoration: const InputDecoration(
                            labelText: 'Modelo', border: OutlineInputBorder()),
                        onChanged: (_) => _saveFreezerData(),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: volumeControllers[index],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Volume (litros)',
                            border: OutlineInputBorder()),
                        onChanged: (_) => _saveFreezerData(),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: tiposFreezer[index].isNotEmpty
                            ? tiposFreezer[index]
                            : null,
                        items: tipos
                            .map((tipo) => DropdownMenuItem(
                                value: tipo, child: Text(tipo)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            tiposFreezer[index] = value ?? '';
                            _saveFreezerData();
                          });
                        },
                        decoration: const InputDecoration(
                            labelText: 'Tipo', border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
              );
            }),
            Center(
              child: IconButton(
                icon:
                    const Icon(Icons.add_circle, size: 36, color: Colors.green),
                onPressed: _adicionarFreezer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AssadeirasMM extends StatefulWidget {
  final String storeId;
  final String storeName;
  const AssadeirasMM({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  @override
  State<AssadeirasMM> createState() => _AssadeirasMMState();
}

class _AssadeirasMMState extends State<AssadeirasMM> {
  int quantidadeEsteiras = 0;
  int quantidadeAssadeiras = 0;

  List<String> tiposEsteiras = [];
  List<int> quantidadesEsteiras = [];
  List<String?> fotosEsteiras = [];

  List<String> tiposAssadeiras = [];
  List<int> quantidadesAssadeiras = [];
  List<String?> fotosAssadeiras = [];

  // Mapas para controle de progresso
  Map<String, double> uploadProgress = {}; // 'esteira_0', 'assadeira_1'

  final List<String> tiposMaterial = [
    'Alumínio',
    'Inox',
    'Flandre',
    'Ferro Fundido'
  ];
  final List<int> quantidades = List.generate(120, (index) => index + 1);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    criarEsteiraAssadeiraControllers(0, 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void criarEsteiraAssadeiraControllers(int qtdEsteiras, int qtdAssadeiras) {
    fotosEsteiras = List.generate(qtdEsteiras, (_) => null);
    fotosAssadeiras = List.generate(qtdAssadeiras, (_) => null);
  }

  // ===================== FOTO - COM PARÂMETROS IGUAIS =====================
  Future<void> _selecionarFoto(bool isEsteira, int index) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 70,
    );

    if (image == null) return;

    final chave = isEsteira ? 'esteira_$index' : 'assadeira_$index';
    final ref = _storage.ref().child(
          'MM/stores/${widget.storeId}/${isEsteira ? 'esteiras' : 'assadeiras'}/$chave.jpg',
        );

    UploadTask task;

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      task = ref.putData(bytes);
    } else {
      task = ref.putFile(File(image.path));
    }

    // ✅ BARRA DE PROGRESSO
    task.snapshotEvents.listen((event) {
      final progress = event.bytesTransferred / event.totalBytes;
      setState(() {
        uploadProgress[chave] = progress;
      });
    });

    // ✅ UPLOAD EM BACKGROUND
    task.then((snapshot) async {
      final url = await snapshot.ref.getDownloadURL();
      setState(() {
        if (isEsteira) {
          fotosEsteiras[index] = url;
        } else {
          fotosAssadeiras[index] = url;
        }
        uploadProgress.remove(chave);
      });
      _saveData();
    }).catchError((error) {
      print('Erro no upload: $error');
      setState(() {
        uploadProgress.remove(chave);
      });
    });
  }

  Future<void> _excluirFoto(bool isEsteira, int index) async {
    final url = isEsteira ? fotosEsteiras[index] : fotosAssadeiras[index];
    if (url == null) return;

    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {}

    setState(() {
      if (isEsteira) {
        fotosEsteiras[index] = null;
      } else {
        fotosAssadeiras[index] = null;
      }
    });
    _saveData();
  }

  // ===================== VISUALIZAR FOTO =====================
  void _visualizarFoto(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // ===================== MENU FOTO =====================
  void _abrirMenuFoto(bool isEsteira, int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Visualizar'),
              onTap: () {
                Navigator.pop(context);
                final url =
                    isEsteira ? fotosEsteiras[index] : fotosAssadeiras[index];
                if (url != null) {
                  _visualizarFoto(url);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Trocar foto'),
              onTap: () {
                Navigator.pop(context);
                _selecionarFoto(isEsteira, index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Excluir foto'),
              onTap: () {
                Navigator.pop(context);
                _excluirFoto(isEsteira, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===================== FIRESTORE =====================
  Future<void> _saveData() async {
    try {
      final esteirasData = List.generate(
        quantidadeEsteiras,
        (i) => {
          'tipo': tiposEsteiras[i],
          'quantidade': quantidadesEsteiras[i],
          'photoUrl': fotosEsteiras[i],
        },
      );

      final assadeirasData = List.generate(
        quantidadeAssadeiras,
        (i) => {
          'tipo': tiposAssadeiras[i],
          'quantidade': quantidadesAssadeiras[i],
          'photoUrl': fotosAssadeiras[i],
        },
      );

      await _firestore.collection('storesmm').doc(widget.storeId).set({
        'storeName': widget.storeName,
        'esteiras': esteirasData,
        'assadeiras': assadeirasData,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Erro ao salvar esteiras/assadeiras: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      final doc =
          await _firestore.collection('storesmm').doc(widget.storeId).get();
      if (!doc.exists) return;

      final data = doc.data() ?? {};
      final List esteirasList = (data['esteiras'] as List?) ?? [];
      final List assadeirasList = (data['assadeiras'] as List?) ?? [];

      setState(() {
        quantidadeEsteiras = esteirasList.length;
        quantidadeAssadeiras = assadeirasList.length;

        tiposEsteiras = esteirasList
            .map<String>((e) => (e as Map)['tipo']?.toString() ?? '')
            .toList();
        quantidadesEsteiras = esteirasList
            .map<int>((e) => (e as Map)['quantidade'] as int? ?? 0)
            .toList();
        fotosEsteiras = esteirasList
            .map<String?>((e) => (e as Map)['photoUrl'] as String?)
            .toList();

        tiposAssadeiras = assadeirasList
            .map<String>((e) => (e as Map)['tipo']?.toString() ?? '')
            .toList();
        quantidadesAssadeiras = assadeirasList
            .map<int>((e) => (e as Map)['quantidade'] as int? ?? 0)
            .toList();
        fotosAssadeiras = assadeirasList
            .map<String?>((e) => (e as Map)['photoUrl'] as String?)
            .toList();
      });
    } catch (e) {
      debugPrint('Erro ao carregar esteiras/assadeiras: $e');
    }
  }

  // ===================== AÇÕES =====================
  void _adicionarEsteira() {
    setState(() {
      quantidadeEsteiras++;
      tiposEsteiras.add('');
      quantidadesEsteiras.add(0);
      fotosEsteiras.add(null);
    });
    _saveData();
  }

  void _removerEsteira(int index) {
    setState(() {
      quantidadeEsteiras--;
      tiposEsteiras.removeAt(index);
      quantidadesEsteiras.removeAt(index);
      fotosEsteiras.removeAt(index);
    });
    _saveData();
  }

  void _adicionarAssadeira() {
    setState(() {
      quantidadeAssadeiras++;
      tiposAssadeiras.add('');
      quantidadesAssadeiras.add(0);
      fotosAssadeiras.add(null);
    });
    _saveData();
  }

  void _removerAssadeira(int index) {
    setState(() {
      quantidadeAssadeiras--;
      tiposAssadeiras.removeAt(index);
      quantidadesAssadeiras.removeAt(index);
      fotosAssadeiras.removeAt(index);
    });
    _saveData();
  }

  // ===================== CARD =====================
  Widget _buildCard({
    required String title,
    required String tipo,
    required int quantidade,
    required String? photoUrl,
    required String uploadKey,
    required void Function(String?) onTipoChanged,
    required void Function(int?) onQtdChanged,
    required VoidCallback onRemove,
    required VoidCallback onPhotoTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                          photoUrl == null ? Icons.add_a_photo : Icons.photo),
                      onPressed: onPhotoTap,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onRemove,
                    ),
                  ],
                ),
              ],
            ),

            // ✅ BARRA DE PROGRESSO
            if (uploadProgress.containsKey(uploadKey))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LinearProgressIndicator(
                  value: uploadProgress[uploadKey],
                ),
              ),

            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: tipo.isNotEmpty ? tipo : null,
              hint: const Text('Tipo de material'),
              items: tiposMaterial
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: onTipoChanged,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: quantidade > 0 ? quantidade : null,
              hint: const Text('Quantidade'),
              items: quantidades
                  .map((q) =>
                      DropdownMenuItem(value: q, child: Text(q.toString())))
                  .toList(),
              onChanged: onQtdChanged,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Esteiras e Assadeiras')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Esteiras:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...List.generate(quantidadeEsteiras, (index) {
              return _buildCard(
                title: 'Esteira ${index + 1}',
                tipo: tiposEsteiras[index],
                quantidade: quantidadesEsteiras[index],
                photoUrl: fotosEsteiras[index],
                uploadKey: 'esteira_$index',
                onTipoChanged: (v) {
                  setState(() => tiposEsteiras[index] = v ?? '');
                  _saveData();
                },
                onQtdChanged: (v) {
                  setState(() => quantidadesEsteiras[index] = v ?? 0);
                  _saveData();
                },
                onRemove: () => _removerEsteira(index),
                onPhotoTap: () => fotosEsteiras[index] == null
                    ? _selecionarFoto(true, index)
                    : _abrirMenuFoto(true, index),
              );
            }),
            Center(
              child: IconButton(
                icon:
                    const Icon(Icons.add_circle, size: 36, color: Colors.green),
                onPressed: _adicionarEsteira,
              ),
            ),
            const SizedBox(height: 30),
            const Text('Assadeiras:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...List.generate(quantidadeAssadeiras, (index) {
              return _buildCard(
                title: 'Assadeira ${index + 1}',
                tipo: tiposAssadeiras[index],
                quantidade: quantidadesAssadeiras[index],
                photoUrl: fotosAssadeiras[index],
                uploadKey: 'assadeira_$index',
                onTipoChanged: (v) {
                  setState(() => tiposAssadeiras[index] = v ?? '');
                  _saveData();
                },
                onQtdChanged: (v) {
                  setState(() => quantidadesAssadeiras[index] = v ?? 0);
                  _saveData();
                },
                onRemove: () => _removerAssadeira(index),
                onPhotoTap: () => fotosAssadeiras[index] == null
                    ? _selecionarFoto(false, index)
                    : _abrirMenuFoto(false, index),
              );
            }),
            Center(
              child: IconButton(
                icon:
                    const Icon(Icons.add_circle, size: 36, color: Colors.green),
                onPressed: _adicionarAssadeira,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResumoEquipamentosMM extends StatefulWidget {
  final String storeId;
  final String storeName;
  const ResumoEquipamentosMM({
    required this.storeId,
    required this.storeName,
  });

  @override
  State<ResumoEquipamentosMM> createState() => _ResumoEquipamentosMMState();
}

class _ResumoEquipamentosMMState extends State<ResumoEquipamentosMM> {
  Map<String, dynamic> dadosResumo = {};
  bool isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _carregarTodosDados();
  }

  Future<void> _carregarTodosDados() async {
    try {
      final doc =
          await _firestore.collection('storesmm').doc(widget.storeId).get();
      if (doc.exists) {
        final data = doc.data() ?? {};

        if (mounted) {
          setState(() {
            dadosResumo = {
              'fornos': data['fornos'] ?? [],
              'armarios': data['armarios'] ?? [],
              'esqueletos': data['esqueletos'] ?? [],
              'esteiras': data['esteiras'] ?? [],
              'assadeiras': data['assadeiras'] ?? [],
              'climaticas': data['climaticas'] ?? [],
              'freezers': data['freezers'] ?? [],
            };
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<Uint8List> _gerarPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) {
          final List<pw.Widget> widgets = [];

          widgets.add(
            pw.Center(
              child: pw.Text(
                'Inventário de Equipamentos - ${widget.storeName}',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
            ),
          );
          widgets.add(pw.SizedBox(height: 20));

          void addSection(
              String title, List lista, String Function(int, Map) fn) {
            if (lista.isEmpty) return;

            widgets.add(
              pw.Text(
                title,
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            );

            for (int i = 0; i < lista.length; i++) {
              final item = lista[i];
              widgets.add(
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Bullet(text: fn(i, item)),
                    if (item['photoUrl'] != null)
                      pw.UrlLink(
                        destination: item['photoUrl'],
                        child: pw.Text(
                          'Ver foto',
                          style: pw.TextStyle(
                            color: PdfColors.blue,
                            decoration: pw.TextDecoration.underline,
                          ),
                        ),
                      ),
                    pw.SizedBox(height: 4),
                  ],
                ),
              );
            }

            widgets.add(pw.SizedBox(height: 10));
          }

          addSection(
            'Fornos:',
            dadosResumo['fornos'],
            (i, f) =>
                'Forno ${i + 1} - Modelo: ${f['modelo'] ?? 'N/I'}, Tipo: ${f['tipo'] ?? 'N/I'}, Suportes: ${f['suportes'] ?? 0}',
          );

          addSection(
            'Armários:',
            dadosResumo['armarios'],
            (i, a) =>
                'Armário ${i + 1} - Tipo: ${a['tipo'] ?? 'N/I'}, Suportes: ${a['suportes'] ?? 0}',
          );

          addSection(
            'Esqueletos:',
            dadosResumo['esqueletos'],
            (i, e) =>
                'Esqueleto ${i + 1} - Tipo: ${e['tipo'] ?? 'N/I'}, Suportes: ${e['suportes'] ?? 0}',
          );

          addSection(
            'Esteiras:',
            dadosResumo['esteiras'],
            (i, e) =>
                'Esteira ${i + 1} - Tipo: ${e['tipo'] ?? 'N/I'}, Quantidade: ${e['quantidade'] ?? 0}',
          );

          addSection(
            'Assadeiras:',
            dadosResumo['assadeiras'],
            (i, a) =>
                'Assadeira ${i + 1} - Tipo: ${a['tipo'] ?? 'N/I'}, Quantidade: ${a['quantidade'] ?? 0}',
          );

          addSection(
            'Climáticas:',
            dadosResumo['climaticas'],
            (i, c) =>
                'Climática ${i + 1} - Modelo: ${c['modelo'] ?? 'N/I'}, Suportes: ${c['suportes'] ?? 0}',
          );

          addSection(
            'Conservadores:',
            dadosResumo['freezers'],
            (i, f) =>
                'Conservador ${i + 1} - Modelo: ${f['modelo'] ?? 'N/I'}, Volume: ${f['volume'] ?? 'N/I'}L, Tipo: ${f['tipo'] ?? 'N/I'}',
          );

          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _compartilharPdf() async {
    final pdfBytes = await _gerarPdf();
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: "Inventário Equipamentos_${widget.storeName}.pdf",
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(String title, String subtitle, {String? photoUrl}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[50],
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (photoUrl != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(),
                        body: Center(
                          child: InteractiveViewer(
                            child: CachedNetworkImage(
                              imageUrl: photoUrl,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: photoUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.white70),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
            if (photoUrl != null) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> buildItems(
      String key, String Function(Map) detailsFn) {
    final list = dadosResumo[key] ?? [];
    return List<Map<String, dynamic>>.from(list.map((item) => {
          'nome': (item['modelo'] != null &&
                  item['modelo'].toString().trim().isNotEmpty)
              ? item['modelo']
              : (item['tipo'] != null &&
                      item['tipo'].toString().trim().isNotEmpty)
                  ? item['tipo']
                  : 'Não informado',
          'detalhes': detailsFn(item),
          'photoUrl': item['photoUrl'],
        }));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final hasData = dadosResumo.isNotEmpty &&
        dadosResumo.values.any((value) => value != null && value.isNotEmpty);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventário'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _compartilharPdf,
          ),
        ],
      ),
      body: !hasData
          ? const Center(
              child: Text('Nenhum dado cadastrado',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dadosResumo['fornos'] != null &&
                      dadosResumo['fornos'].isNotEmpty)
                    _buildSection(
                      'Fornos (${dadosResumo['fornos'].length})',
                      buildItems(
                              'fornos',
                              (item) =>
                                  'Modelo: ${item['modelo'] ?? 'N/I'}, Tipo: ${item['tipo'] ?? 'N/I'}, Suportes: ${item['suportes'] ?? 0}')
                          .map((e) => _buildItemCard(e['nome'], e['detalhes'],
                              photoUrl: e['photoUrl']))
                          .toList(),
                    ),
                  if (dadosResumo['armarios'] != null &&
                      dadosResumo['armarios'].isNotEmpty)
                    _buildSection(
                      'Armários (${dadosResumo['armarios'].length})',
                      buildItems(
                              'armarios',
                              (item) =>
                                  'Tipo: ${item['tipo'] ?? 'N/I'}, Suportes: ${item['suportes'] ?? 0}')
                          .map((e) => _buildItemCard(e['nome'], e['detalhes'],
                              photoUrl: e['photoUrl']))
                          .toList(),
                    ),
                  if (dadosResumo['esqueletos'] != null &&
                      dadosResumo['esqueletos'].isNotEmpty)
                    _buildSection(
                      'Esqueletos (${dadosResumo['esqueletos'].length})',
                      buildItems(
                              'esqueletos',
                              (item) =>
                                  'Tipo: ${item['tipo'] ?? 'N/I'}, Suportes: ${item['suportes'] ?? 0}')
                          .map((e) => _buildItemCard(e['nome'], e['detalhes'],
                              photoUrl: e['photoUrl']))
                          .toList(),
                    ),
                  if (dadosResumo['esteiras'] != null &&
                      (dadosResumo['esteiras'] as List).isNotEmpty)
                    _buildSection(
                      'Esteiras (${dadosResumo['esteiras'].length})',
                      buildItems(
                              'esteiras',
                              (item) =>
                                  'Tipo: ${item['tipo'] ?? 'N/I'}, Quantidade: ${item['quantidade'] ?? 0}')
                          .map((e) => _buildItemCard(e['nome'], e['detalhes'],
                              photoUrl: e['photoUrl']))
                          .toList(),
                    ),
                  if (dadosResumo['assadeiras'] != null &&
                      (dadosResumo['assadeiras'] as List).isNotEmpty)
                    _buildSection(
                      'Assadeiras (${dadosResumo['assadeiras'].length})',
                      buildItems(
                              'assadeiras',
                              (item) =>
                                  'Tipo: ${item['tipo'] ?? 'N/I'}, Quantidade: ${item['quantidade'] ?? 0}')
                          .map((e) => _buildItemCard(e['nome'], e['detalhes'],
                              photoUrl: e['photoUrl']))
                          .toList(),
                    ),
                  if (dadosResumo['climaticas'] != null &&
                      dadosResumo['climaticas'].isNotEmpty)
                    _buildSection(
                      'Climáticas (${dadosResumo['climaticas'].length})',
                      buildItems(
                              'climaticas',
                              (item) =>
                                  'Modelo: ${item['modelo'] ?? 'N/I'}, Suportes: ${item['suportes'] ?? 0}')
                          .map((e) => _buildItemCard(e['nome'], e['detalhes'],
                              photoUrl: e['photoUrl']))
                          .toList(),
                    ),
                  if (dadosResumo['freezers'] != null &&
                      dadosResumo['freezers'].isNotEmpty)
                    _buildSection(
                      'Conservadores (${dadosResumo['freezers'].length})',
                      buildItems(
                              'freezers',
                              (item) =>
                                  'Modelo: ${item['modelo'] ?? 'N/I'}, Volume: ${item['volume'] ?? 'N/I'}L, Tipo: ${item['tipo'] ?? 'N/I'}')
                          .map((e) => _buildItemCard(e['nome'], e['detalhes'],
                              photoUrl: e['photoUrl']))
                          .toList(),
                    ),
                ],
              ),
            ),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [
    {"text": "Oi!", "isMe": false},
    {"text": "Olá 👋", "isMe": true},
    {"text": "Tudo bem?", "isMe": false},
  ];

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      messages.add({
        "text": _controller.text,
        "isMe": true,
      });
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                "https://i.pravatar.cc/150?img=3",
              ),
            ),
            SizedBox(width: 10),
            Text("Usuário"),
          ],
        ),
      ),
      body: Column(
        children: [
          /// LISTA DE MENSAGENS
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message["isMe"];

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 250),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.green[400] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message["text"],
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          /// CAMPO DE DIGITAÇÃO
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Digite uma mensagem...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Meta extends StatelessWidget {
  final String storeName;

  const Meta({
    super.key,
    required this.storeName,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
      home: MetaTabelaScreen(storeName: storeName),
    );
  }
}

class Produto {
  final String nome;
  final String codigo;
  final double fatorPacote;

  Produto({
    required this.nome,
    required this.codigo,
    this.fatorPacote = 8.4,
  });
}

final List<Produto> produtos = [
  Produto(nome: 'Pão Francês', codigo: '510', fatorPacote: 8.4),
  Produto(nome: 'Pão Francês Fibras', codigo: '164967', fatorPacote: 2.64),
  Produto(nome: 'Pão Francês Panhoca', codigo: '137975', fatorPacote: 2.64),
  Produto(nome: 'Pão Baguete Francesa', codigo: '137892', fatorPacote: 2.64),
  Produto(
      nome: 'Pão Baguete Francesa Queijo', codigo: '31541', fatorPacote: 2.93),
  Produto(
      nome: 'Pão Baguete Francesa Gergelim', codigo: '132', fatorPacote: 2.73),
  Produto(nome: 'Pão Queijo Tradicional', codigo: '62948', fatorPacote: 2.31),
  Produto(nome: 'Pão Queijo Coquetel', codigo: '65139', fatorPacote: 2.31),
  Produto(nome: 'Biscoito Queijo', codigo: '146428', fatorPacote: 2.31),
  Produto(nome: 'Baguete Francesa', codigo: '132472', fatorPacote: 10),
  Produto(nome: 'Baguete Francesa Queijo', codigo: '135582', fatorPacote: 10),
  Produto(nome: 'Pão Francês com Queijo', codigo: '635', fatorPacote: 3.3),
  Produto(nome: 'Biscoito Polvilho', codigo: '97921', fatorPacote: 0.783),
  Produto(nome: 'Pão Tatu', codigo: '511', fatorPacote: 2.97),
  Produto(nome: 'Caseirinho', codigo: '114913', fatorPacote: 2.8),
  Produto(nome: 'Pão Fofinho', codigo: '106794', fatorPacote: 2.8),
  Produto(nome: 'Rosca Fofinha Temperada', codigo: '142098', fatorPacote: 11),
  Produto(nome: 'Pão Doce Ferradura', codigo: '33749', fatorPacote: 4.71),
  Produto(nome: 'Pão Doce Caracol', codigo: '33724', fatorPacote: 4.71),
  Produto(nome: 'Mini Pão Sonho', codigo: '112730', fatorPacote: 8.8),
  Produto(nome: 'Mini Pão Sonho Chocolate', codigo: '141971', fatorPacote: 8.8),
  Produto(nome: 'Pão Bambino', codigo: '112728', fatorPacote: 8.8),
  Produto(nome: 'Mini Pão Marta Rocha', codigo: '112732', fatorPacote: 8.8),
  Produto(nome: 'Sanduíche Bahamas', codigo: '55961', fatorPacote: 37),
  Produto(nome: 'Sanduíche Fofinho', codigo: '142099', fatorPacote: 55),
  Produto(nome: 'Pão de Alho da Casa', codigo: '132317', fatorPacote: 12),
  Produto(
      nome: 'Pão de Alho da Casa Picante', codigo: '132320', fatorPacote: 12),
  Produto(nome: 'Pão Samaritano', codigo: '132318', fatorPacote: 123),
  Produto(nome: 'Pão Pizza', codigo: '132319', fatorPacote: 42),
];

class MetaTabelaScreen extends StatefulWidget {
  final String storeName;

  const MetaTabelaScreen({
    super.key,
    required this.storeName,
  });

  @override
  State<MetaTabelaScreen> createState() => _MetaTabelaScreenState();
}

class _MetaTabelaScreenState extends State<MetaTabelaScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController percentualController =
      TextEditingController(text: '20');

  final Map<String, TextEditingController> vendaControllers = {};
  final Map<String, TextEditingController> precoControllers = {};

  final Map<String, double> meta = {};
  final Map<String, double> quantidade = {};
  final Map<String, double> pacotesMes = {};
  final Map<String, double> pacotesDia = {};

  final Map<String, double> qtdReal = {};
  final Map<String, double> mesReal = {};
  final Map<String, double> diaReal = {};

  double diasGiro = 0;

  // NOVO: Controla quais produtos estão com comentário visível
  final Map<String, bool> comentarioVisivel = {};

  // ================= COMENTÁRIOS =================
  final Map<String, Map<String, String>> comentariosProdutos = {
    'Pão Francês': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não está faltando pão para o cliente em horários de pico. Garanta que a produção esteja alinhada com o fluxo de movimento da loja, há dias em que vende mais pão, fique atento e use como referência o relatório de venda diária, assim se programa pra cada dia da semana. Pra cima que ainda dá tempo!!!",
      'ate20':
          "Calma Amigo que nada está perdido. Foque em pão quentinho nos horários de pico, mantendo o fluxo de forneamento de acordo com a venda, nada de assar muito pão de uma vez e deixar o cliente da tarde pegar o pão assado de manhã. E não menos importante: controle as sobras de geladeira pois o aspecto desse produto faz cair muito a venda. Pão feio ninguém merece né. Pra cima que ainda dá tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, talvez falte um pouco de toque de excelência, mas você é capaz. Foque em pão quentinho nos horários de pico, mantendo o fluxo de forneamento de acordo com a venda, nada de assar muito pão de uma vez e deixar o cliente da tarde pegar o pão assado de manhã. E não menos importante: controle as sobras de geladeira pois o aspecto desse produto faz cair muito a venda. Pão feio ninguém merece né. Pra cima que ainda dá, tempo!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Pão Francês Fibras': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não está faltando pão para o cliente em horários de pico. Garanta que a produção esteja alinhada com o fluxo de movimento da loja, há dias em que vende mais pão, fique atento e use como referência o relatório de venda diária, assim se programa pra cada dia da semana. Pra cima que ainda dá tempo!!!",
      'ate20':
          "Não desanime, foco e paciência é tudo. Garanta que o produto seja assado no tamanho correto, use um cortador novo e borrife água antes de realizar o corte. O cliente come com os olhos né. Não deixe faltar o produto na parte da tarde, fique atento a venda no período da manhã para engatilhar a produção da tarde. Pra cima que ainda dá, tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, talvez falte um pouco de toque de excelência mas você é capaz. Garanta que o produto seja assado no tamanho correto, use um cortador novo e borrife água antes de realizar o corte. O cliente come com os olhos né. Não deixe faltar o produto na parte da tarde, fique atento a venda no período da manhã para engatilhar a produção da tarde. Pra cima que ainda dá, tempo!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Pão Francês Panhoca': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não está faltando pão para o cliente em horários de pico. Garanta que a produção esteja alinhada com o fluxo de movimento da loja, há dias em que vende mais pão, fique atento e use como referência o relatório de venda diária, assim se programa pra cada dia da semana. Pra cima que ainda dá tempo!!!",
      'ate20':
          "Não desanime, foco e paciência é tudo. Garanta que o produto seja assado no tamanho correto, use um cortador novo e borrife água antes de realizar o corte. O cliente come com os olhos né. Não deixe faltar o produto na parte da tarde, fique atento a venda no período da manhã para engatilhar a produção da tarde. Pra cima que ainda dá, tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, talvez falte um pouco de toque de excelência mas você é capaz. Garanta que o produto seja assado no tamanho correto, use um cortador novo e borrife água antes de realizar o corte. O cliente come com os olhos né. Não deixe faltar o produto na parte da tarde, fique atento a venda no período da manhã para engatilhar a produção da tarde. Pra cima que ainda dá, tempo!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Pão Baguete Francesa': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não está faltando pão para o cliente em horários de pico. Garanta que a produção esteja alinhada com o fluxo de movimento da loja, há dias em que vende mais pão, fique atento e use como referência o relatório de venda diária, assim se programa pra cada dia da semana. Pra cima que ainda dá tempo!!!",
      'ate20':
          "Não desanime, foco e paciência é tudo. Garanta que o produto seja assado no tamanho correto, use um cortador novo e borrife água antes de realizar o corte. O cliente come com os olhos né. Não deixe faltar o produto na parte da tarde, fique atento a venda no período da manhã para engatilhar a produção da tarde. Pra cima que ainda dá, tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, talvez falte um pouco de toque de excelência mas você é capaz. Garanta que o produto seja assado no tamanho correto, use um cortador novo e borrife água antes de realizar o corte. O cliente come com os olhos né. Não deixe faltar o produto na parte da tarde, fique atento a venda no período da manhã para engatilhar a produção da tarde. Pra cima que ainda dá, tempo!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Pão Baguete Francesa Queijo': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não está faltando pão para o cliente em horários de pico. Garanta que a produção esteja alinhada com o fluxo de movimento da loja, há dias em que vende mais pão, fique atento e use como referência o relatório de venda diária, assim se programa pra cada dia da semana. Pra cima que ainda dá tempo!!!",
      'ate20':
          "Não desanime, foco e paciência é tudo. Garanta que o produto seja assado no tamanho correto, use um cortador novo e borrife água antes de realizar o corte. O cliente come com os olhos né. Não deixe faltar o produto na parte da tarde, fique atento a venda no período da manhã para engatilhar a produção da tarde. Pra cima que ainda dá, tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, talvez falte um pouco de toque de excelência mas você é capaz. Garanta que o produto seja assado no tamanho correto, use um cortador novo e borrife água antes de realizar o corte. O cliente come com os olhos né. Não deixe faltar o produto na parte da tarde, fique atento a venda no período da manhã para engatilhar a produção da tarde. Pra cima que ainda dá, tempo!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Pão Baguete Francesa Gergelim': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não está faltando pão para o cliente em horários de pico. Garanta que a produção esteja alinhada com o fluxo de movimento da loja, há dias em que vende mais pão, fique atento e use como referência o relatório de venda diária, assim se programa pra cada dia da semana. Pra cima que ainda dá tempo!!!",
      'ate20':
          "Não desanime, foco e paciência é tudo. Garanta que o produto seja assado no tamanho correto, use um cortador novo e borrife água antes de realizar o corte. O cliente come com os olhos né. Não deixe faltar o produto na parte da tarde, fique atento a venda no período da manhã para engatilhar a produção da tarde. Pra cima que ainda dá, tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, talvez falte um pouco de toque de excelência mas você é capaz. Garanta que o produto seja assado no tamanho correto, use um cortador novo e borrife água antes de realizar o corte. O cliente come com os olhos né. Não deixe faltar o produto na parte da tarde, fique atento a venda no período da manhã para engatilhar a produção da tarde. Pra cima que ainda dá, tempo!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Pão Francês com Queijo': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Mantenha o balcão sempre abastecido, principalmente nos horários de pico. Já possui ponto extra? Se não tiver é hora de montar um, quem sabe próximo a fila dos caixas... Pra cima que ainda dá tempo!!!",
      'ate20':
          "Não desanime, foco e paciência é tudo. Garanta que o produto seja assado no tamanho correto, respeitando o espaçamento. O cliente come com os olhos né. Não deixe faltar o produto na parte da tarde, fique atento a venda no período da manhã para engatilhar a produção da tarde. Já possui ponto extra? Se não tiver é hora de montar um, quem sabe próximo a fila dos caixas... Pra cima que ainda dá, tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, já têm pontos extras? Esse produto embalado têm potencial enorme de venda, quem sabe não é esse o diferencial para alcançar o objetivo. Vamos que vamos!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Baguete Francesa Queijo': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Garanta que o produto seja assado no tamanho correto, use um cortador novo e borrife água antes de realizar o corte. O cliente come com os olhos né. Não deixe faltar o produto na parte da tarde, se for o caso aumente a produção no dia anterior. Já possui ponto extra? Se não tiver é hora de montar um, quem sabe próximo a fila dos caixas... Pra cima que ainda dá tempo!!!",
      'ate20':
          "Não desanime, foco e paciência é tudo. Garanta que o produto seja assado no tamanho correto, use um cortador novo e borrife água antes de realizar o corte. O cliente come com os olhos né. Não deixe faltar o produto na parte da tarde, se for o caso aumente a produção no dia anterior. Já possui ponto extra? Se não tiver é hora de montar um, quem sabe próximo a fila dos caixas... Pra cima que ainda dá tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, já têm pontos extras? Tudo é questão de detalhe, quem sabe uma exposição bem trabalhada possa dar mais visibilidade ao produto?. Vamos que vamos!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Baguete Francesa': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Garanta que o produto seja assado no tamanho correto, use um cortador novo e borrife água antes de realizar o corte. O cliente come com os olhos né. Não deixe faltar o produto na parte da tarde, se for o caso aumente a produção no dia anterior. Já possui ponto extra? Se não tiver é hora de montar um, quem sabe próximo a fila dos caixas... Pra cima que ainda dá tempo!!!",
      'ate20':
          "Não desanime, foco e paciência é tudo. Garanta que o produto seja assado no tamanho correto, use um cortador novo e borrife água antes de realizar o corte. O cliente come com os olhos né. Não deixe faltar o produto na parte da tarde, se for o caso aumente a produção no dia anterior. Já possui ponto extra? Se não tiver é hora de montar um, quem sabe próximo a fila dos caixas... Pra cima que ainda dá tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, já têm pontos extras? Tudo é questão de detalhe, quem sabe uma exposição bem trabalhada possa dar mais visibilidade ao produto?. Vamos que vamos!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Pão Queijo Tradicional': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não está faltando pão para o cliente em horários de pico. Na abertura de loja priorize a saída desse produto o mais rápido possível, os clientes não esperam, rs... Pra cima que ainda dá tempo!!!",
      'ate20':
          "Calma Amigo que nada está perdido. Foque em pão quentinho nos horários de pico, mantendo o fluxo de forneamento de acordo com a venda, nada de assar muito pão de uma vez e deixar o cliente da tarde pegar o pão assado de manhã. Pra cima que ainda dá tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, talvez falte um pouco de toque de excelência, mas você é capaz. Na abertura de loja priorize a saída desse produto o mais rápido possível, os clientes não esperam, rs... Foque em pão quentinho nos horários de pico, mantendo o fluxo de forneamento de acordo com a venda, nada de assar muito pão de uma vez e deixar o cliente da tarde pegar o pão assado de manhã. Pra cima que ainda dá, tempo!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Pão Queijo Coquetel': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não está faltando pão para o cliente em horários de pico. Na abertura de loja priorize a saída desse produto o mais rápido possível, assim que esfriar embale, precifique e coloque no PDV. Pra cima que ainda dá tempo!!!",
      'ate20':
          "Calma Amigo que nada está perdido. Verifique se não está faltando pão para o cliente em horários de pico, principalmente a tarde. Na abertura de loja priorize a saída desse produto o mais rápido possível, assim que esfriar embale, precifique e coloque no PDV. Mesmo que tenha produto do dia anterior no PDV, não deixe de produzir, os clientes não gostam de levar quando veêm a data do dia anterior. Pra cima que ainda dá tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, já têm pontos extras? Tudo é questão de detalhe, quem sabe uma exposição bem trabalhada possa dar mais visibilidade ao produto? Ponto extra próximo a fila dos caixas é bem promissor... Vamos que vamos!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Biscoito Queijo': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não está faltando pão para o cliente em horários de pico. Na abertura de loja priorize a saída desse produto o mais rápido possível, os clientes não esperam, rs... Pra cima que ainda dá tempo!!!",
      'ate20':
          "Calma Amigo que nada está perdido. Foque em pão quentinho nos horários de pico, mantendo o fluxo de forneamento de acordo com a venda, nada de assar muito pão de uma vez e deixar o cliente da tarde pegar o pão assado de manhã. Pra cima que ainda dá tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, talvez falte um pouco de toque de excelência, mas você é capaz. Na abertura de loja priorize a saída desse produto o mais rápido possível, os clientes não esperam, rs... Foque em pão quentinho nos horários de pico, mantendo o fluxo de forneamento de acordo com a venda, nada de assar muito pão de uma vez e deixar o cliente da tarde pegar o pão assado de manhã. Pra cima que ainda dá, tempo!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Biscoito Polvilho': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção. Não deixe de trabalhar com esse produto embalado, além do balcão. Pra cima que ainda dá tempo!!!",
      'ate20':
          "Calma Amigo que nada está perdido. Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção. Não deixe de trabalhar com esse produto embalado, além do balcão. Pra cima que ainda dá tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, já têm pontos extras? Tudo é questão de detalhe, quem sabe uma exposição bem trabalhada possa dar mais visibilidade ao produto? Ponto extra próximo a fila dos caixas é bem promissor... Vamos que vamos!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Pão Tatu': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção. Como está a qualidade? Pintura e corte devem estar bem atrativos, o cliente come com os olhos... Pra cima que ainda dá tempo!!!",
      'ate20':
          "Calma Amigo que nada está perdido. Como está a qualidade? Pintura e corte devem estar bem atrativos, o cliente come com os olhos... O controle de produção deve ser bem equilibrado: não deixe faltar mas também não produza em excesso, pão fresco e macio é o que o cliente procura. Se não tiver em condições em que você compraria, é porque não está bom, né.. Pra cima que ainda dá tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, talvez falte um pouco de toque de excelência, mas você é capaz. Pintura e corte devem estar bem atrativos, o cliente come com os olhos... O controle de produção deve ser bem equilibrado: não deixe faltar mas também não produza em excesso, pão fresco e macio é o que o cliente procura. E não se esqueça de embalar o produto caso fique no armário para o dia seguinte. Vamos que vamos!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Mini Pão Sonho': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção. Como está a qualidade? O cliente come com os olhos... Pra cima que ainda dá tempo!!!",
      'ate20':
          "Calma Amigo que nada está perdido.  Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção. Como está a qualidade? O cliente come com os olhos... Use sempre creme de confeiteiro fresco e opte por uma produção diária. Mesmo que a validade seja 3 dias, em dias quentes o produto pode não aguentar até o último dia de validade. Pra cima que ainda dá tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, talvez falte um pouco de toque de excelência, mas você é capaz. Como está a qualidade? O cliente come com os olhos... Use sempre creme de confeiteiro fresco e opte por uma produção diária. Mesmo que a validade seja 3 dias, em dias quentes o produto pode não aguentar até o último dia de validade. Já possui ponto extra? Vamos que vamos!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Mini Pão Sonho Chocolate': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção. Como está a qualidade? O cliente come com os olhos... Pra cima que ainda dá tempo!!!",
      'ate20':
          "Calma Amigo que nada está perdido.  Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção. Como está a qualidade? O cliente come com os olhos... Use sempre creme de confeiteiro fresco e opte por uma produção diária. Mesmo que a validade seja 3 dias, em dias quentes o produto pode não aguentar até o último dia de validade. Pra cima que ainda dá tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, talvez falte um pouco de toque de excelência, mas você é capaz. Como está a qualidade? O cliente come com os olhos... Use sempre creme de confeiteiro fresco e opte por uma produção diária. Mesmo que a validade seja 3 dias, em dias quentes o produto pode não aguentar até o último dia de validade. Já possui ponto extra? Vamos que vamos!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Mini Marta Rocha': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção. Como está a qualidade? O cliente come com os olhos... Pra cima que ainda dá tempo!!!",
      'ate20':
          "Calma Amigo que nada está perdido.  Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção. Como está a qualidade? O cliente come com os olhos... Use sempre creme de confeiteiro fresco e opte por uma produção diária. Mesmo que a validade seja 3 dias, em dias quentes o produto pode não aguentar até o último dia de validade. Pra cima que ainda dá tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, talvez falte um pouco de toque de excelência, mas você é capaz. Como está a qualidade? O cliente come com os olhos... Use sempre creme de confeiteiro fresco e opte por uma produção diária. Mesmo que a validade seja 3 dias, em dias quentes o produto pode não aguentar até o último dia de validade. Já possui ponto extra? Vamos que vamos!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Pão Bambino': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção. Como está a qualidade? O cliente come com os olhos... Pra cima que ainda dá tempo!!!",
      'ate20':
          "Calma Amigo que nada está perdido.  Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção. Como está a qualidade? O cliente come com os olhos... Use sempre creme de confeiteiro fresco e opte por uma produção diária. Mesmo que a validade seja 3 dias, em dias quentes o produto pode não aguentar até o último dia de validade. Pra cima que ainda dá tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, talvez falte um pouco de toque de excelência, mas você é capaz. Como está a qualidade? O cliente come com os olhos... Use sempre creme de confeiteiro fresco e opte por uma produção diária. Mesmo que a validade seja 3 dias, em dias quentes o produto pode não aguentar até o último dia de validade. Já possui ponto extra? Vamos que vamos!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Pão Doce Ferradura': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção. Como está a qualidade? Pintura, tamanho e acabamento estão atrativos? O cliente come com os olhos... Pra cima que ainda dá tempo!!!",
      'ate20':
          "Calma Amigo que nada está perdido. Como está a qualidade? Pintura e acabamento estão atrativos? O cliente come com os olhos... O controle de produção deve ser bem equilibrado: não deixe faltar mas também não produza em excesso, pão fresco e macio é o que o cliente procura. Se não tiver em condições em que você compraria, é porque não está bom, né.. Pra cima que ainda dá tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, talvez falte um pouco de toque de excelência, mas você é capaz. Pintura e acabamento estão atrativos? O cliente come com os olhos... O controle de produção deve ser bem equilibrado: não deixe faltar mas também não produza em excesso, pão fresco e macio é o que o cliente procura. E não se esqueça de embalar o produto caso fique no armário para o dia seguinte. Vamos que vamos!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Pão Doce Caracol': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção. Como está a qualidade? Pintura, tamanho e acabamento estão atrativos? O cliente come com os olhos... Pra cima que ainda dá tempo!!!",
      'ate20':
          "Calma Amigo que nada está perdido. Como está a qualidade? Pintura e acabamento estão atrativos? O cliente come com os olhos... O controle de produção deve ser bem equilibrado: não deixe faltar mas também não produza em excesso, pão fresco e macio é o que o cliente procura. Se não tiver em condições em que você compraria, é porque não está bom, né.. Pra cima que ainda dá tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, talvez falte um pouco de toque de excelência, mas você é capaz. Pintura e acabamento estão atrativos? O cliente come com os olhos... O controle de produção deve ser bem equilibrado: não deixe faltar mas também não produza em excesso, pão fresco e macio é o que o cliente procura. E não se esqueça de embalar o produto caso fique no armário para o dia seguinte. Vamos que vamos!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Caseirinho': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção. Como está a qualidade? Pintura deve estar bem atrativa, o cliente come com os olhos... Procure retirar e assar o produto no mesmo dia, isso garante mais 'força' na estrutura da massa. Pra cima que ainda dá tempo!!!",
      'ate20':
          "Calma Amigo que nada está perdido.  Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção. Como está a qualidade? Pintura deve estar bem atrativa, o cliente come com os olhos... Procure retirar e assar o produto no mesmo dia, isso garante mais 'força' na estrutura da massa. O controle de produção deve ser bem equilibrado: não deixe faltar mas também não produza em excesso, pão fresco e macio é o que o cliente procura. Se não tiver em condições em que você compraria, é porque não está bom, né.. Pra cima que ainda dá tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, talvez falte um pouco de toque de excelência, mas você é capaz.  Pintura deve estar bem atrativa, o cliente come com os olhos... Procure retirar e assar o produto no mesmo dia, isso garante mais 'força' na estrutura da massa. O controle de produção deve ser bem equilibrado: não deixe faltar mas também não produza em excesso, pão fresco e macio é o que o cliente procura. E não se esqueça de embalar o produto caso fique no armário para o dia seguinte. Vamos que vamos!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Pão Fofinho': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção. Como está a qualidade? Pintura deve estar bem atrativa, o cliente come com os olhos... Procure retirar e assar o produto no mesmo dia, isso garante mais 'força' na estrutura da massa. Pra cima que ainda dá tempo!!!",
      'ate20':
          "Calma Amigo que nada está perdido.  Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção. Como está a qualidade? Pintura deve estar bem atrativa, o cliente come com os olhos... Procure retirar e assar o produto no mesmo dia, isso garante mais 'força' na estrutura da massa. O controle de produção deve ser bem equilibrado: não deixe faltar mas também não produza em excesso, pão fresco e macio é o que o cliente procura. Se não tiver em condições em que você compraria, é porque não está bom, né.. Pra cima que ainda dá tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, talvez falte um pouco de toque de excelência, mas você é capaz.  Pintura deve estar bem atrativa, o cliente come com os olhos... Procure retirar e assar o produto no mesmo dia, isso garante mais 'força' na estrutura da massa. O controle de produção deve ser bem equilibrado: não deixe faltar mas também não produza em excesso, pão fresco e macio é o que o cliente procura. Vamos que vamos!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Sanduíche Bahamas': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção, o item têm validade de 4 dias no refrigerado. Pra cima que ainda dá tempo!!!",
      'ate20':
          "Calma Amigo que nada está perdido.  Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção, o item têm validade de 4 dias no refrigerado. Pra cima que ainda dá tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, talvez falte um pouco de toque de excelência, mas você é capaz. Como está a qualidade? Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção, o item têm validade de 4 dias no refrigerado. Vamos que vamos!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Sanduíche Fofinho': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção, o item têm validade de 4 dias no refrigerado. Pra cima que ainda dá tempo!!!",
      'ate20':
          "Calma Amigo que nada está perdido.  Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção, o item têm validade de 4 dias no refrigerado. Pra cima que ainda dá tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, talvez falte um pouco de toque de excelência, mas você é capaz. Como está a qualidade? Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção, o item têm validade de 4 dias no refrigerado. Vamos que vamos!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Pão de Alho da Casa': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção, o item têm validade de 5 dias. Melhor dia para produção é quinta-feira para abranger o fim de semana. Pra cima que ainda dá tempo!!!",
      'ate20':
          "Calma Amigo que nada está perdido.  Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção, o item têm validade de 5 dias. Pra cima que ainda dá tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, talvez falte um pouco de toque de excelência, mas você é capaz. Como está a qualidade? Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção, o item têm validade de 5 dias. Melhor dia para produção é quinta-feira para abranger o fim de semana. Vamos que vamos!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Foque em pontos extras junto com outros itens dirrecionados a churrasco e bebidas. Um passo é tudo que precisa. Boa sorte!!!",
    },
    'Pão de Alho da Casa Picante': {
      'acimaMeta':
          "Parabêns!!! Você atingiu resultado de excelência! Agora é só manter o que já faz e bora para o próximo nível!!!",
      'zero':
          "Ops! Parece que seu estoque está em ruptura. Alinhe os pedidos para não deixar faltar massa em seu freezer. Se tiver dúvidas ou dificuldades pode contar com seu gestor. Pra cima que ainda dá tempo!!!",
      'ate50':
          "Vamos com calma que nada está perdido. Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção, o item têm validade de 5 dias. Melhor dia para produção é quinta-feira para abranger o fim de semana. Pra cima que ainda dá tempo!!!",
      'ate20':
          "Calma Amigo que nada está perdido.  Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção, o item têm validade de 5 dias. Pra cima que ainda dá tempo!!!",
      'ate10':
          "Sua venda não está ruim amigo, talvez falte um pouco de toque de excelência, mas você é capaz. Como está a qualidade? Verifique se não há rupturas constantes no PDV, se for o caso aumente a produção, o item têm validade de 5 dias. Melhor dia para produção é quinta-feira para abranger o fim de semana. Vamos que vamos!!!",
      'ate1':
          "Você é o cara!!! Chegou até aqui porque trabalha com excelência e vigor. Falta muito pouco, concentre em melhorar aquilo que já é bem feito. Foque em pontos extras junto com outros itens dirrecionados a churrasco e bebidas. Um passo é tudo que precisa. Boa sorte!!!",
    },
  };

  String getComentario(String produto, double atual, double quantidadeMeta) {
    if (quantidadeMeta == 0) return '';

    final dados = comentariosProdutos[produto];

    if (dados == null || dados.isEmpty) {
      return 'Comentário ainda não configurado para este produto.';
    }

    if (atual.abs() < 0.0001) {
      return dados['zero'] ?? '';
    }

    double percentualFalta = ((quantidadeMeta - atual) / quantidadeMeta) * 100;

    if (percentualFalta <= 0) {
      return dados['acimaMeta'] ?? '';
    } else if (percentualFalta >= 50) {
      return dados['ate50'] ?? '';
    } else if (percentualFalta >= 20) {
      return dados['ate20'] ?? '';
    } else if (percentualFalta >= 10) {
      return dados['ate10'] ?? '';
    } else {
      return dados['ate1'] ?? '';
    }
  }

  double _parse(String value) {
    value = value.replaceAll(',', '.');
    return double.tryParse(value) ?? 0.0;
  }

  @override
  void initState() {
    super.initState();

    for (var p in produtos) {
      vendaControllers[p.codigo] = TextEditingController();
      precoControllers[p.codigo] = TextEditingController();

      meta[p.codigo] = 0;
      quantidade[p.codigo] = 0;
      pacotesMes[p.codigo] = 0;
      pacotesDia[p.codigo] = 0;

      qtdReal[p.codigo] = 0;
      mesReal[p.codigo] = 0;
      diaReal[p.codigo] = 0;

      // Inicializa todos os comentários como ocultos
      comentarioVisivel[p.codigo] = false;
    }

    carregarDados();
    carregarVendasFirebase();
  }

  Future<void> carregarVendasFirebase() async {
    try {
      final lojaDoc =
          await _firestore.collection('stores').doc(widget.storeName).get();

      if (!lojaDoc.exists) {
        print('❌ Loja não encontrada');
        return;
      }

      final data = lojaDoc.data() ?? {};

      var dias = data['diasGiro'];

      if (dias is int) {
        diasGiro = dias.toDouble();
      } else if (dias is double) {
        diasGiro = dias;
      } else {
        diasGiro = 0;
      }

      final vendasData = data['vendas'] ?? {};

      qtdReal.clear();
      mesReal.clear();
      diaReal.clear();

      for (var p in produtos) {
        var valorFirebase = vendasData[p.nome];

        double valor = 0;

        if (valorFirebase is int) {
          valor = valorFirebase.toDouble();
        } else if (valorFirebase is double) {
          valor = valorFirebase;
        } else if (valorFirebase is String) {
          valor = double.tryParse(valorFirebase.replaceAll(',', '.')) ?? 0;
        }

        if (diasGiro > 0) {
          double quantidadeCalc = 0;
          double mesCalc = 0;
          double diaCalc = 0;

          if (valor > 0) {
            quantidadeCalc = (valor / diasGiro) * 30.5;
            mesCalc = quantidadeCalc / p.fatorPacote;
            diaCalc = mesCalc / 26;
          }

          qtdReal[p.codigo] = quantidadeCalc;
          mesReal[p.codigo] = mesCalc;
          diaReal[p.codigo] = diaCalc;
        }
      }

      setState(() {});
    } catch (e) {
      print('❌ ERRO: $e');
    }
  }

  Future<void> salvarDados() async {
    Map<String, dynamic> dados = {};

    for (var p in produtos) {
      dados[p.codigo] = {
        'nome': p.nome,
        'venda': _parse(vendaControllers[p.codigo]!.text),
        'preco': _parse(precoControllers[p.codigo]!.text),
        'meta': meta[p.codigo],
        'quantidade': quantidade[p.codigo],
        'pacotesMes': pacotesMes[p.codigo],
        'pacotesDia': pacotesDia[p.codigo],
      };
    }

    await _firestore.collection('metas').doc(widget.storeName).set({
      'percentual': _parse(percentualController.text),
      'produtos': dados,
    });
  }

  Future<void> carregarDados() async {
    final doc =
        await _firestore.collection('metas').doc(widget.storeName).get();

    if (!doc.exists) return;

    final data = doc.data()!;

    percentualController.text = (data['percentual'] ?? 20).toString();

    final produtosData = data['produtos'] ?? {};

    for (var p in produtos) {
      if (produtosData[p.codigo] != null) {
        vendaControllers[p.codigo]!.text =
            (produtosData[p.codigo]['venda'] ?? '').toString();

        precoControllers[p.codigo]!.text =
            (produtosData[p.codigo]['preco'] ?? '').toString();
      }
    }

    calcular();
  }

  void calcular() {
    double percentual = _parse(percentualController.text);

    setState(() {
      for (var p in produtos) {
        double venda = _parse(vendaControllers[p.codigo]!.text);
        double preco = _parse(precoControllers[p.codigo]!.text);

        double novaMeta = venda * (1 + percentual / 100);

        double novaQuantidade = 0;
        double novosPacotesMes = 0;
        double novosPacotesDia = 0;

        if (preco > 0) {
          novaQuantidade = novaMeta / preco;
          novosPacotesMes = novaQuantidade / p.fatorPacote;
          novosPacotesDia = novosPacotesMes / 26;
        }

        meta[p.codigo] = novaMeta;
        quantidade[p.codigo] = novaQuantidade;
        pacotesMes[p.codigo] = novosPacotesMes;
        pacotesDia[p.codigo] = novosPacotesDia;
      }
    });

    salvarDados();
  }

  Widget buildProduto(Produto p) {
    double diffQtd = (qtdReal[p.codigo] ?? 0) - (quantidade[p.codigo] ?? 0);
    double diffMes = (mesReal[p.codigo] ?? 0) - (pacotesMes[p.codigo] ?? 0);
    double diffDia = (diaReal[p.codigo] ?? 0) - (pacotesDia[p.codigo] ?? 0);

    Color cor = diffQtd >= 0 ? Colors.green : Colors.red;

    final comentario = getComentario(
      p.nome,
      qtdReal[p.codigo] ?? 0,
      quantidade[p.codigo] ?? 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(p.nome,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text(p.codigo, style: TextStyle(color: Color(0xff4b48ed))),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: vendaControllers[p.codigo],
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Venda Base',
                    prefixText: 'R\$ ',
                  ),
                  onChanged: (_) => calcular(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: precoControllers[p.codigo],
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Preço Atual',
                    prefixText: 'R\$ ',
                  ),
                  onChanged: (_) => calcular(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text('Meta',
              style: TextStyle(color: Color(0xff08550c), fontSize: 18)),

          Text('R\$ ${(meta[p.codigo] ?? 0).toStringAsFixed(2)}',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

          const SizedBox(height: 12),

          Column(
            children: [
              buildIndicador(
                  'Quantidade (Kg/Unid)', quantidade[p.codigo] ?? 0, 0),
              buildIndicador('Pacotes/Mês', pacotesMes[p.codigo] ?? 0, 1),
              buildIndicador('Pacotes/Dia', pacotesDia[p.codigo] ?? 0, 1,
                  destaque: true),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Quantidade atual: ${(qtdReal[p.codigo] ?? 0).toStringAsFixed(0)} (${diffQtd >= 0 ? '+' : ''}${diffQtd.toStringAsFixed(0)})',
            style: TextStyle(color: cor, fontSize: 15),
          ),
          Text(
            'Pacotes/Mês atual: ${(mesReal[p.codigo] ?? 0).toStringAsFixed(1)} (${diffMes >= 0 ? '+' : ''}${diffMes.toStringAsFixed(1)})',
            style: TextStyle(color: cor, fontSize: 15),
          ),
          Text(
            'Pacotes/Dia atual: ${(diaReal[p.codigo] ?? 0).toStringAsFixed(1)} (${diffDia >= 0 ? '+' : ''}${diffDia.toStringAsFixed(1)})',
            style: TextStyle(color: cor, fontSize: 15),
          ),

          const SizedBox(height: 10),

          // Botão "Dica" e comentário
          if (comentario.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      comentarioVisivel[p.codigo] =
                          !comentarioVisivel[p.codigo]!;
                    });
                  },
                  icon: Icon(
                    comentarioVisivel[p.codigo]!
                        ? Icons.visibility_off
                        : Icons.lightbulb_outline,
                    size: 18,
                  ),
                  label: Text(
                    comentarioVisivel[p.codigo]! ? "Ocultar Dica" : "Dica",
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffecc078),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(80, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                if (comentarioVisivel[p.codigo]!)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb,
                            color: Colors.amber.shade700, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            comentario,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade800,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildIndicador(String label, double valor, int casas,
      {bool destaque = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          Text(
            (valor).toStringAsFixed(casas),
            style: TextStyle(
              fontSize: destaque ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: destaque ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0x762586e5),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SecondScreen(storeName: widget.storeName),
              ),
            );
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/Logo StockOne.png', height: 32),
            const SizedBox(width: 8),
            const Text("METAS",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lora',
                    color: Colors.white)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: TextField(
                controller: percentualController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Percentual (%)'),
                onChanged: (_) => calcular(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: produtos.map(buildProduto).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ManutencaoScreen extends StatelessWidget {
  const ManutencaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2691E),
        centerTitle: true,
        title: const Text(
          "METAS",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFE5B4),
              Color(0xFFD29752),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.construction,
                  size: 80,
                  color: Colors.brown.shade700,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Em manutenção",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Estamos trabalhando para melhorar sua experiência.\nVolte em breve!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF5D4037),
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TelaMetasLojas extends StatelessWidget {
  const TelaMetasLojas({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Metas por Loja',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),
      home: const ListaLojasScreen(),
    );
  }
}

class ListaLojasScreen extends StatelessWidget {
  const ListaLojasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0x762586e5),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Bahamas(),
              ),
            );
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/Logo StockOne.png', height: 32),
            const SizedBox(width: 8),
            const Text(
              "METAS POR LOJA",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lora',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('metas').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final lojas = snapshot.data?.docs ?? [];

          if (lojas.isEmpty) {
            return const Center(child: Text('Nenhuma loja encontrada'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lojas.length,
            itemBuilder: (context, index) {
              final lojaDoc = lojas[index];
              final nomeLoja = lojaDoc.id;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.store,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  title: Text(
                    nomeLoja,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MetasProdutosScreen(lojaId: nomeLoja),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MetasProdutosScreen extends StatefulWidget {
  final String lojaId;

  const MetasProdutosScreen({
    super.key,
    required this.lojaId,
  });

  @override
  State<MetasProdutosScreen> createState() => _MetasProdutosScreenState();
}

class _MetasProdutosScreenState extends State<MetasProdutosScreen> {
  double diasGiro = 0;
  Map<String, dynamic> vendasData = {};

  @override
  void initState() {
    super.initState();
    carregarVendas();
  }

  Future<void> carregarVendas() async {
    final doc = await FirebaseFirestore.instance
        .collection('stores')
        .doc(widget.lojaId)
        .get();

    if (!doc.exists) return;

    final data = doc.data() ?? {};

    final dias = data['diasGiro'];

    if (dias is int) {
      diasGiro = dias.toDouble();
    } else if (dias is double) {
      diasGiro = dias;
    } else {
      diasGiro = 0;
    }

    vendasData = data['vendas'] ?? {};

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0x762586e5),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/Logo StockOne.png', height: 32),
            const SizedBox(width: 8),
            Text(
              "METAS - ${widget.lojaId}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lora',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('metas')
            .doc(widget.lojaId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
                child: Text('Nenhuma meta encontrada para esta loja'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final Map<String, dynamic> produtos =
              (data['produtos'] as Map<String, dynamic>?) ?? {};

          final listaProdutos = produtos.entries.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listaProdutos.length,
            itemBuilder: (context, index) {
              final codigo = listaProdutos[index].key;
              final produtoData =
                  listaProdutos[index].value as Map<String, dynamic>;

              final nome = produtoData['nome'] ?? codigo;
              final meta = (produtoData['meta'] ?? 0).toDouble();
              final preco = (produtoData['preco'] ?? 0).toDouble();

              double vendas = 0;

              var valorFirebase = vendasData[nome];

              if (valorFirebase is int) {
                vendas = valorFirebase.toDouble();
              } else if (valorFirebase is double) {
                vendas = valorFirebase;
              } else if (valorFirebase is String) {
                vendas =
                    double.tryParse(valorFirebase.replaceAll(',', '.')) ?? 0;
              }

              double projecao = 0;

              if (diasGiro > 0) {
                projecao = ((vendas / diasGiro) * 30.5) * preco;
              }

              final bool abaixoMeta = projecao < meta;
              final cor = abaixoMeta ? Colors.red : Colors.green;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'META',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'R\$ ${meta.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cor.withOpacity(0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PROJEÇÃO',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: cor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'R\$ ${projecao.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: cor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Requisicao extends StatefulWidget {
  final String storeName;

  const Requisicao({super.key, required this.storeName});

  @override
  State<Requisicao> createState() => _RequisicaoState();
}

class _RequisicaoState extends State<Requisicao>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, TextEditingController> controllersProducao = {};
  final Map<String, TextEditingController> controllersPerdas = {};

  late TabController _tabController;

  // Estado para forçar rebuild da aba Planilha quando os dados mudarem
  final ValueNotifier<int> _planilhaNotifier = ValueNotifier<int>(0);

  // Data atual para exibir na planilha
  DateTime _dataSelecionada = DateTime.now();
  late String _responsavel;

  // ------------------ PRODUÇÃO ------------------
  final List<Map<String, String>> produtosProducao = [
    {
      "codigo": "33639",
      "nome": "PÃO FRANCÊS",
      "hint": "Preencher a quantidade de pacotes abertos",
      "unidade": "PACOTE",
      "imagem": "assets/images/paofrancesx.png",
    },
    {
      "codigo": "336392",
      "nome": "PÃO CERVEJINHA",
      "hint": "Preencher a quantidade de pacotes abertos",
      "unidade": "PACOTE",
      "imagem": "assets/images/paofrancespanhocax.png",
    },
    {
      "codigo": "164966",
      "nome": "PÃO FRANCÊS FIBRAS",
      "hint": "Preencher a quantidade de pacotes abertos",
      "unidade": "PACOTE",
      "imagem": "assets/images/paofrancesfibrasx.png",
    },
    {
      "codigo": "81235",
      "nome": "PÃO BAGUETE FRANCESA",
      "hint": "Preencher a quantidade de pacotes abertos",
      "unidade": "PACOTE",
      "imagem": "assets/images/paobagutefrancesax.png",
    },
    {
      "codigo": "62948",
      "nome": "PÃO DE QUEIJO TRADICIONAL",
      "hint": "Preencher a quantidade de pacotes abertos",
      "unidade": "PACOTE",
      "imagem": "assets/images/paodequeijotradicionalx.png",
    },
    {
      "codigo": "65139",
      "nome": "PÃO DE QUEIJO COQUETEL",
      "hint": "Preencher a quantidade de pacotes abertos",
      "unidade": "PACOTE",
      "imagem": "assets/images/paodequeijocoquetelx.png",
    },
    {
      "codigo": "97922",
      "nome": "BISCOITO POLVILHO",
      "hint": "Preencher a quantidade de mangas usadas",
      "unidade": "MANGA",
      "imagem": "assets/images/biscoitopolvilhox.png",
    },
    {
      "codigo": "146428",
      "nome": "BISCOITO DE QUEIJO",
      "hint": "Preencher a quantidade de pacotes abertos",
      "unidade": "PACOTE",
      "imagem": "assets/images/biscoitodequeijox.png",
    },
    {
      "codigo": "42842",
      "nome": "PÃO TATU",
      "hint": "Preencher a quantidade de pacotes abertos",
      "unidade": "PACOTE",
      "imagem": "assets/images/paotatux.png",
    },
    {
      "codigo": "106793",
      "nome": "PÃO FOFINHO",
      "hint": "Preencher a quantidade de pacotes abertos",
      "unidade": "PACOTE",
      "imagem": "assets/images/paofofinhox.png",
    },
    {
      "codigo": "132318",
      "nome": "PÃO SAMARITANO",
      "hint": "Preencher em unidades a produção",
      "unidade": "UNID",
      "imagem": "assets/images/paosamaritanox.png",
    },
    {
      "codigo": "132319",
      "nome": "PÃO PIZZA",
      "hint": "Preencher em unidades a produção",
      "unidade": "UNID",
      "imagem": "assets/images/paopizzax.png",
    },
    {
      "codigo": "132317",
      "nome": "PÃO DE ALHO DA CASA",
      "hint": "Preencher a quantidade de bandejas produzidas",
      "unidade": "BANDEJA",
      "imagem": "assets/images/paodealhodacasax.png",
    },
    {
      "codigo": "132320",
      "nome": "PÃO DE ALHO DA CASA PICANTE",
      "hint": "Preencher a quantidade de bandejas produzidas",
      "unidade": "BANDEJA",
      "imagem": "assets/images/paodealhodacasax.png",
    },
    {
      "codigo": "62901",
      "nome": "RABANADA ASSADA",
      "hint": "Pesar a quantidade produzida",
      "unidade": "KG",
      "imagem": "assets/images/rabanadaassadax.png",
    },
    {
      "codigo": "148231",
      "nome": "ROSCA DOCE CÔCO E QUEIJO",
      "hint": "Preencher em unidades a produção",
      "unidade": "UNID",
      "imagem": "assets/images/roscacocoequeijox.png",
    },
    {
      "codigo": "142099",
      "nome": "SANDUÍCHE FOFINHO",
      "hint": "Preencher em unidades a produção",
      "unidade": "UNID",
      "imagem": "assets/images/sanduichefofinho.png",
    },
    {
      "codigo": "142098",
      "nome": "ROSCA FOFINHA TEMPERADA",
      "hint": "Preencher em unidades a produção",
      "unidade": "UNID",
      "imagem": "assets/images/roscafofinhatemperadax.png",
    },
    {
      "codigo": "112727",
      "nome": "MINI PÃO SONHO",
      "hint": "Pesar a quantidade produzida",
      "unidade": "KG",
      "imagem": "assets/images/minipaosonhox.png",
    },
    {
      "codigo": "1127272",
      "nome": "MINI PÃO SONHO CHOCOLATE",
      "hint": "Pesar a quantidade produzida",
      "unidade": "KG",
      "imagem": "assets/images/minipaosonhochocolatex.png",
    },
    {
      "codigo": "1127273",
      "nome": "BAMBINO",
      "hint": "Pesar a quantidade produzida",
      "unidade": "KG",
      "imagem": "assets/images/paobambinox.png",
    },
    {
      "codigo": "112731",
      "nome": "MINI MARTA ROCHA",
      "hint": "Pesar a quantidade produzida",
      "unidade": "KG",
      "imagem": "assets/images/minipaomartarochax.png",
    },
    {
      "codigo": "81238",
      "nome": "PÃO DOCE CARACOL",
      "hint": "Pesar a quantidade produzida",
      "unidade": "KG",
      "imagem": "assets/images/paodocecaracolx.png",
    },
    {
      "codigo": "81240",
      "nome": "PÃO DOCE FERRADURA",
      "hint": "Pesar a quantidade produzida",
      "unidade": "KG",
      "imagem": "assets/images/paodoceferradurax.png",
    },
  ];

  // ------------------ PERDAS ------------------
  final List<Map<String, String>> produtosPerdas = [
    {
      "codigo": "132318",
      "nome": "PÃO SAMARITANO",
      "hint": "Preencher em unidades a perda",
      "unidade": "UNID",
      "imagem": "assets/images/paosamaritanox.png",
    },
    {
      "codigo": "132319",
      "nome": "PÃO PIZZA",
      "hint": "Preencher em unidades a perda",
      "unidade": "UNID",
      "imagem": "assets/images/paopizzax.png",
    },
    {
      "codigo": "132317",
      "nome": "PÃO DE ALHO DA CASA",
      "hint": "Preencher a quantidade de bandejas perdidas",
      "unidade": "BANDEJA",
      "imagem": "assets/images/paodealhodacasax.png",
    },
    {
      "codigo": "132320",
      "nome": "PÃO DE ALHO DA CASA PICANTE",
      "hint": "Preencher a quantidade de bandejas perdidas",
      "unidade": "BANDEJA",
      "imagem": "assets/images/paodealhodacasapicantex.png",
    },
    {
      "codigo": "148231",
      "nome": "ROSCA CÔCO E QUEIJO",
      "hint": "Preencher em unidades a perda",
      "unidade": "UNID",
      "imagem": "assets/images/roscacocoequeijox.png",
    },
    {
      "codigo": "142099",
      "nome": "SANDUÍCHE FOFINHO",
      "hint": "Preencher em unidades a perda",
      "unidade": "UNID",
      "imagem": "assets/images/sanduichefofinho.png",
    },
    {
      "codigo": "142098",
      "nome": "ROSCA FOFINHA TEMPERADA",
      "hint": "Preencher em unidades a perda",
      "unidade": "UNID",
      "imagem": "assets/images/roscafofinhatemperadax.png",
    },
    {
      "codigo": "132471",
      "nome": "BAGUETE FRANCESA",
      "hint": "Preencher em unidades a perda",
      "unidade": "UNID",
      "imagem": "assets/images/baguetefrancesax.png",
    },
    {
      "codigo": "1324712",
      "nome": "BAGUETE FRANCESA C/ QUEIJO",
      "hint": "Preencher em unidades a perda",
      "unidade": "UNID",
      "imagem": "assets/images/baguetefrancesacomqueijox.png",
    },
    {
      "codigo": "62948",
      "nome": "PÃO DE QUEIJO TRADICIONAL",
      "hint": "Pesar a quantidade perdida",
      "unidade": "KG",
      "imagem": "assets/images/paodequeijotradicionalx.png",
    },
    {
      "codigo": "65139",
      "nome": "PÃO DE QUEIJO COQUETEL",
      "hint": "Pesar a quantidade perdida",
      "unidade": "KG",
      "imagem": "assets/images/paodequeijocoquetelx.png",
    },
    {
      "codigo": "97922",
      "nome": "BISCOITO POLVILHO",
      "hint": "Pesar a quantidade perdida",
      "unidade": "KG",
      "imagem": "assets/images/biscoitopolvilhox.png",
    },
    {
      "codigo": "146428",
      "nome": "BISCOITO DE QUEIJO",
      "hint": "Pesar a quantidade perdida",
      "unidade": "KG",
      "imagem": "assets/images/biscoitodequeijox.png",
    },
    {
      "codigo": "42842",
      "nome": "PÃO TATU",
      "hint": "Pesar a quantidade perdida",
      "unidade": "KG",
      "imagem": "assets/images/paotatux.png",
    },
    {
      "codigo": "106793",
      "nome": "PÃO FOFINHO",
      "hint": "Pesar a quantidade perdida",
      "unidade": "KG",
      "imagem": "assets/images/paofofinhox.png",
    },
    {
      "codigo": "112727",
      "nome": "MINI PÃO SONHO",
      "hint": "Pesar a quantidade perdida",
      "unidade": "KG",
      "imagem": "assets/images/minipaosonhox.png",
    },
    {
      "codigo": "1127272",
      "nome": "MINI PÃO SONHO CHOCOLATE",
      "hint": "Pesar a quantidade perdida",
      "unidade": "KG",
      "imagem": "assets/images/minipaosonhochocolatex.png",
    },
    {
      "codigo": "1127273",
      "nome": "BAMBINO",
      "hint": "Pesar a quantidade perdida",
      "unidade": "KG",
      "imagem": "assets/images/paobambinox.png",
    },
    {
      "codigo": "112731",
      "nome": "MINI MARTA ROCHA",
      "hint": "Pesar a quantidade perdida",
      "unidade": "KG",
      "imagem": "assets/images/minipaomartarochax.png",
    },
    {
      "codigo": "1067932",
      "nome": "PÃO CASEIRINHO",
      "hint": "Pesar a quantidade perdida",
      "unidade": "KG",
      "imagem": "assets/images/paocaseirinhox.png",
    },
    {
      "codigo": "81238",
      "nome": "PÃO DOCE CARACOL",
      "hint": "Pesar a quantidade perdida",
      "unidade": "KG",
      "imagem": "assets/images/paodocecaracolx.png",
    },
    {
      "codigo": "81240",
      "nome": "PÃO DOCE FERRADURA",
      "hint": "Pesar a quantidade perdida",
      "unidade": "KG",
      "imagem": "assets/images/paodoceferradurax.png",
    },
    {
      "codigo": "81235",
      "nome": "PÃO BAGUETE FRANCESA C/ QUEIJO",
      "hint": "Pesar a quantidade perdida",
      "unidade": "KG",
      "imagem": "assets/images/paobaguetefrancesacomqueijox.png",
    },
    {
      "codigo": "812352",
      "nome": "PÃO BAGUETE FRANCESA C/ GERGELIM",
      "hint": "Pesar a quantidade perdida",
      "unidade": "KG",
      "imagem": "assets/images/paobaguetefrancesacomgergelimx.png",
    },
    {
      "codigo": "68170",
      "nome": "PÂO FRANCÊS C/ QUEIJO",
      "hint": "Pesar a quantidade perdida",
      "unidade": "KG",
      "imagem": "assets/images/paofrancescomqueijox.png",
    },
    {
      "codigo": "62901",
      "nome": "RABANADA ASSADA",
      "hint": "Pesar a quantidade perdida",
      "unidade": "KG",
      "imagem": "assets/images/rabanadaassadax.png",
    },
    {
      "codigo": "131281",
      "nome": "PÃO PARA RABANADA",
      "hint": "Pesar a quantidade perdida",
      "unidade": "KG",
      "imagem": "assets/images/paopararabanadax.png",
    },
  ];

  // Função para formatar o número (sem decimais se for inteiro)
  String _formatNumber(dynamic valor) {
    if (valor is double) {
      if (valor == valor.roundToDouble()) {
        return valor.round().toString();
      } else {
        return valor.toStringAsFixed(2);
      }
    } else if (valor is int) {
      return valor.toString();
    } else {
      return '0';
    }
  }

  // Função para converter string com vírgula ou ponto para double
  double _parseInputValue(String value) {
    if (value.isEmpty) return 0.0;
    String normalizedValue = value.replaceAll(',', '.');
    return double.tryParse(normalizedValue) ?? 0.0;
  }

  // Função auxiliar para pegar um valor numérico do controller (segura)
  double _getValorController(
      Map<String, TextEditingController> controllers, String codigo) {
    final text = controllers[codigo]?.text.trim() ?? '';
    if (text.isEmpty) return 0.0;
    return _parseInputValue(text);
  }

  int _getValorControllerInt(
      Map<String, TextEditingController> controllers, String codigo) {
    final text = controllers[codigo]?.text.trim() ?? '';
    if (text.isEmpty) return 0;
    return _parseInputValue(text).round();
  }

  // --- Cálculos para o Motivo 49 ---
  Map<String, dynamic> _calcularMotivo49() {
    return {
      'paoFrances': _getValorController(controllersProducao, '33639') * 2.1 +
          _getValorController(controllersProducao, '336392') * 0.66,
      'paoFrancesFibras':
          _getValorController(controllersProducao, '164966') * 0.66,
      'massaBaguete': _getValorController(controllersProducao, '81235') * 0.66,
      'paoQueijoTradicional':
          _getValorController(controllersProducao, '62948') * 0.99,
      'paoQueijoCoquetel':
          _getValorController(controllersProducao, '65139') * 0.99,
      'biscoitoPolvilho':
          _getValorController(controllersProducao, '97922') * 0.567,
      'biscoitoQueijo':
          _getValorController(controllersProducao, '146428') * 0.99,
      'paoTatu': _getValorController(controllersProducao, '42842') * 0.33,
      'paoFofinho': _getValorController(controllersProducao, '106793') * 0.495,
    };
  }

  // --- Cálculos para o Motivo 8 ---
  Map<String, dynamic> _calcularMotivo8() {
    return {
      'baguete': (_getValorController(controllersProducao, '132317') +
              _getValorController(controllersProducao, '132320')) *
          0.27,
      'paoFrances': _getValorController(controllersProducao, '132318') * 0.09,
      'miniMarta': _getValorController(controllersProducao, '132319') * 0.06,
      'rabanada': _getValorControllerInt(controllersProducao, '148231') +
          (_getValorController(controllersProducao, '62901') / 0.8).round(),
      'paoFofinho': _getValorController(controllersProducao, '142099') * 0.06,
    };
  }

  // --- Cálculos para o Motivo 23 (Perdas) ---
  Map<String, dynamic> _calcularMotivo23() {
    return {
      'bagueteFrancesa': _getValorController(controllersPerdas, '132471') +
          _getValorController(controllersPerdas, '1324712'),
      'bambino': _getValorController(controllersPerdas, '112727') +
          _getValorController(controllersPerdas, '1127272') +
          _getValorController(controllersPerdas, '1127273'),
      'biscoitoQueijo': _getValorController(controllersPerdas, '146428'),
      'biscoitoPolvilho': _getValorController(controllersPerdas, '97922'),
      'miniMarta': _getValorController(controllersPerdas, '112731'),
      'baguete': _getValorController(controllersPerdas, '81235') +
          _getValorController(controllersPerdas, '812352'),
      'paoFofinho': _getValorController(controllersPerdas, '106793') +
          _getValorController(controllersPerdas, '1067932'),
      'paoQueijoCoquetel': _getValorController(controllersPerdas, '65139'),
      'paoQueijoTradicional': _getValorController(controllersPerdas, '62948'),
      'paoDoceCaracol': _getValorController(controllersPerdas, '81238'),
      'paoDoceFerradura': _getValorController(controllersPerdas, '81240'),
      'paoTatu': _getValorController(controllersPerdas, '42842'),
      'paoRabanada': _getValorController(controllersPerdas, '131281'),
      'miniBaguetinha': _getValorController(controllersPerdas, '68170'),
      'sanduicheFofinho': _getValorController(controllersPerdas, '142099'),
      'paoSamaritano': _getValorController(controllersPerdas, '132318'),
      'paoPizza': _getValorController(controllersPerdas, '132319'),
      'paoAlhoCasa': _getValorController(controllersPerdas, '132317'),
      'paoAlhoCasaPicante': _getValorController(controllersPerdas, '132320'),
      'roscaFofinha': _getValorController(controllersPerdas, '142098'),
      'roscaCocoQueijo': _getValorController(controllersPerdas, '148231'),
      'rabanadaAssada': _getValorController(controllersPerdas, '62901'),
    };
  }

  // --- Cálculos para o Motivo 9 ---
  Map<String, dynamic> _calcularMotivo9() {
    return {
      'sanduicheFofinho': _getValorController(controllersProducao, '142099'),
      'paoSamaritano': _getValorController(controllersProducao, '132318'),
      'paoPizza': _getValorController(controllersProducao, '132319'),
      'paoAlhoCasa': _getValorController(controllersProducao, '132317'),
      'paoAlhoCasaPicante': _getValorController(controllersProducao, '132320'),
      'roscaFofinha': _getValorController(controllersProducao, '142098'),
      'roscaCocoQueijo': _getValorController(controllersProducao, '148231'),
      'rabanadaAssada': _getValorController(controllersProducao, '62901'),
      'bambino': (_getValorController(controllersProducao, '112727') +
              _getValorController(controllersProducao, '1127272') +
              _getValorController(controllersProducao, '1127273')) /
          1.6,
      'miniMarta': _getValorController(controllersProducao, '112731') / 1.6,
      'paoDoceCaracol': _getValorController(controllersProducao, '81238') / 4.5,
      'paoDoceFerradura':
          _getValorController(controllersProducao, '81240') / 3.3,
    };
  }

  // Função para limpar todos os dados de uma coleção
  Future<void> _limparDados(String tipo, String titulo) async {
    // Mostrar diálogo de confirmação
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Limpar $titulo'),
          content: Text(
            'Tem certeza que deseja limpar todos os dados de $titulo?\n\nEsta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Limpar'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    // Mostrar indicador de carregamento
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Limpar cada documento da coleção
      final controllers =
          tipo == 'producao' ? controllersProducao : controllersPerdas;
      final produtos = tipo == 'producao' ? produtosProducao : produtosPerdas;

      // Criar um batch para operações em lote (mais rápido)
      final batch = _firestore.batch();

      for (var item in produtos) {
        final codigo = item['codigo']!;

        // Limpar o TextController
        controllers[codigo]?.clear();

        // Adicionar ao batch para deletar
        final docRef = _firestore
            .collection('stores')
            .doc(widget.storeName)
            .collection(tipo)
            .doc(codigo);

        batch.delete(docRef);
      }

      // Executar todas as deleções de uma única vez
      await batch.commit();

      // Atualizar a planilha
      _planilhaNotifier.value++;

      // Fechar o diálogo de carregamento
      if (context.mounted) Navigator.of(context).pop();

      // Mostrar mensagem de sucesso
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$titulo limpo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Fechar o diálogo de carregamento
      if (context.mounted) Navigator.of(context).pop();

      // Mostrar mensagem de erro
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao limpar $titulo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _carregarResponsavel() async {
    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        setState(() {
          _responsavel = data['userName'] ?? '';
        });
      }
    } catch (e) {
      print('Erro ao carregar responsável: $e');
      setState(() {
        _responsavel = '';
      });
    }
  }

  // Função para compartilhar em PDF
  // Função para compartilhar em PDF
  Future<void> _compartilharPlanilhaPDF() async {
    final motivo49 = _calcularMotivo49();
    final motivo8 = _calcularMotivo8();
    final motivo23 = _calcularMotivo23();
    final motivo9 = _calcularMotivo9();

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'REQUISIÇÃO PADARIA',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            '${widget.storeName.toUpperCase()}',
            style: pw.TextStyle(fontSize: 14),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Responsável: $_responsavel',
            style: pw.TextStyle(fontSize: 14),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Data: ${DateFormat('dd/MM/yyyy').format(_dataSelecionada)}',
            style: pw.TextStyle(fontSize: 14),
          ),
          pw.SizedBox(height: 30),
          _buildMotivoPDF('MOTIVO 49', _getMotivo49Items(motivo49)),
          pw.SizedBox(height: 20),
          _buildMotivoPDF('MOTIVO 8', _getMotivo8Items(motivo8)),
          pw.SizedBox(height: 20),
          _buildMotivoPDF('MOTIVO 23', _getMotivo23Items(motivo23)),
          pw.SizedBox(height: 20),
          _buildMotivoPDF('MOTIVO 9', _getMotivo9Items(motivo9)),
          pw.SizedBox(height: 40),
          pw.Text(
            'ASSINATURA: __________________________________',
            style: pw.TextStyle(fontSize: 14, fontStyle: pw.FontStyle.italic),
          ),
        ],
      ),
    );

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final bytes = await pdf.save();

      // Para Web - faz download
      if (kIsWeb) {
        final base64 = base64Encode(bytes);
        final anchor = html.AnchorElement(
            href:
                'data:application/octet-stream;charset=utf-16le;base64,$base64')
          ..setAttribute('download',
              'requisicao_padaria_${widget.storeName}_${DateFormat('ddMMyyyy').format(_dataSelecionada)}.pdf')
          ..click();

        if (context.mounted) Navigator.of(context).pop();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF baixado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Para Mobile - compartilha
        final dir = await getTemporaryDirectory();
        final fileName =
            'requisicao_padaria_${widget.storeName}_${DateFormat('ddMMyyyy').format(_dataSelecionada)}.pdf';
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text:
              'Requisição Padaria - ${widget.storeName} - ${DateFormat('dd/MM/yyyy').format(_dataSelecionada)}',
        );

        if (context.mounted) Navigator.of(context).pop();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF gerado e compartilhado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

// Função para construir tabela do motivo no PDF
  pw.Widget _buildMotivoPDF(String titulo, List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            titulo,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Nenhum registro',
            style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic),
          ),
        ],
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          titulo,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.5),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FlexColumnWidth(1.5),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('CÓDIGO',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('PRODUTO',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('QUANTIDADE',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            ...items.map((item) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item['codigo']),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item['produto']),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child:
                          pw.Text('${item['quantidade']} ${item['unidade']}'),
                    ),
                  ],
                )),
          ],
        ),
      ],
    );
  }

// Funções para extrair itens de cada motivo (TODAS usando _formatNumber)
  List<Map<String, dynamic>> _getMotivo49Items(Map<String, dynamic> motivo49) {
    final items = <Map<String, dynamic>>[];

    if (motivo49['paoFrances'] > 0) {
      items.add({
        'codigo': '33639',
        'produto': 'Massa Pão Francês',
        'quantidade': _formatNumber(motivo49['paoFrances']),
        'unidade': 'KG',
      });
    }
    if (motivo49['paoFrancesFibras'] > 0) {
      items.add({
        'codigo': '164966',
        'produto': 'Massa Pão Francês Fibras',
        'quantidade': _formatNumber(motivo49['paoFrancesFibras']),
        'unidade': 'KG',
      });
    }
    if (motivo49['paoQueijoTradicional'] > 0) {
      items.add({
        'codigo': '62948',
        'produto': 'Massa Pão de Queijo Tradicional',
        'quantidade': _formatNumber(motivo49['paoQueijoTradicional']),
        'unidade': 'KG',
      });
    }
    if (motivo49['paoQueijoCoquetel'] > 0) {
      items.add({
        'codigo': '65139',
        'produto': 'Massa Pão de Queijo Coquetel',
        'quantidade': _formatNumber(motivo49['paoQueijoCoquetel']),
        'unidade': 'KG',
      });
    }
    if (motivo49['biscoitoPolvilho'] > 0) {
      items.add({
        'codigo': '97922',
        'produto': 'Massa Biscoito Polvilho',
        'quantidade': _formatNumber(motivo49['biscoitoPolvilho']),
        'unidade': 'KG',
      });
    }
    if (motivo49['biscoitoQueijo'] > 0) {
      items.add({
        'codigo': '146428',
        'produto': 'Massa Biscoito de Queijo',
        'quantidade': _formatNumber(motivo49['biscoitoQueijo']),
        'unidade': 'KG',
      });
    }
    if (motivo49['paoTatu'] > 0) {
      items.add({
        'codigo': '42842',
        'produto': 'Massa Pão Tatu',
        'quantidade': _formatNumber(motivo49['paoTatu']),
        'unidade': 'KG',
      });
    }
    if (motivo49['paoFofinho'] > 0) {
      items.add({
        'codigo': '106793',
        'produto': 'Massa Pão Fofinho',
        'quantidade': _formatNumber(motivo49['paoFofinho']),
        'unidade': 'KG',
      });
    }
    if (motivo49['massaBaguete'] > 0) {
      items.add({
        'codigo': '81235',
        'produto': 'Massa Baguete',
        'quantidade': _formatNumber(motivo49['massaBaguete']),
        'unidade': 'KG',
      });
    }

    return items;
  }

  List<Map<String, dynamic>> _getMotivo8Items(Map<String, dynamic> motivo8) {
    final items = <Map<String, dynamic>>[];

    if (motivo8['baguete'] > 0) {
      items.add({
        'codigo': '81235',
        'produto': 'Massa Baguete',
        'quantidade': _formatNumber(motivo8['baguete']),
        'unidade': 'KG',
      });
    }
    if (motivo8['paoFrances'] > 0) {
      items.add({
        'codigo': '33639',
        'produto': 'Massa Pão Francês',
        'quantidade': _formatNumber(motivo8['paoFrances']),
        'unidade': 'KG',
      });
    }
    if (motivo8['miniMarta'] > 0) {
      items.add({
        'codigo': '112731',
        'produto': 'Massa Mini Marta Rocha',
        'quantidade': _formatNumber(motivo8['miniMarta']),
        'unidade': 'KG',
      });
    }
    if (motivo8['rabanada'] > 0) {
      items.add({
        'codigo': '131281',
        'produto': 'Massa Pão P/ Rabanada',
        'quantidade': _formatNumber(motivo8['rabanada']),
        'unidade': 'UNID',
      });
    }
    if (motivo8['paoFofinho'] > 0) {
      items.add({
        'codigo': '106793',
        'produto': 'Massa Pão Fofinho',
        'quantidade': _formatNumber(motivo8['paoFofinho']),
        'unidade': 'KG',
      });
    }

    return items;
  }

  List<Map<String, dynamic>> _getMotivo23Items(Map<String, dynamic> motivo23) {
    final items = <Map<String, dynamic>>[];

    if (motivo23['bagueteFrancesa'] > 0) {
      items.add({
        'codigo': '132471',
        'produto': 'Massa Baguete Francesa',
        'quantidade': _formatNumber(motivo23['bagueteFrancesa']),
        'unidade': 'UNID',
      });
    }
    if (motivo23['bambino'] > 0) {
      items.add({
        'codigo': '112727',
        'produto': 'Massa Bambino',
        'quantidade': _formatNumber(motivo23['bambino']),
        'unidade': 'KG',
      });
    }
    if (motivo23['biscoitoQueijo'] > 0) {
      items.add({
        'codigo': '146428',
        'produto': 'Massa Biscoito Queijo',
        'quantidade': _formatNumber(motivo23['biscoitoQueijo']),
        'unidade': 'KG',
      });
    }
    if (motivo23['biscoitoPolvilho'] > 0) {
      items.add({
        'codigo': '97922',
        'produto': 'Massa Biscoito Polvilho',
        'quantidade': _formatNumber(motivo23['biscoitoPolvilho']),
        'unidade': 'KG',
      });
    }
    if (motivo23['miniMarta'] > 0) {
      items.add({
        'codigo': '112731',
        'produto': 'Massa Mini Marta Rocha',
        'quantidade': _formatNumber(motivo23['miniMarta']),
        'unidade': 'KG',
      });
    }
    if (motivo23['baguete'] > 0) {
      items.add({
        'codigo': '81235',
        'produto': 'Massa Baguete',
        'quantidade': _formatNumber(motivo23['baguete']),
        'unidade': 'KG',
      });
    }
    if (motivo23['paoFofinho'] > 0) {
      items.add({
        'codigo': '106793',
        'produto': 'Massa Pão Fofinho',
        'quantidade': _formatNumber(motivo23['paoFofinho']),
        'unidade': 'KG',
      });
    }
    if (motivo23['paoQueijoCoquetel'] > 0) {
      items.add({
        'codigo': '65139',
        'produto': 'Massa Pão De Queijo Coquetel',
        'quantidade': _formatNumber(motivo23['paoQueijoCoquetel']),
        'unidade': 'KG',
      });
    }
    if (motivo23['paoQueijoTradicional'] > 0) {
      items.add({
        'codigo': '62948',
        'produto': 'Massa Pão de Queijo Tradicional',
        'quantidade': _formatNumber(motivo23['paoQueijoTradicional']),
        'unidade': 'KG',
      });
    }
    if (motivo23['paoDoceCaracol'] > 0) {
      items.add({
        'codigo': '81238',
        'produto': 'Massa Pão Doce Caracol',
        'quantidade': _formatNumber(motivo23['paoDoceCaracol']),
        'unidade': 'KG',
      });
    }
    if (motivo23['paoDoceFerradura'] > 0) {
      items.add({
        'codigo': '81240',
        'produto': 'Massa Pão Doce Ferradura',
        'quantidade': _formatNumber(motivo23['paoDoceFerradura']),
        'unidade': 'KG',
      });
    }
    if (motivo23['paoTatu'] > 0) {
      items.add({
        'codigo': '42842',
        'produto': 'Massa Pão Tatu',
        'quantidade': _formatNumber(motivo23['paoTatu']),
        'unidade': 'KG',
      });
    }
    if (motivo23['paoRabanada'] > 0) {
      items.add({
        'codigo': '131281',
        'produto': 'Massa Pão P/ Rabanada',
        'quantidade': _formatNumber(motivo23['paoRabanada']),
        'unidade': 'UNID',
      });
    }
    if (motivo23['miniBaguetinha'] > 0) {
      items.add({
        'codigo': '68170',
        'produto': 'Massa Mini Baguetinha',
        'quantidade': _formatNumber(motivo23['miniBaguetinha']),
        'unidade': 'KG',
      });
    }
    if (motivo23['sanduicheFofinho'] > 0) {
      items.add({
        'codigo': '142099',
        'produto': 'Sanduíche Fofinho',
        'quantidade': _formatNumber(motivo23['sanduicheFofinho']),
        'unidade': 'UNID',
      });
    }
    if (motivo23['paoSamaritano'] > 0) {
      items.add({
        'codigo': '132318',
        'produto': 'Pão Samaritano',
        'quantidade': _formatNumber(motivo23['paoSamaritano']),
        'unidade': 'UNID',
      });
    }
    if (motivo23['paoPizza'] > 0) {
      items.add({
        'codigo': '132319',
        'produto': 'Pão Pizza',
        'quantidade': _formatNumber(motivo23['paoPizza']),
        'unidade': 'UNID',
      });
    }
    if (motivo23['paoAlhoCasa'] > 0) {
      items.add({
        'codigo': '132317',
        'produto': 'Pão de Alho da Casa',
        'quantidade': _formatNumber(motivo23['paoAlhoCasa']),
        'unidade': 'UNID',
      });
    }
    if (motivo23['paoAlhoCasaPicante'] > 0) {
      items.add({
        'codigo': '132320',
        'produto': 'Pão de Alho da Casa Picante',
        'quantidade': _formatNumber(motivo23['paoAlhoCasaPicante']),
        'unidade': 'UNID',
      });
    }
    if (motivo23['roscaFofinha'] > 0) {
      items.add({
        'codigo': '142098',
        'produto': 'Rosca Fofinha Temperada',
        'quantidade': _formatNumber(motivo23['roscaFofinha']),
        'unidade': 'UNID',
      });
    }
    if (motivo23['roscaCocoQueijo'] > 0) {
      items.add({
        'codigo': '148231',
        'produto': 'Rosca Côco e Queijo',
        'quantidade': _formatNumber(motivo23['roscaCocoQueijo']),
        'unidade': 'UNID',
      });
    }
    if (motivo23['rabanadaAssada'] > 0) {
      items.add({
        'codigo': '62901',
        'produto': 'Rabanada Assada',
        'quantidade': _formatNumber(motivo23['rabanadaAssada']),
        'unidade': 'KG',
      });
    }

    return items;
  }

  List<Map<String, dynamic>> _getMotivo9Items(Map<String, dynamic> motivo9) {
    final items = <Map<String, dynamic>>[];

    if (motivo9['sanduicheFofinho'] > 0) {
      items.add({
        'codigo': '142099',
        'produto': 'Sanduíche Fofinho',
        'quantidade': _formatNumber(motivo9['sanduicheFofinho']),
        'unidade': 'UNID',
      });
    }
    if (motivo9['paoSamaritano'] > 0) {
      items.add({
        'codigo': '132318',
        'produto': 'Pão Samaritano',
        'quantidade': _formatNumber(motivo9['paoSamaritano']),
        'unidade': 'UNID',
      });
    }
    if (motivo9['paoPizza'] > 0) {
      items.add({
        'codigo': '132319',
        'produto': 'Pão Pizza',
        'quantidade': _formatNumber(motivo9['paoPizza']),
        'unidade': 'UNID',
      });
    }
    if (motivo9['paoAlhoCasa'] > 0) {
      items.add({
        'codigo': '132317',
        'produto': 'Pão de Alho da Casa',
        'quantidade': _formatNumber(motivo9['paoAlhoCasa']),
        'unidade': 'UNID',
      });
    }
    if (motivo9['paoAlhoCasaPicante'] > 0) {
      items.add({
        'codigo': '132320',
        'produto': 'Pão de Alho da Casa Picante',
        'quantidade': _formatNumber(motivo9['paoAlhoCasaPicante']),
        'unidade': 'UNID',
      });
    }
    if (motivo9['roscaFofinha'] > 0) {
      items.add({
        'codigo': '142098',
        'produto': 'Rosca Fofinha Temperada',
        'quantidade': _formatNumber(motivo9['roscaFofinha']),
        'unidade': 'UNID',
      });
    }
    if (motivo9['roscaCocoQueijo'] > 0) {
      items.add({
        'codigo': '148231',
        'produto': 'Rosca Côco e Queijo',
        'quantidade': _formatNumber(motivo9['roscaCocoQueijo']),
        'unidade': 'UNID',
      });
    }
    if (motivo9['rabanadaAssada'] > 0) {
      items.add({
        'codigo': '62901',
        'produto': 'Rabanada Assada',
        'quantidade': _formatNumber(motivo9['rabanadaAssada']),
        'unidade': 'KG',
      });
    }
    if (motivo9['bambino'] > 0) {
      items.add({
        'codigo': '112727',
        'produto': 'Massa Bambino',
        'quantidade': _formatNumber(motivo9['bambino']),
        'unidade': 'KG',
      });
    }
    if (motivo9['miniMarta'] > 0) {
      items.add({
        'codigo': '112731',
        'produto': 'Massa Mini Marta Rocha',
        'quantidade': _formatNumber(motivo9['miniMarta']),
        'unidade': 'KG',
      });
    }
    if (motivo9['paoDoceCaracol'] > 0) {
      items.add({
        'codigo': '81238',
        'produto': 'Massa Pão Doce Caracol',
        'quantidade': _formatNumber(motivo9['paoDoceCaracol']),
        'unidade': 'KG',
      });
    }
    if (motivo9['paoDoceFerradura'] > 0) {
      items.add({
        'codigo': '81240',
        'produto': 'Massa Pão Doce Ferradura',
        'quantidade': _formatNumber(motivo9['paoDoceFerradura']),
        'unidade': 'KG',
      });
    }

    return items;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _carregarResponsavel();

    for (var item in produtosProducao) {
      controllersProducao[item['codigo']!] = TextEditingController();
    }

    for (var item in produtosPerdas) {
      controllersPerdas[item['codigo']!] = TextEditingController();
    }

    _loadData();
  }

  Future<void> _loadData() async {
    for (var item in produtosProducao) {
      final codigo = item['codigo']!;
      final doc = await _firestore
          .collection('stores')
          .doc(widget.storeName)
          .collection('producao')
          .doc(codigo)
          .get();

      if (doc.exists) {
        controllersProducao[codigo]!.text =
            doc.data()?['quant']?.toString() ?? '';
      }
    }

    for (var item in produtosPerdas) {
      final codigo = item['codigo']!;
      final doc = await _firestore
          .collection('stores')
          .doc(widget.storeName)
          .collection('perdas')
          .doc(codigo)
          .get();

      if (doc.exists) {
        controllersPerdas[codigo]!.text =
            doc.data()?['quant']?.toString() ?? '';
      }
    }

    _planilhaNotifier.value++;
  }

  Future<void> _save(
      String tipo, String codigo, String nome, String valor) async {
    await _firestore
        .collection('stores')
        .doc(widget.storeName)
        .collection(tipo)
        .doc(codigo)
        .set({
      "codigo": codigo,
      "nome": nome,
      "quant": valor,
      "loja": widget.storeName,
      "tipo": tipo,
      "timestamp": FieldValue.serverTimestamp()
    });

    _planilhaNotifier.value++;
  }

  Future<void> _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
      });
      _planilhaNotifier.value++;
    }
  }

  Widget _buildItem(Map<String, String> item,
      Map<String, TextEditingController> controllers, String tipo) {
    final codigo = item['codigo']!;
    final nome = item['nome']!;
    final hint = item['hint']!;
    final imagemPath = item['imagem'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linha 1: Imagem (80x80) +Hint ao lado
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagem 80x80 no topo
                Container(
                  width: 160,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imagemPath != null && imagemPath.isNotEmpty
                        ? Image.asset(
                            imagemPath,
                            width: 160,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.fastfood,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.fastfood,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Hint ao lado da imagem - ocupando o espaço restante
                Expanded(
                  child: Text(
                    hint,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Linha 2: Nome do produto + Campo de quantidade
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Nome do produto - expandido
                Expanded(
                  child: Text(
                    nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                // Campo de quantidade - 4 algarismos
                SizedBox(
                    width: 110,
                    child: TextField(
                      controller: controllers[codigo],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        labelText: "Qtd",
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      ),
                      onChanged: (v) => _save(tipo, codigo, nome, v),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        LengthLimitingTextInputFormatter(
                            5), // 4 números + 1 vírgula + 2 decimais
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLista(
      List<Map<String, String>> lista,
      Map<String, TextEditingController> controllers,
      String tipo,
      String titulo) {
    return Column(
      children: [
        // Botão de limpar dados
        Padding(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => _limparDados(tipo, titulo),
              icon: const Icon(Icons.delete_sweep),
              label: Text('Limpar $titulo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff2174ad),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                textStyle: const TextStyle(fontSize: 14), // Tamanho do texto
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ListView(
              children: lista
                  .map((item) => _buildItem(item, controllers, tipo))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- ABA PLANILHA ----------
  Widget _buildLinhaResultado(String label, dynamic valor,
      {String unidade = 'KG'}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              '${_formatNumber(valor)} $unidade',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivo49() {
    final calc = _calcularMotivo49();
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MOTIVO 49',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            const Divider(),
            if (calc['paoFrances'] > 0)
              _buildLinhaResultado('Massa Pão Francês:', calc['paoFrances']),
            if (calc['massaBaguete'] > 0)
              _buildLinhaResultado('Massa Baguete:', calc['massaBaguete']),
            if (calc['paoFrancesFibras'] > 0)
              _buildLinhaResultado(
                  'Massa Pão Francês Fibras:', calc['paoFrancesFibras']),
            if (calc['paoQueijoTradicional'] > 0)
              _buildLinhaResultado('Massa Pão de Queijo Tradicional:',
                  calc['paoQueijoTradicional']),
            if (calc['paoQueijoCoquetel'] > 0)
              _buildLinhaResultado(
                  'Massa Pão de Queijo Coquetel:', calc['paoQueijoCoquetel']),
            if (calc['biscoitoPolvilho'] > 0)
              _buildLinhaResultado(
                  'Massa Biscoito Polvilho:', calc['biscoitoPolvilho']),
            if (calc['biscoitoQueijo'] > 0)
              _buildLinhaResultado(
                  'Massa Biscoito de Queijo:', calc['biscoitoQueijo']),
            if (calc['paoTatu'] > 0)
              _buildLinhaResultado('Massa Pão Tatu:', calc['paoTatu']),
            if (calc['paoFofinho'] > 0)
              _buildLinhaResultado('Massa Pão Fofinho:', calc['paoFofinho']),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivo8() {
    final calc = _calcularMotivo8();
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MOTIVO 8',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            const Divider(),
            if (calc['baguete'] > 0)
              _buildLinhaResultado('Massa Baguete:', calc['baguete']),
            if (calc['paoFrances'] > 0)
              _buildLinhaResultado('Massa Pão Francês:', calc['paoFrances']),
            if (calc['miniMarta'] > 0)
              _buildLinhaResultado(
                  'Massa Mini Marta Rocha:', calc['miniMarta']),
            if (calc['rabanada'] > 0)
              _buildLinhaResultado('Massa Pão P/ Rabanada:', calc['rabanada'],
                  unidade: 'UNID'),
            if (calc['paoFofinho'] > 0)
              _buildLinhaResultado('Massa Pão Fofinho:', calc['paoFofinho']),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivo23() {
    final calc = _calcularMotivo23();
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MOTIVO 23',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const Divider(),
            if (calc['bagueteFrancesa'] > 0)
              _buildLinhaResultado(
                  'Massa Baguete Francesa:', calc['bagueteFrancesa'],
                  unidade: 'UNID'),
            if (calc['bambino'] > 0)
              _buildLinhaResultado('Massa Bambino:', calc['bambino']),
            if (calc['biscoitoQueijo'] > 0)
              _buildLinhaResultado(
                  'Massa Biscoito Queijo:', calc['biscoitoQueijo']),
            if (calc['biscoitoPolvilho'] > 0)
              _buildLinhaResultado(
                  'Massa Biscoito Polvilho:', calc['biscoitoPolvilho']),
            if (calc['miniMarta'] > 0)
              _buildLinhaResultado(
                  'Massa Mini Marta Rocha:', calc['miniMarta']),
            if (calc['baguete'] > 0)
              _buildLinhaResultado('Massa Baguete:', calc['baguete']),
            if (calc['paoFofinho'] > 0)
              _buildLinhaResultado('Massa Pão Fofinho:', calc['paoFofinho']),
            if (calc['paoQueijoCoquetel'] > 0)
              _buildLinhaResultado(
                  'Massa Pão De Queijo Coquetel:', calc['paoQueijoCoquetel']),
            if (calc['paoQueijoTradicional'] > 0)
              _buildLinhaResultado('Massa Pão de Queijo Tradicional:',
                  calc['paoQueijoTradicional']),
            if (calc['paoDoceCaracol'] > 0)
              _buildLinhaResultado(
                  'Massa Pão Doce Caracol:', calc['paoDoceCaracol']),
            if (calc['paoDoceFerradura'] > 0)
              _buildLinhaResultado(
                  'Massa Pão Doce Ferradura:', calc['paoDoceFerradura']),
            if (calc['paoTatu'] > 0)
              _buildLinhaResultado('Massa Pão Tatu:', calc['paoTatu']),
            if (calc['paoRabanada'] > 0)
              _buildLinhaResultado(
                  'Massa Pão P/ Rabanada:', calc['paoRabanada'],
                  unidade: 'UNID'),
            if (calc['miniBaguetinha'] > 0)
              _buildLinhaResultado(
                  'Massa Mini Baguetinha:', calc['miniBaguetinha']),
            if (calc['sanduicheFofinho'] > 0)
              _buildLinhaResultado(
                  'Sanduíche Fofinho:', calc['sanduicheFofinho'],
                  unidade: 'UNID'),
            if (calc['paoSamaritano'] > 0)
              _buildLinhaResultado('Pão Samaritano:', calc['paoSamaritano'],
                  unidade: 'UNID'),
            if (calc['paoPizza'] > 0)
              _buildLinhaResultado('Pão Pizza:', calc['paoPizza'],
                  unidade: 'UNID'),
            if (calc['paoAlhoCasa'] > 0)
              _buildLinhaResultado('Pão de Alho da Casa:', calc['paoAlhoCasa'],
                  unidade: 'UNID'),
            if (calc['paoAlhoCasaPicante'] > 0)
              _buildLinhaResultado(
                  'Pão de Alho da Casa Picante:', calc['paoAlhoCasaPicante'],
                  unidade: 'UNID'),
            if (calc['roscaFofinha'] > 0)
              _buildLinhaResultado(
                  'Rosca Fofinha Temperada:', calc['roscaFofinha'],
                  unidade: 'UNID'),
            if (calc['roscaCocoQueijo'] > 0)
              _buildLinhaResultado(
                  'Rosca Côco e Queijo:', calc['roscaCocoQueijo'],
                  unidade: 'UNID'),
            if (calc['rabanadaAssada'] > 0)
              _buildLinhaResultado('Rabanada Assada:', calc['rabanadaAssada']),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivo9() {
    final calc = _calcularMotivo9();
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MOTIVO 9',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
            const Divider(),
            if (calc['sanduicheFofinho'] > 0)
              _buildLinhaResultado(
                  'Sanduíche Fofinho:', calc['sanduicheFofinho'],
                  unidade: 'UNID'),
            if (calc['paoSamaritano'] > 0)
              _buildLinhaResultado('Pão Samaritano:', calc['paoSamaritano'],
                  unidade: 'UNID'),
            if (calc['paoPizza'] > 0)
              _buildLinhaResultado('Pão Pizza:', calc['paoPizza'],
                  unidade: 'UNID'),
            if (calc['paoAlhoCasa'] > 0)
              _buildLinhaResultado('Pão de Alho da Casa:', calc['paoAlhoCasa'],
                  unidade: 'UNID'),
            if (calc['paoAlhoCasaPicante'] > 0)
              _buildLinhaResultado(
                  'Pão de Alho da Casa Picante:', calc['paoAlhoCasaPicante'],
                  unidade: 'UNID'),
            if (calc['roscaFofinha'] > 0)
              _buildLinhaResultado(
                  'Rosca Fofinha Temperada:', calc['roscaFofinha'],
                  unidade: 'UNID'),
            if (calc['roscaCocoQueijo'] > 0)
              _buildLinhaResultado(
                  'Rosca Côco e Queijo:', calc['roscaCocoQueijo'],
                  unidade: 'UNID'),
            if (calc['rabanadaAssada'] > 0)
              _buildLinhaResultado('Rabanada Assada:', calc['rabanadaAssada']),
            if (calc['bambino'] > 0)
              _buildLinhaResultado('Massa Bambino:', calc['bambino']),
            if (calc['miniMarta'] > 0)
              _buildLinhaResultado(
                  'Massa Mini Marta Rocha:', calc['miniMarta']),
            if (calc['paoDoceCaracol'] > 0)
              _buildLinhaResultado(
                  'Massa Pão Doce Caracol:', calc['paoDoceCaracol']),
            if (calc['paoDoceFerradura'] > 0)
              _buildLinhaResultado(
                  'Massa Pão Doce Ferradura:', calc['paoDoceFerradura']),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanilha() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              InkWell(
                onTap: _selecionarData,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd/MM/yyyy').format(_dataSelecionada),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<int>(
            valueListenable: _planilhaNotifier,
            builder: (context, _, __) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildMotivo49(),
                    _buildMotivo8(),
                    _buildMotivo23(),
                    _buildMotivo9(),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _planilhaNotifier.dispose();

    for (var c in controllersProducao.values) {
      c.dispose();
    }
    for (var c in controllersPerdas.values) {
      c.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0x762586e5),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SecondScreen(storeName: widget.storeName),
              ),
            );
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/Logo StockOne.png', height: 32),
            const SizedBox(width: 8),
            const Text("REQUISIÇÃO",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lora',
                    color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _compartilharPlanilhaPDF,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Produção"),
            Tab(text: "Perdas"),
            Tab(text: "Planilha"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLista(
              produtosProducao, controllersProducao, "producao", "Produção"),
          _buildLista(produtosPerdas, controllersPerdas, "perdas", "Perdas"),
          _buildPlanilha(),
        ],
      ),
    );
  }
}

class HoleriteScreen extends StatefulWidget {
  const HoleriteScreen({super.key});

  @override
  State<HoleriteScreen> createState() => _HoleriteScreenState();
}

class _HoleriteScreenState extends State<HoleriteScreen> {
  final salarioController = TextEditingController();
  final extra60Controller = TextEditingController();
  final extra100Controller = TextEditingController();
  final atrasoController = TextEditingController();
  final faltaController = TextEditingController();
  final descontosExtrasController = TextEditingController();

  Map<String, double> vencimentos = {};
  Map<String, double> descontos = {};

  double bruto = 0;
  double liquido = 0;

  @override
  void initState() {
    super.initState();
    _loadData();

    // salva automaticamente ao digitar
    salarioController.addListener(_saveData);
    extra60Controller.addListener(_saveData);
    extra100Controller.addListener(_saveData);
    atrasoController.addListener(_saveData);
    faltaController.addListener(_saveData);
    descontosExtrasController.addListener(_saveData);
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('salario', salarioController.text);
    await prefs.setString('extra60', extra60Controller.text);
    await prefs.setString('extra100', extra100Controller.text);
    await prefs.setString('atraso', atrasoController.text);
    await prefs.setString('falta', faltaController.text);
    await prefs.setString('descontosExtras', descontosExtrasController.text);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      salarioController.text = prefs.getString('salario') ?? '';
      extra60Controller.text = prefs.getString('extra60') ?? '';
      extra100Controller.text = prefs.getString('extra100') ?? '';
      atrasoController.text = prefs.getString('atraso') ?? '';
      faltaController.text = prefs.getString('falta') ?? '';
      descontosExtrasController.text = prefs.getString('descontosExtras') ?? '';
    });
  }

  double parse(String v) {
    return double.tryParse(v.replaceAll(',', '.')) ?? 0;
  }

  double calcularINSS(double salario) {
    double total = 0;

    double f1 = salario > 1412 ? 1412 : salario;
    total += f1 * 0.08;

    if (salario > 1412) {
      double f2 = salario > 2666.68 ? 1254.68 : salario - 1412;
      total += f2 * 0.09;
    }

    if (salario > 2666.68) {
      double f3 = salario > 4000.03 ? 1333.35 : salario - 2666.68;
      total += f3 * 0.12;
    }

    if (salario > 4000.03) {
      total += (salario - 4000.03) * 0.14;
    }

    return total;
  }

  double calcularDSR(double totalExtras) {
    return (totalExtras / 24) * 6;
  }

  void calcular() {
    double salario = parse(salarioController.text);
    double he60h = parse(extra60Controller.text);
    double he100h = parse(extra100Controller.text);
    double atraso = parse(atrasoController.text);
    double falta = parse(faltaController.text);
    double descontosExtras = parse(descontosExtrasController.text);

    double valorHora = salario / 220;

    double he60 = he60h * valorHora * 1.6;
    double he100 = he100h * valorHora * 2;

    double totalExtras = he60 + he100;
    double dsr = calcularDSR(totalExtras);

    double baseINSS = salario + he60 + he100 + dsr;

    double premio = 175;
    if (falta > 0 || atraso >= 8) {
      premio = 0;
    } else if (atraso >= 2) {
      premio = 87.5;
    }

    vencimentos = {
      "Salário Base": salario,
      "Horas Extra 60%": he60,
      "Horas Extra 100%": he100,
      "DSR Extras": dsr,
      "Prêmio Assiduidade": premio,
      "Auxílio Refeição": 400,
      "Cesta Básica": 175,
      "Vale Transporte": 345,
    };

    bruto = vencimentos.values.fold(0, (a, b) => a + b);

    descontos = {
      "INSS": calcularINSS(baseINSS),
      "Atraso": atraso * valorHora,
      "Adiantamento (40%)": salario * 0.4,
      "Plano Saúde": 1,
      "Plano Odonto": 1,
      "Outros Descontos": descontosExtras,
    };

    double totalDesc = descontos.values.fold(0, (a, b) => a + b);

    liquido = bruto - totalDesc;

    setState(() {});
  }

  Widget linha(String nome, double valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(nome),
        Text("R\$ ${valor.toStringAsFixed(2)}"),
      ],
    );
  }

  Widget bloco(String titulo, Map<String, double> dados) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        ...dados.entries.map((e) => linha(e.key, e.value)),
        const Divider(),
      ],
    );
  }

  Widget campo(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    salarioController.dispose();
    extra60Controller.dispose();
    extra100Controller.dispose();
    atrasoController.dispose();
    faltaController.dispose();
    descontosExtrasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Holerite Teste")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            campo("Salário Base", salarioController),
            campo("Horas Extra 60%", extra60Controller),
            campo("Horas Extra 100%", extra100Controller),
            campo("Horas de Atraso", atrasoController),
            campo("Descontos adicionais (R\$)", descontosExtrasController),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: calcular,
              child: const Text("Calcular Holerite"),
            ),
            const SizedBox(height: 20),
            bloco("VENCIMENTOS", vencimentos),
            bloco("DESCONTOS", descontos),
            linha("TOTAL BRUTO", bruto),
            linha(
              "TOTAL DESCONTOS",
              descontos.values.fold(0, (a, b) => a + b),
            ),
            const Divider(),
            Text(
              "LÍQUIDO: R\$ ${liquido.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class ConsultarRelatorios extends StatefulWidget {
  const ConsultarRelatorios({super.key});

  @override
  State<ConsultarRelatorios> createState() => _ConsultarRelatoriosState();
}

class _ConsultarRelatoriosState extends State<ConsultarRelatorios> {
  static const verdeEscuro = Color(0xFF006400);
  static const rosaEscuro = Color(0xFFE91E63);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? lojaSelecionada;
  DateTime? dataSelecionada;

  bool carregando = false;
  List<Map<String, dynamic>> relatorios = [];

  late List<String> lojas;

  @override
  void initState() {
    super.initState();
    lojas = List.generate(100, (index) => 'Loja ${index + 1}');
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      setState(() {
        dataSelecionada = picked;
      });
    }
  }

  String _formatarData(DateTime data) {
    return "${data.day.toString().padLeft(2, '0')}/"
        "${data.month.toString().padLeft(2, '0')}/"
        "${data.year}";
  }

  String _formatarDataFirestore(DateTime data) {
    return "${data.year}-"
        "${data.month.toString().padLeft(2, '0')}-"
        "${data.day.toString().padLeft(2, '0')}";
  }

  Future<void> _buscarRelatorios() async {
    if (lojaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma loja'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (dataSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma data'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      carregando = true;
      relatorios.clear();
    });

    try {
      final snapshot = await _firestore
          .collection('relatorios')
          .doc('lojas')
          .collection('lojas')
          .doc(lojaSelecionada)
          .collection('datas')
          .where('data', isEqualTo: _formatarDataFirestore(dataSelecionada!))
          .orderBy('data', descending: true)
          .get();

      setState(() {
        relatorios = snapshot.docs.map((e) => e.data()).toList();
      });

      if (relatorios.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum relatório encontrado para esta loja/data'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao buscar dados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      carregando = false;
    });
  }

  Future<void> _copiarRelatorio(String textoCompleto) async {
    if (textoCompleto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não há texto para copiar!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: textoCompleto));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Relatório copiado para a área de transferência!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _campoInfo(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 17,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: '$titulo ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: verdeEscuro,
              ),
            ),
            TextSpan(text: valor),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivo(Map<String, dynamic> data) {
    final rotinaSelecionadas =
        List<String>.from(data['rotinaSelecionadas'] ?? []);
    final rotinaOutros = data['rotinaOutros'] ?? '';

    if (rotinaSelecionadas.isEmpty) {
      return _campoInfo('Motivo:', 'Nenhum motivo selecionado');
    }

    String motivoTexto = rotinaSelecionadas.join(', ');
    if (rotinaSelecionadas.contains('outros') && rotinaOutros.isNotEmpty) {
      motivoTexto = '$motivoTexto ($rotinaOutros)';
    }

    return _campoInfo('Motivo:', motivoTexto);
  }

  Widget _buildVendasDiaAnterior(Map<String, dynamic> data) {
    final vendamediadiaria = data['vendamediadiaria'] ?? '';
    final qtdRetirada = data['qtdRetirada'] ?? '0';
    final lotesRetirados = data['lotesRetirados'] ?? '0';
    final qtdSobra = data['qtdSobra'] ?? '0';
    final giroMedio = data['giroMedio'] ?? '0';

    String paoFrancesUnidades = vendamediadiaria;
    if (paoFrancesUnidades.isEmpty && giroMedio != '0') {
      final valor = double.tryParse(giroMedio.toString()) ?? 0;
      paoFrancesUnidades = (valor / 0.07).toStringAsFixed(0);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        const Text(
          'Vendas do Dia Anterior:',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: verdeEscuro,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pão Francês: ${paoFrancesUnidades.isEmpty ? '0' : paoFrancesUnidades} unidades',
                style: const TextStyle(fontSize: 17, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'Pão de Queijo Tradicional: $qtdRetirada Kilos',
                style: const TextStyle(fontSize: 17, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'Pão de Queijo Coquetel: $lotesRetirados Kilos',
                style: const TextStyle(fontSize: 17, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'Biscoito de Queijo: $qtdSobra Kilos',
                style: const TextStyle(fontSize: 17, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRupturas(Map<String, dynamic> data) {
    final rupturas = data['rupturas'] ?? {};

    final List<MapEntry<String, dynamic>> produtosComRuptura = [];

    if (rupturas is Map) {
      rupturas.forEach((produto, info) {
        if (info is Map && info['selecionado'] == true) {
          produtosComRuptura.add(MapEntry(produto, info));
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        const Text(
          'Rupturas:',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: verdeEscuro,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: produtosComRuptura.isEmpty
              ? const Text(
                  'Nenhuma ruptura registrada',
                  style: TextStyle(fontSize: 17, color: Colors.black87),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: produtosComRuptura.map((entry) {
                    final produto = entry.key;
                    final info = entry.value;
                    final motivo = info['motivo'] ?? 'sem motivo';
                    final outroMotivo = info['outroMotivo'] ?? '';

                    String motivoTexto = motivo;
                    if (motivo == 'outros' && outroMotivo.isNotEmpty) {
                      motivoTexto = 'outros ($outroMotivo)';
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '• $produto (Motivo: $motivoTexto)',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: rosaEscuro,
        centerTitle: true,
        title: Row(
          children: [
            Image.asset(
              'assets/images/Logo StockOne.png',
              height: 30,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Consultar',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lora',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Loja',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: verdeEscuro,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: lojaSelecionada,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              hint: const Text('Selecione a loja'),
              items: lojas.map((loja) {
                return DropdownMenuItem(
                  value: loja,
                  child: Text(loja),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  lojaSelecionada = value;
                  relatorios.clear();
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Data',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: verdeEscuro,
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _selecionarData,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  dataSelecionada == null
                      ? 'Selecione a data'
                      : _formatarData(dataSelecionada!),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text(
                  'Buscar Relatório',
                  style: TextStyle(fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: rosaEscuro,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _buscarRelatorios,
              ),
            ),
            const SizedBox(height: 30),
            if (carregando) const Center(child: CircularProgressIndicator()),
            if (!carregando &&
                relatorios.isEmpty &&
                dataSelecionada != null &&
                lojaSelecionada != null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    'Nenhum relatório encontrado',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                ),
              ),
            ...relatorios.map((data) {
              final textoCompleto = data['textoCompleto'] ?? '';

              return Card(
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.store, color: rosaEscuro),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              data['loja'] ?? '',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: rosaEscuro,
                              ),
                            ),
                          ),
                          // Botão de copiar ao lado do nome da loja
                          if (textoCompleto.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.blue),
                              tooltip: 'Copiar relatório completo',
                              onPressed: () => _copiarRelatorio(textoCompleto),
                            ),
                        ],
                      ),
                      const Divider(height: 30),
                      _campoInfo('Data:', data['dataFormatada'] ?? ''),
                      _campoInfo('Horário:', data['horario'] ?? ''),
                      _campoInfo('Técnico:', data['tecnico'] ?? ''),
                      _campoInfo('Crachá:', data['cracha'] ?? ''),
                      _campoInfo('Gerente:', data['gerente'] ?? ''),
                      _campoInfo('Encarregado:', data['encarregado'] ?? ''),
                      _campoInfo('Colaboradores:',
                          '${data['colaboradoresAtivos'] ?? ''}'),
                      _campoInfo('Venda Média Pão Francês/Dia:',
                          '${data['resultadoInteiro'] ?? '0'} unidades'),

                      _buildMotivo(data),

                      const SizedBox(height: 18),
                      const Text(
                        'Trabalho Realizado:',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: verdeEscuro,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          data['trabalhoRealizado'] ?? 'Não informado',
                          style: const TextStyle(
                              fontSize: 17, color: Colors.black87),
                        ),
                      ),

                      _buildVendasDiaAnterior(data),
                      _buildRupturas(data),

                      const SizedBox(height: 16),
                      // Botão de copiar no final do card
                      if (textoCompleto.isNotEmpty)
                        Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.copy, size: 20),
                            label: const Text(
                              'Copiar Relatório',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _copiarRelatorio(textoCompleto),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
