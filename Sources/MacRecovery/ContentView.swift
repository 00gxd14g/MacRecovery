import AppKit
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BackupViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("MacRecovery")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Rsync tabanlı hızlı yedekleme aracı")
                    .foregroundColor(.secondary)
            }

            GroupBox(label: Label("Kaynak", systemImage: "folder")) {
                HStack(spacing: 8) {
                    TextField("Yedeklenecek klasör yolu...", text: $viewModel.sourcePath)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Seç...") { viewModel.pickSourceFolder() }
                }
                .padding(8)
            }

            GroupBox(label: Label("Hedef", systemImage: "externaldrive")) {
                HStack(spacing: 8) {
                    TextField("Yedekleme hedefi yolu...", text: $viewModel.destinationPath)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Seç...") { viewModel.pickDestinationFolder() }
                }
                .padding(8)
            }

            GroupBox(label: Label("Seçenekler", systemImage: "gearshape")) {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Kaynak klasörünü hedefin içine kopyala", isOn: $viewModel.copySourceFolderIntoDestination)
                    Toggle("Hedefi kaynağa göre aynala (--delete)", isOn: $viewModel.mirrorDestination)
                    Toggle("Dry run (sadece simülasyon)", isOn: $viewModel.dryRun)

                    Text(viewModel.copySourceFolderIntoDestination
                         ? "Kaynak klasörü, hedefin içinde ayrı bir klasör olarak oluşturulur."
                         : "Kaynağın içeriği doğrudan hedefe kopyalanır.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if viewModel.mirrorDestination {
                        Text("Dikkat: Aynalama seçeneği hedefte kaynakta olmayan dosyaları silebilir.")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }

                    if !viewModel.usedRsyncPath.isEmpty {
                        Text("Rsync: \(viewModel.usedRsyncPath)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if viewModel.isBackingUp {
                        if let progress = viewModel.progress {
                            HStack(spacing: 8) {
                                ProgressView(value: progress)
                                    .frame(maxWidth: 220)
                                Text("%\(Int(progress * 100))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            HStack(spacing: 8) {
                                ProgressView()
                                Text("Yedekleniyor...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(8)
            }

            GroupBox(label: Label("İşlem Günlüğü", systemImage: "text.alignleft")) {
                VStack(spacing: 8) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            Text(viewModel.outputLog)
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                                .id("logBottom")
                        }
                        .frame(minHeight: 220)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .onChange(of: viewModel.outputLog) { _ in
                            DispatchQueue.main.async {
                                proxy.scrollTo("logBottom", anchor: .bottom)
                            }
                        }
                    }

                    HStack(spacing: 8) {
                        Button("Kopyala") { viewModel.copyLogToClipboard() }
                        Button("Temizle") { viewModel.resetLog() }
                        Spacer()
                    }
                }
                .padding(8)
            }

            HStack {
                Spacer()

                if viewModel.isBackingUp {
                    Button("İptal") { viewModel.cancelBackup() }
                        .buttonStyle(.bordered)
                }

                Button("Yedeklemeyi Başlat") { viewModel.startBackup() }
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.canStartBackup)
            }
        }
        .padding(16)
        .frame(minWidth: 720, minHeight: 640)
        .alert(isPresented: $viewModel.isShowingAlert) {
            Alert(
                title: Text("Hata"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("Tamam"))
            )
        }
    }
}
