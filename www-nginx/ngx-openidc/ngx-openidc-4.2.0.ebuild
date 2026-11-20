# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="ngx_openidc_module"

NGINX_MOD_CONFIG_DIR="src"
inherit nginx-module toolchain-funcs

DESCRIPTION="OpenID Connect Relying Party module for NGINX (liboauth2)"
HOMEPAGE="https://github.com/OpenIDC/ngx_openidc_module"
SRC_URI="https://github.com/OpenIDC/ngx_openidc_module/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND=">=dev-libs/liboauth2-2.2.1:=[nginx]"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	# upstream's autoconf only fills these four placeholders in src/config.in; pkg-config gives the same values.
	# NGINX prefixes every word of ngx_module_incs with -I itself, so the include values are bare directories.
	local pc="$(tc-getPKG_CONFIG)" incs libs
	incs="$(${pc} --cflags-only-I liboauth2 liboauth2_nginx)" || die
	libs="$(${pc} --libs liboauth2 liboauth2_nginx)" || die
	incs="${incs//-I/}"
	sed -e "s|@OAUTH2_CFLAGS@|${incs}|" \
		-e "s|@OAUTH2_NGINX_CFLAGS@||" \
		-e "s|@OAUTH2_LIBS@|${libs}|" \
		-e "s|@OAUTH2_NGINX_LIBS@||" \
		src/config.in > src/config || die
	nginx-module_src_prepare
}
