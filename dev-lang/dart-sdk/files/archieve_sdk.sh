#!/bin/bash


SCRIPT_PATH=`readlink -f $0`
SCRIPT_HOME=`dirname $SCRIPT_PATH`
DART_SVN_BRANCH_BASE="http://dart.googlecode.com/svn/branches"
DART_GIT_URL="https://github.com/dart-lang/sdk.git"
PN="dart-sdk"
declare -A branch_urls_by_version

function list_tags
{
	tags=`git ls-remote --tags -t "$DART_GIT_URL" | awk '$2 ~ /refs\/tags\/[0-9.]*$/ { split($2, arr, "/"); print arr[3];}'`
	echo "* Available Versions"
	for tag in $tags
	do
		if [[ $tag =~ ^[1-9] ]]; then
			echo $tag
		fi
	done
}

function get_package_version
{
	dart_sdk_root=$1
	version=`cat "$dart_sdk_root/tools/VERSION" | awk '
		$1 == "MAJOR" { major=$2; }
		$1 == "MINOR" { minor=$2; }
		$1 == "PATCH" { patch=$2; }
		END { print major "." minor "." patch }'`
	echo "$version"
}

function run_gclient
{
	git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
	tag=$1
	./depot_tools/gclient config "$DART_GIT_URL" || exit
	./depot_tools/gclient sync -n -r "$tag" > /dev/null || exit
}

# main
list_tags

echo "Please enter a tag to checkout."
read tag

# clone the repo
work_directory=`mktemp -d`
pushd "$work_directory"
run_gclient "$tag"

# get the package version
PV=`get_package_version $work_directory/sdk`
echo "Detected Version: $PV"
P="$PN-$PV"

mv sdk "$P"

# Exclude unnecessary third-party packages.
tar -cjf "$SCRIPT_HOME/$P.tar.bz2" --exclude-vcs $P \
--exclude=$P/third_party/chrome \
--exclude=$P/third_party/clang \
--exclude=$P/third_party/firefox_jsshell \
--exclude=$P/third_party/d8
popd

# clean up
rm -rf "$work_directory" "$DEPOT_PATH"
