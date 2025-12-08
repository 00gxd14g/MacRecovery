import SwiftUI
import Foundation

struct ContentView: View {
    @State private var sourcePath: String = ""
    @State private var destinationPath: String = ""
    @State private var outputLog: String = "Hazır... (Lütfen Full Disk Access izniniz olduğundan emin olun)"
    @State private var isBackingUp: Bool = false
    @State private var progress: Double = 0.0

    var body: some View {
        VStack(spacing: 20) {
            Text("MacOS Hızlı Yedekleyici")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            // Kaynak Seçimi
            VStack(alignment: .leading) {
                Text("Kaynak Klasör:")
                    .font(.headline)
                HStack {
                    TextField("/Users/kullanici/Belgeler", text: $sourcePath)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: { selectFolder { path in sourcePath = path } }) {
                        Image(systemName: "folder")
                        Text("Seç")
                    }
                }
            }
            .padding(.horizontal)

            // Hedef Seçimi
            VStack(alignment: .leading) {
                Text("Hedef Disk/Klasör:")
                    .font(.headline)
                HStack {
                    TextField("/Volumes/YedekDiski", text: $destinationPath)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: { selectFolder { path in destinationPath = path } }) {
                        Image(systemName: "externaldrive")
                        Text("Seç")
                    }
                }
            }
            .padding(.horizontal)

            Divider()

            // Log Ekranı
            VStack(alignment: .leading) {
                Text("İşlem Günlüğü:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                ScrollView {
                    Text(outputLog)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                }
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            }
            .frame(height: 200)
            .padding(.horizontal)

            // Başlat Butonu
            Button(action: startBackup) {
                HStack {
                    if isBackingUp {
                        ProgressView().controlSize(.small)
                    }
                    Text(isBackingUp ? "Yedekleniyor..." : "Yedeklemeyi Başlat")
                        .fontWeight(.semibold)
                }
                .frame(width: 200, height: 40)
            }
            .disabled(sourcePath.isEmpty || destinationPath.isEmpty || isBackingUp)
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
        }
        .frame(minWidth: 600, minHeight: 500)
    }

    // Klasör Seçme Fonksiyonu
    func selectFolder(completion: @escaping (String) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Klasörü Seç"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                completion(url.path)
            }
        }
    }

    // Yedekleme Mantığı (Rsync Wrapper)
    func startBackup() {
        guard !sourcePath.isEmpty && !destinationPath.isEmpty else { return }
        
        isBackingUp = true
        outputLog = "Yedekleme başlatılıyor...\nKaynak: \(sourcePath)\nHedef: \(destinationPath)\n----------------------------------------\n"
        
        // Arka planda çalıştır (UI donmaması için)
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            // rsync genellikle /usr/bin/rsync konumundadır
            task.executableURL = URL(fileURLWithPath: "/usr/bin/rsync")
            
            // -a: arşiv modu (izinleri korur)
            // -v: verbose
            // --progress: ilerleme
            // --delete: kaynakta olmayanları hedefte de sil (opsiyonel, dikkatli kullanılmalı, buraya eklemiyorum güvenli olsun diye)
            task.arguments = ["-av", "--progress", sourcePath, destinationPath]
            
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe // Hataları da görelim
            
            do {
                try task.run()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.outputLog += "\n" + output
                        self.isBackingUp = false
                        self.outputLog += "\n✅ Yedekleme Tamamlandı!"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.outputLog += "\n❌ Hata: \(error.localizedDescription)"
                    self.isBackingUp = false
                }
            }
        }
    }
}
