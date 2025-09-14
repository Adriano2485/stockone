import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

void main() {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2691E),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/Logo StockOne.png', height: 32),
            const SizedBox(width: 8),
            Image.asset('assets/images/logobahamas.jpg',
                height: 40), // imagem no lugar do texto
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffe16767), // topo claro
              Color(0xf7ed1717), // base marrom padaria
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
                Icons.menu_book, // ícone
                'RECEITUÁRIO', // texto
                ReceituarioScreen(),
                Colors.white,
              ),
              _menuCard(
                context,
                Icons.list_alt,
                'CÓDIGOS',
                Codigos(),
                Colors.white, // vermelho padaria
              ),
              _menuCard(
                context,
                Icons.store,
                'ATENDIMENTO',
                StoreSelectionScreen(),
                Colors.white, // cinza
              ),
            ],
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

class _StoreSelectionScreenState extends State<StoreSelectionScreen> {
  final List<String> stores =
      List.generate(100, (index) => 'Loja ${index + 1}');
  List<String> favoriteStores = [];

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

  // Mantém a navegação original sem alterações
  Future<void> _onStoreSelected(BuildContext context, String storeName) async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch_$storeName') ?? true;
    await prefs.setString('selectedStore', storeName);

    if (isFirstLaunch) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FirstTimeScreen(storeName: storeName),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SecondScreen(storeName: storeName),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedStores = [
      ...stores.where((store) => favoriteStores.contains(store)),
      ...stores.where((store) => !favoriteStores.contains(store))
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade700,
        centerTitle: true,
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
                            color: Colors.amber, // Cor âmbar para estrelas
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
  String? _selectedDeliveries;

  void _saveData() async {
    String userName = _userNameController.text.trim();
    if (userName.isEmpty || _selectedDeliveries == null) {
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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName_${widget.storeName}', userName);
    await prefs.setInt('deliveries_${widget.storeName}', deliveriesValue);
    await prefs.setBool('isFirstLaunch_${widget.storeName}', false);
    await prefs.setString('storeName', widget.storeName);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => SecondScreen(storeName: widget.storeName)),
    );
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
                decoration: const InputDecoration(labelText: "Nome do Usuário"),
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
                  onPressed: _saveData, child: const Text("Salvar Dados")),
            ],
          ),
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName_${widget.storeName}') ?? "Usuário";
    });
  }

  Future<void> _resetStoreData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('deliveries');
    await prefs.setBool('isFirstLaunch', true);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => FirstTimeScreen(storeName: widget.storeName)),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => StoreSelectionScreen()),
        );
        return false;
      },
      child: Scaffold(
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => StoreSelectionScreen()),
            ),
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
                              await _resetStoreData();
                              Navigator.pop(context);
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
                Color(0xFFFFE5B4), // topo claro
                Color(0xFFD29752), // marrom padaria (seu antigo fundo)
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
                // Grid para preencher toda a tela
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2, // duas colunas
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2, // altura proporcional
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
                          Icons.settings, "Equipamento", Colors.brown.shade400,
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
    'Profiteroles Brigadeiro',
    'Profiteroles Brigadeiro Branco',
    'Profiteroles Doce de Leite',
  ];

  int deliveries = 0;
  int? diasDeGiro;

  final Map<String, TextEditingController> vendasControllers = {};
  final Map<String, TextEditingController> estoqueControllers = {};
  final Map<String, bool> estoqueEditadoManual = {};

  final TextEditingController giroController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
    _initializeControllers();
    _loadDiasDeGiro();
    WakelockPlus.enable(); // mantém a tela ligada
  }

  void _initializeControllers() {
    for (var produto in subprodutos) {
      vendasControllers[produto] = TextEditingController();
      estoqueControllers[produto] = TextEditingController();
      estoqueEditadoManual[produto] = false;
    }
    _loadAllProductsData();
  }

  void _onVendasChanged(String produto) {
    final valorMensal = double.tryParse(vendasControllers[produto]!.text) ?? 0;
    final estoqueMax = _calcularEstoqueMaximo(valorMensal, produto);

    setState(() {
      // Atualiza o estoque automaticamente sempre que a venda mudar
      estoqueControllers[produto]!.text = estoqueMax.toInt().toString();
      // Considera que agora não é mais editado manual
      estoqueEditadoManual[produto] = false;
    });

    _saveProductData(produto);
  }

  Future<void> _loadDeliveries() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      deliveries = prefs.getInt('deliveries_${widget.storeName}') ?? 0;
    });
  }

  Future<void> _loadDiasDeGiro() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      diasDeGiro = prefs.getInt('diasGiro_${widget.storeName}');
      giroController.text = diasDeGiro?.toString() ?? '';
    });
    // Carrega os estoques existentes, não força recalculo
    _recalculateAllAutocalc(force: false);
  }

  Future<void> _saveDiasDeGiro(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('diasGiro_${widget.storeName}', value);
    setState(() {
      diasDeGiro = value;
    });
    // Força recalculo de todos os estoques ao alterar diasDeGiro
    _recalculateAllAutocalc(force: true);
  }

  Future<void> _loadAllProductsData() async {
    final prefs = await SharedPreferences.getInstance();
    for (var produto in subprodutos) {
      final vendas = prefs.getString('${produto}_vendas_${widget.storeName}');
      final estoque =
          prefs.getString('${produto}_estoqueMax_${widget.storeName}');
      if (vendas != null) vendasControllers[produto]!.text = vendas;
      if (estoque != null) {
        estoqueControllers[produto]!.text = estoque;
        estoqueEditadoManual[produto] = true; // considera manual se salvo
      }
    }
    _recalculateAllAutocalc(force: false);
  }

  Future<void> _saveProductData(String produto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${produto}_vendas_${widget.storeName}',
        vendasControllers[produto]!.text);
    await prefs.setString('${produto}_estoqueMax_${widget.storeName}',
        estoqueControllers[produto]!.text);
  }

  void _calculateAndSave(String produto) {
    if (!estoqueEditadoManual[produto]!) {
      final valorMensal =
          double.tryParse(vendasControllers[produto]!.text) ?? 0;
      final estoqueMax = _calcularEstoqueMaximo(valorMensal, produto);
      estoqueControllers[produto]!.text = estoqueMax.toInt().toString();
    }
    _saveProductData(produto);
  }

  void _onEstoqueChanged(String produto) {
    estoqueEditadoManual[produto] = true;
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
      // Se editado manualmente e não estamos forçando recalculo, pula
      if (estoqueEditadoManual[produto]! && !force) continue;

      final valorMensal =
          double.tryParse(vendasControllers[produto]!.text) ?? 0;
      final estoqueMax = _calcularEstoqueMaximo(valorMensal, produto);
      estoqueControllers[produto]!.text = estoqueMax.toInt().toString();
      _saveProductData(produto);

      // Se estamos forçando recalculo por causa de diasDeGiro, marca como não editado
      if (force) estoqueEditadoManual[produto] = false;
    }
  }

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
      case 'Pão Francês integral':
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
        estoqueMax =
            (valorMensal / 0.8 * 0.33 * 1.20 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Pão P/ Rabanada':
        estoqueMax =
            (valorMensal * 0.33 * 1.20 / diasDeGiro! / 3.3) * deliveries;
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
      case 'Fatia Hungara Chocolate':
        estoqueMax = (valorMensal * 1.30 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Fatia Hungara Doce de Leite':
        estoqueMax = (valorMensal * 1.30 / diasDeGiro! / 3.3) * deliveries;
        break;
      case 'Fatia Hungara Cocada':
        estoqueMax = (valorMensal * 1.30 / diasDeGiro! / 3.3) * deliveries;
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
      final prefs = await SharedPreferences.getInstance();
      for (final produto in subprodutos) {
        await prefs.remove('${produto}_vendas_${widget.storeName}');
        await prefs.remove('${produto}_estoqueMax_${widget.storeName}');
        vendasControllers[produto]!.clear();
        estoqueControllers[produto]!.clear();
        estoqueEditadoManual[produto] = false;
      }
      await prefs.remove('diasGiro_${widget.storeName}');
      setState(() {
        diasDeGiro = null;
        giroController.text = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // Caixa Dias de giro com título acima
              Card(
                elevation: 1,
                margin: const EdgeInsets.all(2), // margem bem pequena
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(6), // cantos menos arredondados
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4), // padding mínimo
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // altura mínima
                    children: [
                      Text(
                        "DIAS DE GIRO",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12, // fonte menor
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey.shade800,
                        ),
                      ),
                      const SizedBox(height: 2), // quase nada de espaço
                      TextFormField(
                        controller: giroController,
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        style: const TextStyle(
                            fontSize: 16), // texto menor no campo
                        decoration: InputDecoration(
                          isDense: true, // compacto
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
                                child: Text('${index + 1}',
                                    style: const TextStyle(fontSize: 16)),
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
                                Expanded(
                                  flex: 5,
                                  child: TextField(
                                    controller: vendasControllers[produto],
                                    keyboardType: TextInputType.number,
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
                                Expanded(
                                  flex: 5,
                                  child: TextField(
                                    controller: estoqueControllers[produto],
                                    keyboardType: TextInputType.number,
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
                  // Navega para a tela de mapeamento
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
  Map<String, String> estoqueMaximos = {};
  int totalFreezers = 0;

  @override
  void initState() {
    super.initState();
    _loadEstoqueMaximoData();
  }

  Future<void> _loadEstoqueMaximoData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> dadosEstoque = {};

    // Mapeamento de subprodutos para suas categorias
    Map<String, List<String>> categorias = {
      'Massa Pão Fofinho': [
        'Pão Fofinho',
        'Sanduíche Fofinho',
        'Rosca Fofinha Temperada',
        'Caseirinho'
      ],
      'Massa Pão Francês': ['Pão Francês', 'Pão Samaritano'],
      'Massa Pão Francês Integral': ['Pão Francês integral'],
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
      'Profiteroles Brigadeiro': ['Profiteroles Brigadeiro'],
      'Profiteroles Brig Branc': ['Profiteroles Brigadeiro Branco'],
      'Profiteroles Doce Leit.': ['Profiteroles Doce de Leite'],
    };

    // Calculando a quantidade de pacotes de Pão Francês e outras massas
    int pacotesPaoFrances = 0;
    int pacotesOutrasMassas = 0;

    categorias.forEach((categoria, subprodutos) async {
      int somaEstoque = 0;

      for (String subproduto in subprodutos) {
        String? estoqueMax =
            prefs.getString('${subproduto}_estoqueMax_${widget.storeName}');
        if (estoqueMax != null) {
          somaEstoque += int.tryParse(estoqueMax) ?? 0;
        }
      }

      // MODIFICAÇÃO AQUI: Garante estoque mínimo de 6
      int estoqueFinal = somaEstoque < 6 ? 6 : somaEstoque;
      dadosEstoque[categoria] = estoqueFinal.toString();

      // Separando os pacotes de Pão Francês das outras massas
      if (categoria.contains('Pão Francês')) {
        pacotesPaoFrances += estoqueFinal;
      } else {
        pacotesOutrasMassas += estoqueFinal;
      }
    });

    // Calculando o número de freezers para o Pão Francês
    int freezersPaoFrances = (pacotesPaoFrances / 54).ceil();

    // Calculando o espaço restante no último freezer de Pão Francês
    int espacoRestante = freezersPaoFrances * 54 - pacotesPaoFrances;

    // Calculando o espaço ocupado pelas outras massas em termos de pacotes de Pão Francês
    int espacoOcupadoOutrasMassas = (pacotesOutrasMassas / 2.3).ceil();

    // Tentando colocar as outras massas no espaço restante
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
                      String estoqueMax = estoqueMaximos[categoria] ?? '0';

                      return ListTile(
                        title: Text(
                          categoria,
                          style: TextStyle(fontSize: 20),
                        ),
                        subtitle: Text(
                          'Teto de Estoque: $estoqueMax',
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

class LayoutDistribuicaoScreen extends StatelessWidget {
  final Map<String, String> estoqueMassas;

  LayoutDistribuicaoScreen({required this.estoqueMassas});

  final List<String> listaMassas = [
    'Massa Pão Francês',
    'Massa Mini Baguete 80g',
    'Massa Mini Pão Francês',
    'Massa Mini Baguete 40g',
    'Massa Baguete 330g',
    'Massa Pão Francês Integral',
    'Massa Cervejinha',
    'Massa Pão Queijo Tradicional',
    'Massa Pão Queijo Coquetel',
    'Massa Biscoito Queijo',
    'Massa Biscoito Polvilho',
    'Massa Pão Rabanada 330g',
    'Massa Pão Doce Comprido',
    'Massa Pão Fofinho',
    'Massa Pão Tatu',
    'Massa Mini Marta Rocha',
    'Massa Bambino',
    'Massa Pão Doce Caracol',
    'Massa Pão Doce Ferradura',
    'Massa Rosca 330g',
    'Profiteroles Brigadeiro',
    'Profiteroles Brig Branc',
    'Profiteroles Doce Leit.',
  ];

  final int pacotesPaoFrancesPorSlot = 20;
  final int pacotesOutrasMassasPorSlot = 36;

  List<List<Map<String, Map<String, int>>>> _distribuirMassasPorFreezers() {
    List<List<Map<String, Map<String, int>>>> freezers = [];
    List<Map<String, Map<String, int>>> freezerAtual = [];
    int slotIndex = 0;

    // Primeiro, distribui o Pão Francês
    for (var massa in listaMassas) {
      int quantidade = int.tryParse(estoqueMassas[massa] ?? '0') ?? 0;

      if (massa == 'Massa Pão Francês') {
        while (quantidade > 0) {
          int pacotesNoSlot = quantidade >= pacotesPaoFrancesPorSlot
              ? pacotesPaoFrancesPorSlot
              : quantidade;

          freezerAtual.add({
            'slot${slotIndex + 1}': {massa: pacotesNoSlot},
          });

          quantidade -= pacotesNoSlot;
          slotIndex++;

          if (slotIndex % 3 == 0) {
            freezers.add(freezerAtual);
            freezerAtual = [];
          }
        }
      }
    }

    // Agora, distribui as outras massas
    for (var massa in listaMassas) {
      if (massa == 'Massa Pão Francês') continue;

      int quantidade = int.tryParse(estoqueMassas[massa] ?? '0') ?? 0;

      while (quantidade > 0) {
        bool encontrouEspaco = false;

        for (var freezer in freezers) {
          for (var slot in freezer) {
            if (slot.isNotEmpty &&
                !slot.values.first.containsKey('Massa Pão Francês')) {
              int pacotesNoSlotAtual =
                  slot.values.first.values.fold(0, (a, b) => a + b);
              int espacoRestante =
                  pacotesOutrasMassasPorSlot - pacotesNoSlotAtual;

              if (espacoRestante > 0) {
                int adicionar =
                    quantidade >= espacoRestante ? espacoRestante : quantidade;

                if (slot.values.first.containsKey(massa)) {
                  slot.values.first[massa] =
                      (slot.values.first[massa] ?? 0) + adicionar;
                } else {
                  slot.values.first[massa] = adicionar;
                }

                quantidade -= adicionar;
                encontrouEspaco = true;
                break;
              }
            }
          }
          if (encontrouEspaco) break;
        }

        if (!encontrouEspaco) {
          int pacotesNoSlot = quantidade >= pacotesOutrasMassasPorSlot
              ? pacotesOutrasMassasPorSlot
              : quantidade;

          freezerAtual.add({
            'slot${slotIndex + 1}': {massa: pacotesNoSlot},
          });

          quantidade -= pacotesNoSlot;
          slotIndex++;

          if (slotIndex % 3 == 0) {
            freezers.add(freezerAtual);
            freezerAtual = [];
          }
        }
      }
    }

    if (freezerAtual.isNotEmpty) {
      while (freezerAtual.length < 3) {
        freezerAtual.add({});
      }
      freezers.add(freezerAtual);
    }

    return freezers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sugestão de layout'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Distribuição de Massas por Freezers (pcts)'),
            Expanded(
              child: ListView.builder(
                itemCount: _distribuirMassasPorFreezers().length,
                itemBuilder: (context, freezerIndex) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Freezer ${freezerIndex + 1}'),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 3,
                            ),
                          ),
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            alignment: WrapAlignment.center,
                            children:
                                _distribuirMassasPorFreezers()[freezerIndex]
                                    .map((slot) {
                              return Container(
                                padding: EdgeInsets.all(1),
                                margin: EdgeInsets.all(2),
                                width: 180,
                                height: 140,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                  color: slot.isNotEmpty
                                      ? Colors.blue[100]
                                      : Colors.grey[300],
                                ),
                                child: slot.isNotEmpty
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: slot.values
                                            .map((massaInfo) {
                                              return massaInfo.keys
                                                  .map((massa) {
                                                String nomeDaMassa = massa
                                                    .replaceFirst('Massa ', '');
                                                return Text(
                                                  '$nomeDaMassa: ${massaInfo[massa]}',
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                );
                                              }).toList();
                                            })
                                            .expand((widget) => widget)
                                            .toList(),
                                      )
                                    : Center(
                                        child: Text(
                                          'Vazio',
                                          style: TextStyle(fontSize: 12),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
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

  // Produtos por kg com pesos padrão
  final Map<String, double> produtosKg = {
    'Massa Pão Francês': 10.5,
    'Massa Pão Francês Integral': 3.3,
    'Massa Pão Cervejinha': 3.3,
    'Massa Mini Baguete 40g': 3.3,
    'Massa Mini Pão Francês': 3.3,
    'Massa Mini Baguete 80g': 3.3,
    'Massa Pão De Queijo Coq': 3.3,
    'Massa Pão Biscoito Queijo': 3.3,
    'Massa Pão De Queijo Trad.': 3.3,
    'Massa Pão Fofinho': 3.3,
    'Massa Pão Doce Comprido': 3.3,
    'Massa Rosca Doce': 3.3,
    'Massa Pão Doce Caracol': 3.3,
    'Massa Pão Doce Ferradura': 3.3,
    'Massa Bambino': 3.3,
    'Massa Mini Pão Marta Rocha': 3.3,
    'Massa Pão Tatu': 3.3,
    'Profiteroles Brigadeiro': 1.0,
    'Profiteroles Brigadeiro Branco': 1.0,
    'Profiteroles Doce de Leite': 1.0,
    'Massa Biscoito Polvilho': 1.35,
  };

  // Produtos em unidades (10 unid por pacote)
  final List<String> produtosUnidade = [
    'Massa Pão Para Rabanada',
    'Massa Baguete 330g',
  ];

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
    for (var produto in [...produtosKg.keys, ...produtosUnidade]) {
      controllers[produto] = TextEditingController();
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      storeName = prefs.getString('storeName_${widget.storeName}') ??
          'Loja não definida';
      userName = prefs.getString('userName_${widget.storeName}') ??
          'Usuário não definido';
    });
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    controllers.forEach((produto, controller) {
      final key = '${produto}_${widget.storeName}'; // chave por loja
      controller.text = prefs.getString(key) ?? '';
    });
    setState(() {});
  }

  Future<void> _saveData(String produto) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${produto}_${widget.storeName}'; // chave por loja
    await prefs.setString(key, controllers[produto]!.text);
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
                  double pacoteAdicional = adicionar / 10;
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

    if (produtosUnidade.contains(produto)) {
      double unidades = quantidade * 10;
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
                  double pacoteRemovido = remover / 10;
                  novoValor = atual - pacoteRemovido;
                }

                // Não permitir valores negativos
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

  @override
  void dispose() {
    // desliga o wakelock
    WakelockPlus.disable();

    // descarta os controllers
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
                final prefs = await SharedPreferences.getInstance();
                for (var key in controllers.keys) {
                  await prefs.remove('${key}_${widget.storeName}');
                  controllers[key]!.clear();
                }
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dados apagados com sucesso!')),
                );
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
            // --- Cabeçalho ---
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 4),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Row(
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
                  ],
                ),
              ),
            ),
            // --- Lista de produtos ---
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
                              // Input de pacotes
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

                              // Coluna com botões + e -
                              Column(
                                children: [
                                  // Botão +
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
                                  // Botão -
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

                              // Valor convertido
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

                              // Coluna com botões ++ e --
                              Column(
                                children: [
                                  // Botão ++
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
                                  // Botão --
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
    'Massa Pão Francês Integral': TextEditingController(),
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
    'Profiteroles Brigadeiro': TextEditingController(),
    'Profiteroles Brigadeiro Branco': TextEditingController(),
    'Profiteroles Doce de Leite': TextEditingController(),
  };

  final Map<String, TextEditingController> resultadoControllers = {
    'Massa Pão Francês': TextEditingController(),
    'Massa Pão Fofinho': TextEditingController(),
    'Massa Pão Francês Integral': TextEditingController(),
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
    'Profiteroles Brigadeiro': TextEditingController(),
    'Profiteroles Brigadeiro Branco': TextEditingController(),
    'Profiteroles Doce de Leite': TextEditingController(),
  };

  final Map<String, bool> estoqueInsuficiente = {
    'Massa Pão Francês': false,
    'Massa Pão Fofinho': false,
    'Massa Pão Francês Integral': false,
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
    'Profiteroles Brigadeiro': false,
    'Profiteroles Brigadeiro Branco': false,
    'Profiteroles Doce de Leite': false,
  };

  double estoqueMaxPaoFrances = 0.0;
  double estoqueMaxPaoFofinho = 0.0;
  double estoqueMaxPaoFrancesintegral = 0.0;
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
  double estoqueMaxFatiaHungaraChocolate = 0.0;
  double estoqueMaxFatiaHungaraDocedeLeite = 0.0;
  double estoqueMaxFatiaHungaraCocada = 0.0;
  double estoqueMaxProfiterolesBrigadeiro = 0.0;
  double estoqueMaxProfiterolesBrigadeiroBranco = 0.0;
  double estoqueMaxProfiterolesDocedeLeite = 0.0;
  double estoqueMaxPaoBagueteFrancesaQueijo = 0.0;
  double estoqueMaxPaoBagueteFrancesa = 0.0;
  double estoqueMaxPaoBagueteFrancesaGergelim = 0.0;
  double estoqueMaxMiniPaoFrancesGergelim = 0.0;
  double vendaMensalPaoFrances = 0.0;
  double vendaMensalPaoFofinho = 0.0;
  double vendaMensalPaoFrancesintegral = 0.0;
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
  double vendaMensalFatiaHungaraChocolate = 0.0;
  double vendaMensalFatiaHungaraDocedeLeite = 0.0;
  double vendaMensalFatiaHungaraCocada = 0.0;
  double vendaMensalProfiterolesBrigadeiro = 0.0;
  double vendaMensalProfiterolesBrigadeiroBranco = 0.0;
  double vendaMensalProfiterolesDocedeLeite = 0.0;
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
    'Massa Pão Francês Integral',
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
    'Profiteroles Brigadeiro',
    'Profiteroles Brigadeiro Branco',
    'Profiteroles Doce de Leite',
  ];

  @override
  void initState() {
    super.initState();
    _inicializarControllers();
    _loadData();
    _loadUserData();
    _loadDiasDeGiro();
    _loadSavedInputs();
    dateController.text = DateFormat('dd/MM/yy').format(selectedDate);
  }

  void _inicializarControllers() {
    for (String produto in massas) {
      controllers[produto] = TextEditingController();
      resultadoControllers[produto] = TextEditingController();
    }
  }

  Future<void> _loadDiasDeGiro() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      diasDeGiro = prefs.getInt('diasGiro_${widget.storeName}');
    });
  }

  Future<void> _saveInputs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'intervalo_entrega_${widget.storeName}', intervaloEntrega);

    for (String produto in massas) {
      await prefs.setString(
        'pedido_${produto}_${widget.storeName}', // ← chave ajustada
        resultadoControllers[produto]?.text ?? '0',
      );
    }
  }

  Future<void> _loadSavedInputs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      intervaloEntrega =
          prefs.getInt('intervalo_entrega_${widget.storeName}') ?? 1;

      for (String produto in massas) {
        resultadoControllers[produto]?.text =
            prefs.getString('pedido_${produto}_${widget.storeName}') ??
                '0'; // ← ajustado

        controllers[produto]?.text =
            prefs.getString('${produto}_${widget.storeName}') ??
                '0'; // ← ajustado

        _calcularPedidoIndividual(produto);
      }
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      storeName = prefs.getString('storeName_${widget.storeName}') ??
          'Loja não definida';
      userName = prefs.getString('userName_${widget.storeName}') ??
          'Usuário não definido';
    });
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      estoqueMaxPaoFrances = double.tryParse(
              prefs.getString('Pão Francês_estoqueMax_${widget.storeName}') ??
                  '0') ??
          0.0;
      estoqueMaxPaoFofinho = double.tryParse(
              prefs.getString('Pão Fofinho_estoqueMax_${widget.storeName}') ??
                  '0') ??
          0.0;
      estoqueMaxPaoFrancesintegral = double.tryParse(prefs.getString(
                  'Pão Francês integral_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxPaoFrancesPanhoca = double.tryParse(prefs.getString(
                  'Pão Francês Panhoca_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxPaoFrancesComQueijo = double.tryParse(prefs.getString(
                  'Pão Francês com Queijo_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxBagueteFrancesaQueijo = double.tryParse(prefs.getString(
                  'Baguete Francesa Queijo_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxFrancesa = double.tryParse(prefs.getString(
                  'Baguete Francesa_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxPaoQueijoTradicional = double.tryParse(prefs.getString(
                  'Pão Queijo Tradicional_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxPaoQueijoCoquetel = double.tryParse(prefs.getString(
                  'Pão Queijo Coquetel_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxBiscoitoQueijo = double.tryParse(prefs.getString(
                  'Biscoito Queijo_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxBiscoitoPolvilho = double.tryParse(prefs.getString(
                  'Biscoito Polvilho_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxPaoSamaritano = double.tryParse(prefs
                  .getString('Pão Samaritano_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxPaoPizza = double.tryParse(
              prefs.getString('Pão Pizza_estoqueMax_${widget.storeName}') ??
                  '0') ??
          0.0;
      estoqueMaxPaoTatu = double.tryParse(
              prefs.getString('Pão Tatu_estoqueMax_${widget.storeName}') ??
                  '0') ??
          0.0;
      estoqueMaxMiniPaoSonho = double.tryParse(prefs
                  .getString('Mini Pão Sonho_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxMiniPaoSonhoChocolate = double.tryParse(prefs.getString(
                  'Mini Pão Sonho Chocolate_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxPaoBambino = double.tryParse(
              prefs.getString('Pão Bambino_estoqueMax_${widget.storeName}') ??
                  '0') ??
          0.0;
      estoqueMaxMiniMartaRocha = double.tryParse(prefs.getString(
                  'Mini Marta Rocha_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxPaoDoceFerradura = double.tryParse(prefs.getString(
                  'Pão Doce Ferradura_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxPaoDoceCaracol = double.tryParse(prefs.getString(
                  'Pão Doce Caracol_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxRoscaCaseira = double.tryParse(
              prefs.getString('Rosca Caseira_estoqueMax_${widget.storeName}') ??
                  '0') ??
          0.0;
      estoqueMaxRoscaCaseiraCoco = double.tryParse(prefs.getString(
                  'Rosca Caseira Côco_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxRoscaCaseiraPo = double.tryParse(prefs.getString(
                  'Rosca Caseira Leite em Pó_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxRoscaCocoQueijo = double.tryParse(prefs.getString(
                  'Rosca Côco/Queijo_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxSanduicheBahamas = double.tryParse(prefs.getString(
                  'Sanduíche Bahamas_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxRabanadaAssada = double.tryParse(prefs.getString(
                  'Rabanada Assada_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxSanduicheFofinho = double.tryParse(prefs.getString(
                  'Sanduíche Fofinho_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxRoscaFofinhaTemperada = double.tryParse(prefs.getString(
                  'Rosca Fofinha Temperada_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxCaseirinho = double.tryParse(
              prefs.getString('Caseirinho_estoqueMax_${widget.storeName}') ??
                  '0') ??
          0.0;
      estoqueMaxPaoParaRabanada = double.tryParse(prefs.getString(
                  'Pão P/ Rabanada_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxPaoDoceComprido = double.tryParse(prefs.getString(
                  'Pão Doce Comprido_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxPaoMilho = double.tryParse(
              prefs.getString('Pão Milho_estoqueMax_${widget.storeName}') ??
                  '0') ??
          0.0;
      estoqueMaxPaodeAlhodaCasa = double.tryParse(prefs.getString(
                  'Pão de Alho da Casa_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxPaodeAlhodaCasaPicante = double.tryParse(prefs.getString(
                  'Pão de Alho da Casa Picante_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxPaodeAlhodaCasaRefri = double.tryParse(prefs.getString(
                  'Pão de Alho da Casa Refri._estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;

      estoqueMaxProfiterolesBrigadeiro = double.tryParse(prefs.getString(
                  'Profiteroles Brigadeiro_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxProfiterolesBrigadeiroBranco = double.tryParse(prefs.getString(
                  'Profiteroles Brigadeiro Branco_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxProfiterolesDocedeLeite = double.tryParse(prefs.getString(
                  'Profiteroles Doce de Leite_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;

      estoqueMaxPaoBagueteFrancesaQueijo = double.tryParse(prefs.getString(
                  'Pão Baguete Francesa Queijo_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxPaoBagueteFrancesa = double.tryParse(prefs.getString(
                  'Pão Baguete Francesa_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxPaoBagueteFrancesaGergelim = double.tryParse(prefs.getString(
                  'Pão Baguete Francesa Gergelim_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;
      estoqueMaxMiniPaoFrancesGergelim = double.tryParse(prefs.getString(
                  'Mini Pão Francês Gergelim_estoqueMax_${widget.storeName}') ??
              '0') ??
          0.0;

      vendaMensalPaoFrances = double.tryParse(
              prefs.getString('Pão Francês_vendas_${widget.storeName}') ??
                  '0') ??
          0.0;
      vendaMensalPaoFofinho = double.tryParse(
              prefs.getString('Pão Fofinho_vendas_${widget.storeName}') ??
                  '0') ??
          0.0;
      vendaMensalPaoFrancesintegral = double.tryParse(prefs.getString(
                  'Pão Francês integral_vendas_${widget.storeName}') ??
              '0') ??
          0.0;
      vendaMensalPaoFrancesPanhoca = double.tryParse(prefs.getString(
                  'Pão Francês Panhoca_vendas_${widget.storeName}') ??
              '0') ??
          0.0;
      vendaMensalPaoFrancesComQueijo = double.tryParse(prefs.getString(
                  'Pão Francês com Queijo_vendas_${widget.storeName}') ??
              '0') ??
          0.0;
      vendaMensalBagueteFrancesaQueijo = double.tryParse(prefs.getString(
                  'Baguete Francesa Queijo_vendas_${widget.storeName}') ??
              '0') ??
          0.0;
      vendaMensalFrancesa = double.tryParse(
              prefs.getString('Baguete Francesa_vendas_${widget.storeName}') ??
                  '0') ??
          0.0;
      vendaMensalPaoQueijoTradicional = double.tryParse(prefs.getString(
                  'Pão Queijo Tradicional_vendas_${widget.storeName}') ??
              '0') ??
          0.0;
      vendaMensalPaoQueijoCoquetel = double.tryParse(prefs.getString(
                  'Pão Queijo Coquetel_vendas_${widget.storeName}') ??
              '0') ??
          0.0;
      vendaMensalBiscoitoQueijo = double.tryParse(
              prefs.getString('Biscoito Queijo_vendas_${widget.storeName}') ??
                  '0') ??
          0.0;
      vendaMensalBiscoitoPolvilho = double.tryParse(
              prefs.getString('Biscoito Polvilho_vendas_${widget.storeName}') ??
                  '0') ??
          0.0;
      vendaMensalPaoSamaritano = double.tryParse(
              prefs.getString('Pão Samaritano_vendas_${widget.storeName}') ??
                  '0') ??
          0.0;
      vendaMensalPaoPizza = double.tryParse(
              prefs.getString('Pão Pizza_vendas_${widget.storeName}') ?? '0') ??
          0.0;
      vendaMensalPaoTatu = double.tryParse(
              prefs.getString('Pão Tatu_vendas_${widget.storeName}') ?? '0') ??
          0.0;
      vendaMensalMiniPaoSonho = double.tryParse(
              prefs.getString('Mini Pão Sonho_vendas_${widget.storeName}') ??
                  '0') ??
          0.0;
      vendaMensalMiniPaoSonhoChocolate = double.tryParse(prefs.getString(
                  'Mini Pão Sonho Chocolate_vendas_${widget.storeName}') ??
              '0') ??
          0.0;
      vendaMensalPaoBambino = double.tryParse(
              prefs.getString('Pão Bambino_vendas_${widget.storeName}') ??
                  '0') ??
          0.0;
      vendaMensalMiniMartaRocha = double.tryParse(
              prefs.getString('Mini Marta Rocha_vendas_${widget.storeName}') ??
                  '0') ??
          0.0;
      vendaMensalPaoDoceFerradura = double.tryParse(prefs
                  .getString('Pão Doce Ferradura_vendas_${widget.storeName}') ??
              '0') ??
          0.0;
      vendaMensalPaoDoceCaracol = double.tryParse(
              prefs.getString('Pão Doce Caracol_vendas_${widget.storeName}') ??
                  '0') ??
          0.0;
      vendaMensalRoscaCaseira = double.tryParse(
              prefs.getString('Rosca Caseira_vendas_${widget.storeName}') ??
                  '0') ??
          0.0;
      vendaMensalRoscaCaseiraCoco = double.tryParse(prefs
                  .getString('Rosca Caseira Côco_vendas_${widget.storeName}') ??
              '0') ??
          0.0;
      vendaMensalRoscaCaseiraPo = double.tryParse(prefs.getString(
                  'Rosca Caseira Leite em Pó_vendas_${widget.storeName}') ??
              '0') ??
          0.0;
      vendaMensalRoscaCocoQueijo = double.tryParse(
              prefs.getString('Rosca Côco/Queijo_vendas_${widget.storeName}') ??
                  '0') ??
          0.0;
      vendaMensalSanduicheBahamas = double.tryParse(
              prefs.getString('Sanduíche Bahamas_vendas_${widget.storeName}') ??
                  '0') ??
          0.0;
      vendaMensalRabanadaAssada = double.tryParse(
              prefs.getString('Rabanada Assada_vendas_${widget.storeName}') ??
                  '0') ??
          0.0;
      vendaMensalSanduicheFofinho = double.tryParse(
              prefs.getString('Sanduíche Fofinho_vendas_${widget.storeName}') ??
                  '0') ??
          0.0;
      vendaMensalRoscaFofinhaTemperada = double.tryParse(prefs.getString(
                  'Rosca Fofinha Temperada_vendas_${widget.storeName}') ??
              '0') ??
          0.0;
      vendaMensalCaseirinho = double.tryParse(
              prefs.getString('Caseirinho_vendas_${widget.storeName}') ??
                  '0') ??
          0.0;
      vendaMensalPaoParaRabanada = double.tryParse(
              prefs.getString('Pão P/ Rabanada_vendas_${widget.storeName}') ??
                  '0') ??
          0.0;
      vendaMensalPaoDoceComprido = double.tryParse(
              prefs.getString('Pão Doce Comprido_vendas_${widget.storeName}') ??
                  '0') ??
          0.0;
      vendaMensalPaoMilho = double.tryParse(
              prefs.getString('Pão Milho_vendas_${widget.storeName}') ?? '0') ??
          0.0;
      vendaMensalPaodeAlhodaCasa = double.tryParse(prefs.getString(
                  'Pão de Alho da Casa_vendas_${widget.storeName}') ??
              '0') ??
          0.0;
      vendaMensalPaodeAlhodaCasaPicante = double.tryParse(prefs.getString(
                  'Pão de Alho da Casa Picante_vendas_${widget.storeName}') ??
              '0') ??
          0.0;
      vendaMensalPaodeAlhodaCasaRefri = double.tryParse(prefs.getString(
                  'Pão de Alho da Casa Refri._vendas_${widget.storeName}') ??
              '0') ??
          0.0;
      vendaMensalProfiterolesBrigadeiro = double.tryParse(prefs.getString(
                  'Profiteroles Brigadeiro_vendas_${widget.storeName}') ??
              '0') ??
          0.0;
      vendaMensalProfiterolesBrigadeiroBranco = double.tryParse(prefs.getString(
                  'Profiteroles Brigadeiro Branco_vendas_${widget.storeName}') ??
              '0') ??
          0.0;
      vendaMensalProfiterolesDocedeLeite = double.tryParse(prefs.getString(
                  'Profiteroles Doce de Leite_vendas_${widget.storeName}') ??
              '0') ??
          0.0;
      vendaMensalPaoBagueteFrancesaQueijo = double.tryParse(prefs.getString(
                  'Pão Baguete Francesa Queijo_vendas_${widget.storeName}') ??
              '0') ??
          0.0;
      vendaMensalPaoBagueteFrancesa = double.tryParse(prefs.getString(
                  'Pão Baguete Francesa_vendas_${widget.storeName}') ??
              '0') ??
          0.0;
      vendaMensalPaoBagueteFrancesaGergelim = double.tryParse(prefs.getString(
                  'Pão Baguete Francesa Gergelim_vendas_${widget.storeName}') ??
              '0') ??
          0.0;
      vendaMensalMiniPaoFrancesGergelim = double.tryParse(prefs.getString(
                  'Mini Pão Francês Gergelim_vendas_${widget.storeName}') ??
              '0') ??
          0.0;

      for (String produto in massas) {
        controllers[produto]?.text =
            prefs.getString('${produto}_${widget.storeName}') ?? '0';
        _calcularPedidoIndividual(produto);
      }
    });
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
              (vendaMensalPaoFrancesPanhoca * 1.45 / diasDeGiro! / 3.3));
      resultadoPedido = estoqueCalculado < 0
          ? estoqueMaxPaoFrancesPanhoca / 6
          : (estoqueMaxPaoFrancesPanhoca - estoqueCalculado) / 6;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Massa Pão Francês Integral') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              (vendaMensalPaoFrancesintegral * 1.40 / diasDeGiro! / 3.3));
      resultadoPedido = estoqueCalculado < 0
          ? estoqueMaxPaoFrancesintegral / 6
          : (estoqueMaxPaoFrancesintegral - estoqueCalculado) / 6;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Massa Mini Baguete 40g') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              (vendaMensalPaoFrancesComQueijo * 1.40 / diasDeGiro! / 3.3));
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
              ((vendaMensalPaodeAlhodaCasa * 0.24) +
                  (vendaMensalPaodeAlhodaCasaPicante * 0.24) +
                  (vendaMensalSanduicheBahamas * 0.085) +
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
                  (vendaMensalRabanadaAssada * 0.8 * 0.33) *
                      1.20 /
                      diasDeGiro! /
                      3.3));
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
                  1.30 /
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
          (intervaloEntrega * (vendaMensalPaoTatu * 1.40 / diasDeGiro! / 3.3));
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
    } else if (produto == 'Profiteroles Brigadeiro') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              (vendaMensalProfiterolesBrigadeiro * 1.20 / diasDeGiro! / 1));
      resultadoPedido = estoqueCalculado < 0
          ? estoqueMaxProfiterolesBrigadeiro / 1
          : (estoqueMaxProfiterolesBrigadeiro - estoqueCalculado) / 1;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Profiteroles Brigadeiro Branco') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              (vendaMensalProfiterolesBrigadeiroBranco *
                  1.20 /
                  diasDeGiro! /
                  1));
      resultadoPedido = estoqueCalculado < 0
          ? estoqueMaxProfiterolesBrigadeiroBranco / 1
          : (estoqueMaxProfiterolesBrigadeiroBranco - estoqueCalculado) / 1;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    } else if (produto == 'Profiteroles Doce de Leite') {
      estoqueCalculado = estoqueAtual -
          (intervaloEntrega *
              (vendaMensalProfiterolesDocedeLeite * 1.20 / diasDeGiro! / 1));
      resultadoPedido = estoqueCalculado < 0
          ? estoqueMaxProfiterolesDocedeLeite / 1
          : (estoqueMaxProfiterolesDocedeLeite - estoqueCalculado) / 1;
      if (estoqueCalculado < 0)
        _showInsufficientStockAlert(produto);
      else
        estoqueInsuficiente[produto] = false;
    }

    resultadoPedido = resultadoPedido.ceilToDouble();
    resultadoControllers[produto]?.text =
        resultadoPedido > 0 ? resultadoPedido.toInt().toString() : '0';
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

  void _gerarPedido() async {
    Map<String, String> pedidos = {};
    massas.forEach((produto) {
      pedidos[produto] = resultadoControllers[produto]?.text ?? '0';
    });

    final pedidoCompleto = {
      'produtos': pedidos,
      'usuario': userName,
      'loja': widget.storeName, // chave correta para a loja
      'data': DateFormat('dd/MM/yy').format(selectedDate),
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Salvar localmente com chave única por loja
    final prefs = await SharedPreferences.getInstance();
    final chavePedidos = 'pedidos_salvos_${widget.storeName}'; // chave com loja
    List<String> pedidosSalvos = prefs.getStringList(chavePedidos) ?? [];
    pedidosSalvos.add(jsonEncode(pedidoCompleto));
    await prefs.setStringList(chavePedidos, pedidosSalvos);

    // Mostrar alerta de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pedido gerado com sucesso'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff955a97),
          centerTitle: true, // ← Isso força a centralização total
          title: Row(
            mainAxisSize: MainAxisSize
                .min, // ← Importante: faz a Row ocupar apenas o espaço necessário
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
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Centraliza no eixo horizontal
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
                              _saveInputs();
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
                                _loadData();
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
  late Future<List<Map<String, dynamic>>> _pedidosFuturos;

  @override
  void initState() {
    super.initState();
    _pedidosFuturos = _carregarPedidosSalvos();
  }

  Future<List<Map<String, dynamic>>> _carregarPedidosSalvos() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'pedidos_salvos_${widget.storeName}';
    List<String> pedidosString = prefs.getStringList(key) ?? [];
    return pedidosString
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();
  }

  Future<void> _deletarPedido(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'pedidos_salvos_${widget.storeName}';
    List<String> pedidosString = prefs.getStringList(key) ?? [];
    if (index >= 0 && index < pedidosString.length) {
      pedidosString.removeAt(index);
      await prefs.setStringList(key, pedidosString);
      setState(() {
        _pedidosFuturos = _carregarPedidosSalvos();
      });
    }
  }

  void _recarregarPedidos() {
    setState(() {
      _pedidosFuturos = _carregarPedidosSalvos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff955a97),
        title: Text('Pedidos Salvos'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _pedidosFuturos,
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
              child: Text(
                'Nenhum pedido salvo',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pedido['data'] ?? 'Data não informada',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        pedido['loja'] ?? 'Loja não informada',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Usuário: ${pedido['usuario'] ?? 'Não informado'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmarExclusao(context, index),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalhesPedidoScreen(
                          pedido: pedido,
                          storeName: widget.storeName,
                        ),
                      ),
                    );
                    if (result == true) {
                      _recarregarPedidos();
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmarExclusao(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja deletar este pedido?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletarPedido(index);
              },
              child: Text(
                'Deletar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
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
    'Massa Pão Fofinho': 6,
    'Massa Pão Francês Integral': 6,
    'Massa Pão Cervejinha': 6,
    'Massa Mini Baguete 40g': 6,
    'Massa Mini Pão Francês': 6,
    'Massa Mini Baguete 80g': 6,
    'Massa Baguete 330g': 6,
    'Massa Pão De Queijo Coq': 6,
    'Massa Pão Biscoito Queijo': 6,
    'Massa Pão De Queijo Trad.': 6,
    'Massa Biscoito Polvilho': 6,
    'Massa Pão Para Rabanada': 6,
    'Massa Pão Doce Comprido': 6,
    'Massa Rosca Doce': 6,
    'Massa Pão Doce Caracol': 6,
    'Massa Pão Doce Ferradura': 6,
    'Massa Bambino': 6,
    'Massa Mini Pão Marta Rocha': 6,
    'Massa Pão Tatu': 6,
    'Massa Fatia Hungara Chocolate': 6,
    'Massa Fatia Hungara Doce de Leite': 6,
    'Massa Fatia Hungara Cocada': 6,
    'Profiteroles Brigadeiro': 1,
    'Profiteroles Brigadeiro Branco': 1,
    'Profiteroles Doce de Leite': 1,
  };

  Future<void> _adicionarPedidoAoEstoque(BuildContext context) async {
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

    final prefs = await SharedPreferences.getInstance();
    final produtos = Map<String, dynamic>.from(pedido['produtos']);

    produtos.forEach((produto, quantidadeStr) {
      double quantidade = double.tryParse(quantidadeStr.toString()) ?? 0;
      double multiplicador = multiplicadores[produto] ?? 1;

      final chaveEstoque = '${produto}_$storeName';
      double estoqueAtual =
          double.tryParse(prefs.getString(chaveEstoque) ?? '0') ?? 0;
      double novoEstoque = estoqueAtual + (quantidade * multiplicador);

      prefs.setString(chaveEstoque, novoEstoque.toStringAsFixed(0));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Estoque atualizado com sucesso!')),
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
            data: produtos.entries.map((entry) {
              final produto = entry.key;
              final caixas = entry.value.toString();
              return [produto, caixas];
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
                          ...produtos.entries.map((entry) => TableRow(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(entry.key),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      '${entry.value} caixa(s)',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _adicionarPedidoAoEstoque(context),
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
  late TextEditingController equipamentoController;
  late TextEditingController modeloController;
  late TextEditingController gerenteController;
  late TextEditingController defeitoController;
  late TextEditingController observacoesController;

  late String dataFormatada;

  @override
  void initState() {
    super.initState();
    equipamentoController = TextEditingController();
    modeloController = TextEditingController();
    gerenteController = TextEditingController();
    defeitoController = TextEditingController();
    observacoesController = TextEditingController();

    _carregarPreferencias();

    final dataHoje = DateTime.now();
    dataFormatada =
        "${dataHoje.day.toString().padLeft(2, '0')}/${dataHoje.month.toString().padLeft(2, '0')}/${dataHoje.year}";
  }

  Future<void> _carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      equipamentoController.text =
          prefs.getString('equipamento_${widget.storeName}') ?? '';
      modeloController.text =
          prefs.getString('modelo_${widget.storeName}') ?? '';
      gerenteController.text =
          prefs.getString('gerente_${widget.storeName}') ?? '';
      defeitoController.text =
          prefs.getString('defeito_${widget.storeName}') ?? '';
      observacoesController.text =
          prefs.getString('observacoes_${widget.storeName}') ?? '';
    });
  }

  Future<void> _salvarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'equipamento_${widget.storeName}', equipamentoController.text);
    prefs.setString('modelo_${widget.storeName}', modeloController.text);
    prefs.setString('gerente_${widget.storeName}', gerenteController.text);
    prefs.setString('defeito_${widget.storeName}', defeitoController.text);
    prefs.setString(
        'observacoes_${widget.storeName}', observacoesController.text);
  }

  Future<void> _compartilharRelatorio() async {
    String texto = """
ORDEM DE SERVIÇO

*${widget.storeName}
*Data: $dataFormatada
*Gerência: ${gerenteController.text}

*Equipamento(s):
${equipamentoController.text}

*Modelo(s): 
${modeloController.text}

*Defeito(s):
${defeitoController.text}

*Observações:
${observacoesController.text}
""";
    await Share.share(texto.trim(), subject: 'Relatório Manutenção');
  }

  @override
  void dispose() {
    equipamentoController.dispose();
    modeloController.dispose();
    gerenteController.dispose();
    defeitoController.dispose();
    observacoesController.dispose();
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
      body: SingleChildScrollView(
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
              const SizedBox(height: 32),
              _buildInput("Gerência:", gerenteController, verdeEscuro),
              const SizedBox(height: 16),
              _buildInput(
                  "Equipamento(s):", equipamentoController, verdeEscuro),
              const SizedBox(height: 16),
              _buildInput("Modelo(s):", modeloController, verdeEscuro),
              const SizedBox(height: 16),
              _buildInput("Defeito(s):", defeitoController, verdeEscuro),
              const SizedBox(height: 16),
              _buildInput("Observações:", observacoesController, verdeEscuro),
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

  Widget _buildInput(
      String label, TextEditingController controller, Color color) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 23, color: color),
      ),
      controller: controller,
      onChanged: (_) => _salvarPreferencias(),
    );
  }
}

///
/// TELA RELATÓRIO ABERTURA (código base enviado pelo usuário)
///

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
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      crachaController.text =
          prefs.getString('cracha_${widget.storeName}') ?? '';
      gerenteController.text =
          prefs.getString('gerente_${widget.storeName}') ?? '';
      encarregadoController.text =
          prefs.getString('encarregado_${widget.storeName}') ?? '';
      userName = prefs.getString('userName_${widget.storeName}') ?? '';
      colaboradoresAtivos =
          prefs.getInt('colaboradoresAtivos_${widget.storeName}') ?? 0;
      sobrasGeladeira =
          prefs.getInt('sobrasGeladeira_${widget.storeName}') ?? 0;
    });
  }

  Future<void> _salvarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cracha_${widget.storeName}', crachaController.text);
    prefs.setString('gerente_${widget.storeName}', gerenteController.text);
    prefs.setString(
        'encarregado_${widget.storeName}', encarregadoController.text);
    prefs.setInt(
        'colaboradoresAtivos_${widget.storeName}', colaboradoresAtivos);
    prefs.setInt('sobrasGeladeira_${widget.storeName}', sobrasGeladeira);
  }

  Future<void> _compartilharRelatorioComImagens() async {
    String texto = """
BOM DIA A TODOS!

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
              _buildInput("Gerência:", gerenteController, verdeEscuro),
              const SizedBox(height: 16),
              _buildInput(
                  "Encarregado(s):", encarregadoController, verdeEscuro),
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
              _buildInput("Crachá:", crachaController, verdeEscuro),
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

  Widget _buildInput(
      String label, TextEditingController controller, Color color) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 23, color: color),
      ),
      controller: controller,
      onChanged: (_) => _salvarPreferencias(),
    );
  }
}

///
/// TELA RELATÓRIO FINAL (com todos os campos e SharedPreferences)
///

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

  String cracha = '';
  String resultadoInteiro = '';
  String vendamediadiaria = '';
  String encarregado = '';
  String gerente = '';
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
  DateTime dataVisita = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Inicializa os mapas para cada produto
    rupturasSelecionadas = {for (var p in produtos) p: false};
    motivosSelecionados = {for (var p in produtos) p: motivos[0]};
    outrosMotivos = {for (var p in produtos) p: ''};

    final dataHoje = DateTime.now();
    dataFormatada =
        "${dataHoje.day.toString().padLeft(2, '0')}/${dataHoje.month.toString().padLeft(2, '0')}/${dataHoje.year}";

    _carregarPreferencias();
  }

  String _prefsKey(String key) => '${key}_${widget.storeName}';

  Future<void> _carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      colaboradoresAtivos = prefs.getInt(_prefsKey('colaboradoresAtivos')) ?? 0;
      rotinaSelecionadas =
          prefs.getStringList(_prefsKey('rotinaSelecionadas')) ?? [];
      rotinaOutros = prefs.getString(_prefsKey('rotinaOutros')) ?? '';
      trabalhoRealizado = prefs.getString(_prefsKey('trabalhoRealizado')) ?? '';
      giroMedio = prefs.getString(_prefsKey('giroMedio')) ?? '';
      qtdRetirada = prefs.getString(_prefsKey('qtdRetirada')) ?? '';
      lotesRetirados = prefs.getString(_prefsKey('lotesRetirados')) ?? '';
      qtdSobra = prefs.getString(_prefsKey('qtdSobra')) ?? '';
      cracha = prefs.getString(_prefsKey('cracha')) ?? '';
      encarregado = prefs.getString(_prefsKey('encarregado')) ?? '';
      gerente = prefs.getString(_prefsKey('gerente')) ?? '';
      vendamediadiaria = prefs.getString(_prefsKey('vendamediadiaria')) ?? '';
      userName = prefs.getString(_prefsKey('userName')) ?? '';
      resultadoInteiro =
          prefs.getString(_prefsKey('resultadoInteiro')) ?? ''; // <<< carregado

      // Carregar rupturas e motivos
      for (var produto in produtos) {
        rupturasSelecionadas[produto] =
            prefs.getBool(_prefsKey('ruptura_$produto')) ?? false;
        motivosSelecionados[produto] =
            prefs.getString(_prefsKey('motivo_$produto')) ?? motivos[0];
        outrosMotivos[produto] =
            prefs.getString(_prefsKey('outroMotivo_$produto')) ?? '';
      }

      // Recalcular venda pão francês/dia
      final vendaMensalPaoFrances = double.tryParse(
              prefs.getString('Pão Francês_vendas_${widget.storeName}') ??
                  '0') ??
          0;
      final diasDeGiro = prefs.getInt('diasGiro_${widget.storeName}') ?? 1;
      final resultado = vendaMensalPaoFrances / diasDeGiro / 0.07;
      resultadoInteiro = resultado.ceil().toString();
      prefs.setString(_prefsKey('resultadoInteiro'), resultadoInteiro);
    });
  }

  Future<void> _salvarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_prefsKey('colaboradoresAtivos'), colaboradoresAtivos);
    await prefs.setStringList(
        _prefsKey('rotinaSelecionadas'), rotinaSelecionadas);
    await prefs.setString(_prefsKey('rotinaOutros'), rotinaOutros);
    await prefs.setString(_prefsKey('trabalhoRealizado'), trabalhoRealizado);
    await prefs.setString(_prefsKey('giroMedio'), giroMedio);
    await prefs.setString(_prefsKey('qtdRetirada'), qtdRetirada);
    await prefs.setString(_prefsKey('lotesRetirados'), lotesRetirados);
    await prefs.setString(_prefsKey('qtdSobra'), qtdSobra);
    await prefs.setString(_prefsKey('cracha'), cracha);
    await prefs.setString(_prefsKey('encarregado'), encarregado);
    await prefs.setString(_prefsKey('gerente'), gerente);
    await prefs.setString(_prefsKey('vendamediadiaria'), vendamediadiaria);
    await prefs.setString(_prefsKey('userName'), userName);
    await prefs.setString(
        _prefsKey('resultadoInteiro'), resultadoInteiro); // <<< salvo também

    // Salvar rupturas e motivos
    for (var produto in produtos) {
      await prefs.setBool(_prefsKey('ruptura_$produto'),
          rupturasSelecionadas[produto] ?? false);
      await prefs.setString(_prefsKey('motivo_$produto'),
          motivosSelecionados[produto] ?? motivos[0]);
      await prefs.setString(
          _prefsKey('outroMotivo_$produto'), outrosMotivos[produto] ?? '');
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
*Crachá: $cracha
*Gerência: $gerente
*Encarregado: $encarregado
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
                controller: TextEditingController(text: gerente)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: gerente.length),
                  ),
                onChanged: (value) {
                  gerente = value;
                  _salvarPreferencias();
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Encarregado (s):',
                  labelStyle: TextStyle(fontSize: 23, color: verdeEscuro),
                ),
                controller: TextEditingController(text: encarregado)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: encarregado.length),
                  ),
                onChanged: (value) {
                  encarregado = value;
                  _salvarPreferencias();
                },
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
                controller: TextEditingController(text: cracha)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: cracha.length),
                  ),
                onChanged: (value) {
                  cracha = value;
                  _salvarPreferencias();
                },
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
                  // Coluna do input em KG
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Pão Francês (kg)',
                        labelStyle: TextStyle(fontSize: 22),
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
                            // salva o valor convertido em outra variável
                            vendamediadiaria = convertido;
                          });
                          _salvarPreferencias();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Coluna do resultado em UNIDADES
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
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
                          fontSize: 20,
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
                  labelStyle: TextStyle(fontSize: 22),
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
                  labelStyle: TextStyle(fontSize: 22),
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
                  labelStyle: TextStyle(fontSize: 22),
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

class ReceituarioScreen extends StatelessWidget {
  const ReceituarioScreen({super.key});

  // 🔹 Recebe o context como parâmetro
  Widget _padariaCard(BuildContext context, String label, Widget destination) {
    return Material(
      color: Color(0xffe1d98e),
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.brown.withOpacity(0.3),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> paes = [
      {'label': "Pão Francês", 'screen': const PaoFrancesScreen()},
      {'label': "Pão Francês Integral", 'screen': const integral()},
      {'label': "Pão Francês Panhoca", 'screen': const panhoca()},
      {'label': "Pão Baguete Francesa", 'screen': const paobaguete()},
      {
        'label': "Pão Baguete Francesa C/ Gergelim",
        'screen': const PaoFrancesScreen()
      },
      {
        'label': "Pão Baguete Francesa C/ Queijo",
        'screen': const PaoFrancesScreen()
      },
      {'label': "Baguete Francesa", 'screen': const PaoFrancesScreen()},
      {
        'label': "Baguete Francesa C/ Queijo",
        'screen': const PaoFrancesScreen()
      },
      {'label': "Pão Francês", 'screen': const PaoFrancesScreen()},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffbc2337),
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
              Color(0xffd5848f), // topo claro
              Color(0xffbc2337), // marrom padaria (seu antigo fundo)
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

class PaoFrancesScreen extends StatelessWidget {
  const PaoFrancesScreen({super.key});

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
                'assets/images/paofrances.jpg',
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
                'assets/images/integral.jpg',
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
                'assets/images/codigos.jpg',
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
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 48), // dobro
    textStyle: const TextStyle(fontSize: 32), // dobro do texto
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
  icon: const Icon(Icons.person_add, size: 36, color: Colors.white), // ícone Cadastro
  label: const Text(
    'Cadastro',
    style: TextStyle(color: Colors.white),
  ),
),
const SizedBox(height: 24), // mais espaço
ElevatedButton.icon(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0x97095195),
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 48),
    textStyle: const TextStyle(fontSize: 32),
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
  icon: const Icon(Icons.cleaning_services, size: 36, color: Colors.white), // ícone Limpeza
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
                    'Freezers',
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

class Forno extends StatefulWidget {
  final String storeName;
  const Forno({super.key, required this.storeName});

  @override
  State<Forno> createState() => _FornoState();
}

class _FornoState extends State<Forno> {
  int quantidadeFornos = 0;

  // Para armazenar os dados de cada forno
  List<TextEditingController> modeloControllers = [];
  List<String?> tiposForno = [];
  List<int?> suportesForno = [];

  final List<String> tipos = ['Elétrico', 'Gás'];
  final List<int> suportes = [1, 2, 3, 4, 5];

  @override
  void initState() {
    super.initState();
    _loadFornoData(); // Carrega os dados salvos
  }

  @override
  void dispose() {
    for (var controller in modeloControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void criarFornoControllers(int quantidade) {
    modeloControllers =
        List.generate(quantidade, (_) => TextEditingController());
    tiposForno = List.generate(quantidade, (_) => null);
    suportesForno = List.generate(quantidade, (_) => null);
  }

  // ----------------- SharedPreferences -----------------
  Future<void> _saveFornoData() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> fornoList = [];

    for (int i = 0; i < quantidadeFornos; i++) {
      fornoList.add({
        'modelo': modeloControllers[i].text,
        'tipo': tiposForno[i] ?? '',
        'suportes': suportesForno[i] ?? 0,
      });
    }

    String jsonString = jsonEncode(fornoList);
    await prefs.setString('fornos_${widget.storeName}', jsonString);
  }

  Future<void> _loadFornoData() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('fornos_${widget.storeName}');
    if (jsonString != null) {
      List<dynamic> fornoList = jsonDecode(jsonString);
      setState(() {
        quantidadeFornos = fornoList.length;
        criarFornoControllers(quantidadeFornos);

        for (int i = 0; i < quantidadeFornos; i++) {
          var forno = fornoList[i];
          modeloControllers[i].text = forno['modelo'] ?? '';
          tiposForno[i] = forno['tipo'] ?? null;
          suportesForno[i] = forno['suportes'] ?? null;
        }
      });
    }
  }

  // Chama _saveFornoData sempre que houver mudança
  void _onFieldChanged() {
    _saveFornoData();
  }

  // -------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forno'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quantidade de fornos:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<int>(
              value: quantidadeFornos > 0 ? quantidadeFornos : null,
              hint: const Text('Selecione a quantidade'),
              isExpanded: true,
              items: List.generate(10, (index) => index + 1)
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e.toString())))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    quantidadeFornos = value;
                    criarFornoControllers(quantidadeFornos);
                    _saveFornoData(); // salva sempre que muda a quantidade
                  });
                }
              },
            ),
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
                      Text('Forno ${index + 1}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      // Campo modelo maior
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
                              value: tiposForno[index],
                              hint: const Text('Tipo de forno'),
                              items: tipos
                                  .map((tipo) => DropdownMenuItem(
                                        value: tipo,
                                        child: Text(tipo,
                                            overflow: TextOverflow.ellipsis),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  tiposForno[index] = value;
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
                              value: suportesForno[index],
                              hint: const Text('Suportes'),
                              items: suportes
                                  .map((num) => DropdownMenuItem(
                                        value: num,
                                        child: Text(num.toString(),
                                            overflow: TextOverflow.ellipsis),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  suportesForno[index] = value;
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
                        ],
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
                    'Freezers',
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
