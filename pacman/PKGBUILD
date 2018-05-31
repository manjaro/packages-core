# Based on the file created for Arch Linux by:
# Dan McGee <dan@archlinux.org>
# Dave Reisner <dreisner@archlinux.org>

# Maintainer: Philip Müller <philm@manjaro.org>
# Maintainer: Guinux <guillaume@manjaro.org>

# Note: since we include pacman-contrib with this package we have to build pacman twice
# Example: pacsort: error while loading shared libraries

pkgname=pacman
pkgver=5.1.0
_pkgver=1.0.0
pkgrel=2
pkgdesc="A library-based package manager with dependency support"
arch=('i686' 'x86_64')
url="http://www.archlinux.org/pacman/"
license=('GPL')
groups=('base' 'base-devel')
depends=('bash>=4.2.042-2' 'glibc>=2.17-2' 'libarchive>=3.1.2' 'curl>=7.39.0'
         'gpgme' 'archlinux-keyring' 'manjaro-keyring' 'pacman-mirrors>=4.1.0')
checkdepends=('python2' 'fakechroot')
makedepends=('asciidoc' 'pacman>=5.1')
optdepends=('haveged: for pacman-init.service')
provides=('pacman-contrib' 'pacman-init')
conflicts=('pacman-contrib' 'pacman-init')
replaces=('pacman-contrib' 'pacman-init')
backup=(etc/pacman.conf etc/makepkg.conf)
install=pacman.install
options=('strip' 'debug')
validpgpkeys=('6645B0A8C7005E78DB1D7864F99FFE0FEAE999BD'  # Allan McRae <allan@archlinux.org>
              'B8151B117037781095514CA7BBDFFC92306B1121'  # Andrew Gregory (pacman) <andrew@archlinux.org>
              '5134EF9EAF65F95B6BB1608E50FB9B273A9D0BB5') # Johannes Löthberg <johannes@kyriasis.com>
source=(https://sources.archlinux.org/other/pacman/$pkgname-$pkgver.tar.gz{,.sig}
        https://sources.archlinux.org/other/community/pacman-contrib/pacman-contrib-$_pkgver.tar.gz{,.asc}
        pacman.conf.i686
        pacman.conf.x86_64
        makepkg.conf
        0001-makepkg-Clear-ERR-trap-before-trying-to-restore-it.patch
        0002-makepkg-Don-t-use-parameterless-return.patch
        pacman-sync-first-option.patch
        etc-pacman.d-gnupg.mount
        pacman-init.service)

prepare() {
  cd $srcdir/$pkgname-$pkgver

  # Fix install_packages failure exit code, required by makechrootpkg
  patch -Np1 -i $srcdir/0001-makepkg-Clear-ERR-trap-before-trying-to-restore-it.patch
  patch -Np1 -i $srcdir/0002-makepkg-Don-t-use-parameterless-return.patch

  # Manjaro patches
  patch -p1 -i $srcdir/pacman-sync-first-option.patch

  ./configure --prefix=/usr --sysconfdir=/etc \
    --localstatedir=/var --enable-doc \
    --with-scriptlet-shell=/usr/bin/bash \
    --with-ldconfig=/usr/bin/ldconfig
}

build() {
  cd $srcdir/$pkgname-$pkgver
  make V=1

  cd $srcdir/pacman-contrib-$_pkgver

  ./configure \
      --prefix=/usr \
      --sysconfdir=/etc \
      --localstatedir=/var
  make
}

check() {
  make -C "$pkgname-$pkgver" check
  make -C pacman-contrib-$_pkgver check
}

package() {
  cd $srcdir/$pkgname-$pkgver
  make DESTDIR=$pkgdir install

  # install Arch specific stuff
  install -dm755 $pkgdir/etc
  install -m644 $srcdir/pacman.conf.$CARCH $pkgdir/etc/pacman.conf
  
  case "$CARCH" in
    i686)    
      mycarch="i686"
      mychost="i686-pc-linux-gnu"
      myflags="-march=i686"
      ;;
    x86_64)
      mycarch="x86_64"
      mychost="x86_64-pc-linux-gnu"
      myflags="-march=x86-64"
      ;;
  esac
  install -m644 $srcdir/makepkg.conf $pkgdir/etc/
  # set things correctly in the default conf file
  sed -i $pkgdir/etc/makepkg.conf \
    -e "s|@CARCH[@]|$mycarch|g" \
    -e "s|@CHOST[@]|$mychost|g" \
    -e "s|@CARCHFLAGS[@]|$myflags|g"
    
  # put bash_completion in the right location
  install -dm755 ${pkgdir}/usr/share/bash-completion/completions
  mv ${pkgdir}/etc/bash_completion.d/pacman \
    ${pkgdir}/usr/share/bash-completion/completions
  rmdir ${pkgdir}/etc/bash_completion.d

  for f in makepkg pacman-key; do
    ln -s pacman "$pkgdir/usr/share/bash-completion/completions/$f"
  done

  # install pacman-init
  install -dm755 $pkgdir/usr/lib/systemd/system/
  install -m644 $srcdir/etc-pacman.d-gnupg.mount $pkgdir/usr/lib/systemd/system/etc-pacman.d-gnupg.mount
  install -m644 $srcdir/pacman-init.service $pkgdir/usr/lib/systemd/system/pacman-init.service

  cd $srcdir/pacman-contrib-$_pkgver

  make DESTDIR="$pkgdir" install

  # replace rankmirrors
  rm "$pkgdir/usr/bin/rankmirrors"
  ln -sfv "/usr/bin/pacman-mirrors" "$pkgdir/usr/bin/rankmirrors"
}

sha256sums=('9f5993fc8923530713742f15df284677f297b3eca15ed7a24758c98ac7399bd3'
            'SKIP'
            '0fb95514bd16a316d4cce920d34edc88b0d0618c484e2d7588746869d2339795'
            'SKIP'
            'b2ebeb47dd78e9df277f5d363daa079c82850a0ee65d2017689497b340b92e80'
            '01aa62ecd3e3d37bf800cd3ab0bf55121d3dd1d51a5070175c67216167a846de'
            'eec71e0b23f2ac1f06ad6ec5890d9de62effe0883ffd16573eed2153d0c87475'
            '9b2304141582a421e812c76760a74f360a3cbd780472cbb60cf023a34d6fcb3d'
            '2a31d4db5f6e19e0148d4892de14317514f2b2dfb5369c7972a641ca8be89e5a'
            'd3a77bf8ea916c24a73b2a2dc4162d2b81f993394850e0f2c331a8f8893c1a0b'
            'b6d14727ec465bb66d0a0358163b1bbfafcb4eaed55a0f57c30aabafae7eed68'
            '65d8bdccdcccb64ae05160b5d1e7f3e45e1887baf89dda36c1bd44c62442f91b')
