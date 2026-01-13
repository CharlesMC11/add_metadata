# Screenshot Tagger

A Zsh-based automation suite for macOS that monitors a directory, renames screenshots based on their original capture timestamp, injects custom EXIF metadata, and archives the original files.

## Features

- Automated Monitoring: Uses macOS `launchd` to watch for new files added to the screenshots directory

- Smart Renaming: Exctracts timestamps from filenames to create a standardized format: `YYMMDD_HHMMSS`.

- Metadata Injection: Uses `Exiftool` to embed capture dates, hardware/software info, and custom tag files.

- Automatic Archiving: Compresses original screenshots into a `.tar.gz` archive after processing to keep folders clean.

- Race-Condition Projection: Implements a lockfile mechanism to prevent multiple `launchd` triggers from conflicting.

## Requirements

- `ExifTool`: Required for metadata manipulation.
- `Gzip/libarchive`: Used for archiving processed files.
- `envsubst`: Used during installation to configure the `.plist` file.

## Project Struture

- `metadata-engine.zsh`: The core logic for renaming, tagging, and archiving.
- `screenshot-watcher.zsh`: A wrapper script that manages execution locks and calls the engine.
- `screenshot_tagger.plist.template`: A launch agent template to automate the script via macOS `WatchPaths`.

## Installation

The project includes a `Makefile` for streamlined setup:

1. Compile and Install:

```zsh
make install
```

This compiles the scripts to Zsh Word Code (`.zwc`) for faster execution and moves them to `~/.local/bin/screenshot-tagger/`.

2. Start the Automation:

```zsh
make start
```

This generates the final `.plist` with your user information and loads it into `launchctl`.
