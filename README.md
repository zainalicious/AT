AT - Minimal AT Command Terminal (Pure Shell)

A lightweight, dependency-free AT command terminal for embedded Linux / OpenWrt environments.

No "minicom", no "picocom", no "microcom" — just pure shell.

---

✨ Features

- 🔍 Auto-scan common modem interfaces:
  - "/dev/ttyUSB*"
  - "/dev/mhi_DUN"
  - "/dev/wwan*at*"
  - "/dev/smd*"
- 🖥 Interactive terminal (single window)
- ⌨️ Send AT commands easily
- 🚪 Clean exit ("exit", "quit", "q")
- 🧩 Works on minimal systems (BusyBox / OpenWrt)
- ⚡ Zero dependencies

---

📥 Install (One Line)

Copy & paste this:

```sh
wget -O /usr/bin/AT https://raw.githubusercontent.com/zainalicious/AT/main/AT && chmod +x /usr/bin/AT
```
---

🚀 Usage

Run:

AT

---

🔥🔥 enable AT-Over-TCP

Copy & paste this:

```sh
wget -O /etc/init.d/at-server https://raw.githubusercontent.com/zainalicious/AT/main/at-server && chmod +x /etc/init.d/at-server && service at-server enable && service at-server start
```
----

🚀 Usage

from client-side Run:
```
nc [IP] 5555
```

---
