# Copyright 2026 SCteam
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="Native ALSA plugin for xrdp audio redirection — no PulseAudio required"
HOMEPAGE="https://github.com/smooker/alsa-xrdp"
EGIT_REPO_URI="https://github.com/smooker/alsa-xrdp.git"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS=""

DEPEND="
	media-libs/alsa-lib
"
RDEPEND="${DEPEND}
	net-misc/xrdp
"
BDEPEND="
	virtual/pkgconfig
"

src_install() {
	cmake_src_install
	insinto /usr/share/alsa-xrdp
	doins conf/asound-xrdp.conf
}

pkg_postinst() {
	elog "To enable xrdp audio, copy the ALSA config:"
	elog "  cp /usr/share/alsa-xrdp/asound-xrdp.conf /etc/asound.conf"
	elog "or add to ~/.asoundrc"
}
