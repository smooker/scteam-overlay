# Copyright 2026 SCteam
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools git-r3

DESCRIPTION="Xorg drivers for xrdp"
HOMEPAGE="https://github.com/smooker/xorgxrdp"
EGIT_REPO_URI="https://github.com/smooker/xorgxrdp.git"
EGIT_BRANCH="devel"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""

IUSE="glamor lrandr"

DEPEND="
	>=net-misc/xrdp-0.10.0
	x11-base/xorg-server
	x11-libs/libX11
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
		$(use_enable glamor)
		$(use_enable lrandr)
	)
	econf "${myconf[@]}"
}
