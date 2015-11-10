#! /bin/bash
set -e

function usage {
	echo "Usage:"
	echo "This docker image will build .deb files out of a given source tarball, for example:"
	echo "docker run --rm -v ~/out_dir:/export/ joernhees/dpkg_build <tar_ball_uri> <opt build args>"
	echo "make sure the mounted out_dir is empty"
	echo
        echo "docker run --rm -v ~/out_dir:/export/ joernhees/dpkg_build \\"
	echo "    https://github.com/openlink/virtuoso-opensource/archive/stable/7.tar.gz -j16"
	exit 1
}

if [[ $# -lt 1 ]]; then
	usage
fi

src="$1"
shift

if [[ "$(ls /export/)" ]]; then
	echo "mounted directory is not empty" >&2
	ls >&2
	exit 1
fi

echo "downloading $src..."
wget "$src"
echo "downloading done."

tarfile=(*.tar*)

if [[ ${#tarfile[@]} -ne 1 ]]; then
	echo "we should have exactly one tar file, but we have this:" >&2
	ls >&2
	exit 1
fi

echo -n "extracting..."
tar -xavf "${tarfile[0]}"
echo " done."

echo -n "removing tarfile ${tarfile[0]}..."
rm "${tarfile[0]}"
echo " done."

src_folder=(*/)
if [[ ${#src_folder[@]} -ne 1 ]]; then
	echo "the given tar file should contain exactly one folder at the uppermost level," >&2
	echo "but it contained this:" >&2
	ls >&2
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

echo -n "removing source folder..."
rm -r "${src_folder[0]}"
echo " done."

echo "copying resulting dpkg files:"
cp -v * /export/
