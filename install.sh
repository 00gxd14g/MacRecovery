#!/bin/bash

# Renkler
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}MacOS Recovery Tool Kurulumu Başlatılıyor...${NC}"

# Swift kontrolü
if ! command -v swift &> /dev/null; then
    echo "Hata: 'swift' komutu bulunamadı. Lütfen Xcode Command Line Tools'u yükleyin."
    echo "Çalıştır: xcode-select --install"
    exit 1
fi

echo -e "${GREEN}Derleniyor (Release Modu)...${NC}"
swift build -c release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Derleme Başarılı!${NC}"
    
    # Binary'i buraya kopyala
    cp .build/release/MacRecovery ./MacRecoveryApp
    
    echo -e "${BLUE}Uygulama hazır: ./MacRecoveryApp${NC}"
    echo "Çalıştırmak için: ./MacRecoveryApp"
    
    read -p "Uygulamayı şimdi başlatmak ister misiniz? (e/h): " choice
    if [[ "$choice" == "e" || "$choice" == "E" ]]; then
        ./MacRecoveryApp
    fi
else
    echo "Derleme sırasında bir hata oluştu."
    exit 1
fi
