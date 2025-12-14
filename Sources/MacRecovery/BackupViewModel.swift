import AppKit
import Foundation

@MainActor
final class BackupViewModel: ObservableObject {
    @Published var sourcePath: String = ""
    @Published var destinationPath: String = ""

    @Published var copySourceFolderIntoDestination: Bool = true
    @Published var mirrorDestination: Bool = false
    @Published var dryRun: Bool = false

    @Published var outputLog: String = "Hazır... (Lütfen Tam Disk Erişimi izinlerini kontrol edin.)\n"
    @Published var isBackingUp: Bool = false
    @Published var progress: Double? = nil
    @Published var usedRsyncPath: String = ""

    @Published var isShowingAlert: Bool = false
    @Published var alertMessage: String = ""

    private var task: Process?
    private var pipe: Pipe?
    private var didRequestCancel: Bool = false

    var canStartBackup: Bool {
        !isBackingUp
        && !sourcePath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !destinationPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func pickSourceFolder() {
        pickFolder(title: "Kaynak Klasörü Seç", canCreateDirectories: false) { [weak self] url in
            self?.sourcePath = url.path
        }
    }

    func pickDestinationFolder() {
        pickFolder(title: "Hedef Klasörü Seç", canCreateDirectories: true) { [weak self] url in
            self?.destinationPath = url.path
        }
    }

    func resetLog() {
        outputLog = "Hazır... (Lütfen Tam Disk Erişimi izinlerini kontrol edin.)\n"
        progress = nil
    }

    func copyLogToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(outputLog, forType: .string)
    }

    func startBackup() {
        guard canStartBackup else { return }

        guard let rsyncURL = RsyncSupport.findExecutable() else {
            showError("Rsync bulunamadı. Lütfen macOS’te rsync’in kurulu olduğundan emin olun (varsayılan: /usr/bin/rsync).")
            return
        }

        guard let validated = validateAndNormalizePaths() else { return }

        do {
            try ensureDirectoryExists(validated.destination)
        } catch {
            showError("Hedef klasör oluşturulamadı: \(error.localizedDescription)")
            return
        }

        let args = RsyncSupport.buildArguments(
            source: validated.source,
            destination: validated.destination,
            copySourceFolderIntoDestination: copySourceFolderIntoDestination,
            mirrorDestination: mirrorDestination,
            dryRun: dryRun
        )

        usedRsyncPath = rsyncURL.path
        isBackingUp = true
        didRequestCancel = false
        progress = nil

        outputLog = [
            "Yedekleme başlatılıyor...",
            "Kaynak: \(validated.source.path)",
            "Hedef: \(validated.destination.path)",
            "Rsync: \(rsyncURL.path)",
            mirrorDestination ? "Mod: Aynalama (--delete)" : "Mod: Kopyalama (güvenli)",
            dryRun ? "Dry run: Açık (değişiklik yapılmaz)" : "Dry run: Kapalı",
            "----------------------------------------",
            ""
        ].joined(separator: "\n")

        let newTask = Process()
        newTask.executableURL = rsyncURL
        newTask.arguments = args

        let newPipe = Pipe()
        newTask.standardOutput = newPipe
        newTask.standardError = newPipe

        newPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            let chunk = String(decoding: data, as: UTF8.self)
                .replacingOccurrences(of: "\r", with: "\n")
            Task { @MainActor [weak self] in
                self?.appendOutput(chunk)
            }
        }

        newTask.terminationHandler = { [weak self, weak newPipe] task in
            newPipe?.fileHandleForReading.readabilityHandler = nil
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isBackingUp = false
                self.task = nil
                self.pipe = nil

                let exitCode = task.terminationStatus
                self.outputLog += "\n----------------------------------------\n"

                if self.didRequestCancel {
                    self.outputLog += "⏹ Yedekleme iptal edildi. (Çıkış kodu: \(exitCode))\n"
                } else if exitCode == 0 {
                    self.progress = 1
                    self.outputLog += "✓ Yedekleme tamamlandı.\n"
                } else {
                    self.outputLog += "✗ Yedekleme hata ile bitti. (Çıkış kodu: \(exitCode))\n"
                }

                self.didRequestCancel = false
            }
        }

        do {
            try newTask.run()
        } catch {
            newPipe.fileHandleForReading.readabilityHandler = nil
            showError("Rsync çalıştırılamadı: \(error.localizedDescription)")
            isBackingUp = false
            return
        }

        task = newTask
        pipe = newPipe
    }

    func cancelBackup() {
        guard isBackingUp else { return }
        didRequestCancel = true
        outputLog += "\n⏹ İptal isteniyor...\n"
        task?.terminate()
    }

    private func appendOutput(_ chunk: String) {
        outputLog += chunk
        if let value = RsyncSupport.parseOverallProgress(from: chunk) {
            progress = value
        }

        let maxChars = 200_000
        if outputLog.count > maxChars {
            outputLog = String(outputLog.suffix(maxChars))
        }
    }

    private func validateAndNormalizePaths() -> (source: URL, destination: URL)? {
        let source = normalizedDirectoryURL(fromUserInput: sourcePath)
        let destination = normalizedDirectoryURL(fromUserInput: destinationPath)

        guard source.path != "/" else {
            showError("Kaynak olarak kök dizin (/) seçilemez.")
            return nil
        }

        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: source.path, isDirectory: &isDir), isDir.boolValue else {
            showError("Kaynak klasör bulunamadı veya klasör değil: \(source.path)")
            return nil
        }

        if FileManager.default.fileExists(atPath: destination.path, isDirectory: &isDir), !isDir.boolValue {
            showError("Hedef bir dosya olamaz: \(destination.path)")
            return nil
        }

        if source.standardizedFileURL == destination.standardizedFileURL {
            showError("Kaynak ve hedef aynı olamaz.")
            return nil
        }

        if destination.standardizedFileURL.path.hasPrefix(source.standardizedFileURL.path + "/") {
            showError("Hedef, kaynağın içinde olamaz. (Sonsuz döngü riski)")
            return nil
        }

        sourcePath = source.path
        destinationPath = destination.path
        return (source, destination)
    }

    private func normalizedDirectoryURL(fromUserInput input: String) -> URL {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let expanded = (trimmed as NSString).expandingTildeInPath
        return URL(fileURLWithPath: expanded, isDirectory: true).standardizedFileURL
    }

    private func ensureDirectoryExists(_ url: URL) throws {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
            if !isDir.boolValue {
                throw NSError(domain: "MacRecovery", code: 2, userInfo: [NSLocalizedDescriptionKey: "Hedef yol bir dosyayı işaret ediyor."])
            }
            return
        }

        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    private func pickFolder(title: String, canCreateDirectories: Bool, completion: @escaping (URL) -> Void) {
        let panel = NSOpenPanel()
        panel.title = title
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = canCreateDirectories
        panel.prompt = "Seç"

        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            completion(url)
        }
    }

    private func showError(_ message: String) {
        alertMessage = message
        isShowingAlert = true
        outputLog += "\n✗ \(message)\n"
    }
}
