#!/bin/bash

SWAPFILE="/swapfile"
SWAPSIZE="4G"
THRESHOLD_MB=500
INTERVAL_SEC=60

get_free_mem_mb() {
  free -m | awk '/^Mem:/ { print $7 }'
}

enable_swap() {
  if [ ! -f "$SWAPFILE" ]; then
    echo "[+] Creating $SWAPSIZE swapfile..."
    fallocate -l $SWAPSIZE $SWAPFILE
    chmod 600 $SWAPFILE
    mkswap $SWAPFILE
  fi
  swapon $SWAPFILE
  echo "[✓] Swap enabled."
}

disable_swap() {
  if swapon --summary | grep -q "$SWAPFILE"; then
    echo "[-] Disabling and removing swap..."
    swapoff $SWAPFILE
    rm -f $SWAPFILE
  fi
}

trap "echo '[!] Caught SIGTERM'; disable_swap; exit" SIGTERM

echo "[*] Starting smart_swapd..."

while true; do
  free_mb=$(get_free_mem_mb)
  echo "[i] Available RAM: ${free_mb} MB"

  if (( free_mb < THRESHOLD_MB )); then
    echo "[!] Low RAM. Enabling swap..."
    enable_swap
  fi

  sleep $INTERVAL_SEC
done
