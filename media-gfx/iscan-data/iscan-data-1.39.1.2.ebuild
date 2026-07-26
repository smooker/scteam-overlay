# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Version bump of the ::gentoo ebuild. The tree still wants 1.39.0-1, whose
# tarball is no longer obtainable: Epson answers 403 to direct downloads and
# the Gentoo mirrors do not carry it. 1.39.1-2 is what every current Packman
# release ships, and it is the same upstream Epson tarball -- see
# ~/work/epson_scanner/README.md for where it was recovered from.

EAPI=7

inherit udev

DESCRIPTION="Image Scan! for Linux data files"
HOMEPAGE="http://download.ebz.epson.net/dsc/search/01/search/?OSC=LX"
SRC_URI="http://support.epson.net/linux/src/scanner/iscan/${PN}_$(ver_rs 3 -).tar.gz"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="amd64 x86"
IUSE="udev"

# Upstream serves 403 for direct fetches; the file has to be placed in
# DISTDIR by hand (see pkg_nofetch).
RESTRICT="fetch"

DEPEND="
	udev? (
		dev-libs/libxslt
		media-gfx/sane-backends
	)"
RDEPEND=""

S="${WORKDIR}/${PN}-$(ver_cut 1-3)"

DOCS=( NEWS SUPPORTED-DEVICES KNOWN-PROBLEMS )

pkg_nofetch() {
	einfo "Epson no longer allows direct downloads (HTTP 403)."
	einfo "Recover the tarball from Packman's iscan source RPM:"
	einfo "  http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Leap_15.4/Extra/src/"
	einfo "    iscan-2.30.4-150400.6.pm.4.src.rpm"
	einfo "It contains ${PN}_$(ver_rs 3 -).tar.gz verbatim."
	einfo "Place it in ${DISTDIR}"
}

src_install() {
	ewarn "Some profiles automatically enable udev which will cause install"
	ewarn "to fail if media-gfx/sane-backends is not already installed."
	default

	if use udev; then
		# Create udev rules
		local rulesdir=$(get_udevdir)/rules.d
		dodir ${rulesdir}
		"${D}/usr/$(get_libdir)/iscan-data/make-policy-file" \
			--force --mode udev \
			-d "${D}/usr/share/iscan-data/epkowa.desc" \
			--template "${D}/usr/share/iscan-data/fdi.xsl" \
			-o "${D}${rulesdir}/99-iscan.rules" || die
	fi
}
