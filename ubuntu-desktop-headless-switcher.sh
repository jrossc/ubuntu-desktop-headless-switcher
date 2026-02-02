#!/bin/bash
set -o pipefail

LOG_PREFIX="[POWER-MGR]"

log() {
  echo -e "$LOG_PREFIX $1"
}

run() {
  log "RUN → $*"
  "$@"
}

ask() {
  while true; do
    read -rp "$1 [y/n]: " yn
    case $yn in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}

header() {
  clear
  echo
  echo "======================================"
  echo " Ubuntu Desktop Headless Switcher"
  echo "======================================"
  echo " 1) Apply LOW POWER (Headless) mode"
  echo " 2) REVERT to DESKTOP mode"
  echo " q) Quit"
  echo
}

# Root check
if [ "$EUID" -ne 0 ]; then
  echo "❌ Run as root: sudo bash power-manager.sh"
  exit 1
fi

header
read -rp "Select an option [1/2/q]: " choice

case "$choice" in
# ==================================================
# LOW POWER MODE
# ==================================================
1)
  log "Selected LOW POWER mode"
  echo

  if ask "Switch system to HEADLESS (disable GUI)?"; then
    run systemctl set-default multi-user.target
  fi

  if ask "Install and enable TLP power management?"; then
    run apt update
    run apt install -y tlp tlp-rdw
    run systemctl enable tlp
    run systemctl start tlp
  fi

  if ask "Enable Wi-Fi power saving (keep Wi-Fi ON)?"; then
    run mkdir -p /etc/NetworkManager/conf.d
    cat <<EOF | tee /etc/NetworkManager/conf.d/wifi-powersave.conf
[connection]
wifi.powersave = 3
EOF
    run systemctl restart NetworkManager
  fi

  if ask "Set CPU governor to POWERSAVE?"; then
    run apt install -y cpufrequtils
    run cpufreq-set -g powersave || true
  fi

  if ask "Disable Bluetooth?"; then
    run systemctl disable bluetooth --now
  fi

  if ask "Disable unused background services (cups, avahi, snapd)?"; then
    run systemctl disable cups --now || true
    run systemctl disable avahi-daemon --now || true
    run systemctl disable snapd --now || true
  fi

  if ask "Enable disk power saving (safe)?"; then
    run apt install -y hdparm
    for d in /dev/sd?; do
      run hdparm -B 128 "$d" || true
    done
  fi

  if ask "Apply Powertop auto-tune (runtime only)?"; then
    run apt install -y powertop
    run powertop --auto-tune
  fi
  ;;
# ==================================================
# REVERT MODE
# ==================================================
2)
  log "Selected REVERT mode"
  echo

  if ask "Restore GUI (graphical desktop)?"; then
    run systemctl set-default graphical.target
  fi

  if ask "Disable TLP?"; then
    run systemctl disable tlp --now || true
    run systemctl disable tlp-sleep.service --now || true
  fi

  if ask "Remove Wi-Fi power saving config?"; then
    run rm -f /etc/NetworkManager/conf.d/wifi-powersave.conf
    run systemctl restart NetworkManager
  fi

  if ask "Restore CPU governor to ONDEMAND?"; then
    run cpufreq-set -g ondemand || true
  fi

  if ask "Re-enable Bluetooth?"; then
    run systemctl enable bluetooth --now
  fi

  if ask "Re-enable background services (cups, avahi, snapd)?"; then
    run systemctl enable cups --now || true
    run systemctl enable avahi-daemon --now || true
    run systemctl enable snapd --now || true
  fi

  if ask "Reset disk power settings to default?"; then
    for d in /dev/sd?; do
      run hdparm -B 254 "$d" || true
    done
  fi

  log "Powertop tunings clear automatically after reboot"
  ;;
q|Q)
  log "Exiting"
  exit 0
  ;;
*)
  echo "❌ Invalid option"
  exit 1
  ;;
esac

echo
if ask "Reboot now to apply changes?"; then
  run reboot
else
  log "Reboot later to fully apply changes"
fi
