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
