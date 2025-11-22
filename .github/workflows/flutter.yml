name: Build do App

on:
  push:
    branches: [ master ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Baixar código
      uses: actions/checkout@v4
    
    - name: Configurar Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.38.3'
        
    - name: Criar local.properties
      run: |
        cat > android/local.properties << EOF
        sdk.dir=$ANDROID_HOME
        flutter.sdk=$FLUTTER_ROOT
        EOF
        
    - name: Instalar dependências
      run: flutter pub get
    
    - name: 🔥 LIMPAR TUDO
      run: flutter clean
    
    - name: Build APK
      run: flutter build apk --release  # ⬅️ CORRETO
      
    - name: Build AAB
      run: flutter build appbundle --release  # ⬅️ CORRETO
      
    - name: 📱 Fazer upload do APK
      uses: actions/upload-artifact@v4
      with:
        name: StockOne-APK
        path: build/app/outputs/flutter-apk/app-release.apk
        retention-days: 30
        
    - name: 📦 Fazer upload do AAB
      uses: actions/upload-artifact@v4
      with:
        name: StockOne-AAB
        path: build/app/outputs/bundle/release/app.aab
        retention-days: 30
