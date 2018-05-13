#
# Maintainer : Philip Müller <philm[at]manjaro[dot]org>
# Maintainer : Roland Singer <roland[at]manjaro[dot]org>
# Contributor: Rob McCathie <rob[at]manjaro[dot]org>
# Contributor: Alexandru Ianu <alexandru[at]manjaro[dot]org>

pkgname=manjaro-system
pkgver=$(date +%Y%m%d)
pkgrel=1
pkgdesc="Manjaro Linux System - Update script"
arch=('any')
url="http://www.manjaro.org"
license=('GPL')
# groups=('base')
depends=('mkinitcpio>=0.12.0-2' 'pcmciautils>=018-5' 'linux>=3.4' 'pacman>=5.0' 'coreutils' 'sed' 'awk')
install=manjaro-update-system.sh
source=('fsck.overlay')
sha256sums=('e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855')

package() {
   install -Dm755 "$srcdir/fsck.overlay" "$pkgdir/usr/bin/fsck.overlay"
}

