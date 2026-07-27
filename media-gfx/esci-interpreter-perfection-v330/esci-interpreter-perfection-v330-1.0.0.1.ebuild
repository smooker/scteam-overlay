# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Epson's proprietary ESC/I interpreter for the Perfection V33/V330 Photo
# (GT-F730/GT-S630, USB 04b8:0142).
#
# Why this exists: NO stock SANE backend supports this scanner. epson2 only
# knows ancient Perfection models -- verifiable directly from the built library:
#   strings /usr/lib64/sane/libsane-epson2.so.* | grep -i perfection
# so sane-find-scanner sees the device while scanimage -L finds nothing. The
# model needs the proprietary epkowa backend (media-gfx/iscan) plus this
# per-model interpreter. The V300 plugin (media-gfx/iscan-plugin-gt-f720) does
# NOT work here: Epson ships a separate interpreter and separate firmware per
# family (ours is esfwad.bin).
#
# ::gentoo has no ebuild for it, and the third-party ones point at
# dev.gentoo.org/~flameeyes/avasys/, which is gone (404). See pkg_nofetch.

EAPI=8

RPM_COMPRESS_TYPE=none
inherit rpm

MY_PVR="$(ver_rs 3 -)"
MY_P="${PN}-${MY_PVR}"

DESCRIPTION="Epson Perfection V33/V330 Photo (GT-F730/GT-S630) plugin for the SANE 'epkowa' backend"
HOMEPAGE="http://download.ebz.epson.net/dsc/search/01/search/?OSC=LX"
SRC_URI="amd64? ( ${MY_P}.x86_64.rpm )
	x86? ( ${MY_P}.i686.rpm )"
S="${WORKDIR}"

LICENSE="AVASYS"
SLOT="0"
KEYWORDS="-* amd64 x86"

# Every upstream and mirror for this binary is dead or behind auth, so it has
# to be placed in DISTDIR by hand -- see pkg_nofetch.
RESTRICT="fetch"

DEPEND="
	<media-gfx/iscan-3
	>=media-gfx/iscan-2.21.0
"
RDEPEND="${DEPEND}"

QA_PREBUILT="usr/lib*/esci/libesci-interpreter-perfection-v330.so*"

pkg_nofetch() {
	einfo "This binary is no longer downloadable from anywhere automatically:"
	einfo "  - dev.gentoo.org/~flameeyes/avasys/  -> 404 (gone)"
	einfo "  - Epson's own site                   -> 403 on direct fetches"
	einfo "  - Packman build service              -> 401 (needs auth)"
	einfo ""
	einfo "Recover it from Packman's iscan-plugin SOURCE rpm, which bundles the"
	einfo "pristine Epson packages (note: the *binary* iscan-plugin rpm omits the"
	einfo "firmware, so the source one is the right thing to take):"
	einfo "  http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Leap_15.4/Extra/src/"
	einfo "    iscan-plugin-2.30.4-pm150400.2.1.src.rpm"
	einfo ""
	einfo "Then place ${MY_P}.x86_64.rpm in ${DISTDIR}"
}

src_install() {
	# The interpreter loads its firmware at runtime from ESCI_FIRMWARE_DIR
	# (visible with `strings` on the .so), so esfwad.bin must ship alongside
	# it -- installing only the library gives a scanner that is still not
	# claimed by epkowa.
	insinto /usr/share/esci
	doins usr/share/esci/*

	insinto /usr/$(get_libdir)/esci
	insopts -m0755
	doins usr/$(get_libdir)/esci/*

	# Device descriptions keyed by model name in hex: 47542d46373330 = "GT-F730",
	# 47542d53363330 = "GT-S630". They carry the USB ids (04b8:0142) and the
	# colour profiles.
	insinto /usr/share/iscan-data/device
	insopts -m0644
	doins usr/share/iscan-data/device/*

	einstalldocs
}

pkg_postinst() {
	# THIS IS THE STEP THAT ACTUALLY MAKES IT WORK. Without it epkowa still
	# enumerates the scanner (given the epkowa.conf line below) but reports
	# "unknown model" and every scan hangs until it times out -- the backend has
	# no way to know which interpreter and which firmware belong to 04b8:0142.
	# Registering adds a second, working device node: epkowa:interpreter:<bus>:<dev>.
	#
	# Note the plugin path is passed WITHOUT the .so extension, per
	# iscan-registry(8).
	iscan-registry --add interpreter usb 0x04b8 0x0142 \
		"${EROOT}/usr/$(get_libdir)/esci/libesci-interpreter-perfection-v330" \
		"${EROOT}/usr/share/esci/esfwad.bin" \
		|| ewarn "iscan-registry failed -- scans will hang until it is run by hand"

	elog "The stock /etc/sane.d/epkowa.conf (a bare 'usb' line) is all you need."
	elog ""
	elog "Do NOT add an explicit 'usb 0x04b8 0x0142' line. It creates a SECOND,"
	elog "broken device on the raw USB path -- that one identifies the model and"
	elog "then dies with 'Invalid argument', because the interpreter is bound to"
	elog "the interpreter path, not the raw one. With the explicit line present"
	elog "the scanner also reports as '(unknown model)'. Removing it leaves a"
	elog "single working device and the proper model name."
	elog ""
	elog "Verify with:  scanimage -L"
	elog "  device 'epkowa:interpreter:<bus>:<dev>' is a Epson Perfection V330 Photo"
	elog ""
	elog "The device node is root:usb, so a non-root user must be in group 'usb'."
}

pkg_prerm() {
	iscan-registry --remove interpreter usb 0x04b8 0x0142 \
		"${EROOT}/usr/$(get_libdir)/esci/libesci-interpreter-perfection-v330" \
		"${EROOT}/usr/share/esci/esfwad.bin" \
		|| ewarn "iscan-registry --remove failed; stale entry may remain"
}
