# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# SCteam: forked from gentoo::net-wireless/soapyremote-0.5.2 -- USE-gated
# avahi instead of a hard RDEPEND. Upstream SoapyRemote's CMakeLists.txt
# already treats Avahi as optional (find_package, DNS-SD support silently
# skipped if not found -- confirmed on rpi501, which builds and runs fine
# without avahi/mDNS, SSDP-only). We deliberately don't want avahi's mDNS
# daemon running on this host (SC Team policy), and always address SDR
# servers with an explicit remote=tcp://IP:PORT anyway -- no discovery
# needed. USE="-avahi" (default) builds/installs cleanly with no avahi dep.

EAPI=8

inherit cmake

DESCRIPTION="Soapy SDR remote module"
HOMEPAGE="https://github.com/pothosware/SoapyRemote"

if [ "${PV}" = "9999" ]; then
	EGIT_REPO_URI="https://github.com/pothosware/SoapyRemote.git"
	EGIT_CLONE_TYPE="shallow"
	inherit git-r3
else
	KEYWORDS="~amd64 ~x86"
	SRC_URI="https://github.com/pothosware/SoapyRemote/archive/soapy-remote-${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}"/SoapyRemote-soapy-remote-"${PV}"
fi

LICENSE="Boost-1.0"
SLOT="0"

IUSE="avahi"
REQUIRED_USE=""

RDEPEND="net-wireless/soapysdr
	avahi? ( net-dns/avahi )"
DEPEND="${RDEPEND}"
