---

description: Development environment configuration
alwaysApply: true
-----------------

# Development Environment

Target environment:

* Windows 11 Pro (64-bit)
* Godot 4.x Stable
* GDScript 2.0
* Visual Studio Code
* Git
* GitHub
* PowerShell

---

# Operating System Rules

Never assume Linux or macOS.

Always generate:

* Windows paths
* Windows installation instructions
* PowerShell commands

Never generate:

* Bash scripts
* chmod
* apt
* sudo
* shell scripts

Unless explicitly requested.

---

# Godot Version

Always target the latest stable release of Godot 4.

Never use Godot 3 syntax.

Never generate deprecated APIs.

---

# Language

Primary language:

GDScript 2.0

Do not use C# unless explicitly requested.

---

# Terminal Commands

Use PowerShell syntax.

Examples should work directly on Windows 11.

---

# File Paths

Prefer:

res://

inside Godot.

Outside Godot use Windows paths.

Example:

D:\Projects\VNGame

Never assume POSIX file paths.
