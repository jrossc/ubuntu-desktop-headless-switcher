# Ubuntu Desktop Headless Switcher

An **interactive, menu-driven Bash script** to switch Ubuntu systems between:

- 🔋 **Low-Power Mode** (headless, tuned for efficiency)
- 🔁 **Normal Mode** (fully reverted to desktop defaults)

Designed for **home servers, always-on laptops, mini-PCs, and VPN boxes** where power efficiency matters — without breaking Wi-Fi, Ethernet, or SSH access.

---

## ✨ Features

- ✅ Single script with **Apply / Revert** modes
- ✅ Interactive **Y/N prompts** for every change
- ✅ **Fully verbose** – prints every command executed
- ✅ Keeps **Wi-Fi and Ethernet enabled**
- ✅ Safe for **headless (SSH-only) setups**
- ✅ No hard-coded assumptions about hardware
- ✅ Easy rollback to default Ubuntu behavior

---

## 🔋 Why This Exists

Ubuntu Desktop is great — but it’s **not optimized for idle power usage**.

Common issues:
- GUI keeps CPU and GPU awake
- Wi-Fi scans aggressively
- Background services run unnecessarily
- CPU governor defaults to performance-biased modes

This script applies **practical, reversible optimizations** commonly used on:
- Home servers
- VPN gateways (OpenVPN / WireGuard)
- Always-on laptops
- Intel NUCs / mini-PCs

---

## ⚡ Expected Power Savings (Real-World)

Actual savings depend on hardware, but typical results:

| Device | Default Ubuntu | Low-Power Mode |
|------|----------------|----------------|
| Laptop (idle, lid closed) | 7–12 W | **3–6 W** |
| Intel NUC i3 | 8–12 W | **4–8 W** |
| Desktop (older) | 30–50 W | **20–35 W** |

> Wi-Fi stays enabled (power-saved).  
> Ethernet stays enabled.  
> SSH access is never disabled.

---

## 🛠 What Low-Power Mode Does

When selected, the script can:

- Switch system to **headless mode** (disable GUI)
- Enable **TLP** power management
- Enable **Wi-Fi power saving** (NetworkManager)
- Set CPU governor to **powersave**
- Disable **Bluetooth** (optional)
- Disable unused services:
  - `cups`
  - `avahi-daemon`
  - `snapd`
- Apply safe disk power tuning (`hdparm`)
- Apply **Powertop auto-tuning** (runtime only)

Every step is optional and confirmed interactively.

---

## 🔁 What Revert Mode Does

Revert mode cleanly restores:

- Graphical desktop (GUI)
- Default CPU governor
- Bluetooth
- Disabled services
- Disk power settings
- Removes Wi-Fi power-saving config
- Disables TLP

Powertop changes are runtime-only and reset automatically after reboot.
