pkg_origin=bixu
pkg_name=lapack
pkg_version="3.8.0"
pkg_maintainer="Jeff Moody <fifthecho@gmail.com>, Blake Irvin <blakeirvin@me.com>"
pkg_license=("http://www.netlib.org/lapack/LICENSE.txt")
pkg_source="http://www.netlib.org/${pkg_name}/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="deb22cc4a6120bff72621155a9917f485f96ef8319ac074a7afbc68aab88bcf6"
pkg_lib_dirs=("lib64")
pkg_pconfig_dirs=("lib64/pkgconfig")
pkg_description="Linear Algebra PACKage"
pkg_upstream_url="http://www.netlib.org/lapack/"

pkg_build_deps=(
  "core/cmake"
  "core/gcc"
  "core/make"
  "core/pkg-config"
  "core/python2"
)
pkg_deps=(
  "core/gcc-libs"
  "core/glibc"
  "core/zlib"
)

do_setup_environment(){
  push_buildtime_env LIBRARY_PATH "$(pkg_path_for core/glibc)/lib"
  push_buildtime_env LIBRARY_PATH "$(pkg_path_for core/gcc-libs)/lib"
  return $?
}

do_prepare() {
  push_buildtime_env FC "gfortran"
  do_default_prepare
  return $?
}

do_build() {
  if [ ! -d "build" ]
  then
    mkdir -p "build"
  fi
  pushd "build" || exit 1
    cmake \
        -D BUILD_DEPRECATED="ON" \
        -D BUILD_SHARED_LIBS="ON" \
        -D BUILD_TESTING="OFF" \
        -D CBLAS="ON" \
        -D CMAKE_BUILD_TYPE="Release" \
        -D CMAKE_Fortran_COMPILER="gfortran" \
        -D CMAKE_INSTALL_PREFIX="$pkg_prefix" \
        -D CMAKE_SKIP_RPATH="ON" \
        -D LAPACKE_WITH_TMG="ON" \
      ..
    make -j"$(nproc)"
  popd || exit 1

  pushd LAPACKE || exit 1
  if [ ! -d "build" ]
  then
    mkdir -p "build"
  fi
    pushd "build" || exit 1
      cmake \
        -D BUILD_DEPRECATED="ON" \
        -D BUILD_SHARED_LIBS="ON" \
        -D BUILD_TESTING="OFF" \
        -D CBLAS="ON" \
        -D CMAKE_BUILD_TYPE="Release" \
        -D CMAKE_Fortran_COMPILER="gfortran" \
        -D CMAKE_INSTALL_PREFIX="$pkg_prefix" \
        -D CMAKE_SKIP_RPATH="ON" \
        -D LAPACKE_WITH_TMG="ON" \
        ..
      make -j"$(nproc)"
    popd || exit 1
  popd || exit 1
  return $?
}

do_install() {
  pushd "$HAB_CACHE_SRC_PATH/${pkg_name}-${pkg_version}/build" || exit 1
    make install
  popd || exit 1

  pushd "$HAB_CACHE_SRC_PATH/${pkg_name}-${pkg_version}/LAPACKE/build" || exit 1
    make install
  popd || exit 1
  return $?
}
