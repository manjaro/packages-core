# Based on the file created for Arch Linux by:
# Tobias Powalowski <tpowa@archlinux.org>
# Thomas Baechler <thomas@archlinux.org>

# Maintainer: Philip Müller <philm@manjaro.org>
# Maintainer: Guinux <guillaume@manjaro.org>
# Maintainer: Rob McCathie <rob@manjaro.org>

pkgbase=linux414
pkgname=('linux414' 'linux414-headers')
_kernelname=-MANJARO
_basekernel=4.14
_basever=414
_aufs=20170703
_bfq=v8r12
_bfqdate=20171108
_sub=3
_rc=
_shortgit=
_git=
#pkgver=${_basekernel}${_shortgit}
pkgver=${_basekernel}.${_sub}
pkgrel=1
arch=('i686' 'x86_64')
url="http://www.kernel.org/"
license=('GPL2')
makedepends=('xmlto' 'docbook-xsl' 'kmod' 'inetutils' 'bc' 'elfutils')
options=('!strip')
source=("https://www.kernel.org/pub/linux/kernel/v4.x/linux-${_basekernel}.tar.xz"
        #"https://git.kernel.org/torvalds/t/linux-${_basekernel}-${_rc}.tar.gz"
        #https://github.com/torvalds/linux/archive/v${_basekernel}.tar.gz
        #linux-${_basekernel}${_rc}${_shortgit}-${pkgrel}.tar.gz::https://github.com/torvalds/linux/archive/${_git}.tar.gz
        "http://www.kernel.org/pub/linux/kernel/v4.x/patch-${pkgver}.xz"
        # the main kernel config files
        'config.x86_64' 'config' # 'config.aufs'
        "${pkgbase}.preset" # standard config files for mkinitcpio ramdisk
        '60-linux.hook'     # pacman hook for depmod
        '90-linux.hook'     # pacman hook for initramfs regeneration
        #"aufs4.x-rcN-${_aufs}.patch.bz2"
        #'aufs4-base.patch'
        #'aufs4-kbuild.patch'
        #'aufs4-loopback.patch'
        #'aufs4-mmap.patch'
        #'aufs4-standalone.patch'
        #'tmpfs-idr.patch'
        #'vfs-ino.patch'
        #"0001-BFQ-${_bfq}-v${pkgver}.patch::https://github.com/Algodev-github/bfq-mq/compare/d93d4ce...abdfb33.patch"
        0001-BFQ-${_bfq}-${_bfqdate}.patch
        0002-BFQ-${_bfq}-WARN-ON.patch
        # ARCH Patches
        # MANJARO Patches
        # Zen temperature
        '0001-zen-temp.patch::https://lkml.org/lkml/diff/2017/9/6/682/1'
        '0002-zen-temp.patch::https://lkml.org/lkml/diff/2017/9/6/683/1'
        '0003-zen-temp.patch::https://lkml.org/lkml/diff/2017/9/6/684/1'
        # Bootsplash
        #'0001-bootsplash.patch::https://patchwork.kernel.org/patch/10026659/raw/'
        #'0002-bootsplash.patch::https://patchwork.kernel.org/patch/10026661/raw/'
        #'0003-bootsplash.patch::https://patchwork.kernel.org/patch/10026617/raw/'
        #'0004-bootsplash.patch::https://patchwork.kernel.org/patch/10026615/raw/'
        #'0005-bootsplash.patch::https://patchwork.kernel.org/patch/10026635/raw/'
        #'0006-bootsplash.patch::https://patchwork.kernel.org/patch/10026643/raw/'
        #'0007-bootsplash.patch::https://patchwork.kernel.org/patch/10026641/raw/'
        #'0008-bootsplash.patch::https://patchwork.kernel.org/patch/10026647/raw/'
        #'0009-bootsplash.patch::https://patchwork.kernel.org/patch/10026627/raw/'
        #'0010-bootsplash.patch::https://patchwork.kernel.org/patch/10026639/raw/'
        #'0011-bootsplash.patch::https://patchwork.kernel.org/patch/10026629/raw/'
        #'0012-bootsplash.patch::https://patchwork.kernel.org/patch/10026637/raw/'
        #'0013-bootsplash.patch::https://patchwork.kernel.org/patch/10026619/raw/'
        #'0014-bootsplash.patch::https://patchwork.kernel.org/patch/10026623/raw/'
        # Fix HP-WMI for libinput v1.9.1+
        'hp-wmi-fix-tablet-mode-detection-for-convertibles.patch::https://github.com/torvalds/linux/commit/9968e12a291e639dd51d1218b694d440b22a917f.patch'
)
sha256sums=('f81d59477e90a130857ce18dc02f4fbe5725854911db1e7ba770c7cd350f96a7'
            'e13995c11d0c2d3379c887666dbfaca619200fb8853db6d5d67f97d47fd959b7'
            '310385c9970a7d4a846f9d45fde84a6f3c79fdb7d851fa57a2429671d9725ebb'
            '90116ffa4aa143448a9b4ad59ba5ca549a6d30c5aa0ffa3dfe4222abf7b0098d'
            '43942683a7ff01b180dff7f3de2db4885d43ab3d4e7bd0e1918c3aaf2ee061f4'
            'ae2e95db94ef7176207c690224169594d49445e04249d2499e9d2fbc117a0b21'
            '90831589b7ab43d6fab11bfa3ad788db14ba77ea4dc03d10ee29ad07194691e1'
            '5ac0d9fb774ed038c5537c59836b389bb64bdb50a01f32d0ee8ae03159ca9198'
            '8f7069fd2c530ef60f4c700e0dc2d486424485cabff8b1324d3921c86cc7e1cf'
            'a1b1c30d53d0a7ffe2b84331f634388807489b807b20cc24041e2591f7da2ec1'
            'df9ff4580281ce431b42490a69f51d0a839471983930044bebe268aaee70c5ad'
            '009da98553e3c9b5d452b7850aac25b9e81fa39de9f2aa33744c012c1a912006'
            '66120f53d43a3ebef4ed6bd3cae6d75b8f13c2abdfd159df0e77c775cf01cca6')
prepare() {
  #mv "${srcdir}/linux-${_git}" "${srcdir}/linux-${_basekernel}"
  #mv "${srcdir}/linux-${_basekernel}-${_rc}" "${srcdir}/linux-${_basekernel}"
  cd "${srcdir}/linux-${_basekernel}"

  # add upstream patch
  patch -p1 -i "${srcdir}/patch-${pkgver}"

  # add latest fixes from stable queue, if needed
  # http://git.kernel.org/?p=linux/kernel/git/stable/stable-queue.git
  # enable only if you have "gen-stable-queue-patch.sh" executed before
  #patch -Np1 -i "${srcdir}/prepatch-${_basekernel}`date +%Y%m%d`"

  # libinput v1.9.1 issue
  # see: https://bugs.freedesktop.org/show_bug.cgi?id=103561
  patch -Np1 -i "${srcdir}/hp-wmi-fix-tablet-mode-detection-for-convertibles.patch"

  # Add support for temperature sensors on Family 17h (Ryzen) processors.
  patch -Np1 -i "${srcdir}/0001-zen-temp.patch"
  patch -Np1 -i "${srcdir}/0002-zen-temp.patch"
  patch -Np1 -i "${srcdir}/0003-zen-temp.patch"

  # Add bootsplash - http://lkml.iu.edu/hypermail/linux/kernel/1710.3/01542.html
  #patch -Np1 -i "${srcdir}/0001-bootsplash.patch"
  #patch -Np1 -i "${srcdir}/0002-bootsplash.patch"
  #patch -Np1 -i "${srcdir}/0003-bootsplash.patch"
  #patch -Np1 -i "${srcdir}/0004-bootsplash.patch"
  #patch -Np1 -i "${srcdir}/0005-bootsplash.patch"
  #patch -Np1 -i "${srcdir}/0006-bootsplash.patch"
  #patch -Np1 -i "${srcdir}/0007-bootsplash.patch"
  #patch -Np1 -i "${srcdir}/0008-bootsplash.patch"
  #patch -Np1 -i "${srcdir}/0009-bootsplash.patch"
  #patch -Np1 -i "${srcdir}/0010-bootsplash.patch"
  #patch -Np1 -i "${srcdir}/0011-bootsplash.patch"
  #patch -Np1 -i "${srcdir}/0012-bootsplash.patch"
  #patch -Np1 -i "${srcdir}/0013-bootsplash.patch"
  #patch -Np1 -i "${srcdir}/0014-bootsplash.patch"

  # add aufs4 support
  #patch -Np1 -i "${srcdir}/aufs4.x-rcN-${_aufs}.patch"
  #patch -Np1 -i "${srcdir}/aufs4-base.patch"
  #patch -Np1 -i "${srcdir}/aufs4-kbuild.patch"
  #patch -Np1 -i "${srcdir}/aufs4-loopback.patch"
  #patch -Np1 -i "${srcdir}/aufs4-mmap.patch"
  #patch -Np1 -i "${srcdir}/aufs4-standalone.patch"
  #patch -Np1 -i "${srcdir}/tmpfs-idr.patch"
  #patch -Np1 -i "${srcdir}/vfs-ino.patch"

  # add BFQ scheduler
  msg "Fix naming schema in BFQ-MQ patch"
  sed -i -e "s|SUBLEVEL = 0|SUBLEVEL = ${_sub}|g" \
      -i -e "s|EXTRAVERSION = -rc8|EXTRAVERSION =|g" \
      -i -e "s|EXTRAVERSION = -rc8-bfq-mq|EXTRAVERSION =|g" \
      -i -e "s|NAME = Fearless Coyote|NAME = Petit Gorille|g" \
      "${srcdir}/0001-BFQ-${_bfq}-${_bfqdate}.patch"
  #"${srcdir}/0001-BFQ-${_bfq}-v${pkgver}.patch"
  #patch -Np1 -i "${srcdir}/0001-BFQ-${_bfq}-v${pkgver}.patch"
  patch -Np1 -i "${srcdir}/0001-BFQ-${_bfq}-${_bfqdate}.patch"
  patch -Np1 -i "${srcdir}/0002-BFQ-${_bfq}-WARN-ON.patch"

  if [ "${CARCH}" = "x86_64" ]; then
    cat "${srcdir}/config.x86_64" > ./.config
  else
    cat "${srcdir}/config" > ./.config
  fi

  #cat "${srcdir}/config.aufs" >> ./.config

  if [ "${_kernelname}" != "" ]; then
    sed -i "s|CONFIG_LOCALVERSION=.*|CONFIG_LOCALVERSION=\"${_kernelname}\"|g" ./.config
    sed -i "s|CONFIG_LOCALVERSION_AUTO=.*|CONFIG_LOCALVERSION_AUTO=n|" ./.config
  fi

  # set extraversion to pkgrel
  sed -ri "s|^(EXTRAVERSION =).*|\1 -${pkgrel}|" Makefile

  # don't run depmod on 'make install'. We'll do this ourselves in packaging
  sed -i '2iexit 0' scripts/depmod.sh

  # get kernel version
  make prepare

  # load configuration
  # Configure the kernel. Replace the line below with one of your choice.
  #make menuconfig # CLI menu for configuration
  #make nconfig # new CLI menu for configuration
  #make xconfig # X-based configuration
  #make oldconfig # using old config from previous kernel version
  # ... or manually edit .config

  # rewrite configuration
  yes "" | make config >/dev/null
}

build() {
  cd "${srcdir}/linux-${_basekernel}"

  # build!
  make ${MAKEFLAGS} LOCALVERSION= bzImage modules
}

package_linux414() {
  pkgdesc="The ${pkgbase/linux/Linux} kernel and modules"
  depends=('coreutils' 'linux-firmware' 'kmod' 'mkinitcpio>=0.7')
  optdepends=('crda: to set the correct wireless channels of your country')
  provides=("linux=${pkgver}")
  backup=("etc/mkinitcpio.d/${pkgbase}.preset")
  install=${pkgname}.install

  cd "${srcdir}/linux-${_basekernel}"

  KARCH=x86

  # get kernel version
  _kernver="$(make LOCALVERSION= kernelrelease)"

  mkdir -p "${pkgdir}"/{boot,usr/lib/modules}
  make LOCALVERSION= INSTALL_MOD_PATH="${pkgdir}/usr" modules_install
  cp arch/$KARCH/boot/bzImage "${pkgdir}/boot/vmlinuz-${_basekernel}-${CARCH}"

  # add kernel version
  if [ "${CARCH}" = "x86_64" ]; then
     echo "${pkgver}-${pkgrel}-MANJARO x64" > "${pkgdir}/boot/${pkgbase}-${CARCH}.kver"
  else
     echo "${pkgver}-${pkgrel}-MANJARO x32" > "${pkgdir}/boot/${pkgbase}-${CARCH}.kver"
  fi

  # make room for external modules
  local _extramodules="extramodules-${_basekernel}${_kernelname:--MANJARO}"
  ln -s "../${_extramodules}" "${pkgdir}/usr/lib/modules/${_kernver}/extramodules"

  # add real version for building modules and running depmod from hook
  echo "${_kernver}" |
    install -Dm644 /dev/stdin "${pkgdir}/usr/lib/modules/${_extramodules}/version"

  # remove build and source links
  rm "${pkgdir}"/usr/lib/modules/${_kernver}/{source,build}

  # now we call depmod...
  depmod -b "${pkgdir}/usr" -F System.map "${_kernver}"

  # add vmlinux
  install -Dt "${pkgdir}/usr/lib/modules/${_kernver}/build" -m644 vmlinux

  # sed expression for following substitutions
  local _subst="
    s|%PKGBASE%|${pkgbase}|g
    s|%BASEKERNEL%|${_basekernel}|g
    s|%ARCH%|${CARCH}|g
    s|%KERNVER%|${_kernver}|g
    s|%EXTRAMODULES%|${_extramodules}|g
  "

  # hack to allow specifying an initially nonexisting install file
  sed "${_subst}" "${startdir}/${install}" > "${startdir}/${install}.pkg"
  true && install=${install}.pkg

  # install mkinitcpio preset file
  sed "${_subst}" ${srcdir}/linux414.preset |
    install -Dm644 /dev/stdin "${pkgdir}/etc/mkinitcpio.d/${pkgbase}.preset"

  # install pacman hooks
  sed "${_subst}" ${srcdir}/60-linux.hook |
    install -Dm644 /dev/stdin "${pkgdir}/usr/share/libalpm/hooks/60-${pkgbase}.hook"
  sed "${_subst}" ${srcdir}/90-linux.hook |
    install -Dm644 /dev/stdin "${pkgdir}/usr/share/libalpm/hooks/90-${pkgbase}.hook"
}

package_linux414-headers() {
  pkgdesc="Header files and scripts for building modules for ${pkgbase/linux/Linux} kernel"
  provides=("linux-headers=$pkgver")

  cd "${srcdir}/linux-${_basekernel}"
  local _builddir="${pkgdir}/usr/lib/modules/${_kernver}/build"

  install -Dt "${_builddir}" -m644 Makefile .config Module.symvers
  install -Dt "${_builddir}/kernel" -m644 kernel/Makefile

  mkdir "${_builddir}/.tmp_versions"

  cp -t "${_builddir}" -a include scripts

  install -Dt "${_builddir}/arch/${KARCH}" -m644 "arch/${KARCH}/Makefile"
  install -Dt "${_builddir}/arch/${KARCH}/kernel" -m644 "arch/${KARCH}/kernel/asm-offsets.s"

  if [ "${CARCH}" = "i686" ]; then
    install -Dt "${_builddir}/arch/${KARCH}" -m644 "arch/${KARCH}/Makefile_32.cpu"
  fi

  cp -t "${_builddir}/arch/${KARCH}" -a "arch/${KARCH}/include"

  install -Dt "${_builddir}/drivers/md" -m644 drivers/md/*.h
  install -Dt "${_builddir}/net/mac80211" -m644 net/mac80211/*.h

  # http://bugs.archlinux.org/task/9912
  install -Dt "${_builddir}/drivers/media/dvb-core" -m644 drivers/media/dvb-core/*.h

  # http://bugs.archlinux.org/task/13146
  install -Dt "${_builddir}/drivers/media/i2c" -m644 drivers/media/i2c/msp3400-driver.h

  # http://bugs.archlinux.org/task/20402
  install -Dt "${_builddir}/drivers/media/usb/dvb-usb" -m644 drivers/media/usb/dvb-usb/*.h
  install -Dt "${_builddir}/drivers/media/dvb-frontends" -m644 drivers/media/dvb-frontends/*.h
  install -Dt "${_builddir}/drivers/media/tuners" -m644 drivers/media/tuners/*.h

  # add xfs and shmem for aufs building
  mkdir -p "${_builddir}"/{fs/xfs,mm}

  # copy in Kconfig files
  find . -name Kconfig\* -exec install -Dm644 {} "${_builddir}/{}" \;

  if [ "${CARCH}" = "x86_64" ]; then
    # add objtool for external module building and enabled VALIDATION_STACK option
    install -Dt "${_builddir}/tools/objtool" tools/objtool/objtool
  fi

  # remove unneeded architectures
  local _arch
  for _arch in "${_builddir}"/arch/*/; do
    [[ ${_arch} == */x86/ ]] && continue
    rm -r "${_arch}"
  done

  # remove files already in linux-docs package
  rm -r "${_builddir}/Documentation"

  # Fix permissions
  chmod -R u=rwX,go=rX "${_builddir}"

  # strip scripts directory
  local _binary _strip
  while read -rd '' _binary; do
    case "$(file -bi "${_binary}")" in
      *application/x-sharedlib*)  _strip="${STRIP_SHARED}"   ;; # Libraries (.so)
      *application/x-archive*)    _strip="${STRIP_STATIC}"   ;; # Libraries (.a)
      *application/x-executable*) _strip="${STRIP_BINARIES}" ;; # Binaries
      *) continue ;;
    esac
    /usr/bin/strip ${_strip} "${_binary}"
  done < <(find "${_builddir}/scripts" -type f -perm -u+w -print0 2>/dev/null)
}
