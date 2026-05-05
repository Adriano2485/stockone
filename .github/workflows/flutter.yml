name: Build do App (AAB)

on:
  push:
    branches: [ master ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: 📥 Baixar código
      uses: actions/checkout@v4

    - name: 🐦 Configurar Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.38.3'

    - name: ⚙️ Criar local.properties
      run: |
        cat > android/local.properties << EOF
        sdk.dir=$ANDROID_HOME
        flutter.sdk=$FLUTTER_ROOT
        EOF

    - name: 📦 Instalar dependências
      run: flutter pub get

    - name: 🧹 Limpar build
      run: flutter clean

    # ---------------- ANDROID ----------------
    - name: 🤖 Build AAB (Release)
      run: flutter build appbundle --release

    - name: 📦 Upload AAB
      uses: actions/upload-artifact@v4
      with:
        name: StockOne-AAB
        path: build/app/outputs/bundle/release/app-release.aab
        retention-days: 30
