# Copyright 2026 SCteam
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools git-r3

DESCRIPTION="Open source Remote Desktop Protocol (RDP) server"
HOMEPAGE="https://github.com/smooker/xrdp"
EGIT_REPO_URI="https://github.com/smooker/xrdp.git"
EGIT_BRANCH="devel"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""

IUSE="fuse ibus jpeg mp3lame nvenc opus pixman rdpsndaudin rfxcodec
	tjpeg x264 fdkaac accel vsock"

DEPEND="
	dev-libs/openssl:=
	sys-libs/pam
	x11-libs/libX11
	x11-libs/libXfixes
	x11-libs/libXrandr
	fuse? ( sys-fs/fuse:3 )
	jpeg? ( media-libs/libjpeg-turbo )
	tjpeg? ( media-libs/libjpeg-turbo )
	mp3lame? ( media-sound/lame )
	opus? ( media-libs/opus )
	fdkaac? ( media-libs/fdk-aac )
	x264? ( media-libs/x264 )
	nvenc? ( media-libs/nv-codec-headers )
	pixman? ( x11-libs/pixman )
	ibus? ( app-i18n/ibus )
"
RDEPEND="${DEPEND}"
BDEPEND="
	virtual/pkgconfig
	dev-build/libtool
"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	local myconf=(
		$(use_enable fuse)
		$(use_enable ibus)
		$(use_enable jpeg)
		$(use_enable tjpeg)
		$(use_enable mp3lame)
		$(use_enable opus)
		$(use_enable fdkaac)
		$(use_enable x264)
		$(use_enable nvenc)
		$(use_enable accel)
		$(use_enable vsock)
		$(use_enable pixman)
		$(use_enable rfxcodec)
		$(use_enable rdpsndaudin)
		--enable-sound
	)
	econf "${myconf[@]}"
}

src_install() {
	default

	# OpenRC init scripts
	newinitd "${FILESDIR}"/xrdp.initd xrdp
	newinitd "${FILESDIR}"/xrdp-sesman.initd xrdp-sesman

	# Default configs from source
	insinto /etc/xrdp
	doins "${S}"/xrdp/xrdp.ini
	doins "${S}"/xrdp/xrdp_keyboard.toml
	doins "${S}"/sesman/sesman.ini
	doins "${S}"/sesman/startwm.sh
	# Keymaps (may not exist in all versions)
	local km
	for km in "${S}"/xrdp/km-*.ini; do
		[ -f "${km}" ] && doins "${km}"
	done

	# Gfx config
	[ -f "${S}"/xrdp/gfx.toml ] && doins "${S}"/xrdp/gfx.toml

	# SCteam configs (override defaults)
	if [ -d "${S}"/conf ]; then
		local f
		for f in "${S}"/conf/*; do
			[ -f "${f}" ] && doins "${f}"
		done
	fi

	# Ensure startwm.sh is executable
	fperms 0755 /etc/xrdp/startwm.sh
}
