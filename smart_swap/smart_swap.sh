#!/bin/bash

SWAPFILE="/swapfile"
SWAPSIZE="4G"
THRESHOLD_MB=500  # Minimum free memory before enabling swap

get_free_mem_mb() {
  free -m | awk '/^Mem:/ { print $7 }'  # "available" memory in MB
}

enable_swap() {
  if [ ! -f "$SWAPFILE" ]; then
    echo "[+] Creating swapfile ($SWAPSIZE)..."
    sudo fallocate -l $SWAPSIZE $SWAPFILE
    sudo chmod 600 $SWAPFILE
    sudo mkswap $SWAPFILE
  fi
  echo "[+] Enabling swap..."
  sudo swapon $SWAPFILE
}

disable_swap() {
  echo "[-] Disabling and removing swap..."
  sudo swapoff $SWAPFILE
  sudo rm -f $SWAPFILE
}

check_and_toggle_swap() {
  local free_mb
  free_mb=$(get_free_mem_mb)
  echo "[i] Free RAM: ${free_mb} MB"

  if (( free_mb < THRESHOLD_MB )); then
    echo "[!] Low RAM detected. Enabling swap..."
    enable_swap
  else
    echo "[✓] RAM is sufficient. No swap needed."
  fi
}

run_with_swap_if_needed() {
  check_and_toggle_swap
  echo "[•] Running: $*"
  eval "$@"
  disable_swap
}

case "$1" in
  run)
    shift
    run_with_swap_if_needed "$@"
    ;;
  status)
    free -h
    swapon --show
    ;;
  *)
    echo "Usage: $0 run <command...>"
    echo "       $0 status"
    ;;
esac
