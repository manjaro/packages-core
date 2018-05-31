# Based on the file created for Arch Linux by:
# Tobias Powalowski <tpowa@archlinux.org>
# Thomas Baechler <thomas@archlinux.org>

# Maintainer: Philip Müller <philm@manjaro.org>
# Maintainer: Guinux <guillaume@manjaro.org>
# Maintainer: Rob McCathie <rob@manjaro.org>

pkgbase=linux44
pkgname=('linux44' 'linux44-headers')
_kernelname=-MANJARO
_basekernel=4.4
_basever=44
_aufs=20170410
_bfq=v8r12
_sub=135
pkgver=${_basekernel}.${_sub}
pkgrel=1
arch=('i686' 'x86_64')
url="http://www.kernel.org/"
license=('GPL2')
makedepends=('xmlto' 'docbook-xsl' 'kmod' 'inetutils' 'bc')
options=('!strip')
source=(#"https://www.kernel.org/pub/linux/kernel/v4.x/linux-${_basekernel}.tar.xz"
        #"https://www.kernel.org/pub/linux/kernel/v4.x/testing/linux-${_basekernel}.tar.xz"
        "https://github.com/torvalds/linux/archive/v${_basekernel}.tar.gz"
        "https://cdn.kernel.org/pub/linux/kernel/v4.x/patch-${pkgver}.xz"
        # the main kernel config files
        'config' 'config.x86_64' 'config.aufs'
        # standard config files for mkinitcpio ramdisk
        "${pkgbase}.preset"
        "${pkgbase}.hook"
        "aufs4.4-${_aufs}.patch.bz2"
        'aufs4-base.patch'
        'aufs4-kbuild.patch'
        'aufs4-loopback.patch'
        'aufs4-mmap.patch'
        'aufs4-standalone.patch'
        'tmpfs-idr.patch'
        'vfs-ino.patch'
        '1700_enable-thinkpad-micled.patch'
        '2700_ThinkPad-30-brightness-control-fix.patch'
        "0001-BFQ-${_bfq}.patch" #https://github.com/linusw/linux-bfq/compare/a8e0574...887cf43.patch
        # ARCH Patches
        'change-default-console-loglevel.patch'
        # MANJARO Patches
        '0001-sdhci-revert.patch'
        'i8042-asus-notebook.patch'
        '0002-Bluetooth-btusb-Apply-QCQ_ROME-setup-for-BTUSB_ATH30.patch'
        # Zen temperature
        '0001-zen-temp.patch'
        '0002-zen-temp.patch'
        '0003-zen-temp.patch'
        '0004-zen-temp.patch'
)
sha256sums=('5b8fc6519a737a5c809171e08225f050bf794f1f369c4c387ed3c8a89b1e995b'
            '9c23ad59a89c4fdc0db23c5b0deaad2a645e1c6fd62a9e62e7f36c39cfcd08ce'
            '0579d0c801502e7fb7d2682acfe8a243888afaa90b597871c112c7d0b00114a2'
            'fc6543a6f5aa3366ffccb584654735410df1df318b3f4831519ade32bcb593e3'
            'd1cecc720df66c70f43bdb86e0169d6b756161c870db8d7d39c32c04dc36ed36'
            '43942683a7ff01b180dff7f3de2db4885d43ab3d4e7bd0e1918c3aaf2ee061f4'
            '5016e07c4afa91866566f6812aa7a4c69537d3abf64076c0307863f45a491e77'
            '7c20920e06f3735106790a3c9dabca44857d60f4a25c474b8187f864ae4ac704'
            'eb0d1d2af199ee40cc6704e6b7bdcd43f17e7e635514501247c413806bce63ff'
            '31ba01590164e89cf275de5a9f2700c4044e79b1d880bafc0b1bfbcaf09ca37c'
            'b6dbf4375b233590fb956c16689edb1ae1e66fa604a1ad536defe97e634df3fb'
            '31ab9a3a628664ed85ad3cce3dc5e94a4ad1270d9925462ea0e50ab3698c53ce'
            'f626fb29eefbf9d002d3786174c1f97344e4d97604ae0dfe28f0516a8a4590b6'
            '0d8ecaa41661327d592c03bb20bf5f911a515e7caf35d457de4e802a55df4498'
            '6f7aa69101d690df2286dd2642a23bce835efab96273389b243dafbec15a1d0c'
            '461aa0da7de8bda9474797339532304894b55825be34f8c009244da8c00c5b41'
            'a3f85c3c35ee478fd174f8aaa6ca15e5fad8612b42ca4d90cc3ef79b49a99989'
            'c8cc7075dd99a02b7deed820ea7e2591be91860cc8cf08718fc7d53fe3634b35'
            '44e7e15c95af9676f715569e72688fd64304a70d2854b0f804c156d4961c72c0'
            '5313df7cb5b4d005422bd4cd0dae956b2dadba8f3db904275aaf99ac53894375'
            '6f836c7ede51db88504fee33e228af368b1b6cb08f3dc7536849945f595a6758'
            '61abfab9093bdfec4edda3586fd05afe2f488a92ca99cff51c36b359acdcc815'
            '4d55d497f1c3ebc7afa82909c3fc63a37855d1753b4cd7dfdbaac21d91fe6968'
            'ee46e4c25b58d1dbd7db963382cf37aeae83dd0b4c13a59bdd11153dc324d8e8'
            'cd463af7193bcf864c42e95d804976a627ac11132886f25e04dfc2471c28bf6c'
            '70cee696fb4204ac7f787cef0742c50637e8bb7f68e2c7bca01aeefff32affc8')

prepare() {
  cd "${srcdir}/linux-${_basekernel}"

  # add upstream patch
  patch -p1 -i "${srcdir}/patch-${pkgver}"

  # add latest fixes from stable queue, if needed
  # http://git.kernel.org/?p=linux/kernel/git/stable/stable-queue.git
  # enable only if you have "gen-stable-queue-patch.sh" executed before
  #patch -Np1 -i "${srcdir}/prepatch-${_basekernel}-20161030"

  # revert http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=9faac7b95ea4f9e83b7a914084cc81ef1632fd91
  # fixes #47778 sdhci broken on some boards
  # https://bugzilla.kernel.org/show_bug.cgi?id=106541
  # https://github.com/manjaro/packages-core/issues/27
  patch -Rp1 -i "${srcdir}/0001-sdhci-revert.patch"

  # set DEFAULT_CONSOLE_LOGLEVEL to 4 (same value as the 'quiet' kernel param)
  # remove this when a Kconfig knob is made available by upstream
  # (relevant patch sent upstream: https://lkml.org/lkml/2011/7/26/227)
  patch -p1 -i "${srcdir}/change-default-console-loglevel.patch"

  # fix X455LB touchpad issue
  # https://github.com/manjaro/packages-core/pull/39
  patch -p1 -i "${srcdir}/i8042-asus-notebook.patch"

  # https://bugzilla.kernel.org/show_bug.cgi?id=199271
  patch -Np1 -i ../0002-Bluetooth-btusb-Apply-QCQ_ROME-setup-for-BTUSB_ATH30.patch

  # Add support for temperature sensors on Family 17h (Ryzen) processors.
  patch -Np1 -i "${srcdir}/0001-zen-temp.patch"
  patch -Np1 -i "${srcdir}/0002-zen-temp.patch"
  patch -Np1 -i "${srcdir}/0003-zen-temp.patch"
  patch -Np1 -i "${srcdir}/0004-zen-temp.patch"

  # add Gentoo patches
  patch -Np1 -i "${srcdir}/1700_enable-thinkpad-micled.patch"
  patch -Np1 -i "${srcdir}/2700_ThinkPad-30-brightness-control-fix.patch"

  # add aufs4 support
  patch -Np1 -i "${srcdir}/aufs4.4-${_aufs}.patch"
  patch -Np1 -i "${srcdir}/aufs4-base.patch"
  patch -Np1 -i "${srcdir}/aufs4-kbuild.patch"
  patch -Np1 -i "${srcdir}/aufs4-loopback.patch"
  patch -Np1 -i "${srcdir}/aufs4-mmap.patch"
  patch -Np1 -i "${srcdir}/aufs4-standalone.patch"
  patch -Np1 -i "${srcdir}/tmpfs-idr.patch"
  patch -Np1 -i "${srcdir}/vfs-ino.patch"

  # add BFQ scheduler
  #sed -i -e 's|__GFP_WAIT|__GFP_DIRECT_RECLAIM|g' "${srcdir}/0002-block-introduce-the-BFQ-${_bfq}-I-O-sched.patch"
  #sed -i -e 's|__GFP_WAIT|__GFP_DIRECT_RECLAIM|g' "${srcdir}/0003-block-bfq-add-Early-Queue-Merge-EQM-to-BFQ-${_bfq}.patch"
  #patch -Np1 -i "${srcdir}/0001-block-cgroups-kconfig-build-bits-for-BFQ-${_bfq}.patch"
  #patch -Np1 -i "${srcdir}/0002-block-introduce-the-BFQ-${_bfq}-I-O-sched.patch"
  #patch -Np1 -i "${srcdir}/0003-block-bfq-add-Early-Queue-Merge-EQM-to-BFQ-${_bfq}.patch"
  #patch -Np1 -i "${srcdir}/0004-block-bfq-update-migration-methods-attach-for-4.4-rc5-v7r8.patch"
  sed -i -e "s|SUBLEVEL = 0|SUBLEVEL = ${_sub}|g" "${srcdir}/0001-BFQ-${_bfq}.patch"
  patch -Np1 -i "${srcdir}/0001-BFQ-${_bfq}.patch"

  if [ "${CARCH}" = "x86_64" ]; then
    cat "${srcdir}/config.x86_64" > ./.config
  else
    cat "${srcdir}/config" > ./.config
  fi

  cat "${srcdir}/config.aufs" >> ./.config

  if [ "${_kernelname}" != "" ]; then
    sed -i "s|CONFIG_LOCALVERSION=.*|CONFIG_LOCALVERSION=\"${_kernelname}\"|g" ./.config
    sed -i "s|CONFIG_LOCALVERSION_AUTO=.*|CONFIG_LOCALVERSION_AUTO=n|" ./.config
  fi

  # set extraversion to pkgrel
  sed -ri "s|^(EXTRAVERSION =).*|\1 -${pkgrel}|" Makefile

  # don't run depmod on 'make install'. We'll do this ourselves in packaging
  sed -i '2iexit 0' scripts/depmod.sh

  # normally not needed
  make clean

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

package_linux44() {
  pkgdesc="The ${pkgbase/linux/Linux} kernel and modules"
  depends=('coreutils' 'linux-firmware' 'kmod' 'mkinitcpio>=0.7')
  optdepends=('crda: to set the correct wireless channels of your country')
  provides=("linux=${pkgver}")
  install=${pkgname}.install

  cd "${srcdir}/linux-${_basekernel}"

  KARCH=x86

  # get kernel version
  _kernver="$(make LOCALVERSION= kernelrelease)"

  mkdir -p "${pkgdir}"/{lib/modules,lib/firmware,boot}
  make LOCALVERSION= INSTALL_MOD_PATH="${pkgdir}" modules_install
  cp arch/$KARCH/boot/bzImage "${pkgdir}/boot/vmlinuz-${_basekernel}-${CARCH}"

  # add kernel version
  if [ "${CARCH}" = "x86_64" ]; then
     echo "${pkgver}-${pkgrel}-MANJARO x64" > "${pkgdir}/boot/${pkgbase}-${CARCH}.kver"
  else
     echo "${pkgver}-${pkgrel}-MANJARO x32" > "${pkgdir}/boot/${pkgbase}-${CARCH}.kver"
  fi

  # set correct depmod command for install
  sed -e "s|%BASEKERNEL%|${_basekernel}|g;s|%KERNVER%|${_kernver}|g;s|%ARCH%|${CARCH}|g" \
  "${startdir}/${install}" > "${startdir}/${install}.pkg"
  true && install=${install}.pkg

  # install mkinitcpio preset file for kernel
  sed "s|%PKGBASE%|${pkgbase}|g;s|%BASEKERNEL%|${_basekernel}|g;s|%ARCH%|${CARCH}|g" "${srcdir}/${pkgbase}.preset" |
  install -D -m644 /dev/stdin "${pkgdir}/etc/mkinitcpio.d/${pkgbase}.preset"

  # install pacman hook for initramfs regeneration
  sed "s|%PKGBASE%|${pkgbase}|g;s|%BASEKERNEL%|${_basekernel}|g;s|%ARCH%|${CARCH}|g" "${srcdir}/${pkgbase}.hook" |
  install -D -m644 /dev/stdin "${pkgdir}/usr/share/libalpm/hooks/90-${pkgbase}.hook"

  # remove build and source links
  rm -f "${pkgdir}"/lib/modules/${_kernver}/{source,build}
  # remove the firmware
  rm -rf "${pkgdir}/lib/firmware"
  # gzip -9 all modules to save 100MB of space
  find "${pkgdir}" -name '*.ko' -exec gzip -9 {} \;
  # make room for external modules
  ln -s "../extramodules-${_basekernel}${_kernelname:--MANJARO}" "${pkgdir}/lib/modules/${_kernver}/extramodules"
  # add real version for building modules and running depmod from post_install/upgrade
  mkdir -p "${pkgdir}/lib/modules/extramodules-${_basekernel}${_kernelname:--MANJARO}"
  echo "${_kernver}" > "${pkgdir}/lib/modules/extramodules-${_basekernel}${_kernelname:--MANJARO}/version"

  # Now we call depmod...
  depmod -b "${pkgdir}" -F System.map "${_kernver}"

  # move module tree /lib -> /usr/lib
  mkdir -p "${pkgdir}/usr"
  mv "${pkgdir}/lib" "${pkgdir}/usr/"

  # add vmlinux
  install -D -m644 vmlinux "${pkgdir}/usr/lib/modules/${_kernver}/build/vmlinux" 
}

package_linux44-headers() {
  pkgdesc="Header files and scripts for building modules for ${pkgbase/linux/Linux} kernel"
  provides=("linux-headers=$pkgver")

  install -dm755 "${pkgdir}/usr/lib/modules/${_kernver}"

  cd "${srcdir}/linux-${_basekernel}"
  install -D -m644 Makefile \
    "${pkgdir}/usr/lib/modules/${_kernver}/build/Makefile"
  install -D -m644 kernel/Makefile \
    "${pkgdir}/usr/lib/modules/${_kernver}/build/kernel/Makefile"
  install -D -m644 .config \
    "${pkgdir}/usr/lib/modules/${_kernver}/build/.config"

  mkdir -p "${pkgdir}/usr/lib/modules/${_kernver}/build/include"

  for i in acpi asm-generic config crypto drm generated keys linux math-emu \
    media net pcmcia scsi sound trace uapi video xen; do
    cp -a include/${i} "${pkgdir}/usr/lib/modules/${_kernver}/build/include/"
  done

  # copy arch includes for external modules
  mkdir -p "${pkgdir}/usr/lib/modules/${_kernver}/build/arch/x86"
  cp -a arch/x86/include "${pkgdir}/usr/lib/modules/${_kernver}/build/arch/x86/"

  # copy files necessary for later builds, like nvidia and vmware
  cp Module.symvers "${pkgdir}/usr/lib/modules/${_kernver}/build"
  cp -a scripts "${pkgdir}/usr/lib/modules/${_kernver}/build"

  # fix permissions on scripts dir
  chmod og-w -R "${pkgdir}/usr/lib/modules/${_kernver}/build/scripts"
  mkdir -p "${pkgdir}/usr/lib/modules/${_kernver}/build/.tmp_versions"

  mkdir -p "${pkgdir}/usr/lib/modules/${_kernver}/build/arch/${KARCH}/kernel"

  cp arch/${KARCH}/Makefile "${pkgdir}/usr/lib/modules/${_kernver}/build/arch/${KARCH}/"

  if [ "${CARCH}" = "i686" ]; then
    cp arch/${KARCH}/Makefile_32.cpu "${pkgdir}/usr/lib/modules/${_kernver}/build/arch/${KARCH}/"
  fi

  cp arch/${KARCH}/kernel/asm-offsets.s "${pkgdir}/usr/lib/modules/${_kernver}/build/arch/${KARCH}/kernel/"

  # add docbook makefile
  install -D -m644 Documentation/DocBook/Makefile \
    "${pkgdir}/usr/lib/modules/${_kernver}/build/Documentation/DocBook/Makefile"

  # add dm headers
  mkdir -p "${pkgdir}/usr/lib/modules/${_kernver}/build/drivers/md"
  cp drivers/md/*.h "${pkgdir}/usr/lib/modules/${_kernver}/build/drivers/md"

  # add inotify.h
  mkdir -p "${pkgdir}/usr/lib/modules/${_kernver}/build/include/linux"
  cp include/linux/inotify.h "${pkgdir}/usr/lib/modules/${_kernver}/build/include/linux/"

  # add wireless headers
  mkdir -p "${pkgdir}/usr/lib/modules/${_kernver}/build/net/mac80211/"
  cp net/mac80211/*.h "${pkgdir}/usr/lib/modules/${_kernver}/build/net/mac80211/"

  # add dvb headers for external modules
  # in reference to:
  # http://bugs.archlinux.org/task/9912
  mkdir -p "${pkgdir}/usr/lib/modules/${_kernver}/build/drivers/media/dvb-core"
  cp drivers/media/dvb-core/*.h "${pkgdir}/usr/lib/modules/${_kernver}/build/drivers/media/dvb-core/"
  # and...
  # http://bugs.archlinux.org/task/11194
  mkdir -p "${pkgdir}/usr/lib/modules/${_kernver}/build/include/config/dvb/"
  cp include/config/dvb/*.h "${pkgdir}/usr/lib/modules/${_kernver}/build/include/config/dvb/"

  # add dvb headers for http://mcentral.de/hg/~mrec/em28xx-new
  # in reference to:
  # http://bugs.archlinux.org/task/13146
  mkdir -p "${pkgdir}/usr/lib/modules/${_kernver}/build/drivers/media/dvb-frontends/"
  cp drivers/media/dvb-frontends/lgdt330x.h "${pkgdir}/usr/lib/modules/${_kernver}/build/drivers/media/dvb-frontends/"
  mkdir -p "${pkgdir}/usr/lib/modules/${_kernver}/build/drivers/media/i2c/"
  cp drivers/media/i2c/msp3400-driver.h "${pkgdir}/usr/lib/modules/${_kernver}/build/drivers/media/i2c/"

  # add dvb headers
  # in reference to:
  # http://bugs.archlinux.org/task/20402
  mkdir -p "${pkgdir}/usr/lib/modules/${_kernver}/build/drivers/media/usb/dvb-usb"
  cp drivers/media/usb/dvb-usb/*.h "${pkgdir}/usr/lib/modules/${_kernver}/build/drivers/media/usb/dvb-usb/"
  mkdir -p "${pkgdir}/usr/lib/modules/${_kernver}/build/drivers/media/dvb-frontends"
  cp drivers/media/dvb-frontends/*.h "${pkgdir}/usr/lib/modules/${_kernver}/build/drivers/media/dvb-frontends/"
  mkdir -p "${pkgdir}/usr/lib/modules/${_kernver}/build/drivers/media/tuners"
  cp drivers/media/tuners/*.h "${pkgdir}/usr/lib/modules/${_kernver}/build/drivers/media/tuners/"

  # add xfs and shmem for aufs building
  mkdir -p "${pkgdir}/usr/lib/modules/${_kernver}/build/fs/xfs/libxfs"
  mkdir -p "${pkgdir}/usr/lib/modules/${_kernver}/build/mm"
  cp fs/xfs/libxfs/xfs_sb.h "${pkgdir}/usr/lib/modules/${_kernver}/build/fs/xfs/libxfs/xfs_sb.h"

  # copy in Kconfig files
  for i in $(find . -name "Kconfig*"); do
    mkdir -p "${pkgdir}"/usr/lib/modules/${_kernver}/build/`echo ${i} | sed 's|/Kconfig.*||'`
    cp ${i} "${pkgdir}/usr/lib/modules/${_kernver}/build/${i}"
  done

  chown -R root.root "${pkgdir}/usr/lib/modules/${_kernver}/build"
  find "${pkgdir}/usr/lib/modules/${_kernver}/build" -type d -exec chmod 755 {} \;

  # strip scripts directory
  find "${pkgdir}/usr/lib/modules/${_kernver}/build/scripts" -type f -perm -u+w 2>/dev/null | while read binary ; do
    case "$(file -bi "${binary}")" in
      *application/x-sharedlib*) # Libraries (.so)
        /usr/bin/strip ${STRIP_SHARED} "${binary}";;
      *application/x-archive*) # Libraries (.a)
        /usr/bin/strip ${STRIP_STATIC} "${binary}";;
      *application/x-executable*) # Binaries
        /usr/bin/strip ${STRIP_BINARIES} "${binary}";;
    esac
  done

  # remove unneeded architectures
  rm -rf "${pkgdir}"/usr/lib/modules/${_kernver}/build/arch/{alpha,arc,arm,arm26,arm64,avr32,blackfin,c6x,cris,frv,h8300,hexagon,ia64,m32r,m68k,m68knommu,metag,mips,microblaze,mn10300,openrisc,parisc,powerpc,ppc,s390,score,sh,sh64,sparc,sparc64,tile,unicore32,um,v850,xtensa}

  # remove a files already in linux-docs package
  rm -f "${pkgdir}/usr/lib/modules/${_kernver}/build/Documentation/kbuild/Kconfig.recursion-issue-01"
  rm -f "${pkgdir}/usr/lib/modules/${_kernver}/build/Documentation/kbuild/Kconfig.recursion-issue-02"
  rm -f "${pkgdir}/usr/lib/modules/${_kernver}/build/Documentation/kbuild/Kconfig.select-break"
}
