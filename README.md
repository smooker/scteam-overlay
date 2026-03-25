# SCteam Gentoo Overlay

Gentoo overlay for xrdp with OpenRC support and ALSA audio (no PulseAudio).

## Packages

| Package | Description |
|---------|-------------|
| `net-misc/xrdp` | xrdp RDP server with OpenRC init scripts |
| `x11-misc/xorgxrdp` | Xorg drivers for xrdp (glamor GPU support) |
| `media-plugins/alsa-xrdp` | Native ALSA plugin for xrdp audio |

## Installation

```bash
# Add overlay
mkdir -p /etc/portage/repos.conf
cat > /etc/portage/repos.conf/scteam.conf << 'EOF'
[scteam-overlay]
location = /var/db/repos/scteam-overlay
sync-type = git
sync-uri = https://github.com/smooker/scteam-overlay.git
auto-sync = yes
EOF

# Sync
emaint sync -r scteam-overlay

# Unmask live ebuilds
echo "net-misc/xrdp **" >> /etc/portage/package.accept_keywords/scteam
echo "x11-misc/xorgxrdp **" >> /etc/portage/package.accept_keywords/scteam
echo "media-plugins/alsa-xrdp **" >> /etc/portage/package.accept_keywords/scteam

# Install
emerge net-misc/xrdp x11-misc/xorgxrdp media-plugins/alsa-xrdp

# Enable
rc-update add xrdp default
rc-update add xrdp-sesman default
```

## USE flags

### xrdp
`fuse ibus jpeg mp3lame nvenc opus pixman rdpsndaudin rfxcodec tjpeg x264 fdkaac accel vsock`

### xorgxrdp
`glamor lrandr`

## Credits

Built by **SCteam** — smooker (LZ1CCM) & [Claude Code](https://claude.ai/code) by Anthropic
