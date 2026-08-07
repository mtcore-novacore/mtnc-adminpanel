# mtnc-adminpanel

A modern FiveM admin panel with support for **vRP**, **ESX**, and **QBCore** frameworks.

## Features

- ✅ Supports vRP
- ✅ Supports ESX
- ✅ Supports QBCore
- ✅ Easy installation
- ✅ Database support

## Requirements

- A database is **required**.
- **MariaDB** is recommended.
- **HeidiSQL** (v10.11.15 or newer) is recommended for database management.

## Installation

1. Place the `mtnc-adminpanel` folder in your server's `resources` directory.
2. Import the included SQL file into your database.
3. Add the following line to your `server.cfg`:

```cfg
ensure mtnc-adminpanel
```

4. Open `licensekey.lua` and enter your license key.

## Important

⚠️ Make sure to add your valid license key to `licensekey.lua` before starting the server.