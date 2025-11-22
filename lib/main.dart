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
                          builder: (context) => Bahamas(),
                        ),
                      );
                    }),
                    _padariaCard("assets/images/paisefilhos.jpg", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Bahamas(),
                        ),
                      );
                    }),
                    _padariaCard("assets/images/bh.jpg", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Bahamas(),
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

class Bahamas extends StatelessWidget {
  const Bahamas({super.key});

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SecondScreen(storeName: storeName),
        ),
      );
    } else {
      // Verificar se já existe cadastro para esta loja
      bool hasExistingPassword = await _checkExistingPassword(storeName);

      await prefs.setString('selectedStore', storeName);

      if (hasExistingPassword) {
        // Loja já tem senha cadastrada - pedir senha
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordScreen(
              storeName: storeName,
              isFirstTime: false,
            ),
          ),
        );
      } else {
        // Primeiro cadastro - criar senha
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FirstTimeScreen(storeName: storeName),
          ),
        );
      }
    }
  }

  Future<bool> _checkDeviceAuthorization(String storeName) async {
    try {
      // Verificar se temos um token válido para esta loja neste dispositivo
      String? deviceToken =
          await _secureStorage.read(key: '${storeName}_auth_token');
      return deviceToken != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkExistingPassword(String storeName) async {
    try {
      final doc = await _firestore.collection('stores').doc(storeName).get();
      return doc.exists && doc.data()?['password'] != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedStores = [
      ...stores.where((store) => favoriteStores.contains(store)),
      ...stores.where((store) => !favoriteStores.contains(store))
    ];

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Bahamas()),
        );
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Bahamas()),
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
                  "SELECIONE:",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown,
                    fontFamily: 'Lora',
                  ),
                ),
                const SizedBox(height: 30),
                ...sortedStores.map((store) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.store),
                              label: Text(store),
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
                              onPressed: () => _onStoreSelected(context, store),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              favoriteStores.contains(store)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () => _toggleFavorite(store),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
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
  String? _selectedDeliveries;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _saveData() async {
    String userName = _userNameController.text.trim();
    String password = _passwordController.text.trim();

    if (userName.isEmpty || _selectedDeliveries == null || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, preencha todos os campos!")),
      );
      return;
    }

    int deliveriesValue = switch (_selectedDeliveries) {
      '1' => 7,
      '2' => 4,
      '3' => 3,
      _ => 0,
    };

    try {
      // Salvar dados no Firestore
      await _firestore.collection('stores').doc(widget.storeName).set({
        'userName': userName,
        'deliveries': deliveriesValue,
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
              const SizedBox(height: 20),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Entregas por semana',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDeliveries,
                    onChanged: (newValue) =>
                        setState(() => _selectedDeliveries = newValue),
                    items: const [
                      DropdownMenuItem(child: Text('1'), value: '1'),
                      DropdownMenuItem(child: Text('2'), value: '2'),
                      DropdownMenuItem(child: Text('3'), value: '3'),
                    ],
                    hint: const Text("Escolha"),
                  ),
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

      if (doc.exists && doc.data()?['password'] == _passwordController.text) {
        // Senha correta - autorizar este dispositivo
        await _authorizeThisDevice();

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

  Future<void> _authorizeThisDevice() async {
    String deviceToken =
        '${DateTime.now().millisecondsSinceEpoch}_${widget.storeName}_authorized';
    await _secureStorage.write(
        key: '${widget.storeName}_auth_token', value: deviceToken);
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
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _goBack,
        ),
        title: Text(
          widget.storeName,
          style: TextStyle(color: Colors.white),
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
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: widget.isFirstTime ? "Criar Senha" : "Senha",
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifyPassword,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Text(
                        widget.isFirstTime ? "Criar Senha" : "Acessar Loja",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade400,
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

      // 1️⃣ REMOVE apenas a senha, mantém outros dados
      await storeDoc.update({
        'password': null, // 🔥 APENAS remove a senha
        'isFirstLaunch': true, // Marca para novo cadastro
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });
      // ✅ userName, deliveries, etc. PERMANECEM

      // 2️⃣ (Opcional) Remove token deste dispositivo
      await _secureStorage.delete(key: '${widget.storeName}_auth_token');

      // 3️⃣ Navega para o cadastro inicial
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
                            title:
                                const Text("Resetar dados de loja e usuário"),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "${widget.storeName}",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  "Bem-vindo, $userName!",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.brown.shade700,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
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

class ThirdScreen extends StatefulWidget {
  final String storeName;
  const ThirdScreen({required this.storeName});

  @override
  _ThirdScreenState createState() => _ThirdScreenState();
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
    'Pão de Alho da Casa Refri.',
  ];

  int deliveries = 0;
  int? diasDeGiro;

  final Map<String, TextEditingController> vendasControllers = {};
  final Map<String, TextEditingController> estoqueControllers = {};
  final Map<String, bool> estoqueEditadoManual = {};

  final TextEditingController giroController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  bool _dataLoaded = false;

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

  Future<void> _loadAllData() async {
    if (_dataLoaded) return;

    setState(() => _isLoading = true);

    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();

      if (doc.exists) {
        final data = doc.data() ?? {};

        setState(() {
          deliveries = data['deliveries'] ?? 0;
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
            // ✅ Como é número, verifica se é inteiro
            if (vendas % 1 == 0) {
              vendasControllers[produto]!.text =
                  vendas.toInt().toString(); // "1500"
            } else {
              vendasControllers[produto]!.text = vendas.toString(); // "1500.5"
            }
          }

          if (estoque != null) {
            // ✅ CORREÇÃO: MIN. PCTS sempre como número inteiro
            final numero = double.tryParse(estoque.toString());
            if (numero != null) {
              estoqueControllers[produto]!.text =
                  numero.floor().toString(); // 🔥 Número inteiro
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

  // ✅ MUDANÇA: Atualização automática sempre funciona
  void _onVendasChanged(String produto) {
    final valorMensal = double.tryParse(vendasControllers[produto]!.text) ?? 0;
    final estoqueMax = _calcularEstoqueMaximo(valorMensal, produto);

    // ✅ SEMPRE atualiza automaticamente + marca como cálculo automático
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
          vendasData[prod] = double.tryParse(vendaText) ?? 0;
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

  // ✅ MUDANÇA: Método atualizado para cálculo
  void _calculateAndSave(String produto) {
    final valorMensal = double.tryParse(vendasControllers[produto]!.text) ?? 0;
    final estoqueMax = _calcularEstoqueMaximo(valorMensal, produto);

    setState(() {
      estoqueControllers[produto]!.text = estoqueMax.toInt().toString();
      estoqueEditadoManual[produto] = false; // ✅ Marca como automático
    });

    _saveProductData(produto);
  }

  void _onEstoqueChanged(String produto) {
    setState(() {
      estoqueEditadoManual[produto] = true;
    });
    _saveProductData(produto);
  }

  // ✅ MUDANÇA: Botão refresh atualizado
  void _refreshEstoque(String produto) {
    if (vendasControllers[produto]!.text.isNotEmpty) {
      setState(() {
        estoqueEditadoManual[produto] = false; // Libera para cálculo automático
        _calculateAndSave(produto);
      });
    }
  }

  void _recalculateAllAutocalc({bool force = false}) {
    if (diasDeGiro == null || diasDeGiro! <= 0) return;

    for (var produto in subprodutos) {
      if (estoqueEditadoManual[produto]! && !force) continue;

      final valorMensal =
          double.tryParse(vendasControllers[produto]!.text) ?? 0;
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

  // ✅ MUDANÇA: Garantia de números inteiros nos cálculos
  double _calcularEstoqueMaximo(double valorMensal, String produto) {
    if (diasDeGiro == null || diasDeGiro! <= 0) return 0;

    double estoqueMax = 0;
    switch (produto) {
      case 'Pão Francês':
        estoqueMax = (valorMensal * 1.40 / diasDeGiro! / 10.5) * deliveries;
        break;
      case 'Pão Fofinho':
        estoqueMax = (valorMensal * 1.30 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Sanduíche Fofinho':
        estoqueMax =
            (valorMensal * 0.06 * 1.30 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Rosca Fofinha Temperada':
        estoqueMax =
            (valorMensal * 0.3 * 1.30 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Caseirinho':
        estoqueMax = (valorMensal * 1.30 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Pão Francês Fibras':
        estoqueMax = (valorMensal * 1.40 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Pão Francês Panhoca':
        estoqueMax = (valorMensal * 1.40 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Pão Francês com Queijo':
        estoqueMax = (valorMensal * 1.40 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Baguete Francesa Queijo':
        estoqueMax =
            (valorMensal * 0.33 * 1.20 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Baguete Francesa':
        estoqueMax =
            (valorMensal * 0.33 * 1.20 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Pão Queijo Tradicional':
        estoqueMax = (valorMensal * 1.42 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Pão Queijo Coquetel':
        estoqueMax = (valorMensal * 1.5 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Biscoito Queijo':
        estoqueMax = (valorMensal * 1.42 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Biscoito Polvilho':
        estoqueMax = (valorMensal * 2 / diasDeGiro! / 1.35) * deliveries;
        break;
      case 'Pão Samaritano':
        estoqueMax =
            (valorMensal * 0.085 * 1.20 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Pão Pizza':
        estoqueMax =
            (valorMensal * 0.08 * 1.20 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Pão Tatu':
        estoqueMax = (valorMensal * 1.40 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Mini Pão Sonho':
        estoqueMax =
            (valorMensal * 0.5 * 1.20 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Mini Pão Sonho Chocolate':
        estoqueMax =
            (valorMensal * 0.5 * 1.20 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Pão Bambino':
        estoqueMax =
            (valorMensal * 0.6 * 1.20 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Mini Marta Rocha':
        estoqueMax =
            (valorMensal * 0.5 * 1.20 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Pão Doce Ferradura':
        estoqueMax = (valorMensal * 1.20 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Pão Doce Caracol':
        estoqueMax = (valorMensal * 1.20 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Rosca Caseira':
        estoqueMax = (valorMensal * 1.20 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Rosca Caseira Côco':
        estoqueMax = (valorMensal * 1.20 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Rosca Caseira Leite em Pó':
        estoqueMax = (valorMensal * 1.20 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Rosca Côco/Queijo':
        estoqueMax =
            (valorMensal * 0.33 * 1.20 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Rabanada Assada':
        estoqueMax = (valorMensal / 0.8 * 1.20 / diasDeGiro! / 30) * deliveries;
        break;
      case 'Pão P/ Rabanada':
        estoqueMax = (valorMensal * 1.20 / diasDeGiro! / 30) * deliveries;
        break;
      case 'Pão Doce Comprido':
        estoqueMax = (valorMensal * 1.20 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Pão Milho':
        estoqueMax = (valorMensal * 1.3 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Pão de Alho da Casa':
        estoqueMax =
            (valorMensal * 0.24 * 1.20 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Pão de Alho da Casa Picante':
        estoqueMax =
            (valorMensal * 0.24 * 1.20 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Pão de Alho da Casa Refri.':
        estoqueMax =
            (valorMensal * 0.24 * 1.20 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Sanduíche Bahamas':
        estoqueMax =
            (valorMensal * 0.085 * 1.20 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Profiteroles Brigadeiro':
        estoqueMax = (valorMensal * 1.20 / diasDeGiro! / 1) * deliveries;
        break;
      case 'Profiteroles Brigadeiro Branco':
        estoqueMax = (valorMensal * 1.20 / diasDeGiro! / 1) * deliveries;
        break;
      case 'Profiteroles Doce de Leite':
        estoqueMax = (valorMensal * 1.20 / diasDeGiro! / 1) * deliveries;
        break;
      case 'Pão Baguete Francesa Queijo':
        estoqueMax = (valorMensal * 1.40 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Pão Baguete Francesa':
        estoqueMax = (valorMensal * 1.40 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Pão Baguete Francesa Gergelim':
        estoqueMax = (valorMensal * 1.40 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Mini Pão Francês Gergelim':
        estoqueMax = (valorMensal * 1.40 / diasDeGiro! / 3.3) * deliveries;
        break;
      default:
        estoqueMax = 0.0;
    }
    return estoqueMax.ceilToDouble(); // ✅ Sempre retorna número inteiro
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
              Card(
                elevation: 1,
                margin: const EdgeInsets.all(2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
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
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.blue),
                            tooltip: "Atualizar todos",
                            onPressed: _refreshTodos,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      TextFormField(
                        controller: giroController,
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 6),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          counterText: "",
                          suffixIcon: PopupMenuButton<int>(
                            icon: const Icon(Icons.arrow_drop_down, size: 18),
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
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          final val = int.tryParse(value);
                          if (val != null && val > 0) _saveDiasDeGiro(val);
                        },
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
                                // ✅ MUDANÇA: Campo VENDA com decimais
                                Expanded(
                                  flex: 5,
                                  child: TextField(
                                    controller: vendasControllers[produto],
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(
                                          r'^\d+\.?\d{0,2}')), // 2 casas decimais
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Venda',
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
                                // ✅ MUDANÇA: Campo MIN. PCTS apenas inteiros
                                Expanded(
                                  flex: 5,
                                  child: TextField(
                                    controller: estoqueControllers[produto],
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter
                                          .digitsOnly, // Apenas números inteiros
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
          'Massa Mini Baguete 80g': [
            'Pão de Alho da Casa',
            'Pão de Alho da Casa Picante',
            'Sanduíche Bahamas',
            'Pão Baguete Francesa Queijo',
            'Pão Baguete Francesa',
            'Pão Baguete Francesa Gergelim'
          ],
          'Massa Mini Pão Francês': [
            'Pão de Alho da Casa Refri.',
            'Mini Pão Francês Gergelim'
          ],
          'Massa Mini Baguete 40g': ['Pão Francês com Queijo'],
          'Massa Baguete 330g': ['Baguete Francesa Queijo', 'Baguete Francesa'],
          'Massa Pão Rabanada 330g': [
            'Rabanada Assada',
            'Pão P/ Rabanada',
            'Rosca Côco/Queijo'
          ],
          'Massa Pão Doce Comprido': ['Pão Milho', 'Pão Doce Comprido'],
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

        final produtosTetoMinimo2 = [
          'Massa Pão Rabanada 330g',
          'Massa Pão Francês'
        ];

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
  List<Map<String, dynamic>> freezersData = [];
  bool faltaEspaco = false;
  Map<String, int> massasFaltantes = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> listaMassas = [
    'Massa Pão Francês',
    'Massa Cervejinha',
    'Massa Pão Francês Fibras',
    'Massa Mini Baguete 80g',
    'Massa Mini Pão Francês',
    'Massa Mini Baguete 40g',
    'Massa Baguete 330g',
    'Massa Pão Queijo Tradicional',
    'Massa Pão Queijo Coquetel',
    'Massa Biscoito Queijo',
    'Massa Biscoito Polvilho',
    'Massa Pão Doce Comprido',
    'Massa Pão Fofinho',
    'Massa Pão Tatu',
    'Massa Mini Marta Rocha',
    'Massa Bambino',
    'Massa Pão Doce Caracol',
    'Massa Pão Doce Ferradura',
    'Massa Rosca 330g',
    'Massa Pão Rabanada 330g',
  ];

  @override
  void initState() {
    super.initState();
    _loadFreezersData();
  }

  Future<void> _loadFreezersData() async {
    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        final freezersList = data['freezers'] ?? [];

        if (freezersList is List && freezersList.isEmpty) {
          showDialog(
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
          return;
        }

        setState(() {
          freezersData = List<Map<String, dynamic>>.from(freezersList);
        });

        _distribuirMassas();
      } else {
        showDialog(
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
    } catch (e) {
      print('Erro ao carregar freezers: $e');
    }
  }

  Map<int, Map<String, int>> distribuicao = {};

  void _distribuirMassas() {
    freezersData.sort((a, b) {
      if (a['tipo'] == b['tipo']) return 0;
      return a['tipo'] == 'Vertical' ? -1 : 1;
    });

    distribuicao = Map.fromIterable(
      List.generate(freezersData.length, (i) => i),
      value: (_) => {},
    );

    massasFaltantes = {};

    List<double> volumesFreezers = freezersData.map((freezer) {
      return double.tryParse(freezer['volume'] ?? '0') ?? 0.0;
    }).toList();

    List<double> volumeOcupado = List.generate(freezersData.length, (_) => 0.0);

    faltaEspaco = false;

    List<String> ordemMassas = ['Massa Pão Francês'] +
        listaMassas.where((m) => m != 'Massa Pão Francês').toList();

    for (String massa in ordemMassas) {
      // ✅ MUDANÇA: Acessar como int diretamente, sem parse
      int quantidade = widget.estoqueMassas[massa] ?? 0;

      for (int i = 0; i < freezersData.length && quantidade > 0; i++) {
        String tipo = freezersData[i]['tipo'] ?? 'Horizontal';
        double fatorMassa = _getFatorPorMassa(massa, tipo);

        double volumePorPacote = 1.0 / fatorMassa;
        double volumeDisponivel = volumesFreezers[i] - volumeOcupado[i];
        int maxPacotes = (volumeDisponivel * fatorMassa).floor();

        if (maxPacotes > 0) {
          int paraAlocar = quantidade <= maxPacotes ? quantidade : maxPacotes;

          distribuicao[i]![massa] = (distribuicao[i]![massa] ?? 0) + paraAlocar;
          volumeOcupado[i] += paraAlocar * volumePorPacote;
          quantidade -= paraAlocar;
        }
      }

      if (quantidade > 0) {
        faltaEspaco = true;
        massasFaltantes[massa] = quantidade;
      }
    }

    setState(() {});
  }

  double _getFatorPorMassa(String massa, String tipo) {
    if (massa == 'Massa Pão Francês') return 0.0557;
    if (massa == 'Massa Biscoito Polvilho') return 0.053;
    if (massa == 'Massa Pão Rabanada 330g') return 0.064;

    return tipo == 'Horizontal' ? 0.187 : 0.113;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Distribuição Pacotes')),
      body: freezersData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                      _loadFreezersData();
                    },
                    child: const Text(
                      'Conservadores',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(freezersData.length, (i) {
                    Map<String, dynamic> freezer = freezersData[i];
                    Map<String, int> massas = distribuicao[i] ?? {};

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${freezer['modelo'] ?? 'Freezer'} (${freezer['tipo'] ?? 'N/A'}) - ${freezer['volume'] ?? '0'} litros',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...massas.entries.map((e) {
                              return Text(
                                  '${e.key.replaceFirst("Massa ", "")}: ${e.value} pacotes');
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (faltaEspaco)
                    Card(
                      color: Colors.red[300],
                      margin: const EdgeInsets.only(top: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ATENÇÃO: Freezers insuficientes para armazenar todas as massas!',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            if (massasFaltantes.isNotEmpty) ...[
                              const Text(
                                'Massas que não couberam:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              ...massasFaltantes.entries.map((e) {
                                return Text(
                                  '• ${e.key.replaceFirst("Massa ", "")}: ${e.value} pacotes',
                                  style: const TextStyle(fontSize: 14),
                                );
                              }).toList(),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
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
    'Massa Mini Pão Francês': 3.3,
    'Massa Mini Baguete 80g': 3.3,
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

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/acerto_estoque.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([XFile(file.path)], text: 'Acerto Estoque PDF');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar ou compartilhar PDF: $e')),
      );
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
  TextEditingController resultadoPedidoController = TextEditingController();
  TextEditingController estoqueAtualController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  final Map<String, TextEditingController> controllers = {
    'Massa Pão Francês': TextEditingController(),
    'Massa Pão Fofinho': TextEditingController(),
    'Massa Pão Francês Fibras': TextEditingController(),
    'Massa Pão Cervejinha': TextEditingController(),
    'Massa Mini Baguete 40g': TextEditingController(),
    'Massa Mini Pão Francês': TextEditingController(),
    'Massa Mini Baguete 80g': TextEditingController(),
    'Massa Baguete 330g': TextEditingController(),
    'Massa Pão De Queijo Coq': TextEditingController(),
    'Massa Pão Biscoito Queijo': TextEditingController(),
    'Massa Pão De Queijo Trad.': TextEditingController(),
    'Massa Biscoito Polvilho': TextEditingController(),
    'Massa Pão Para Rabanada': TextEditingController(),
    'Massa Pão Doce Comprido': TextEditingController(),
    'Massa Rosca Doce': TextEditingController(),
    'Massa Pão Doce Caracol': TextEditingController(),
    'Massa Pão Doce Ferradura': TextEditingController(),
    'Massa Bambino': TextEditingController(),
    'Massa Mini Pão Marta Rocha': TextEditingController(),
    'Massa Pão Tatu': TextEditingController(),
  };

  final Map<String, TextEditingController> resultadoControllers = {
    'Massa Pão Francês': TextEditingController(),
    'Massa Pão Fofinho': TextEditingController(),
    'Massa Pão Francês Fibras': TextEditingController(),
    'Massa Pão Cervejinha': TextEditingController(),
    'Massa Mini Baguete 40g': TextEditingController(),
    'Massa Mini Pão Francês': TextEditingController(),
    'Massa Mini Baguete 80g': TextEditingController(),
    'Massa Baguete 330g': TextEditingController(),
    'Massa Pão De Queijo Coq': TextEditingController(),
    'Massa Pão Biscoito Queijo': TextEditingController(),
    'Massa Pão De Queijo Trad.': TextEditingController(),
    'Massa Biscoito Polvilho': TextEditingController(),
    'Massa Pão Para Rabanada': TextEditingController(),
    'Massa Pão Doce Comprido': TextEditingController(),
    'Massa Rosca Doce': TextEditingController(),
    'Massa Pão Doce Caracol': TextEditingController(),
    'Massa Pão Doce Ferradura': TextEditingController(),
    'Massa Bambino': TextEditingController(),
    'Massa Mini Pão Marta Rocha': TextEditingController(),
    'Massa Pão Tatu': TextEditingController(),
  };

  final Map<String, bool> estoqueInsuficiente = {
    'Massa Pão Francês': false,
    'Massa Pão Fofinho': false,
    'Massa Pão Francês Fibras': false,
    'Massa Pão Cervejinha': false,
    'Massa Mini Baguete 40g': false,
    'Massa Mini Pão Francês': false,
    'Massa Mini Baguete 80g': false,
    'Massa Baguete 330g': false,
    'Massa Pão De Queijo Coq': false,
    'Massa Pão Biscoito Queijo': false,
    'Massa Pão De Queijo Trad.': false,
    'Massa Biscoito Polvilho': false,
    'Massa Pão Para Rabanada': false,
    'Massa Pão Doce Comprido': false,
    'Massa Rosca Doce': false,
    'Massa Pão Doce Caracol': false,
    'Massa Pão Doce Ferradura': false,
    'Massa Bambino': false,
    'Massa Mini Pão Marta Rocha': false,
    'Massa Pão Tatu': false,
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
    'Massa Mini Pão Francês',
    'Massa Mini Baguete 80g',
    'Massa Baguete 330g',
    'Massa Pão De Queijo Coq',
    'Massa Pão Biscoito Queijo',
    'Massa Pão De Queijo Trad.',
    'Massa Biscoito Polvilho',
    'Massa Pão Para Rabanada',
    'Massa Pão Fofinho',
    'Massa Pão Doce Comprido',
    'Massa Rosca Doce',
    'Massa Pão Doce Caracol',
    'Massa Pão Doce Ferradura',
    'Massa Bambino',
    'Massa Mini Pão Marta Rocha',
    'Massa Pão Tatu',
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _inicializarControllers();
    _loadAllData();
    dateController.text = DateFormat('dd/MM/yy').format(selectedDate);
  }

  void _inicializarControllers() {
    for (String produto in massas) {
      controllers[produto] = TextEditingController();
      resultadoControllers[produto] = TextEditingController();
    }
  }

  // ✅ MIGRADO: Carregar tudo de uma vez do Firebase
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

          // ✅ Carregar pedidos salvos
          final pedidosSalvosData = data['pedidosSalvos'] ?? {};
          for (String produto in massas) {
            final pedido = pedidosSalvosData[produto];
            if (pedido != null) {
              resultadoControllers[produto]!.text = pedido.toString();
            } else {
              resultadoControllers[produto]!.text = '0';
            }
          }
        });

        // Calcular todos os pedidos após carregar os dados
        for (String produto in massas) {
          _calcularPedidoIndividual(produto);
        }
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
    }
  }

  // ✅ MIGRADO: Salvar configurações do pedido
  Future<void> _saveInputs() async {
    try {
      final pedidoConfig = {
        'intervaloEntrega': intervaloEntrega,
      };

      final pedidosSalvos = {};
      for (String produto in massas) {
        if (resultadoControllers[produto]!.text.isNotEmpty) {
          pedidosSalvos[produto] =
              double.tryParse(resultadoControllers[produto]!.text) ?? 0;
        }
      }

      final estoqueAtual = {};
      for (String produto in massas) {
        if (controllers[produto]!.text.isNotEmpty) {
          estoqueAtual[produto] =
              double.tryParse(controllers[produto]!.text) ?? 0;
        }
      }

      await _firestore.collection('stores').doc(widget.storeName).set({
        'pedidoConfig': pedidoConfig,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Erro ao salvar inputs: $e');
    }
  }

  void _showInsufficientStockAlert(String produto) {
    setState(() {
      estoqueInsuficiente[produto] = true;
    });
  }

  void _calcularPedidoIndividual(String produto) {
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
    } else if (produto == 'Massa Mini Baguete 80g') {
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
          ? (estoqueMaxPaoParaRabanada + estoqueMaxRabanadaAssada) / 2
          : ((estoqueMaxPaoParaRabanada + estoqueMaxRabanadaAssada) -
                  estoqueCalculado) /
              2;
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
    }

    resultadoPedido = resultadoPedido.ceilToDouble();
    resultadoControllers[produto]?.text =
        resultadoPedido > 0 ? resultadoPedido.toInt().toString() : '0';

    _saveInputs(); // ✅ Salva automaticamente após cálculo
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

  // ✅ MIGRADO: Gerar pedido no Firebase
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

      // ✅ Salvar no Firebase como histórico de pedidos
      await _firestore.collection('pedidos').add(pedidoCompleto);

      // ✅ Também salvar como último pedido na loja
      await _firestore.collection('stores').doc(widget.storeName).set({
        'ultimoPedido': pedidoCompleto,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Mostrar alerta de sucesso
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
                      icon:
                          const Icon(Icons.calendar_today, color: Colors.white),
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
                              massas.forEach(_calcularPedidoIndividual);
                            });
                          },
                          items: List.generate(9, (index) => index + 1)
                              .map((days) => DropdownMenuItem(
                                    value: days,
                                    child: Text(
                                      '$days',
                                      textAlign: TextAlign.center,
                                      style:
                                          TextStyle(color: Color(0xff240217)),
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

                      return Card(
                        color: Colors.white70,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(produto,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
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
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => setState(() =>
                                        _calcularPedidoIndividual(produto)),
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
        ));
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
    'Massa Mini Pão Francês': 6,
    'Massa Mini Baguete 80g': 6,
    'Massa Baguete 330g': 6,
    'Massa Pão De Queijo Coq': 6,
    'Massa Pão Biscoito Queijo': 6,
    'Massa Pão De Queijo Trad.': 6,
    'Massa Biscoito Polvilho': 6,
    'Massa Pão Para Rabanada': 2,
    'Massa Pão Doce Comprido': 6,
    'Massa Rosca Doce': 6,
    'Massa Pão Doce Caracol': 6,
    'Massa Pão Doce Ferradura': 6,
    'Massa Bambino': 6,
    'Massa Mini Pão Marta Rocha': 6,
    'Massa Pão Tatu': 6,
    'Massa Pão Fofinho': 6,
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

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/pedido.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([XFile(file.path)], text: 'Pedido em PDF');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar ou compartilhar PDF: $e')),
      );
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

          // Inicializa seleção e controllers
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

      equipamento.forEach((campo, valor) {
        relatorio.writeln("   $campo: $valor");
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

                    // Lista de checkboxes
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

  // Adicionar controllers para os campos compartilhados
  late TextEditingController crachaController;
  late TextEditingController gerenteController;
  late TextEditingController encarregadoController;

  String resultadoInteiro = '';
  String vendamediadiaria = '';
  String userName = '';
  int colaboradoresAtivos = 0;
  late String dataFormatada;

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
    'Pão de Alho da Casa Refri.',
    'Profiteroles Brigadeiro Branco',
    'Profiteroles Doce de Leite',
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

    // Inicializar os controllers
    crachaController = TextEditingController();
    gerenteController = TextEditingController();
    encarregadoController = TextEditingController();

    // Inicializa os mapas para cada produto
    rupturasSelecionadas = {for (var p in produtos) p: false};
    motivosSelecionados = {for (var p in produtos) p: motivos[0]};
    outrosMotivos = {for (var p in produtos) p: ''};

    final dataHoje = DateTime.now();
    dataFormatada =
        "${dataHoje.day.toString().padLeft(2, '0')}/${dataHoje.month.toString().padLeft(2, '0')}/${dataHoje.year}";

    _carregarPreferencias();
  }

  Future<void> _carregarPreferencias() async {
    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        final relatorioData = data['relatorioFinal'] ?? {};

        setState(() {
          // Carregar dados compartilhados do nível principal
          crachaController.text = data['cracha'] ?? '';
          gerenteController.text = data['gerente'] ?? '';
          encarregadoController.text = data['encarregado'] ?? '';

          colaboradoresAtivos = relatorioData['colaboradoresAtivos'] ?? 0;
          rotinaSelecionadas =
              List<String>.from(relatorioData['rotinaSelecionadas'] ?? []);
          rotinaOutros = relatorioData['rotinaOutros'] ?? '';
          trabalhoRealizado = relatorioData['trabalhoRealizado'] ?? '';
          giroMedio = relatorioData['giroMedio'] ?? '';
          qtdRetirada = relatorioData['qtdRetirada'] ?? '';
          lotesRetirados = relatorioData['lotesRetirados'] ?? '';
          qtdSobra = relatorioData['qtdSobra'] ?? '';
          userName = data['userName'] ?? '';
          resultadoInteiro = relatorioData['resultadoInteiro'] ?? '';

          // Carregar vendas do Firebase para calcular resultado
          final vendasData = data['vendas'] ?? {};
          final vendaMensalPaoFrances =
              (vendasData['Pão Francês'] ?? 0).toDouble();
          final diasDeGiro = data['diasGiro'] ?? 1;
          final resultado = vendaMensalPaoFrances / diasDeGiro / 0.07;
          resultadoInteiro = resultado.ceil().toString();

          // Carregar rupturas e motivos
          final rupturasData = relatorioData['rupturas'] ?? {};
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
      // Salvar dados compartilhados no nível principal
      await _firestore.collection('stores').doc(widget.storeName).set({
        'cracha': crachaController.text,
        'gerente': gerenteController.text,
        'encarregado': encarregadoController.text,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Salvar dados específicos do relatório final
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
      };

      await _firestore.collection('stores').doc(widget.storeName).set({
        'relatorioFinal': relatorioData,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Erro ao salvar preferências: $e');
    }
  }

  String _formatarRupturas() {
    final buffer = StringBuffer();
    for (var produto in produtos) {
      if (rupturasSelecionadas[produto] == true) {
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
    if (buffer.isEmpty) {
      buffer.writeln('Nenhuma');
    }
    return buffer.toString();
  }

  Future<void> _compartilharRelatorioFinal() async {
    String texto = '''
BOA TARDE A TODOS!

*Término de visita: ${widget.storeName}
*Data: $dataFormatada
*Horário: ${horarioSaida.format(context)}
*Técnico(s): $userName 
*Crachá: ${crachaController.text}
*Gerência: ${gerenteController.text}
*Encarregado: ${encarregadoController.text}
*Colaboradores no dia: $colaboradoresAtivos
*Venda Pão Francês/dia: 
$resultadoInteiro unidades

*Motivo: 

${rotinaSelecionadas.join(', ')}${rotinaSelecionadas.contains('outros') ? ' ($rotinaOutros)' : ''}

*Trabalho Realizado No Setor:

$trabalhoRealizado

*Vendas Do Dia:

#Pão Francês: 
$vendamediadiaria unidades
#Pão de Queijo Tradicional: 
$qtdRetirada Kilos
#Pão de Queijo Coquetel: 
$lotesRetirados Kilos
#Biscoito de Queijo: 
$qtdSobra Kilos

*Rupturas: 

${_formatarRupturas()}

''';

    await Share.share(texto.trim(), subject: 'Relatório Final');
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
                          'Venda Pão Francês/Dia:',
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
                'Vendas do Dia:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                    color: verdeEscuro),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  // Coluna do input em KG - MAIOR espaço
                  Expanded(
                    flex: 4, // ✅ Da mais espaço para o TextField
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Pão Francês (kg)',
                        labelStyle: TextStyle(fontSize: 16),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: giroMedio)
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: giroMedio.length),
                        ),
                      onChanged: (v) {
                        giroMedio = v;
                        _salvarPreferencias();

                        final valor = double.tryParse(giroMedio);
                        if (valor != null && valor > 0) {
                          final convertido = (valor / 0.07).toStringAsFixed(0);
                          setState(() {
                            vendamediadiaria = convertido;
                          });
                          _salvarPreferencias();
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                      width: 10), // ✅ Aumentei o espaço entre os campos
                  // Coluna do resultado em UNIDADES - MENOR espaço
                  Expanded(
                    flex: 2, // ✅ Reduz o espaço da caixa de unidades
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
                child: ElevatedButton.icon(
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
        'label': "Mini Pão Francês C/ Gergelim",
        'screen': const MiniPaoFrancesCGergelimScreen()
      },
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
      {'label': "Pão Doce Comprido", 'screen': const PaoDoceCompridoScreen()},
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
      {
        'label': "Profiteroles Brigadeiro",
        'screen': const ProfiterolesBrigadeiroScreen()
      },
      {
        'label': "Profiteroles Brigadeiro Branco",
        'screen': const ProfiterolesBrigadeiroBrancoScreen()
      },
      {
        'label': "Profiteroles Doce de Leite",
        'screen': const ProfiterolesDoceDeLeiteScreen()
      },
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
          'https://firebasestorage.googleapis.com/v0/b/stockone-1c804.firebasestorage.app/o/requisi%C3%A7%C3%A3o%20motivos%208%2C9%2C49.pdf?alt=media&token=cca98f50-84f6-4c9f-94d9-3fcf28b329cc'
    },
    {
      'label': 'Baixas Motivo (23,71)',
      'url':
          'https://firebasestorage.googleapis.com/v0/b/stockone-1c804.firebasestorage.app/o/requisi%C3%A7%C3%A3o%20motivos%2023%2C71.pdf?alt=media&token=57e4e0ff-ac8b-487e-82e6-76e837efbf1e'
    },
    {
      'label': 'Etiqueta Validade',
      'url':
          'https://firebasestorage.googleapis.com/v0/b/stockone-1c804.firebasestorage.app/o/etiqueta%20de%20validade.pdf?alt=media&token=d25a38d2-52a5-4d2e-bb5e-d3772558e2d6'
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
            const SizedBox(height: 20),
            _buildOptionButton(
              context,
              icon: Icons.visibility,
              text: 'Visualizar',
              onTap: () => _viewDocument(context, url),
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
              icon: const Icon(Icons.arrow_back,
                  color: Colors.white, size: 30),
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
  State<Forno> createState() => _FornoState();
}

class _FornoState extends State<Forno> {
  int quantidadeFornos = 0;
  List<TextEditingController> modeloControllers = [];
  List<String> tiposForno = [];
  List<int> suportesForno = [];

  final List<String> tipos = ['Elétrico', 'Gás'];
  final List<int> suportes = [1, 2, 3, 4, 5, 6, 7, 8];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    criarFornoControllers(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFornoData();
    });
  }

  @override
  void dispose() {
    for (var controller in modeloControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void criarFornoControllers(int quantidade) {
    for (var controller in modeloControllers) {
      controller.dispose();
    }
    modeloControllers =
        List.generate(quantidade, (_) => TextEditingController());
    tiposForno = List.generate(quantidade, (_) => '');
    suportesForno = List.generate(quantidade, (_) => 0);
  }

  Future<void> _saveFornoData() async {
    try {
      List<Map<String, dynamic>> fornoList = [];
      for (int i = 0; i < quantidadeFornos; i++) {
        fornoList.add({
          'modelo': modeloControllers[i].text,
          'tipo': tiposForno[i],
          'suportes': suportesForno[i],
        });
      }

      await _firestore.collection('stores').doc(widget.storeName).set({
        'fornos': fornoList,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Erro ao salvar fornos: $e');
    }
  }

  Future<void> _loadFornoData() async {
    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        final fornoList = data['fornos'] ?? [];

        if (mounted) {
          setState(() {
            quantidadeFornos = fornoList.length;
            criarFornoControllers(quantidadeFornos);
            for (int i = 0; i < quantidadeFornos; i++) {
              var forno = fornoList[i];
              modeloControllers[i].text = forno['modelo'] ?? '';
              tiposForno[i] = forno['tipo'] ?? '';
              suportesForno[i] = forno['suportes'] ?? 0;
            }
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar fornos: $e');
    }
  }

  void _onFieldChanged() {
    _saveFornoData();
  }

  void _adicionarForno() {
    setState(() {
      quantidadeFornos++;
      modeloControllers.add(TextEditingController());
      tiposForno.add('');
      suportesForno.add(0);
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
    });
    _saveFornoData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fornos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            ...List.generate(quantidadeFornos, (index) {
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
                          Text('Forno ${index + 1}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removerForno(index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: modeloControllers[index],
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Modelo',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        onChanged: (_) => _onFieldChanged(),
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
                                  .map((tipo) => DropdownMenuItem(
                                        value: tipo,
                                        child: Text(tipo,
                                            overflow: TextOverflow.ellipsis),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  tiposForno[index] = value ?? '';
                                  _saveFornoData();
                                });
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
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
                                  .map((num) => DropdownMenuItem(
                                        value: num,
                                        child: Text(num.toString()),
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
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
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
  List<String> tiposArmario = [];
  List<int> suportesArmario = [];
  List<String> tiposEsqueleto = [];
  List<int> suportesEsqueleto = [];

  final List<String> tiposMaterial = ['Inox', 'Alumínio', 'Epoxi'];
  final List<int> suportes = List.generate(20, (index) => index + 1);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _saveData() async {
    try {
      List<Map<String, dynamic>> armarioList = [];
      for (int i = 0; i < tiposArmario.length; i++) {
        armarioList.add({
          'tipo': tiposArmario[i],
          'suportes': suportesArmario[i],
        });
      }

      List<Map<String, dynamic>> esqueletoList = [];
      for (int i = 0; i < tiposEsqueleto.length; i++) {
        esqueletoList.add({
          'tipo': tiposEsqueleto[i],
          'suportes': suportesEsqueleto[i],
        });
      }

      await _firestore.collection('stores').doc(widget.storeName).set({
        'armarios': armarioList,
        'esqueletos': esqueletoList,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Erro ao salvar armários/esqueletos: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();
      if (doc.exists) {
        final data = doc.data() ?? {};

        // Armários
        final armarioList = data['armarios'] ?? [];
        if (mounted) {
          setState(() {
            tiposArmario = List.generate(armarioList.length, (_) => '');
            suportesArmario = List.generate(armarioList.length, (_) => 0);
            for (int i = 0; i < armarioList.length; i++) {
              tiposArmario[i] = armarioList[i]['tipo'] ?? '';
              suportesArmario[i] = armarioList[i]['suportes'] ?? 0;
            }
          });
        }

        // Esqueletos
        final esqueletoList = data['esqueletos'] ?? [];
        if (mounted) {
          setState(() {
            tiposEsqueleto = List.generate(esqueletoList.length, (_) => '');
            suportesEsqueleto = List.generate(esqueletoList.length, (_) => 0);
            for (int i = 0; i < esqueletoList.length; i++) {
              tiposEsqueleto[i] = esqueletoList[i]['tipo'] ?? '';
              suportesEsqueleto[i] = esqueletoList[i]['suportes'] ?? 0;
            }
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar armários/esqueletos: $e');
    }
  }

  void _onFieldChanged() => _saveData();

  void _adicionarArmario() {
    setState(() {
      tiposArmario.add('');
      suportesArmario.add(0);
    });
    _saveData();
  }

  void _removerArmario(int index) {
    setState(() {
      tiposArmario.removeAt(index);
      suportesArmario.removeAt(index);
    });
    _saveData();
  }

  void _adicionarEsqueleto() {
    setState(() {
      tiposEsqueleto.add('');
      suportesEsqueleto.add(0);
    });
    _saveData();
  }

  void _removerEsqueleto(int index) {
    setState(() {
      tiposEsqueleto.removeAt(index);
      suportesEsqueleto.removeAt(index);
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Armários e Esqueletos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Armários:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...List.generate(tiposArmario.length, (index) {
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
                          Text('Armário ${index + 1}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removerArmario(index)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: tiposArmario[index].isNotEmpty
                                  ? tiposArmario[index]
                                  : null,
                              items: tiposMaterial
                                  .map((tipo) => DropdownMenuItem(
                                      value: tipo, child: Text(tipo)))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  tiposArmario[index] = value ?? '';
                                  _saveData();
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Tipo',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              isExpanded: true,
                              value: suportesArmario[index] > 0
                                  ? suportesArmario[index]
                                  : null,
                              items: suportes
                                  .map((num) => DropdownMenuItem(
                                      value: num, child: Text(num.toString())))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  suportesArmario[index] = value ?? 0;
                                  _saveData();
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Suportes',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
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
                    const Icon(Icons.add_circle, size: 40, color: Colors.green),
                onPressed: _adicionarArmario,
              ),
            ),
            const SizedBox(height: 30),
            const Text('Esqueletos:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...List.generate(tiposEsqueleto.length, (index) {
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
                          Text('Esqueleto ${index + 1}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removerEsqueleto(index)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: tiposEsqueleto[index].isNotEmpty
                                  ? tiposEsqueleto[index]
                                  : null,
                              items: tiposMaterial
                                  .map((tipo) => DropdownMenuItem(
                                      value: tipo, child: Text(tipo)))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  tiposEsqueleto[index] = value ?? '';
                                  _saveData();
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Tipo de material',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              isExpanded: true,
                              value: suportesEsqueleto[index] > 0
                                  ? suportesEsqueleto[index]
                                  : null,
                              items: suportes
                                  .map((num) => DropdownMenuItem(
                                      value: num, child: Text(num.toString())))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  suportesEsqueleto[index] = value ?? 0;
                                  _saveData();
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Suportes',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
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
                    const Icon(Icons.add_circle, size: 40, color: Colors.green),
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
  List<String> tiposEsteiras = [];
  List<int> quantidadesEsteiras = [];
  List<String> tiposAssadeiras = [];
  List<int> quantidadesAssadeiras = [];

  final List<String> tiposMaterial = [
    'Alumínio',
    'Inox',
    'Flandre',
    'Ferro Fundido'
  ];
  final List<int> quantidades = List.generate(120, (index) => index + 1);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _saveData() async {
    try {
      final esteirasData = List.generate(
          tiposEsteiras.length,
          (i) =>
              {'tipo': tiposEsteiras[i], 'quantidade': quantidadesEsteiras[i]});

      final assadeirasData = List.generate(
          tiposAssadeiras.length,
          (i) => {
                'tipo': tiposAssadeiras[i],
                'quantidade': quantidadesAssadeiras[i]
              });

      await _firestore.collection('stores').doc(widget.storeName).set({
        'esteiras': esteirasData,
        'assadeiras': assadeirasData,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Erro ao salvar esteiras/assadeiras: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();
      if (doc.exists) {
        final data = doc.data() ?? {};

        // Esteiras
        final esteirasList = data['esteiras'] ?? [];
        setState(() {
          tiposEsteiras =
              esteirasList.map((e) => e['tipo'] as String? ?? '').toList();
          quantidadesEsteiras =
              esteirasList.map((e) => e['quantidade'] as int? ?? 0).toList();
        });

        // Assadeiras
        final assadeirasList = data['assadeiras'] ?? [];
        setState(() {
          tiposAssadeiras =
              assadeirasList.map((e) => e['tipo'] as String? ?? '').toList();
          quantidadesAssadeiras =
              assadeirasList.map((e) => e['quantidade'] as int? ?? 0).toList();
        });
      }
    } catch (e) {
      print('Erro ao carregar esteiras/assadeiras: $e');
    }
  }

  void _adicionarEsteira() {
    setState(() {
      tiposEsteiras.add('');
      quantidadesEsteiras.add(0);
    });
    _saveData();
  }

  void _removerEsteira(int index) {
    setState(() {
      tiposEsteiras.removeAt(index);
      quantidadesEsteiras.removeAt(index);
    });
    _saveData();
  }

  void _adicionarAssadeira() {
    setState(() {
      tiposAssadeiras.add('');
      quantidadesAssadeiras.add(0);
    });
    _saveData();
  }

  void _removerAssadeira(int index) {
    setState(() {
      tiposAssadeiras.removeAt(index);
      quantidadesAssadeiras.removeAt(index);
    });
    _saveData();
  }

  Widget _buildCard({
    required String title,
    required int index,
    required String tipo,
    required int quantidade,
    required void Function(String?) onTipoChanged,
    required void Function(int?) onQtdChanged,
    required VoidCallback onRemove,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: tipo.isNotEmpty ? tipo : null,
              hint: const Text('Tipo de material'),
              items: tiposMaterial
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: onTipoChanged,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
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
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onRemove,
              ),
            )
          ],
        ),
      ),
    );
  }

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
            ...List.generate(tiposEsteiras.length, (index) {
              return _buildCard(
                title: 'Esteira Tipo ${index + 1}',
                index: index,
                tipo: tiposEsteiras[index],
                quantidade: quantidadesEsteiras[index],
                onTipoChanged: (value) {
                  setState(() {
                    tiposEsteiras[index] = value ?? '';
                    _saveData();
                  });
                },
                onQtdChanged: (value) {
                  setState(() {
                    quantidadesEsteiras[index] = value ?? 0;
                    _saveData();
                  });
                },
                onRemove: () => _removerEsteira(index),
              );
            }),
            Center(
              child: IconButton(
                icon:
                    const Icon(Icons.add_circle, size: 40, color: Colors.green),
                onPressed: _adicionarEsteira,
              ),
            ),
            const SizedBox(height: 30),
            const Text('Assadeiras:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...List.generate(tiposAssadeiras.length, (index) {
              return _buildCard(
                title: 'Assadeira Tipo ${index + 1}',
                index: index,
                tipo: tiposAssadeiras[index],
                quantidade: quantidadesAssadeiras[index],
                onTipoChanged: (value) {
                  setState(() {
                    tiposAssadeiras[index] = value ?? '';
                    _saveData();
                  });
                },
                onQtdChanged: (value) {
                  setState(() {
                    quantidadesAssadeiras[index] = value ?? 0;
                    _saveData();
                  });
                },
                onRemove: () => _removerAssadeira(index),
              );
            }),
            Center(
              child: IconButton(
                icon:
                    const Icon(Icons.add_circle, size: 40, color: Colors.green),
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
  State<Climatica> createState() => _ClimaticaState();
}

class _ClimaticaState extends State<Climatica> {
  List<TextEditingController> modeloControllers = [];
  List<int> suportesClimatica = [];
  final List<int> suportes = List.generate(40, (index) => index + 1);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    for (var controller in modeloControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void criarClimaticaControllers(int quantidade) {
    for (var controller in modeloControllers) {
      controller.dispose();
    }
    modeloControllers =
        List.generate(quantidade, (_) => TextEditingController());
    suportesClimatica = List.generate(quantidade, (_) => 0);
  }

  Future<void> _saveData() async {
    try {
      List<Map<String, dynamic>> climaticaList = [];

      for (int i = 0; i < modeloControllers.length; i++) {
        climaticaList.add({
          'modelo': modeloControllers[i].text,
          'suportes': suportesClimatica[i],
        });
      }

      await _firestore.collection('stores').doc(widget.storeName).set({
        'climaticas': climaticaList,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Erro ao salvar climáticas: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        final climaticaList = data['climaticas'] ?? [];

        if (mounted) {
          setState(() {
            criarClimaticaControllers(climaticaList.length);
            for (int i = 0; i < climaticaList.length; i++) {
              var climatica = climaticaList[i];
              modeloControllers[i].text = climatica['modelo'] ?? '';
              suportesClimatica[i] = climatica['suportes'] ?? 0;
            }
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar climáticas: $e');
    }
  }

  void _onFieldChanged() => _saveData();

  void _adicionarCard() {
    setState(() {
      modeloControllers.add(TextEditingController());
      suportesClimatica.add(0);
    });
    _saveData();
  }

  void _removerCard(int index) {
    setState(() {
      modeloControllers[index].dispose();
      modeloControllers.removeAt(index);
      suportesClimatica.removeAt(index);
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Climática')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            ...List.generate(modeloControllers.length, (index) {
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
                          Text('Climática ${index + 1}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removerCard(index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: modeloControllers[index],
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Modelo',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        onChanged: (_) => _onFieldChanged(),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        value: suportesClimatica[index] > 0
                            ? suportesClimatica[index]
                            : null,
                        items: suportes
                            .map((num) => DropdownMenuItem(
                                  value: num,
                                  child: Text(num.toString(),
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            suportesClimatica[index] = value ?? 0;
                            _saveData();
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Suportes',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            Center(
              child: IconButton(
                icon:
                    const Icon(Icons.add_circle, size: 40, color: Colors.green),
                onPressed: _adicionarCard,
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
  List<TextEditingController> modeloControllers = [];
  List<TextEditingController> volumeControllers = [];
  List<String> tiposFreezer = [];

  final List<String> tipos = ['Vertical', 'Horizontal'];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    for (var controller in modeloControllers) {
      controller.dispose();
    }
    for (var controller in volumeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void criarFreezerControllers(int quantidade) {
    for (var controller in modeloControllers) {
      controller.dispose();
    }
    for (var controller in volumeControllers) {
      controller.dispose();
    }

    modeloControllers =
        List.generate(quantidade, (_) => TextEditingController());
    volumeControllers =
        List.generate(quantidade, (_) => TextEditingController());
    tiposFreezer = List.generate(quantidade, (_) => '');
  }

  Future<void> _saveData() async {
    try {
      List<Map<String, dynamic>> freezerList = [];

      for (int i = 0; i < modeloControllers.length; i++) {
        freezerList.add({
          'modelo': modeloControllers[i].text,
          'volume': volumeControllers[i].text,
          'tipo': tiposFreezer[i],
        });
      }

      await _firestore.collection('stores').doc(widget.storeName).set({
        'freezers': freezerList,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Erro ao salvar conservadores: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      final doc =
          await _firestore.collection('stores').doc(widget.storeName).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        final freezerList = data['freezers'] ?? [];

        if (mounted) {
          setState(() {
            criarFreezerControllers(freezerList.length);
            for (int i = 0; i < freezerList.length; i++) {
              var freezer = freezerList[i];
              modeloControllers[i].text = freezer['modelo'] ?? '';
              volumeControllers[i].text = freezer['volume'] ?? '';
              tiposFreezer[i] = freezer['tipo'] ?? '';
            }
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar conservadores: $e');
    }
  }

  void _onFieldChanged() => _saveData();

  void _adicionarCard() {
    setState(() {
      modeloControllers.add(TextEditingController());
      volumeControllers.add(TextEditingController());
      tiposFreezer.add('');
    });
    _saveData();
  }

  void _removerCard(int index) {
    setState(() {
      modeloControllers[index].dispose();
      volumeControllers[index].dispose();
      modeloControllers.removeAt(index);
      volumeControllers.removeAt(index);
      tiposFreezer.removeAt(index);
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conservadores')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            ...List.generate(modeloControllers.length, (index) {
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
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removerCard(index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: modeloControllers[index],
                        decoration: const InputDecoration(
                          labelText: 'Modelo',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _onFieldChanged(),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: volumeControllers[index],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Volume (litros)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _onFieldChanged(),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: tiposFreezer[index].isNotEmpty
                            ? tiposFreezer[index]
                            : null,
                        items: tipos
                            .map((tipo) => DropdownMenuItem(
                                  value: tipo,
                                  child: Text(tipo),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            tiposFreezer[index] = value ?? '';
                            _saveData();
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Tipo',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            Center(
              child: IconButton(
                icon:
                    const Icon(Icons.add_circle, size: 40, color: Colors.green),
                onPressed: _adicionarCard,
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
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'Inventário de Equipamentos - ${widget.storeName}',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          if (dadosResumo['fornos'] != null &&
              dadosResumo['fornos'].isNotEmpty) ...[
            pw.Text('Fornos:',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ...List.generate(dadosResumo['fornos'].length, (i) {
              final forno = dadosResumo['fornos'][i];
              return pw.Bullet(
                  text:
                      "Forno ${i + 1} - Modelo: ${forno['modelo'] ?? 'N/I'}, Tipo: ${forno['tipo'] ?? 'N/I'}, Suportes: ${forno['suportes'] ?? 0}");
            }),
            pw.SizedBox(height: 10),
          ],
          if (dadosResumo['armarios'] != null &&
              dadosResumo['armarios'].isNotEmpty) ...[
            pw.Text('Armários:',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ...List.generate(dadosResumo['armarios'].length, (i) {
              final armario = dadosResumo['armarios'][i];
              return pw.Bullet(
                  text:
                      "Armário ${i + 1} - Tipo: ${armario['tipo'] ?? 'N/I'}, Suportes: ${armario['suportes'] ?? 0}");
            }),
            pw.SizedBox(height: 10),
          ],
          if (dadosResumo['esqueletos'] != null &&
              dadosResumo['esqueletos'].isNotEmpty) ...[
            pw.Text('Esqueletos:',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ...List.generate(dadosResumo['esqueletos'].length, (i) {
              final esqueleto = dadosResumo['esqueletos'][i];
              return pw.Bullet(
                  text:
                      "Esqueleto ${i + 1} - Tipo: ${esqueleto['tipo'] ?? 'N/I'}, Suportes: ${esqueleto['suportes'] ?? 0}");
            }),
            pw.SizedBox(height: 10),
          ],
          if (dadosResumo['esteiras'] != null &&
              (dadosResumo['esteiras'] as List).isNotEmpty) ...[
            pw.Text('Esteiras:',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ...List.generate((dadosResumo['esteiras'] as List).length, (i) {
              final esteira = dadosResumo['esteiras'][i];
              return pw.Bullet(
                  text:
                      "Esteira Tipo ${i + 1} - Tipo: ${esteira['tipo'] ?? 'N/I'}, Quantidade: ${esteira['quantidade'] ?? 0}");
            }),
            pw.SizedBox(height: 10),
          ],
          if (dadosResumo['assadeiras'] != null &&
              (dadosResumo['assadeiras'] as List).isNotEmpty) ...[
            pw.Text('Assadeiras:',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ...List.generate((dadosResumo['assadeiras'] as List).length, (i) {
              final assadeira = dadosResumo['assadeiras'][i];
              return pw.Bullet(
                  text:
                      "Assadeira Tipo ${i + 1} - Tipo: ${assadeira['tipo'] ?? 'N/I'}, Quantidade: ${assadeira['quantidade'] ?? 0}");
            }),
            pw.SizedBox(height: 10),
          ],
          if (dadosResumo['climaticas'] != null &&
              dadosResumo['climaticas'].isNotEmpty) ...[
            pw.Text('Climáticas:',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ...List.generate(dadosResumo['climaticas'].length, (i) {
              final clim = dadosResumo['climaticas'][i];
              return pw.Bullet(
                  text:
                      "Climática ${i + 1} - Modelo: ${clim['modelo'] ?? 'N/I'}, Suportes: ${clim['suportes'] ?? 0}");
            }),
            pw.SizedBox(height: 10),
          ],
          if (dadosResumo['freezers'] != null &&
              dadosResumo['freezers'].isNotEmpty) ...[
            pw.Text('Conservadores:',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ...List.generate(dadosResumo['freezers'].length, (i) {
              final freezer = dadosResumo['freezers'][i];
              return pw.Bullet(
                  text:
                      "Conservador ${i + 1} - Modelo: ${freezer['modelo'] ?? 'N/I'}, Volume: ${freezer['volume'] ?? 'N/I'}L, Tipo: ${freezer['tipo'] ?? 'N/I'}");
            }),
            pw.SizedBox(height: 10),
          ],
        ],
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

  Widget _buildItemCard(String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[50],
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      List.generate(dadosResumo['fornos'].length, (index) {
                        final forno = dadosResumo['fornos'][index];
                        return _buildItemCard(
                          'Forno ${index + 1}',
                          'Modelo: ${forno['modelo'] ?? 'Não informado'}, Tipo: ${forno['tipo'] ?? 'Não selecionado'}, Suportes: ${forno['suportes'] ?? 0}',
                        );
                      }),
                    ),
                  if (dadosResumo['armarios'] != null &&
                      dadosResumo['armarios'].isNotEmpty)
                    _buildSection(
                      'Armários (${dadosResumo['armarios'].length})',
                      List.generate(dadosResumo['armarios'].length, (index) {
                        final armario = dadosResumo['armarios'][index];
                        return _buildItemCard(
                          'Armário ${index + 1}',
                          'Tipo: ${armario['tipo'] ?? 'Não selecionado'}, Suportes: ${armario['suportes'] ?? 0}',
                        );
                      }),
                    ),
                  if (dadosResumo['esqueletos'] != null &&
                      dadosResumo['esqueletos'].isNotEmpty)
                    _buildSection(
                      'Esqueletos (${dadosResumo['esqueletos'].length})',
                      List.generate(dadosResumo['esqueletos'].length, (index) {
                        final esqueleto = dadosResumo['esqueletos'][index];
                        return _buildItemCard(
                          'Esqueleto ${index + 1}',
                          'Tipo: ${esqueleto['tipo'] ?? 'Não selecionado'}, Suportes: ${esqueleto['suportes'] ?? 0}',
                        );
                      }),
                    ),
                  if (dadosResumo['esteiras'] != null &&
                      (dadosResumo['esteiras'] as List).isNotEmpty)
                    _buildSection(
                      'Esteiras',
                      List.generate((dadosResumo['esteiras'] as List).length,
                          (index) {
                        final esteira = dadosResumo['esteiras'][index];
                        return _buildItemCard(
                          'Esteira Tipo ${index + 1}',
                          'Tipo: ${esteira['tipo'] ?? 'Não selecionado'}, Quantidade: ${esteira['quantidade'] ?? 0}',
                        );
                      }),
                    ),
                  if (dadosResumo['assadeiras'] != null &&
                      (dadosResumo['assadeiras'] as List).isNotEmpty)
                    _buildSection(
                      'Assadeiras',
                      List.generate((dadosResumo['assadeiras'] as List).length,
                          (index) {
                        final assadeira = dadosResumo['assadeiras'][index];
                        return _buildItemCard(
                          'Assadeira Tipo ${index + 1}',
                          'Tipo: ${assadeira['tipo'] ?? 'Não selecionado'}, Quantidade: ${assadeira['quantidade'] ?? 0}',
                        );
                      }),
                    ),
                  if (dadosResumo['climaticas'] != null &&
                      dadosResumo['climaticas'].isNotEmpty)
                    _buildSection(
                      'Climáticas (${dadosResumo['climaticas'].length})',
                      List.generate(dadosResumo['climaticas'].length, (index) {
                        final climatica = dadosResumo['climaticas'][index];
                        return _buildItemCard(
                          'Climática ${index + 1}',
                          'Modelo: ${climatica['modelo'] ?? 'Não informado'}, Suportes: ${climatica['suportes'] ?? 0}',
                        );
                      }),
                    ),
                  if (dadosResumo['freezers'] != null &&
                      dadosResumo['freezers'].isNotEmpty)
                    _buildSection(
                      'Conservadores (${dadosResumo['freezers'].length})',
                      List.generate(dadosResumo['freezers'].length, (index) {
                        final freezer = dadosResumo['freezers'][index];
                        return _buildItemCard(
                          'Conservador ${index + 1}',
                          'Modelo: ${freezer['modelo'] ?? 'Não informado'}, Volume: ${freezer['volume'] ?? 'Não informado'} litros, Tipo: ${freezer['tipo'] ?? 'Não selecionado'}',
                        );
                      }),
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
