#!/bin/env bash

#    Wine/Wine Staging build script for Ubuntu & variants (amd64)
#    Copyright (C) 2018  Pekka Helenius
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

########################################################

# DO NOT RUN INDIVIDUALLY, ONLY VIA ../../updatewine.sh PARENT SCRIPT!

########################################################

# datedir variable supplied by ../updatewine_debian.sh script file
datedir="${1}"

########################################################

# Staging patchsets. Default: all patchsets.
# Applies only if Wine Staging is set to be compiled
# Please see Wine Staging patchinstall.sh file for individual patchset names.
staging_patchsets=(--all)

########################################################

# Parse input arguments

i=0
for arg in ${@:2}; do
  args[$i]="${arg}"
  let i++
done
# Must be a true array as defined above, not a single index list!
#args="${@:2}"

for check in ${args[@]}; do

  case ${check} in
    --no-staging)
      NO_STAGING=
      ;;
    --no-install)
      NO_INSTALL=
      ;;
  esac

done

########################################################

function Wine_intCleanup() {
  cd ..
  rm -rf winebuild_${datedir}
  exit 0
}

# Allow interruption of the script at any time (Ctrl + C)
trap "Wine_intCleanup" INT

########################################################

# This is specifically for Debian
# Must be done to install Wine buildtime dependencies on amd64 environment
#
if [[ $(dpkg --print-foreign-architectures | grep i386 | wc -l) -eq 0 ]]; then
  sudo dpkg --add-architecture i386
  sudo apt update
fi

########################################################

function getWine() {

  function cleanOldBuilds() {
    if [[ $(find . -type d -name "winebuild_*" | wc -l) -ne 0 ]]; then
      echo -e "Removing old Wine build folders. This can take a while.\n"
      rm -rf ./winebuild_*
    fi
  }

  cleanOldBuilds

  mkdir winebuild_${datedir}
  cd winebuild_${datedir}

  WINEROOT="${PWD}"

  echo -e "Retrieving source code of Wine$(if [[ ! -v NO_STAGING ]]; then echo ' & Wine Staging' ; fi)\n"

  git clone git://source.winehq.org/git/wine.git

  if [[ ! -v NO_STAGING ]]; then
    git clone git://github.com/wine-staging/wine-staging.git
    WINEDIR_STAGING="${WINEROOT}/wine-staging"
    PKGNAME="wine-staging-git"
  else
    PKGNAME="wine-git"
  fi

  mkdir wine-{patches,32-build,32-install,64-build,64-install,package}
  cp -r ../../../wine_custom_patches/*.{patch,diff} wine-patches/ 2>/dev/null

  WINEDIR="${WINEROOT}/wine"
  WINEDIR_PATCHES="${WINEROOT}/wine-patches"
  WINEDIR_BUILD_32="${WINEROOT}/wine-32-build"
  WINEDIR_BUILD_64="${WINEROOT}/wine-64-build"
  WINEDIR_INSTALL_32="${WINEROOT}/wine-32-install"
  WINEDIR_INSTALL_64="${WINEROOT}/wine-64-install"
  WINEDIR_PACKAGE="${WINEROOT}/wine-package"

}

function getDebianFiles() {

  local debian_archive=wine_3.0-1ubuntu1.debian.tar.xz

  cd "${WINEDIR}"
  wget http://archive.ubuntu.com/ubuntu/pool/universe/w/wine/${debian_archive}
  tar xvf ${debian_archive}
  rm ${debian_archive}

}

########################################################

# Wine build dependency list on Debian

wine_deps_build=(
'make'
'gcc-multilib'
'g++-multilib'
'libxml-simple-perl'
'libxml-parser-perl'
'libxml-libxml-perl'
'lzma'
'flex'
'bison'
'quilt'
'gettext'
'oss4-dev'
'sharutils'
'pkg-config'
'dctrl-tools'
'khronos-api'
'unicode-data'
'freebsd-glue'
'icoutils'
'librsvg2-bin'
'imagemagick'
'fontforge'
'libxi-dev:amd64'
'libxt-dev:amd64'
'libxmu-dev:amd64'
'libx11-dev:amd64'
'libxext-dev:amd64'
'libxfixes-dev:amd64'
'libxrandr-dev:amd64'
'libxcursor-dev:amd64'
'libxrender-dev:amd64'
'libxkbfile-dev:amd64'
'libxxf86vm-dev:amd64'
'libxxf86dga-dev:amd64'
'libxinerama-dev:amd64'
'libgl1-mesa-dev:amd64'
'libglu1-mesa-dev:amd64'
'libxcomposite-dev:amd64'
'libpng-dev:amd64'
'libssl-dev:amd64'
'libv4l-dev:amd64'
'libxml2-dev:amd64'
'libgsm1-dev:amd64'
'libjpeg-dev:amd64'
'libkrb5-dev:amd64'
'libtiff-dev:amd64'
'libsane-dev:amd64'
'libudev-dev:amd64'
'libpulse-dev:amd64'
'liblcms2-dev:amd64'
'libldap2-dev:amd64'
'libxslt1-dev:amd64'
'unixodbc-dev:amd64'
'libcups2-dev:amd64'
'libcapi20-dev:amd64'
'libopenal-dev:amd64'
'libdbus-1-dev:amd64'
'freeglut3-dev:amd64'
'libmpg123-dev:amd64'
'libasound2-dev:amd64'
'libgphoto2-dev:amd64'
'libosmesa6-dev:amd64'
'libpcap0.8-dev:amd64'
'libgnutls28-dev:amd64'
'libncurses5-dev:amd64'
'libgettextpo-dev:amd64'
'libfreetype6-dev:amd64'
'libfontconfig1-dev:amd64'
'libgstreamer-plugins-base1.0-dev:amd64'
'ocl-icd-opencl-dev:amd64'
'libvulkan-dev:amd64'
'libxi-dev:i386'
'libxt-dev:i386'
'libxmu-dev:i386'
'libx11-dev:i386'
'libxext-dev:i386'
'libxfixes-dev:i386'
'libxrandr-dev:i386'
'libxcursor-dev:i386'
'libxrender-dev:i386'
'libxkbfile-dev:i386'
'libxxf86vm-dev:i386'
'libxxf86dga-dev:i386'
'libxinerama-dev:i386'
'libgl1-mesa-dev:i386'
'libglu1-mesa-dev:i386'
'libxcomposite-dev:i386'
'libpng-dev:i386'
'libssl-dev:i386'
'libv4l-dev:i386'
'libgsm1-dev:i386'
'libjpeg-dev:i386'
'libkrb5-dev:i386'
'libsane-dev:i386'
'libudev-dev:i386'
'libpulse-dev:i386'
'liblcms2-dev:i386'
'libldap2-dev:i386'
'unixodbc-dev:i386'
'libcapi20-dev:i386'
'libopenal-dev:i386'
'libdbus-1-dev:i386'
'freeglut3-dev:i386'
'libmpg123-dev:i386'
'libasound2-dev:i386'
'libgphoto2-dev:i386'
'libosmesa6-dev:i386'
'libpcap0.8-dev:i386'
'libncurses5-dev:i386'
'libgettextpo-dev:i386'
'libfreetype6-dev:i386'
'libfontconfig1-dev:i386'
'ocl-icd-opencl-dev:i386'
'libvulkan-dev:i386'
)

# Excluded x86 packages since they conflict with their amd64 counterparts:
#
# libxslt1-dev:i386
# libxml2-dev:i386
# libicu-dev:i386
# libtiff-dev:i386
# libcups2-dev:i386
# libgnutls28-dev:i386
# libgstreamer1.0-dev:i386
# libgstreamer-plugins-base1.0-dev:i386

########################################################

# Wine runtime dependency list on Debian

wine_deps_runtime=(
'libxcursor1:i386'
'libxrandr2:i386'
'libxi6:i386'
'libsm6:i386'
'libvulkan1:i386'
'libasound2:i386'
'libc6:i386'
'libfontconfig1:i386'
'libfreetype6:i386'
'libgcc1:i386'
'libglib2.0-0:i386'
'libgphoto2-6:i386'
'libgphoto2-port12:i386'
'liblcms2-2:i386'
'libldap-2.4-2:i386'
'libmpg123-0:i386'
'libncurses5:i386'
'libopenal1:i386'
'libpcap0.8:i386'
'libpulse0:i386'
'libtinfo5:i386'
'libudev1:i386'
'libx11-6:i386'
'libxext6:i386'
'libxml2:i386'
'ocl-icd-libopencl1:i386'
'zlib1g:i386'
'fontconfig:amd64'
'libxcursor1:amd64'
'libxrandr2:amd64'
'libxi6:amd64'
'gettext:amd64'
'libsm6:amd64'
'libvulkan1:amd64'
'libasound2:amd64'
'libc6:amd64'
'libfontconfig1:amd64'
'libfreetype6:amd64'
'libgcc1:amd64'
'libglib2.0-0:amd64'
'libgphoto2-6:amd64'
'libgphoto2-port12:amd64'
'liblcms2-2:amd64'
'libldap-2.4-2:amd64'
'libmpg123-0:amd64'
'libncurses5:amd64'
'libopenal1:amd64'
'libpcap0.8:amd64'
'libpulse0:amd64'
'libtinfo5:amd64'
'libudev1:amd64'
'libx11-6:amd64'
'libxext6:amd64'
'libxml2:amd64'
'ocl-icd-libopencl1:amd64'
'zlib1g:amd64'
'desktop-file-utils'
'libgstreamer-plugins-base1.0-0:amd64'
'libgstreamer1.0-0:amd64'
)

# Exclude the following i386 runtime dependencies
# because they conflict with their amd64 counterparts:
# gettext:i386

########################################################

# Wine dependencies:

function WineDeps() {

  local a=0
  local deps="${1}"
  local depsname=${2}

  echo -e "Installing Wine dependencies.\n" # Sudo password may be required.\n"

  # TODO should we install all at once, or go iterating the list,
  # giving better output for user. Iterative method is slower, though.
  #
#  sudo apt install -y ${deps[*]}
#  if [[ $? -ne 0 ]]; then
#    echo -e "Error while installing Wine dependencies. Aborting\n"
#    exit 1
#  fi

  function pkgdependencies() {

    for pkgdep in ${@}; do

      if [[ $(apt version ${pkgdep} | wc -w) -eq 0 ]]; then

        echo -e "Installing ${depsname} dependency ${pkgdep} ($(($a + 1 )) / $((${#*} + 1)))\n."
        sudo apt install -y ${pkgdep} &> /dev/null
        if [[ $? -eq 0 ]]; then
          let a++
        else
          echo -e "\nError occured while installing ${pkgdep}. Aborting.\n"
          exit 1
        fi
      fi
    done

  }

  pkgdependencies ${deps[*]}

}

########################################################

# Wine staging override list
# Wine Staging replaces and conflicts with these packages
# Applies to debian/control file

wine_over_pkgs=(
'wine'
'wine-development'
'wine64-development'
'wine1.6'
'wine1.6-i386'
'wine1.6-amd64'
'libwine:amd64'
'libwine:i386'
'wine-stable'
'wine32'
'wine64'
)

############################

# Suggest section in debian/control file

wine_suggest_pkgs=(
'winbind'
'winetricks'
'fonts-wine'
'playonlinux'
'wine-binfmt'
'dosbox'
)

########################################################

# Feed the following data to Wine debian/control file

function feedControlfile() {

  local MAINTAINER="$USER"

  sed -ie "s/^Build-Depends:.*$/Build-Depends: debhelper (>=11), $(echo ${wine_deps_build[*]} | sed 's/\s/, /g')/g" debian/control
  sed -ie "s/^Depends:.*$/Depends: $(echo ${wine_deps_runtime[*]} | sed 's/\s/, /g')/g" debian/control
  sed -ie "s/^Suggests:.*$/Suggests: $(echo ${wine_suggest_pkgs[*]} | sed 's/\s/, /g')/g" debian/control

  sed -ie "s/^Maintainer:.*$/Maintainer: ${MAINTAINER}/g" debian/control
  sed -ie "s/^Source:.*$/Source: ${PKGNAME}/g" debian/control
  sed -ie "s/^Package:.*$/Package: ${PKGNAME}/g" debian/control

  for ctrl_section in Conflicts Breaks Replaces Provides; do
      sed -ie "s/^${ctrl_section}:.*$/${ctrl_section}: $(echo ${wine_over_pkgs[*]} | sed 's/\s/, /g')/g" debian/control
  done

}

########################################################

# Refresh Wine GIT

function refreshWineGIT() {

  # Restore the wine tree to its git origin state, without wine-staging patches
  # (necessary for reapllying wine-staging patches in succedent builds,
  # otherwise the patches will fail to be reapplied)
  cd "${WINEDIR}"
  git reset --hard HEAD     # Restore tracked files
  git clean -d -x -f        # Delete untracked files

  if [[ ! -v NO_STAGING ]]; then
    # Change back to the wine upstream commit that this version of wine-staging is based on
    git checkout $(bash "${WINEDIR_STAGING}"/patches/patchinstall.sh --upstream-commit)
  fi
}

########################################################

# Get Wine version tag

function getWineVersion() {
  cd "${WINEDIR}"
  wine_version=$(git describe | sed 's/^[a-z]*-//; s/-[0-9]*-[a-z0-9]*$//')
}

########################################################

# Apply patches

function patchWineSource() {

  if [[ ! -v NO_STAGING ]]; then
    cd "${WINEDIR_STAGING}/patches"
    bash ./patchinstall.sh DESTDIR="${WINEDIR}" ${staging_patchsets[*]}
  fi

  cp -r ${WINEROOT}/../../../wine_custom_patches/* "${WINEDIR_PATCHES}/"

  if [[ $(find "${WINEDIR_PATCHES}" -mindepth 1 -maxdepth 1 -regex ".*\.\(patch\|diff\)$") ]]; then
    cd "${WINEDIR}"
    for i in "${WINEDIR_PATCHES}"/*.patch; do
        patch -Np1 < $i
    done
  fi

}

########################################################

# 64-bit build

function wine64Build() {

  cd "${WINEDIR_BUILD_64}"
  "${WINEDIR}"/configure \
  --with-x \
  --with-gstreamer \
  --enable-win64 \
  --with-xattr \
  --disable-mscoree \
  --with-vulkan \
  --prefix=/usr \
  --libdir=/usr/lib/x86_64-linux-gnu/
  make -j$(nproc --ignore 1)

  make -j$(nproc --ignore 1) prefix="${WINEDIR_INSTALL_64}/usr" \
  libdir="${WINEDIR_INSTALL_64}/usr/lib/x86_64-linux-gnu/" \
  dlldir="${WINEDIR_INSTALL_64}/usr/lib/x86_64-linux-gnu/wine" install

}

# 32-bit build

function wine32Build() {

# Gstreamer amd64 & i386 dev packages conflict on Ubuntu

  cd "${WINEDIR_BUILD_32}"
  "${WINEDIR}"/configure \
  --with-x \
  --with-gstreamer \
  --with-xattr \
  --disable-mscoree \
  --with-vulkan \
  --without-gstreamer \
  --libdir=/usr/lib/i386-linux-gnu/ \
  --with-wine64="${WINEDIR_BUILD_64}" \
  --prefix=/usr
  make -j$(nproc --ignore 1)

  make -j$(nproc --ignore 1) prefix="${WINEDIR_INSTALL_32}/usr" \
  libdir="${WINEDIR_INSTALL_32}/usr/lib/i386-linux-gnu/" \
  dlldir="${WINEDIR_INSTALL_32}/usr/lib/i386-linux-gnu/wine" install

}

########################################################

function mergeWineBuilds() {

  cp -r "${WINEDIR_INSTALL_64}"/* "${WINEDIR_PACKAGE}"/

  cp -r "${WINEDIR_INSTALL_32}"/usr/bin/{wine,wine-preloader} "${WINEDIR_PACKAGE}"/usr/bin/
  cp -r "${WINEDIR_INSTALL_32}"/usr/lib/* "${WINEDIR_PACKAGE}"/usr/lib/

}

function buildDebianArchive() {
  cd "${WINEROOT}"
  mv "${WINEDIR_PACKAGE}" "${WINEROOT}/${PKGNAME}-${wine_version}"
  cd "${WINEROOT}/${PKGNAME}-${wine_version}"
  dh_make --createorig -s -y
  rm debian/*.{ex,EX}
  printf "usr/* /usr" > debian/install

cat << 'DEBIANCONTROL' > debian/control
Source:
Section: otherosfs
Priority: optional
Maintainer:
Build-Depends:
Standards-Version: 4.1.2
Homepage: https://www.winehq.org

Package:
Architecture: any
Depends:
Suggests:
Conflicts:
Breaks:
Replaces:
Provides:
Description: A compatibility layer for running Windows programs.
 Wine is an open source Microsoft Windows API implementation for
 POSIX-compliant operating systems, including Linux.
 Git version includes the latest updates available for Wine.

DEBIANCONTROL

  feedControlfile

  DEB_BUILD_OPTIONS="strip nodocs noddebs" dpkg-buildpackage -b -us -uc

}

function installDebianArchive() {
  cd "${WINEROOT}"
  # TODO Although the package name ends with 'amd64', this contains both 32 and 64 bit Wine versions
  echo -e "\nInstalling Wine.\n" # Please provide your sudo password.
  sudo dpkg -i ${PKGNAME}_${wine_version}-1_amd64.deb
}

function storeDebianArchive() {
  cd "${WINEROOT}"
  mv ${PKGNAME}_${wine_version}-1_amd64.deb ../../compiled_deb/"${datedir}" && \
  echo -e "Compiled ${PKGNAME} is stored at '$(readlink -f ../../compiled_deb/"${datedir}")/'\n"
  rm -rf winebuild_${datedir}
}

function clearTree() {
  rm -rf "${WINEROOT}"
}

########################################################

# Get Wine (& Wine-Staging) sources
getWine

# Install Wine dependencies
WineDeps "${wine_deps_build[*]}" "Wine build time"
WineDeps "${wine_deps_runtime[*]}" "Wine runtime"

# Refresh & sync Wine (+ Wine Staging) git sources
refreshWineGIT

# Update Wine source files
patchWineSource

# Get Wine/Wine Staging version
getWineVersion

# Compile 64 & 32 bit Wine/Wine Staging
wine64Build
wine32Build

# Bundle compiled Wine/Wine-Staging files
mergeWineBuilds

# Bundle and install Debian deb archive
buildDebianArchive

if [[ ! -v NO_INSTALL ]]; then
  installDebianArchive
fi

storeDebianArchive

# Clear all temporary files
clearTree

