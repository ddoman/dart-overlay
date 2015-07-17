EAPI="5"

inherit python

DESCRIPTION="Dark SDK"
HOMEPAGE="http://www.dartlang.org"

LICENSE="BSD"
SLOT="0"

SRC_URI="http://dart.iused.net/sources/dart-sdk-${PV}.tar.bz2"
KEYWORDS="~amd64 ~x86 ~arm64 ~arm ~mips"

IUSE="debug"

DEPEND=""
RDEPEND=""

pkg_setup() {
	if [[ "${SLOT}" == "0" ]]; then
		DART_SUFFIX=""
	else
		DART_SUFFIX="-${SLOT}"
	fi
	DART_HOME="/usr/$(get_libdir)/dart${DART_SUFFIX}"

	if use x86; then
		arch="ia32"
	elif use amd64; then
		arch="x64"
	elif use arm; then
		arch="arm"
	elif use arm64; then
		arch="arm64"
	elif use mips; then
		arch="mips"
	fi

	python-any-r1_pkg_setup
}

src_compile() {
	${PYTHON} ./tools/build.py -m release --arch=${arch} create_sdk || die
}

src_install() {
	RELEASE="Release${arch^}"
	exeinto "${DART_HOME}/bin"
	doexe out/${RELEASE}/dart-sdk/bin/* || die
	dosym "${DART_HOME}/bin/dart" /usr/bin/dart || die

	insinto "${DART_HOME}"
	doins -r out/${RELEASE}/dart-sdk/* || die
}
