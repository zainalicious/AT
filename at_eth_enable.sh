#!/bin/sh
# Install AT Command Server - auto detect nc + remount rw

echo "Remount root as read-write..."
mount -o remount,rw /

# Deteksi kemampuan nc (abaikan error)
NC_HELP=$(nc -h 2>&1 || true)

HAS_LL=no
echo "$NC_HELP" | grep -q -- '-ll' && HAS_LL=yes

HAS_E=no
echo "$NC_HELP" | grep -q -- '-e' && HAS_E=yes

if [ "$HAS_LL" = "yes" ] && [ "$HAS_E" = "yes" ]; then
    NC_CMD="nc -ll -p 5555 -e /usr/bin/AT"
elif [ "$HAS_E" = "yes" ]; then
    NC_CMD="while true; do nc -l -p 5555 -e /usr/bin/AT; done"
else
    NC_CMD="while true; do nc -l -p 5555 -c /usr/bin/AT; done"
fi

echo "Detected: -ll=$HAS_LL, -e=$HAS_E"
echo "Using: $NC_CMD"

# Tulis binary AT
cat > /usr/bin/AT << 'EOF'
#!/bin/sh
echo "=== AT Terminal ==="
i=1
for d in /dev/ttyACM* /dev/ttyUSB* /dev/mhi_DUN /dev/wwan*at* /dev/smd*; do
    [ -e "$d" ] || continue
    echo "[$i] $d"
    eval DEV_$i="$d"
    i=$((i+1))
done
echo "[m] Manual input"
printf "Pilih device: "
read CHOICE
if [ "$CHOICE" = "m" ]; then
    printf "Masukkan path device: "
    read DEV
else
    eval DEV=\$DEV_$CHOICE
fi
if [ ! -e "$DEV" ]; then
    echo "Device tidak valid!"
    exit 1
fi
echo "Menggunakan: $DEV"
echo "Ketik 'exit' untuk keluar"
stty -F "$DEV" 115200 raw -echo 2>/dev/null
cat "$DEV" &
CATPID=$!
trap "kill $CATPID 2>/dev/null; exit" INT TERM
while true; do
    printf "> "
    read CMD || break
    case "$CMD" in exit|quit|q) break ;; esac
    printf "%s\r" "$CMD" > "$DEV"
done
kill $CATPID 2>/dev/null
echo "Keluar."
EOF

chmod +x /usr/bin/AT

# Tulis service systemd
cat > /lib/systemd/system/atd.service << EOF
[Unit]
Description=AT Command Server
After=network.target

[Service]
Type=simple
ExecStart=/bin/sh -c '$NC_CMD'
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable atd.service
systemctl start atd.service

echo
echo "=== Instalasi Selesai ==="
systemctl status atd.service --no-pager

# Kembalikan read-only (abaikan error jika busy)
mount -o remount,ro / 2>/dev/null || echo "Skip remount ro (maybe busy)"
