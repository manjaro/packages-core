#!/bin/bash

rm -Rf aufs4-standalone
# clone the aufs repository to the local disk
git clone git://github.com/sfjro/aufs4-standalone.git aufs4-standalone
cd aufs4-standalone
git branch -r
git checkout origin/aufs4.2

# modify what you want

# and after
# create the patch with the directories: fs, include and Documentation

rm -v $(find . -type f -name '*.orig')
#grep -qse 'EXPORT_SYMBOL(' aufs4-standalone.patch && \
#sed -i-old -e 's|EXPORT_SYMBOL(|EXPORT_SYMBOL_GPL(|' aufs4-standalone.patch
rm -rf ../tmp/linux-4.2
mkdir -p ../tmp/linux-4.2
cp -a fs ../tmp/linux-4.2
cp -a include ../tmp/linux-4.2
cp -a Documentation ../tmp/linux-4.2
rm ../tmp/linux-4.2/include/uapi/linux/Kbuild
cd ../tmp
diff -Naur null linux-4.2  | filterdiff | \
sed -e 's|null\(/include/uapi/linux/Kbuild\)|linux-4.2-old\1|;s|^--- null.*|--- /dev/null|;\|linux-4.2/include/uapi/linux/Kbuild|,${\|@@ -0,0 +1 @@|,$d}' | \
bzip2 > aufs$(sed -ne 's|#define.*AUFS_VERSION.*"\(.*\)"|\1|p'  linux-4.2/include/uapi/linux/aufs_type.h).patch.bz2
mv *.bz2 $OLDPWD
cd $OLDPWD
mv *patch* ..
cd ..
rm -rf tmp aufs4-standalone


# the patch is created in ../tmp
# the other patches needed to compile are in the base directory
