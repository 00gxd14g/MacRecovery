import Foundation

enum RsyncSupport {
    static func findExecutable(fileManager: FileManager = .default) -> URL? {
        let candidates = [
            "/opt/homebrew/bin/rsync",
            "/usr/local/bin/rsync",
            "/usr/bin/rsync"
        ]

        for path in candidates where fileManager.isExecutableFile(atPath: path) {
            return URL(fileURLWithPath: path)
        }

        return nil
    }

    static func buildArguments(
        source: URL,
        destination: URL,
        copySourceFolderIntoDestination: Bool,
        mirrorDestination: Bool,
        dryRun: Bool
    ) -> [String] {
        var args: [String] = ["-a", "-v", "-E", "--human-readable", "--progress"]

        if mirrorDestination {
            args.append("--delete")
        }

        if dryRun {
            args.append("--dry-run")
            args.append("--itemize-changes")
        }

        var sourceArg = source.path
        while copySourceFolderIntoDestination && sourceArg.count > 1 && sourceArg.hasSuffix("/") {
            sourceArg.removeLast()
        }

        if !copySourceFolderIntoDestination && !sourceArg.hasSuffix("/") {
            sourceArg += "/"
        }

        args.append(sourceArg)
        args.append(destination.path)
        return args
    }

    static func parseOverallProgress(from outputChunk: String) -> Double? {
        if let value = parseToCheckProgress(outputChunk, marker: "to-chk=") { return value }
        if let value = parseToCheckProgress(outputChunk, marker: "to-check=") { return value }
        return nil
    }

    private static func parseToCheckProgress(_ text: String, marker: String) -> Double? {
        guard let range = text.range(of: marker, options: .backwards) else { return nil }
        var index = range.upperBound
        var token = ""
        while index < text.endIndex {
            let c = text[index]
            if c.isNumber || c == "/" {
                token.append(c)
                index = text.index(after: index)
            } else {
                break
            }
        }

        let parts = token.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: true)
        guard parts.count == 2, let remaining = Int(parts[0]), let total = Int(parts[1]), total > 0 else { return nil }
        let fraction = Double(total - remaining) / Double(total)
        return min(1, max(0, fraction))
    }
}

