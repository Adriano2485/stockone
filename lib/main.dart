final tempDir = await getTemporaryDirectory();

final file = File('${tempDir.path}/$nomeArquivo');

await file.writeAsBytes(pdfBytes);

await Share.shareXFiles(
  [XFile(file.path)],
  text: 'Posicionamento - ${widget.storeName} - $dataFormatada',
);
