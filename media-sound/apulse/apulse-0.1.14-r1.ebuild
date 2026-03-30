# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# SCteam patched apulse — fixes for Viber, Firefox, and other apps
# that need working pa_context_subscribe and safe pa_stream_drain
# Original: https://github.com/i-rinat/apulse
# Patches: https://github.com/smooker/scteam-overlay

EAPI=8

inherit cmake-multilib

DESCRIPTION="PulseAudio emulation for ALSA (SCteam patched)"
HOMEPAGE="https://github.com/i-rinat/apulse"
SRC_URI="https://github.com/i-rinat/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 ~ppc64 ~x86"

IUSE="debug sdk test"
RESTRICT="!test? ( test )"

DEPEND="dev-libs/glib:2[${MULTILIB_USEDEP}]
	media-libs/alsa-lib[${MULTILIB_USEDEP}]
	sdk? ( !media-libs/libpulse !media-sound/pulseaudio ) "
RDEPEND="${DEPEND}
	!media-plugins/alsa-plugins[pulseaudio]"

PATCHES=(
	"${FILESDIR}/sdk-0.1.14.patch"
	"${FILESDIR}/check-key-before-remove.patch"
	"${FILESDIR}/man.patch"
	"${FILESDIR}/scteam-subscribe-fix.patch"
	"${FILESDIR}/scteam-drain-uaf-fix.patch"
)

src_prepare() {
	cmake_src_prepare

	if ! use sdk; then
		# Ensure all relevant libdirs are added, to support all ABIs
		DIRS=
		_add_dir() { DIRS="${EPREFIX}/usr/$(get_libdir)/apulse${DIRS:+:${DIRS}}"; }
		multilib_foreach_abi _add_dir
		sed -e "s#@@DIRS@@#${DIRS}#g" "${FILESDIR}"/apulse > "${T}"/apulse || die
	fi
}

multilib_src_configure() {
	local mycmakeargs=(
		"-DINSTALL_SDK=$(usex sdk)"
		"-DLOG_TO_STDERR=$(usex debug)"
		"-DWITH_TRACE=$(usex debug)"
	)
	cmake_src_configure
}

multilib_src_test() {
	_test() {
		cmake --build . --target check
	}
	multilib_foreach_abi _test
}

multilib_src_install_all() {
	if ! use sdk; then
		_install_wrapper() { newbin "${BUILD_DIR}/apulse" "${CHOST}-apulse"; }
		multilib_foreach_abi _install_wrapper
		dobin "${T}/apulse"
	fi
	einstalldocs
}
