
# 🧠 smart_swap — Smart Swap Manager for Raspberry Pi (or any Linux)

Automatically enable swap **only when your system is low on RAM** — perfect for compiling large projects (like ROS 2) on headless Raspberry Pi setups without wearing out your SD card unnecessarily.

---

## 📦 Features

- ✅ Lightweight: Bash-only, no dependencies
- 🧠 Monitors RAM and enables swap only if needed
- 🛑 Disables swap after task or at shutdown (optional)
- 🧰 Includes a one-shot script and optional systemd background daemon
- 💡 Ideal for headless Raspberry Pi 4B/3B running Ubuntu/Debian

---

## 🔧 Setup

### 📁 Install the CLI Script

```bash
# Copy script to system path
sudo cp smart_swap.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/smart_swap.sh
```

---

## ▶️ Usage (Manual / CLI Mode)

Run a memory-heavy command (e.g., building ROS 2) with swap automatically enabled **only if needed**:

```bash
smart_swap.sh run <your_command>
```

📌 Examples:

```bash
# Build with colcon
smart_swap.sh run colcon build

# Start a Docker container
smart_swap.sh run docker build .
```

Check current memory + swap status:

```bash
smart_swap.sh status
```

Force enable or disable swap manually:

```bash
smart_swap.sh on     # Force enable swap
smart_swap.sh off    # Turn off and delete swap file
```

---

## 🛠 Optional: Enable Background Monitoring (Daemon Mode)

You can run a background daemon that checks RAM usage periodically and enables swap when needed.

### Step 1: Install the daemon script

```bash
sudo cp smart_swapd.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/smart_swapd.sh
```

### Step 2: Install the systemd service

```bash
sudo cp systemd/smart-swap.service /etc/systemd/system/
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable smart-swap.service
sudo systemctl start smart-swap.service
```

### Step 3: Monitor the daemon

```bash
systemctl status smart-swap.service
journalctl -u smart-swap.service -f
```

---

## ⚙️ Defaults

These can be modified in `smart_swapd.sh`:

- 💾 Swap size: `4G`
- 🧠 Trigger threshold: `500 MB` available RAM
- ⏱️ Daemon check interval: `60 seconds`
- 📄 Swap file: `/swapfile`

---

## 📁 File Overview

| File/Folder                 | Purpose                                 |
|----------------------------|-----------------------------------------|
| `smart_swap.sh`            | One-shot CLI script                     |
| `smart_swapd.sh`           | Daemon script for auto swap monitoring  |
| `systemd/smart-swap.service` | systemd unit file to enable daemon     |
| `README.md`                | This documentation                      |

---

## 🧪 Tested On

- Raspberry Pi 4B (4GB), Ubuntu 24.04 / 22.04 64-bit (headless)
- Also works on other Debian-based Linux systems

---

## 🧊 Example Integration

Use this swap system while building ROS 2:

```bash
smart_swap.sh run colcon build --symlink-install
```

Or let the systemd daemon handle swap automatically in the background when memory drops below 500 MB.

---