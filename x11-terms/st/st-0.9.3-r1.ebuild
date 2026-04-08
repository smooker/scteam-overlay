# Copyright 1999-2025 Gentoo Authors
# Copyright 2026 SC Team
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop savedconfig toolchain-funcs

DESCRIPTION="Simple terminal implementation for X (SC Team patched build)"
HOMEPAGE="https://st.suckless.org/"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://git.suckless.org/${PN}"
else
	SRC_URI="https://dl.suckless.org/${PN}/${P}.tar.gz"
	KEYWORDS="amd64 ~arm arm64 ~hppa ~m68k ppc64 ~riscv x86"
fi

LICENSE="MIT"
SLOT="0"

RDEPEND="
	>=sys-libs/ncurses-6.0:0=
	media-libs/fontconfig
	x11-libs/libX11
	x11-libs/libXft
	~x11-terms/st-terminfo-${PV}
"
DEPEND="
	${RDEPEND}
	x11-base/xorg-proto
"
BDEPEND="virtual/pkgconfig"

# SC Team patches:
#   01: scrollback-reflow-standalone (suckless.org) — 5000-line ring buffer
#       scrollback with full reflow on resize, mouse wheel + Shift+PgUp/Down/Home/End
#   04: min-window-size — refuse window resize below 40x24 cells
PATCHES=(
	"${FILESDIR}/01-scrollback-reflow-standalone.patch"
	"${FILESDIR}/04-min-window-size.patch"
)

src_prepare() {
	default

	sed -i \
		-e "/^X11LIB/{s:/usr/X11R6/lib:/usr/$(get_libdir)/X11:}" \
		-e '/^STLDFLAGS/s|= .*|= $(LDFLAGS) $(LIBS)|g' \
		-e '/^X11INC/{s:/usr/X11R6/include:/usr/include/X11:}' \
		config.mk || die
	sed -i \
		-e '/tic/d' \
		Makefile || die

	restore_config config.h
}

src_configure() {
	sed -i \
		-e "s|pkg-config|$(tc-getPKG_CONFIG)|g" \
		config.mk || die

	tc-export CC
}

src_install() {
	emake DESTDIR="${D}" PREFIX="${EPREFIX}"/usr install

	dodoc TODO

	make_desktop_entry ${PN} simpleterm utilities-terminal 'System;TerminalEmulator;' ''

	save_config config.h
}

pkg_postinst() {
	if [[ -z "${REPLACING_VERSIONS}" ]]; then
		elog "Please ensure a usable font is installed, like"
		elog "    media-fonts/corefonts"
		elog "    media-fonts/dejavu"
		elog "    media-fonts/urw-fonts"
	fi
}
