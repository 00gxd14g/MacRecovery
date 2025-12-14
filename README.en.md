# MacRecovery

[Türkçe README](README.md)

MacRecovery is a fast macOS backup tool with a SwiftUI interface built on top of `rsync`. It copies the selected source folder to the destination, streams logs live during the operation, and allows canceling the backup.

## Features
- Simple SwiftUI UI for selecting source/destination folders
- Live log streaming and cancel support
- Options:
  - Copy the source folder into the destination, or copy only its contents
  - Mirror mode (`--delete`) to keep destination in sync (use with care)
  - Dry-run simulation mode (`--dry-run`)
- Automatically locates `rsync` (prefers Homebrew if available)

## Requirements
- macOS 11.0 (Big Sur) or later
- Swift 5.5+ (Xcode 13+ or Xcode Command Line Tools)
- `rsync` (available on macOS by default; Homebrew rsync recommended)

## Install
```bash
git clone https://github.com/00gxd14g/MacRecovery.git
cd MacRecovery
chmod +x install.sh
./install.sh
```

The install script builds with `swift build -c release` and copies the binary to `./MacRecovery`.

## Run
```bash
./MacRecovery
```

Alternative:
```bash
swift run -c release
```

## Tests
```bash
swift test
```

## Important: Full Disk Access
Due to macOS privacy protections, you may need to grant “Full Disk Access” to your Terminal (or to the compiled binary) to back up certain folders.

If you see “Operation not permitted”:
1. **System Settings** → **Privacy & Security** → **Full Disk Access**
2. Add your Terminal app (Terminal.app / iTerm) or the binary you’re running.

## Safety Note (Mirror / --delete)
The “mirror” option can delete files on the destination that don’t exist in the source. It’s recommended to try “dry run” first.

## License
MIT — see `LICENSE`.

