# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_COMPAT=( python2_7 )

inherit python-any-r1 pax-utils

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
	if [[ "${SLOT}" == "0" ]]; then
		DART_SDK_SUFFIX=""
	else
		DART_SDK_SUFFIX="-${SLOT}"
	fi
	DART_SDK_HOME="/usr/$(get_libdir)/dart${DART_SDK_SUFFIX}"
	python-any-r1_pkg_setup
}

src_prepare() {
	tc-export CC CXX PKG_CONFIG
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
	local RELEASE="${BUILDMODE^}${ARCH^}"
	DART_SDK_OUTPUT="out/${RELEASE}/dart-sdk"

	"${PYTHON}" tools/gyp_dart.py
}

src_compile() {
	"${PYTHON}" tools/build.py -v -m "${BUILDMODE}" -a "${ARCH}" create_sdk || die
	pax-mark m "${DART_SDK_OUTPUT}/bin/dart"
}

src_install() {
	local DART_ROOT="/usr/$(get_libdir)/dart"

	# install executable files.
	exeinto "${DART_ROOT}/bin"
	insinto "${DART_ROOT}/bin"
	for name in "${DART_SDK_OUTPUT}/bin/"*; do
		if [ -d "${name}" ]; then
			doins -r "${name}" || die
		else
			doexe "${name}" || die
		fi
	done

	# Symlink the dart executable to /usr/bin
	dosym "${DART_ROOT}/bin/dart" /usr/bin/dart || die

	# install anything else, such as include/*, libs/*, README, and etc.
	insinto "${DART_ROOT}"
	for name in "${DART_SDK_OUTPUT}/"*; do
		if [[ "${name}" != "${DART_SDK_OUTPUT}/bin" ]]; then
			doins -r "${name}" || die
		fi
	done
}
