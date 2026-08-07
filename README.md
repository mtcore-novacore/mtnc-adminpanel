# mtnc-adminpanel

A simple and powerful FiveM admin panel with support for **vRP**, **ESX**, and **QBCore**.

## 📦 Requirements

- FiveM server
- Database support (MariaDB/MySQL recommended)
- One of the supported frameworks: **ESX**, **vRP**, or **QBCore**

## 🚀 Installation

1. Drag `mtnc-adminpanel` into your `resources` folder.
2. Import the SQL structure from `panel.sql` into your database.
3. Add this to your `server.cfg`:

```cfg
ensure mtnc-adminpanel
```

4. Edit `config.lua` and configure:
   - framework
   - access permissions
   - SteamID access
   - enabled admin categories/actions

## 🔧 Features

- Admin NUI panel with categories for:
  - player actions
  - vehicle actions
  - world actions
  - staff mode actions
- Search and tab filtering in the UI
- SQL-based log tables for admin actions and settings
- Simple permission checks via SteamID and framework groups

## ▶️ Usage

Open the panel with:

```txt
/admin
```

You can also use the configured hotkey (default: `H`).

## ⚙️ Configuration

Edit `config.lua` to configure:

- `Config.framework`
- `Config.general.openCommand`
- `Config.permissions.allowedSteamIds`
- `Config.permissions.esxGroups`
- `Config.permissions.qbRoles`
- `Config.categories`
- `Config.actions`

## ⚠️ Important

If you want full access, add your SteamID or configure framework group permissions in `config.lua`.

Enjoy!