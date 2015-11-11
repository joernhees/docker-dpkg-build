# docker-dpkg-build
This is a docker image to build .deb files from a link to a source tarball.
In theory this should work with all "debianized" packages that contain a
`debian/control` file in the source folder.

Usage:
This docker image can be used like this:
```
docker run --rm -v ~/out_dir:/export/ joernhees/dpkg_build <URI> <opt build args>
```
Note: will cancel if `out_dir` is not empty.
The URI should point to a source tar-ball which can be gzipped/bzipped.

The image supports interactive mode `-it`, which will allow you to run further
commands after compilation or after errors.

Example usage to build the latest virtuoso:
```
docker run --rm -v ~/virtuoso_deb:/export/ joernhees/dpkg_build \
    https://github.com/openlink/virtuoso-opensource/archive/stable/7.tar.gz -j16
```
After completion you should find all build .deb packages in `~/virtuoso_deb`.

