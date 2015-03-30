#
# maintainer: Philip Müller <philm[at]manjaro[dog]org>

pkgname=('keyboardctl')
pkgver=0.1.6
pkgrel=1
arch=('any')
url="https://github.com/manjaro/keyboardctl"
license=('GPL')
options=('emptydirs')
makedepends=('git')
groups=('base')
source=(git://github.com/manjaro/keyboardctl.git)
sha256sums=('SKIP')

package_keyboardctl() {
  pkgdesc="Manjaro Linux keymap setup program"
  depends=('ckbcomp')
  backup=('etc/keyboard.conf')
  install=keyboardctl.install
  cd ${srcdir}/${pkgname}
  make DESTDIR="$pkgdir" install
  rm "$pkgdir"/usr/bin/ckbcomp
}
