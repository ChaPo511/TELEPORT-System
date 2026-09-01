# TELEPORT System

A modern, highly customizable, and interactive system for FiveM. With a sleek UI, in-game admin tools, passcode-protected floors, and multi-language support, this script provides an immersive experience for players while keeping setup effortless for server administrators.

## 🌟 Features

- **Sleek NUI interface**: A beautifully designed UI with floor selection, smooth animations, and progress bars.
- **In-Game Admin Menu**: Create, edit, and delete elevators and floors directly in-game using an admin panel (`/tpmadmin`). You can even capture your current coordinates instantly for new floors!
- **Passcode Protection**: Restrict access to VIP areas, vaults, or private floors using a passcode system.
- **Multi-Language Support**: Fully translated into English (EN), German (DE), Spanish (ES), French (FR), and Arabic (AR). Easily configurable in `config.lua`.
- **Database Integration**: Custom elevators configured in-game are saved persistently to the database using `oxmysql`.
- **Custom Sounds**: Native GTA V elevator sounds playing upon arrival/departure (configurable).
- **Highly Configurable**: Change interaction distances, 3D text/markers, and debug modes straight from `config.lua`.
- **Optimized Performance**: Minimal resource usage with smart distance-checking threads.

## 📦 Requirements

- **Framework**: Compatible with **Qbox**, **QB-Core**, **ESX**, or can be used **Standalone**.
- [oxmysql](https://github.com/overextended/oxmysql) (For saving customized elevators via the admin panel)

## 📥 Installation

1. Download the resource and place it in your `resources` folder (e.g., `[standalone]/TELEPORT`).
2. Run the provided `install.sql` file in your database to create the required table (`TELEPORT_elevators`).
3. Add `ensure TELEPORT` (or your folder name) to your `server.cfg`.
4. Configure the default settings and your preferred language in `config.lua`.

## ⚙️ Configuration (`config.lua`)

Inside `config.lua`, you can adjust the primary behavior of the resource:

- **Language Setting**:
  Change `TELEPORT.LANGUAGE` to `"EN"`, `"DE"`, `"ES"`, `"FR"`, or `"AR"`.

- **Sound Configuration**:
  Enable or disable sound, change the audio clip used, and trigger sounds upon opening/closing UI or teleportation.

- **Marker Configuration**:
  Customize the color, size, interaction distance, and type of the floor markers.

## 🛠️ In-Game Administration

Administrators can use the command `/tpmadmin` to open the Management Interface.
- **Create Elevators**: Add a new elevator system.
- **Add/Edit Floors**: Modify floor names, numbers, passwords, and use the "Capture Here" button to automatically insert your current coordinates.
- **Save Config**: Clicking "Save Config" automatically saves all changes directly to the SQL database, applying them instantly across the server.

## 🌍 Supported Languages (Locales)

You can easily edit existing translations or add your own inside the `TELEPORT.TEXTS` table in `config.lua`. Supported by default:
* `EN` - English
* `DE` - German
* `ES` - Spanish
* `FR` - French
* `AR` - Arabic

## 📝 License

Created by **TELEPORT**. (Discord: [discord.gg/lodstudio](https://discord.gg/lodstudio))
Feel free to modify for your personal server needs.

