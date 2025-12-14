import Foundation
import XCTest
@testable import MacRecovery

final class MacRecoveryTests: XCTestCase {
    func testParseOverallProgress_parsesToChk() {
        let output = "file.txt\\n 12345 100% 1.2MB/s 0:00:01 (xfr#1, to-chk=9/10)\\n"
        XCTAssertEqual(RsyncSupport.parseOverallProgress(from: output), 0.1, accuracy: 0.0001)
    }

    func testParseOverallProgress_parsesToCheck() {
        let output = "sending incremental file list\\n (xfr#1, to-check=0/20)\\n"
        XCTAssertEqual(RsyncSupport.parseOverallProgress(from: output), 1.0, accuracy: 0.0001)
    }

    func testParseOverallProgress_usesLastMatch() {
        let output = "(to-chk=9/10)\\n(to-chk=1/10)\\n"
        XCTAssertEqual(RsyncSupport.parseOverallProgress(from: output), 0.9, accuracy: 0.0001)
    }

    func testBuildArguments_copyFolderIntoDestination_removesTrailingSlash() {
        let source = URL(fileURLWithPath: "/Users/test/Documents/", isDirectory: true)
        let destination = URL(fileURLWithPath: "/Volumes/Backup", isDirectory: true)

        let args = RsyncSupport.buildArguments(
            source: source,
            destination: destination,
            copySourceFolderIntoDestination: true,
            mirrorDestination: false,
            dryRun: false
        )

        XCTAssertEqual(args.suffix(2).first, "/Users/test/Documents")
        XCTAssertEqual(args.suffix(1).first, "/Volumes/Backup")
        XCTAssertFalse(args.contains("--delete"))
        XCTAssertFalse(args.contains("--dry-run"))
    }

    func testBuildArguments_copyContents_addsTrailingSlash() {
        let source = URL(fileURLWithPath: "/Users/test/Documents", isDirectory: true)
        let destination = URL(fileURLWithPath: "/Volumes/Backup/Documents", isDirectory: true)

        let args = RsyncSupport.buildArguments(
            source: source,
            destination: destination,
            copySourceFolderIntoDestination: false,
            mirrorDestination: true,
            dryRun: true
        )

        XCTAssertEqual(args.suffix(2).first, "/Users/test/Documents/")
        XCTAssertEqual(args.suffix(1).first, "/Volumes/Backup/Documents")
        XCTAssertTrue(args.contains("--delete"))
        XCTAssertTrue(args.contains("--dry-run"))
        XCTAssertTrue(args.contains("--itemize-changes"))
    }
}
