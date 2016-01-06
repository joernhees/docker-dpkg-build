#! /bin/bash
set -e

function usage {
	cat /README.md
	exit 1
}

if [[ $# -lt 1 || "$1" = 'help' || "$1" = '-h' || "$1" = '--help' ]]; then
	usage
fi

src="$1"
shift

if [[ "$(ls /export/)" ]]; then
	echo "mounted directory is not empty" >&2
	ls /export/ >&2
	exec /bin/bash  # allow interactive mode to continue
	exit 1
fi

echo "downloading $src..."
wget "$src"
echo "downloading done."

tarfile=(*.tar*)

if [[ ${#tarfile[@]} -ne 1 ]]; then
	echo "we should have exactly one tar file, but we have this:" >&2
	ls >&2
	exec /bin/bash  # allow interactive mode to continue
	exit 1
fi

echo -n "extracting..."
tar -xavf "${tarfile[0]}"
echo " done."

echo -n "moving tarfile ${tarfile[0]}..."
mv "${tarfile[0]}" ../
echo " done."

src_folder=(*/)
if [[ ${#src_folder[@]} -ne 1 ]]; then
	echo "the given tar file should contain exactly one folder at the uppermost level," >&2
	echo "but it contained this:" >&2
	ls >&2
	exec /bin/bash  # allow interactive mode to continue
	exit 1
fi

echo "building your package(s) in ${src_folder[0]}:"
cd "${src_folder[0]}"
ls

apt-get update
mk-build-deps -irt'apt-get --no-install-recommends -yV' && dpkg-checkbuilddeps
dpkg-buildpackage -us -uc "$@"

echo "building done."
cd ..

echo "copying resulting dpkg files:"
cp -v * /export/ || true  # will fail because of source dir

echo "creating package index..."
cd /export
dpkg-scanpackages ./ | gzip > Packages.gz
echo "you should now be able to mount the /export in other docker containers."
echo "if multiple packages with dependencies were built, it's easiest to install"
echo "them with apt-get after inserting them as a source like this:"
echo 'echo "deb file:/mountpoint ./" >> /etc/apt/sources.list && apt-get update'

exec /bin/bash  # allow interactive mode...
