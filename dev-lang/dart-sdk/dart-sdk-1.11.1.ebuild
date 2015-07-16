# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_COMPAT=( python2_7 )

inherit python-single-r1

DESCRIPTION="Dart is an open-source, scalable programming language, with robust libraries and runtimes, for building web, server, and mobile apps."
HOMEPAGE="http://www.dartlang.org"
SRC_URI="http://dart.iused.net/sources/dart-sdk-${PV}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~mips ~x86"
IUSE="debug"

DEPEND=""
RDEPEND=""

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	tc-export CC CXX PKG_CONFIG
	export BUILDTYPE=Release
	BUILDMODE="release"

	# debug builds. change install path, remove optimisations and override buildtype
	if use debug; then
		BUILDMODE="debug"
	fi
}

src_configure() {
	case ${ABI} in
		x86) ARCH="ia32";;
		amd64) ARCH="x64";;
		arm) ARCH="arm";;
		arm64) ARCH="arm64";;
		mips) ARCH="mips";;
		*) die "Unrecognized ARCH ${ARCH}";;
	esac
	"${PYTHON}" tools/gyp_dart.py
}

src_compile() {
	"${PYTHON}" tools/build.py -v -m "${BUILDMODE}" -a "${ARCH}" create_sdk || die
}

src_install() {
	DART_ROOT="/usr/$(get_libdir)/dart"
	RELEASE="${BUILDMODE^}${ARCH^}"
	exeinto "${DART_ROOT}/bin"
	doexe out/${RELEASE}/dart-sdk/bin/* || die
	chmod 755 "${DART_ROOT}/bin/{dart,dart2js,dartanalyzer,dartdocgen,dartfmt,docgen,pub}" || die
	dosym "${DART_ROOT}/bin/dart" /usr/bin/dart || die

	insinto "${DART_ROOT}"
	doins -r out/${RELEASE}/dart-sdk/* || die
}
