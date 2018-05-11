# Maintainer: Guinux <nuxgui@gmail.com>

pkgname=manjaro-release
pkgver=17.1.10
pkgrel=1
pkgdesc="Manjaro's release definition"
arch=("any")
url="https://manjaro.org/"
license=('GPL2')
depends=('lsb-release')
source=('lsb-release')
install="manjaro-release.install"
sha256sums=('8e4cccb4c36076a7283a0ad3639ca90b7941b6fcb693a31ca4ad9860d87fe22a')

package() {
    # Copy files
    mkdir -p ${pkgdir}/etc
    install -m644 ${srcdir}/lsb-release ${pkgdir}/etc/

}
