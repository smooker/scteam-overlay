# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

DESCRIPTION="OAuth 2.x and OpenID Connect C library, with the glue for NGINX modules"
HOMEPAGE="https://github.com/OpenIDC/liboauth2"
SRC_URI="https://github.com/OpenIDC/liboauth2/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
# liboauth2_nginx is compiled against the NGINX headers, which carry no ABI promise between versions:
# the := on www-servers/nginx (SLOT 0/${PV}) rebuilds this package with every NGINX upgrade.
SLOT="0"
KEYWORDS="~amd64"
IUSE="+nginx"
# the unit tests need dev-libs/check and network access
RESTRICT="test"

RDEPEND="
	dev-libs/cjose
	dev-libs/jansson:=
	dev-libs/libpcre2:=
	dev-libs/openssl:=
	net-misc/curl
	nginx? ( www-servers/nginx:= )
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	default
	sed -i -e 's/ -Werror / /' Makefile.am || die
	eautoreconf
}

src_configure() {
	local myconf=(
		--disable-static
		--without-apache
		--without-memcache
		--without-redis
		--without-jq
	)
	if use nginx; then
		# configure wants an NGINX source tree (DIR/src/{core,event,http,os/unix}, DIR/objs); the installed
		# headers in /usr/include/nginx are that tree's src/, with ngx_auto_{config,headers}.h beside them
		local ngx="${T}/nginx"
		mkdir -p "${ngx}/objs" || die
		ln -s "${ESYSROOT}/usr/include/nginx" "${ngx}/src" || die
		ln -s "${ESYSROOT}/usr/include/nginx/ngx_auto_config.h" "${ngx}/objs/" || die
		ln -s "${ESYSROOT}/usr/include/nginx/ngx_auto_headers.h" "${ngx}/objs/" || die
		myconf+=( --with-nginx="${ngx}" )
	fi
	econf "${myconf[@]}"
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
