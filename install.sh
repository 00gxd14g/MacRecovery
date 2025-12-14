#!/usr/bin/env bash

set -euo pipefail

# Renkler
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}MacRecovery kurulumu başlatılıyor...${NC}"

if [[ "$(uname)" != "Darwin" ]]; then
  echo -e "${RED}Hata:${NC} Bu kurulum scripti yalnızca macOS üzerinde çalışır."
  exit 1
fi

# Swift kontrolü
if ! command -v swift &> /dev/null; then
  echo -e "${RED}Hata:${NC} 'swift' komutu bulunamadı. Lütfen Xcode Command Line Tools'u yükleyin."
  echo "Çalıştır: xcode-select --install"
  exit 1
fi

echo -e "${GREEN}Derleniyor (Release)...${NC}"
swift build -c release

echo -e "${GREEN}Derleme başarılı.${NC}"

BIN_DIR="$(swift build -c release --show-bin-path)"
BIN_PATH="$BIN_DIR/MacRecovery"
OUT_PATH="./MacRecovery"

if [[ ! -f "$BIN_PATH" ]]; then
  echo -e "${RED}Hata:${NC} Derlenen binary bulunamadı: $BIN_PATH"
  exit 1
fi

cp "$BIN_PATH" "$OUT_PATH"
chmod +x "$OUT_PATH" || true

echo -e "${BLUE}Uygulama hazır:${NC} $OUT_PATH"
echo "Çalıştırmak için: $OUT_PATH"

read -r -p "Uygulamayı şimdi başlatmak ister misiniz? (e/h): " choice
if [[ "$choice" == "e" || "$choice" == "E" ]]; then
  "$OUT_PATH"
fi
