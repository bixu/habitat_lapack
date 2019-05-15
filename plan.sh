pkg_origin=bixu
pkg_name=lapack
pkg_version="3.8.0"
pkg_license=("Lapack")
pkg_source="https://www.netlib.org/${pkg_name}/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="deb22cc4a6120bff72621155a9917f485f96ef8319ac074a7afbc68aab88bcf6"
pkg_lib_dirs=("lib64")
pkg_description="Linear Algebra PACKage"
pkg_upstream_url="http://www.netlib.org/lapack/"
pkg_lib_dirs=("lib64")
pkg_include_dirs=("include")
pkg_pconfig_dirs=("lib64/pkgconfig")
pkg_deps=(
  "core/doxygen"
  "core/gcc"
  "core/cmake"
  "core/make"
  "core/python"
  "core/glibc"
)

do_setup_environment() {
  set_buildtime_env LIBRARY_PATH "$(hab pkg path core/glibc)/lib"
  return $?
}

do_prepare() {
  install -d build
  return $?
}

do_build() {
  cd build
    cmake /hab/cache/src/$pkg_dirname -DCMAKE_BUILD_TYPE=Release -DCMAKE_SKIP_RPATH=ON -DBUILD_SHARED_LIBS=ON -DBUILD_TESTING=OFF -DCMAKE_INSTALL_PREFIX=/ -DCMAKE_Fortran_COMPILER=gfortran -DLAPACKE_WITH_TMG=ON -DCBLAS=ON -DBUILD_DEPRECATED=ON
    make -j"$(nproc)"
  cd ..
  return $?
}

do_install() {
  cd build
    make DESTDIR="$pkg_prefix" install
  
  cd BLAS
    make DESTDIR="$pkg_prefix" install
  cd ..

  cd CBLAS
    make DESTDIR="$pkg_prefix" install
  cd ..

  cd LAPACKE
    make DESTDIR="$pkg_prefix" install
  cd ..

  mv "$pkg_prefix/usr/include" "$pkg_prefix/"
  mv "$pkg_prefix/usr/lib64" "$pkg_prefix/"
  rm -rf "$pkg_prefix/usr"
  return $?
}
