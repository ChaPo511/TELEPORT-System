<div align="center">
  <h1>🚀 TELEPORT System for FiveM</h1>
  <p>A modern, highly customizable, and interactive elevator/teleport system with an intuitive UI and powerful in-game administration.</p>
  
  [![FiveM](https://img.shields.io/badge/FiveM-Supported-orange.svg)](https://fivem.net/)
  [![Framework](https://img.shields.io/badge/Framework-Qbox%20%7C%20QB--Core%20%7C%20ESX%20%7C%20Standalone-blue.svg)]()
  [![License](https://img.shields.io/badge/License-MIT-green.svg)]()
</div>

---

## 🌟 Features

- 🖥️ **Sleek NUI Interface**: A beautifully designed UI with floor selection, smooth CSS animations, and progress bars.
- ⚙️ **In-Game Admin Menu (`/tpmadmin`)**: Create, edit, and delete elevators and floors directly in-game. You can even capture your current coordinates instantly for new floors!
- 💾 **Auto-Save to Config**: Any changes made via the in-game admin menu are automatically saved to your `config.lua` and database, applying instantly without requiring a server restart!
- 🔒 **Passcode Protection**: Restrict access to VIP areas, vaults, or private floors using a passcode system.
- 🌍 **Multi-Language Support**: Fully translated into **English (EN), German (DE), Spanish (ES), French (FR), and Arabic (AR)**. Easily configurable in `config.lua`.
- 🎵 **Custom Sounds**: Native GTA V elevator sounds playing upon arrival/departure (fully configurable).
- 🛠️ **Highly Configurable**: Change interaction distances, 3D text, marker styles, and debug modes straight from `config.lua`.
- ⚡ **Optimized Performance**: Zero performance hit. Minimal resource usage (0.00ms idle) with smart distance-checking threads.

---

## 📦 Requirements

- **Framework Compatibility**: Works out of the box with **Qbox**, **QB-Core**, **ESX**, or can be used **Standalone**.
- **Database**: [oxmysql](https://github.com/overextended/oxmysql) (Required for saving customized elevators via the admin panel)

---

## 📥 Installation

1. Download the resource and extract it into your `resources` folder (e.g., `[standalone]/TELEPORT`).
2. Run the provided `install.sql` file in your database to create the required table (`TELEPORT_elevators`).
3. Add the following line to your `server.cfg`:
   ```bash
   ensure TELEPORT
   ```
4. Start your server and configure the default settings or language in `config.lua`.

---

## ⚙️ Configuration (`config.lua`)

Inside `config.lua`, you can adjust the primary behavior of the resource:

```lua
-- Change the language (EN, DE, ES, FR, AR)
TELEPORT.LANGUAGE = "EN"

-- Enable or disable elevator sounds
TELEPORT.SoundConfig = {
    enabled = true,
    soundName = "Fake_Arrival",
    soundSet = "Union_Depository_Elevator_Sounds", 
    volume = 0.5, 
}
```

---

## 🛠️ In-Game Administration

Administrators can use the command `/tpmadmin` to open the Management Interface.

* **Permissions**: The script automatically checks for `admin` or `god` permissions based on your framework (Qbox, QB-Core, ESX). For Standalone, it checks for `command.tpmadmin` ACE permissions.
* **Create Elevators**: Add a completely new elevator system from scratch.
* **Add/Edit Floors**: Modify floor names, numbers, passwords.
* **Capture Coordinates**: Use the "Capture Here" button to automatically insert your ped's current coordinates for a floor.
* **Save Config**: Clicking "Save Config" automatically saves all changes directly to the SQL database AND rewrites your `config.lua`, applying them instantly across the server!

---

## 🌍 Supported Languages (Locales)

You can easily edit existing translations or add your own inside the `TELEPORT.TEXTS` table in `config.lua`. Supported by default:
- 🇺🇸 `EN` - English
- 🇩🇪 `DE` - German
- 🇪🇸 `ES` - Spanish
- 🇫🇷 `FR` - French
- 🇸🇦 `AR` - Arabic

---

## 📝 Support & License

Created by **TELEPORT**. 
💬 Discord: [discord.gg/lodstudio](https://discord.gg/lodstudio)

Feel free to fork, modify, and use this resource for your personal server needs.
