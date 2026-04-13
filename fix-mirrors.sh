#!/bin/bash
# Fix all unreachable mirrors in termux-packages
# Run from the root of the termux-packages directory

echo "Fixing broken mirrors..."

# ─── fossies.org → sourceware.org ───────────────────────────────────────────
# libbz2 (already fixed but kept for safety)
if grep -q "fossies.org.*bzip2" packages/libbz2/build.sh 2>/dev/null; then
    sed -i 's|https://fossies.org/linux/misc/bzip2-\(.*\)\.tar\.xz|https://sourceware.org/pub/bzip2/bzip2-\1.tar.gz|' packages/libbz2/build.sh
    # Update SHA256 for .tar.gz
    sed -i 's|47fd74b2ff83effad0ddf62074e6fad1f6b4a77a96e121ab421c20a216371a1f|ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269|' packages/libbz2/build.sh
    echo "  Fixed: libbz2"
fi

# Other fossies.org packages → use GitHub or other mirrors
for pkg in alpine autossh cscope liblzo lzop mathomatic pkg-config psmisc rp-pppoe; do
    if grep -q "fossies.org" packages/$pkg/build.sh 2>/dev/null; then
        # Get current URL and version for reference
        echo "  Needs manual mirror fix: $pkg (fossies.org)"
    fi
done

# ─── freedesktop.org xorg packages → use gitlab.freedesktop.org ─────────────
XORG_PACKAGES=(
    "xorg-util-macros"
    "xcb-proto"
    "xorgproto"
    "xtrans"
    "libx11"
    "libxau"
    "libxcb"
    "libxcursor"
    "libxdmcp"
    "libxext"
    "libxfixes"
    "libxft"
    "libxi"
    "libxrandr"
    "libxrender"
    "libxshmfence"
    "libxss"
    "libxt"
    "libxtst"
    "libxv"
    "libxxf86vm"
    "libice"
    "libsm"
    "libglvnd"
)

for pkg in "${XORG_PACKAGES[@]}"; do
    f="packages/$pkg/build.sh"
    if [ -f "$f" ] && grep -q "xorg.freedesktop.org" "$f"; then
        sed -i 's|https://xorg.freedesktop.org/releases/individual/lib/|https://www.x.org/releases/individual/lib/|g' "$f"
        sed -i 's|https://xorg.freedesktop.org/releases/individual/util/|https://www.x.org/releases/individual/util/|g' "$f"
        sed -i 's|https://xorg.freedesktop.org/releases/individual/proto/|https://www.x.org/releases/individual/proto/|g' "$f"
        sed -i 's|https://xorg.freedesktop.org/releases/individual/app/|https://www.x.org/releases/individual/app/|g' "$f"
        sed -i 's|https://xorg.freedesktop.org/|https://www.x.org/|g' "$f"
        echo "  Fixed: $pkg (xorg mirror → x.org)"
    fi
done

# ─── freedesktop.org other packages → use gitlab mirrors ────────────────────

# dbus
if grep -q "freedesktop.org.*dbus\|dbus.*freedesktop.org" packages/dbus/build.sh 2>/dev/null; then
    sed -i 's|https://dbus.freedesktop.org/releases/dbus/|https://gitlab.freedesktop.org/dbus/dbus/-/archive/|g' packages/dbus/build.sh
    echo "  Fixed: dbus"
fi

# fontconfig
if grep -q "freedesktop.org" packages/fontconfig/build.sh 2>/dev/null; then
    sed -i 's|https://www.freedesktop.org/software/fontconfig/release/|https://gitlab.freedesktop.org/fontconfig/fontconfig/-/archive/|g' packages/fontconfig/build.sh
    echo "  Fixed: fontconfig"
fi

# libdrm
if grep -q "freedesktop.org" packages/libdrm/build.sh 2>/dev/null; then
    sed -i 's|https://dri.freedesktop.org/libdrm/|https://gitlab.freedesktop.org/mesa/drm/-/archive/|g' packages/libdrm/build.sh
    echo "  Fixed: libdrm"
fi

# gstreamer packages
for pkg in gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav gst-python; do
    f="packages/$pkg/build.sh"
    if [ -f "$f" ] && grep -q "freedesktop.org\|gstreamer.freedesktop.org" "$f"; then
        sed -i 's|https://gstreamer.freedesktop.org/src/|https://gitlab.freedesktop.org/gstreamer/|g' "$f"
        echo "  Fixed: $pkg (gstreamer mirror)"
    fi
done

# pipewire
if grep -q "freedesktop.org" packages/pipewire/build.sh 2>/dev/null; then
    sed -i 's|https://gitlab.freedesktop.org/pipewire/pipewire/-/archive/|https://gitlab.freedesktop.org/pipewire/pipewire/-/archive/|g' packages/pipewire/build.sh
    echo "  Checked: pipewire"
fi

# wayland
if grep -q "freedesktop.org" packages/libwayland/build.sh 2>/dev/null; then
    sed -i 's|https://wayland.freedesktop.org/releases/|https://gitlab.freedesktop.org/wayland/wayland/-/archive/|g' packages/libwayland/build.sh
    echo "  Fixed: libwayland"
fi

# harfbuzz
if grep -q "freedesktop.org" packages/harfbuzz/build.sh 2>/dev/null; then
    sed -i 's|https://www.freedesktop.org/software/harfbuzz/release/|https://github.com/harfbuzz/harfbuzz/releases/download/|g' packages/harfbuzz/build.sh
    echo "  Fixed: harfbuzz"
fi

# libpcap
if grep -q "fossies.org\|tcpdump.org" packages/libpcap/build.sh 2>/dev/null; then
    sed -i 's|https://www.tcpdump.org/release/|https://github.com/the-tcpdump-group/libpcap/archive/refs/tags/|g' packages/libpcap/build.sh
    echo "  Fixed: libpcap"
fi

# sound-theme-freedesktop
if grep -q "freedesktop.org" packages/sound-theme-freedesktop/build.sh 2>/dev/null; then
    sed -i 's|https://people.freedesktop.org/~mccann/dist/|https://github.com/freedesktop/sound-theme-freedesktop/archive/|g' packages/sound-theme-freedesktop/build.sh
    echo "  Fixed: sound-theme-freedesktop"
fi

echo ""
echo "Done! Verifying remaining freedesktop.org/fossies.org references..."
grep -rl "fossies.org\|xorg.freedesktop.org" packages/*/build.sh 2>/dev/null | head -20
echo ""
echo "If any files remain above, they need manual fixing."
