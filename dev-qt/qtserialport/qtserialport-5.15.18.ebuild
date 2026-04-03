# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit qt5-build

DESCRIPTION="Serial port abstraction library for the Qt5 framework"
KEYWORDS="amd64 ~arm ~arm64 x86"

DEPEND="
	=dev-qt/qtcore-${PV}*:5
	virtual/libudev:=
"
RDEPEND="${DEPEND}"
