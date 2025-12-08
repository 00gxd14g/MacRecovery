# MacOS Hızlı Yedekleme Aracı

Bu proje, Swift ve SwiftUI kullanılarak geliştirilmiş, terminal üzerinden kolayca kurulup çalıştırılabilen bir macOS yedekleme aracıdır. `rsync` altyapısını kullanarak güvenli ve hızlı dosya transferi sağlar.

## Özellikler
- **Basit Arayüz:** SwiftUI ile modern ve anlaşılır arayüz.
- **Hızlı Yedekleme:** `rsync` ile sadece değişen dosyaları kopyalar (Incremental Backup).
- **Log Takibi:** İşlem detaylarını anlık olarak görebilirsiniz.
- **Kolay Kurulum:** Tek komutla derlenir ve çalışır.

## Kurulum ve Çalıştırma (MacOS)

1. Terminali açın ve bu klasöre gidin.
2. Kurulum scriptini çalıştırın:
   ```bash
   ./install.sh
   ```
3. Script projeyi derleyecek ve size çalıştırmak isteyip istemediğinizi soracaktır.
4. Daha sonra tekrar çalıştırmak için sadece şu komutu kullanabilirsiniz:
   ```bash
   ./MacRecoveryApp
   ```

## Önemli Not: Disk Erişim İzinleri
MacOS güvenlik önlemleri nedeniyle, uygulamanın dosyalara erişebilmesi için "Full Disk Access" (Tam Disk Erişimi) iznine ihtiyacı olabilir.

Uygulamayı terminalden başlattığınızda, terminalin (`iTerm` veya `Terminal.app`) disk erişim izni olması genellikle yeterlidir. Eğer "Operation not permitted" hatası alırsanız:

1. **Sistem Ayarları** > **Gizlilik ve Güvenlik** > **Tam Disk Erişimi** menüsüne gidin.
2. Kullandığınız Terminal uygulamasını (veya derlenmiş `MacRecoveryApp` dosyasını) listeye ekleyin ve izin verin.

## Gereksinimler
- MacOS 11.0 (Big Sur) veya üzeri.
- Xcode Command Line Tools (`xcode-select --install` ile yüklenebilir).
