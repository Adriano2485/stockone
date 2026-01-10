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
