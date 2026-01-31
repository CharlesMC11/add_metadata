# sst (Screenshot Tagger)

A Zsh-based automation suite optimized for Apple Silicon. It leverages a RAM-disk–to–SSD pipeline, injects professional photography metadata to screenshots, and archives the originals using Apple Archive.

## Motivation

This project was originally inspired by finding a way for image cataloging tools such as **Lightroom Classic** and **Capture One** to treat screenshots of video calls with my girlfriend as legitimate photos taken with a camera. Eventually, this also evolved into a project for me to explore macOS-native performance: utilizing RAM disks for transient files, `Zsh Word Code` for execution speed, and `launchd` for automation.

## Architecture & Performance

Designed specifically for my M2 Max MacBook Pro with 96 GB RAM, the suite utilizes:

- **RAM Disk Pipeline**: Uses a 16 GiB RAM disk (`/Volumes/Workbench`) for high-frequency transient data (locking, temporary logging, and process files) to reduce SSD wear.
- **Native Efficiency**: Scripts are compiled to `Zsh Word Code` (`.zwc`) during installation.
- **Atomic Execution**: Uses `zsystem flock` to prevent race conditions when mutiple screenshots taken in succession.
- **Apple Archive (`.aar`)**: Utilizes native Apple Silicon compression (`lz4`) to archive original files after processing.
- **Strict Execution**: Uses `setopt NO_UNSET` and `ERR_EXIT` to ensure daemon fails safely and loudly if the environment is misconfigured.

## Features

- **Photography Metadata**: Injects `Model`, `Software`, `DateTime`, and `OffsetTime` tags via `ExifTool`.
- **Professional Naming**: Standardizes filenames to `YYMMDD_HHMMSS` based on internal capture timestamp.
- **Background Parallelism**: Dispatches `aa` and `exiftool` as background processes to minimize blocking time of the main daemon loop.
- **Native Notifications**: Real-time status updates via macOS Notifications Center.

## Project Structure

- `Makefile`: The build system. "Bakes" configuration constants directly into scripts to satisfy strict shell parameters.
- `sstd.zsh`: The core daemon. Handles the lifecycle of the screenshot processing.
- `functions/`: Autoloaded Zsh functions for modular logging, error-handling, and cleanup.
- `sst.plist.template`: Generates the launch agent that monitors `$INPUT_DIR`.

## Installation

The suite is installed to the RAM disk, and registered as a user-level Launch Agent.

1. **Configure**: Update the paths in the `Makefile` (defaults to `/Volumes/Workbench/sst`).
2. **Build & Install**:

```zsh
make install  # Compiles scripts and moves them into `$(BIN_DIR)`
```

3. **Start the Agent**:

```zsh
make start    # Generates the `.plist` and launches the agent
```

## Requirements

- **ExifTool**: Required for professional metadata injection.
- **macOS**: Optimized for Apple Silicon.
