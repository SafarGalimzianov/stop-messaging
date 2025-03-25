# Stop Messaging

A collection of utility scripts to help limit social media and messaging app usage by automatically monitoring and closing applications when they're detected as running.

## Overview

This project helps you stay focused and reduce distractions by automatically closing messaging applications. Instead of relying solely on willpower, these scripts act as a gentle barrier to mindlessly opening these apps.

## Features

- Monitors for specific applications running on your system
- Automatically closes detected applications
- Temporary pause functionality to allow brief access when needed
- Allow mode for monitoring without closing applications
- Simple command-line interface

## Available Scripts

### Telegram Monitor (Flatpak)

A script that monitors and optionally blocks the Flatpak version of Telegram Desktop.

#### Usage

Run in blocking mode (default):
make tf

Run in monitoring-only mode:
make allow-tf


#### Commands while running:

- `pause`: Temporarily allows Telegram to run for 2 minutes
- `Ctrl+C`: Exit the monitoring script

## Requirements

- Bash shell
- Flatpak (for Telegram monitoring script)

## Installation

1. Clone this repository:
`git clone https://github.com/yourusername/stop-messaging.git && cd stop-messaging`


2. Run the desired script using the Makefile commands

## How It Works

The scripts work by:
1. Periodically checking if the target application is running
2. If detected and in blocking mode, automatically killing the application
3. Providing commands to temporarily pause blocking when needed

## Customization

You can modify the scripts to adjust parameters like:

- Checking interval
- Pause duration
- Target applications
- Blocking behavior

Simply edit the variables at the top of each script file.

## License

[MIT License](LICENSE)

## Contributing

Contributions are welcome! Feel free to submit pull requests or open issues to suggest improvements.
