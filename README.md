# MacRecovery

[English README](README.en.md)

SwiftUI arayüzüyle, `rsync` tabanlı hızlı bir macOS yedekleme aracıdır. Seçtiğiniz kaynak klasörü hedefe kopyalar, işlem sırasında canlı log gösterir ve istenirse işlemi iptal edebilirsiniz.

## Özellikler
- Klasör seçimi (kaynak/hedef) için basit SwiftUI arayüzü
- Canlı log akışı ve işlem iptali
- Seçenekler:
  - Kaynak klasörünü hedefin içine kopyalama / kaynağın içeriğini doğrudan hedefe kopyalama
  - Aynalama modu (`--delete`) ile hedefi kaynakla eşitleme (dikkatli kullanın)
  - Dry run (simülasyon) modu (`--dry-run`)
- `rsync` yolu otomatik bulunur (Homebrew varsa öncelik verilir)

## Gereksinimler
- macOS 11.0 (Big Sur) veya üzeri
- Swift 5.5+ (Xcode 13+ veya Xcode Command Line Tools)
- `rsync` (macOS’te varsayılan olarak bulunur; Homebrew rsync önerilir)

## Kurulum
```bash
git clone https://github.com/00gxd14g/MacRecovery.git
cd MacRecovery
chmod +x install.sh
./install.sh
```

Kurulum scripti, `swift build -c release` ile derler ve çıktıyı proje köküne `./MacRecovery` olarak kopyalar.

## Çalıştırma
```bash
./MacRecovery
```

Alternatif:
```bash
swift run -c release
```

## Testler
```bash
swift test
```

## Önemli Not: Tam Disk Erişimi
macOS güvenlik önlemleri nedeniyle, bazı klasörleri yedeklemek için Terminal’in (veya uygulamanın) “Tam Disk Erişimi” izni gerekebilir.

“Operation not permitted” görürseniz:
1. **Sistem Ayarları** → **Gizlilik ve Güvenlik** → **Tam Disk Erişimi**
2. Kullandığınız Terminal uygulamasını (Terminal.app / iTerm) veya çalıştırdığınız binary’yi ekleyin.

## Güvenlik Notu (Aynalama / --delete)
“Hedefi kaynağa göre aynala (--delete)” seçeneği, hedefte olup kaynakta olmayan dosyaları silebilir. Önce “Dry run” ile denemeniz önerilir.

## Lisans
MIT — detaylar için `LICENSE`.
