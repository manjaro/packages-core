err() {
    ALL_OFF="\e[1;0m"
    BOLD="\e[1;1m"
    RED="${BOLD}\e[1;31m"
	local mesg=$1; shift
	printf "${RED}==>${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@" >&2
}

msg() {
    ALL_OFF="\e[1;0m"
    BOLD="\e[1;1m"
    GREEN="${BOLD}\e[1;32m"
	local mesg=$1; shift
	printf "${GREEN}==>${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@" >&2
}

check_pkgs()
{
	local remove=""

    for pkg in ${packages} ; do
        for rmpkg in $(pacman -Qq | grep ${pkg}) ; do
            if [ "${pkg}" == "${rmpkg}" ] ; then
               removepkgs="${removepkgs} ${rmpkg}"
            fi
        done
    done

    packages="${removepkgs}"
}

detectDE()
{
    if [ x"$KDE_FULL_SESSION" = x"true" ]; then DE=kde;
    elif [ x"$GNOME_DESKTOP_SESSION_ID" != x"" ]; then DE=gnome;
    elif `dbus-send --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.GetNameOwner string:org.gnome.SessionManager > /dev/null 2>&1` ; then DE=gnome;
    elif xprop -root _DT_SAVE_MODE 2> /dev/null | grep ' = \"xfce4\"$' >/dev/null 2>&1; then DE=xfce;
    elif [ x"$DESKTOP_SESSION" = x"LXDE" ]; then DE=lxde;
    else DE=""
    fi
}

post_upgrade() {
	# nvidia legacy changes (may 2018)
	pacman -Qq nvidia-utils &> /tmp/cmd1
	pacman -Qq mhwd-nvidia-390xx &> /tmp/cmd2
	if [ "$(grep 'nvidia-utils' /tmp/cmd1)" == "nvidia-utils" ]; then
		if [ "$(grep 'mhwd-nvidia-390xx' /tmp/cmd2)" != "mhwd-nvidia-390xx" ]; then
			msg "Updating mhwd database"
			rm /var/lib/pacman/db.lck &> /dev/null
			pacman --noconfirm -S mhwd-db
		fi
		mhwd | grep " video-nvidia " &> /tmp/cmd3
		mhwd-gpu | grep nvidia &> /tmp/cmd4
		pacman -Qq | grep nvidia | grep -v mhwd | grep -v toolkit &> /tmp/cmd5
		if [[ -z "$(cat /tmp/cmd3)" && -n "$(cat /tmp/cmd4)" ]]; then
			msg "Maintaining video driver at version nvidia-390xx"
			rm /var/lib/pacman/db.lck &> /dev/null
			pacman --noconfirm -Rdd $(cat /tmp/cmd5)
			pacman --noconfirm -S $(cat /tmp/cmd5 | sed 's|nvidia|nvidia-390xx|g')
			rm -r /var/lib/mhwd/local/pci/video-nvidia/
			cp -a /var/lib/mhwd/db/pci/graphic_drivers/nvidia-390xx/ /var/lib/mhwd/local/pci/
		fi
	fi

	# Fix config issue in sddm.conf
	if [ "$(vercmp $2 20180513)" -eq 0 ] && \
		[ -e "/etc/sddm.conf" ]; then
		msg "Fix default path config issue in sddm.conf ..."
		cp /etc/sddm.conf /etc/sddm.conf.pacsave
		sed -i -e 's|^.*DefaultPath.*|DefaultPath=/usr/local/sbin:/usr/local/bin:/usr/bin|' /etc/sddm.conf
	fi

	# Fix js52 upgrading
	pacman -Q js52 &> /tmp/cmd1
	if [ "$(vercmp $(grep 'js52' /tmp/cmd1 | cut -d' ' -f2) 52.7.3-1)" -le 0 ]; then
		if [ -e "/usr/lib/libmozjs-52.so.0" ]; then
			msg "Fix js52 upgrade ..."
			rm -f /usr/lib/libmozjs-52.so.0
			rm /var/lib/pacman/db.lck &> /dev/null
			pacman --noconfirm -S js52
		fi
	fi

	# Fix Firefox upgrading
	pacman -Q firefox &> /tmp/cmd1
	if [ "$(vercmp $(grep 'firefox' /tmp/cmd1 | cut -d' ' -f2) 59.0.1-0)" -le 0 ]; then
		if [ -e "/usr/lib/firefox/distribution/distribution.ini" ]; then
			msg "Fix firefox upgrade ..."
			rm -f /usr/lib/firefox/distribution/distribution.ini
		fi
	fi

	# Fix upgrading sddm version is 0.17.0-4 or less
	pacman -Q sddm &> /tmp/cmd1
	if [ "$(grep 'sddm' /tmp/cmd1 | cut -d' ' -f1)" == "sddm" ]; then 
		if [ "$(vercmp $(grep 'sddm' /tmp/cmd1 | cut -d' ' -f2) 0.17.0-4)" -le 0 ]; then
			msg "Fix sddm upgrade ..."
			rm /var/lib/pacman/db.lck &> /dev/null
			if [ -e "/etc/sddm.conf" ]; then
				mv /etc/sddm.conf /etc/sddm.backup
			fi
			pacman --noconfirm -S sddm
			if [ -e "/etc/sddm.conf" ]; then
				mv /etc/sddm.conf /etc/sddm.conf.pacnew
			fi
			if [ -e "/etc/sddm.backup" ]; then
				mv /etc/sddm.backup /etc/sddm.conf
			fi
		fi
	fi

	# fix upgrading ca-certificates-utils when version is 20160507-1 or less
	pacman -Q ca-certificates-utils &> /tmp/cmd1
	if [ "$(grep 'ca-certificates-utils' /tmp/cmd1 | cut -d' ' -f1)" == "ca-certificates-utils" ]; then 
		if [ "$(vercmp $(grep 'ca-certificates-utils' /tmp/cmd1 | cut -d' ' -f2) 20160507-1)" -le 0 ]; then
			msg "Fix ca-certificates-utils upgrade ..."
			rm /var/lib/pacman/db.lck &> /dev/null
			pacman --noconfirm -Syw ca-certificates-utils
			rm /etc/ssl/certs/ca-certificates.crt &> /dev/null
			pacman --noconfirm -S ca-certificates-utils
		fi
	fi

	# fix issue with xorg-server
	if [ -L "/usr/lib/xorg/modules/extensions/libglx.xorg" ]; then
		msg "Removing depreciated libglx.so symlink ..."
		rm /usr/lib/xorg/modules/extensions/libglx.so &> /dev/null
	fi

	# fix upgrading mesa when version is 17.0.1-1 or less
	pacman -Q mesa &> /tmp/cmd1
	pacman -Q lib32-mesa &> /tmp/cmd2
	if [ "$(vercmp $(grep 'mesa' /tmp/cmd1 | cut -d' ' -f2) 17.0.1-1)" -le 0 ]; then
		PKG_LIST="mhwd mesa libglvnd"
		if [ "$(grep 'lib32-mesa' /tmp/cmd2 | cut -d' ' -f1)" == "lib32-mesa" ]; then
			if [ "$(vercmp $(grep 'lib32-mesa' /tmp/cmd2 | cut -d' ' -f2) 17.0.1-1)" -le 0 ]; then
				PKG_LIST="${PKG_LIST} lib32-mesa lib32-libglvnd"
			fi
		fi
		msg "Fix mesa-stack ..."
		rm /var/lib/pacman/db.lck &> /dev/null
		pacman --noconfirm -S $PKG_LIST --force
	fi

	# avoid upgrading problems when lib32-libnm-glib46 is installed and lib32-libnm-glib is not, and we want to install lib32-libnm-glib.
	# ldconfig creates varous symlink in /usr/lib32/ from the lib32-libnm-glib46 packages but lib32-libnm-glib provides those files.
	pacman -Q lib32-libnm-glib &> /tmp/cmd1
	pacman -Q lib32-libnm-glib46 &> /tmp/cmd2
	if [ "$(grep 'lib32-libnm-glib' /tmp/cmd1 | cut -d' ' -f1)" != "lib32-libnm-glib" ]; then
		if [ "$(grep 'lib32-libnm-glib46' /tmp/cmd2 | cut -d' ' -f1)" == "lib32-libnm-glib46" ]; then
			rm /var/lib/pacman/db.lck &> /dev/null
			pacman --noconfirm --force -S lib32-libnm-glib
		fi
	fi

	# avoid upgrading problems when lib32-libcurl-{gnutls,compat} is installed and lib32-curl is not, and we want to install lib32-curl.
	# ldconfig creates /usr/lib32/libcurl.so.4 from the lib32-libcurl-{gnutls,compat} packages but lib32-curl provides that file.
	pacman -Q lib32-curl &> /tmp/cmd1
	pacman -Q lib32-libcurl-gnutls &> /tmp/cmd2
	pacman -Q lib32-libcurl-compat &> /tmp/cmd3
	if [ "$(grep 'lib32-curl' /tmp/cmd1 | cut -d' ' -f1)" != "lib32-curl" ]; then
		if [ "$(grep 'lib32-libcurl-gnutls' /tmp/cmd2 | cut -d' ' -f1)" == "lib32-libcurl-gnutls" ]; then
			if [ "$(vercmp $(grep 'lib32-libcurl-gnutls' /tmp/cmd2 | cut -d' ' -f2) 7.52.1-1)" -le 0 ]; then
				rm /var/lib/pacman/db.lck &> /dev/null
				pacman --noconfirm --force -S lib32-curl
			fi
		fi
		if [ "$(grep 'lib32-libcurl-compat' /tmp/cmd3 | cut -d' ' -f1)" == "lib32-libcurl-compat" ]; then 
			if [ "$(vercmp $(grep 'lib32-libcurl-compat' /tmp/cmd3 | cut -d' ' -f2) 7.52.1-1)" -le 0 ]; then
				rm /var/lib/pacman/db.lck &> /dev/null
				pacman --noconfirm --force -S lib32-curl
			fi
		fi
	fi

	# fix upgrading ttf-dejavu when version is 2.35-1 or less
	pacman -Q ttf-dejavu &> /tmp/cmd1
	if [ "$(grep 'ttf-dejavu' /tmp/cmd1 | cut -d' ' -f1)" == "ttf-dejavu" ]; then 
		if [ "$(vercmp $(grep 'ttf-dejavu' /tmp/cmd1 | cut -d' ' -f2) 2.35-1)" -le 0 ]; then
			msg "Fix ttf-dejavu upgrade ..."
			rm /var/lib/pacman/db.lck &> /dev/null
			pacman --noconfirm --force -S ttf-dejavu
		fi
	fi
	
	# fix xfprogs version
	export LANG=C
	pacman -Qi xfsprogs | grep Version | grep 1:3 &> /tmp/cmd1
	if [[ -n $(cat /tmp/cmd1) ]]; then
		rm /var/lib/pacman/db.lck &> /dev/null
		pacman --noconfirm -S xfsprogs
	fi

        # stop gdm attempting to use wayland
        if [ "$(vercmp $2 20151019-2)" -lt 0 ]; then
		pacman -Qq gdm &> /tmp/cmd1
		if [[ "$(grep 'gdm' /tmp/cmd1)" == "gdm" ]]; then
			msg "Stop GDM attempting to use Wayland ..."
			sed -i -e 's/#WaylandEnable=false/WaylandEnable=false/' /etc/gdm/custom.conf
		fi
	fi

        # fix the dbus-openrc upgrade and pull in netifrc
        pacman -Qq dbus-openrc &> /tmp/cmd_dbus_rc
	if [ "$(vercmp $2 20150611)" -eq 0 ] && \
		[ "$(grep 'dbus-openrc' /tmp/cmd_dbus_rc)" == "dbus-openrc" ];then
		msg "Upgrading 'dbus-openrc' ..."
		rm /var/lib/pacman/db.lck &> /dev/null
		pacman --noconfirm -Rdd dbus
		pacman --noconfirm -Syu dbus-openrc netifrc
	fi

        # fix the openrc upgrade and pull in netifrc
	pacman -Qq openrc-core &> /tmp/cmd_netifrc
	if [ "$(vercmp $2 0.18)" -gt 0 ] && \
		[ "$(grep 'openrc-core' /tmp/cmd_netifrc)" == "openrc-core" ];then
		msg "Installing additional 'openrc' package ..."
		rm /var/lib/pacman/db.lck &> /dev/null
		pacman --noconfirm -Syu netifrc
	fi

	# fix oberon's signature
	if [ "$(vercmp $2 20150814-1)" -lt 0 ]; then
		# running dirmngr helps prevent pacman-key from failing to connect to servers
		dirmngr </dev/null
		msg "Get oberon's signature ..."
		pacman-key -r 663CA268
		pacman-key --lsign-key 663CA268
	fi

	# fix the eudev/eudev-systemdcompat upgrade with libgudev split from systemd
	pacman -Qq eudev-systemdcompat &> /tmp/cmd1
	if [ "$(vercmp $2 211-1)" -lt 0 ] && \
		[ "$(grep 'eudev-systemdcompat' /tmp/cmd1)" == "eudev-systemdcompat" ];then
		msg "Fixing eudev/eudev-systemdcompat upgrade ..."
		rm /var/lib/pacman/db.lck &> /dev/null
		pacman --noconfirm -S libgudev
	fi

	# add missing xdg-user-dirs
	pacman -Qq xdg-user-dirs &> /tmp/cmd1
	if [ "$(vercmp $2 20150615-1)" -lt 0 ]; then
		if [[ "$(grep 'xdg-user-dirs' /tmp/cmd1)" != "xdg-user-dirs" ]]; then
			msg "Installing xdg-user-dirs ..."
			rm /var/lib/pacman/db.lck &> /dev/null
			pacman --noconfirm -S xdg-user-dirs
		fi
	fi

	# lxsession replacement
	pacman -Qq xfce4-session &> /tmp/cmd1
	pacman -Qq lxsession &> /tmp/cmd2
	pacman -Qq lxde-common &> /tmp/cmd3
	pacman -Qq openbox &> /tmp/cmd4
	if [[ "$(grep 'xfce4-session' /tmp/cmd1)" == "xfce4-session" && "$(grep 'lxsession' /tmp/cmd2)" == "lxsession" ]]; then
		if [[ "$(grep 'lxde-common' /tmp/cmd3)" == "lxde-common" ]]; then
			msg "Warning: You're running LXDE and XFCE. Please fix polkit-client issues on your own."
		elif [[ "$(grep 'openbox' /tmp/cmd4)" == "openbox" ]]; then
			msg "Warning: You're running Openbox and XFCE. Please fix polkit-client issues on your own."
		else
			msg "Removing lxsession ..."
			rm /var/lib/pacman/db.lck &> /dev/null
			pacman --noconfirm -Rdd lxsession
		fi
	fi

	# ligthdm-gtk3-greeter replacement
	pacman -Qq lightdm-gtk3-greeter &> /tmp/cmd1
	if [[ "$(grep 'lightdm-gtk3-greeter' /tmp/cmd1)" == "lightdm-gtk3-greeter" ]]; then
		msg "Replacing lightdm-gtk3-greeter with lightdm-gtk-greeter ..."
		rm /var/lib/pacman/db.lck &> /dev/null
		pacman --noconfirm -Rdd lightdm-gtk3-greeter
		pacman --noconfirm -S lightdm-gtk-greeter
		rm /etc/lightdm/lightdm-gtk-greeter.conf
		cp /etc/lightdm/lightdm-gtk-greeter.conf.pacsave /etc/lightdm/lightdm-gtk-greeter.conf
	fi


	# dropbox returns to normal
	pacman -Qq dropbox3 &> /tmp/cmd1
	pacman -Qq dropbox2 &> /tmp/cmd2
	if [ "$(grep 'dropbox3' /tmp/cmd1)" == "dropbox3" ]; then
		msg "Replacing dropbox3 with dropbox ..."
		rm /var/lib/pacman/db.lck &> /dev/null
		pacman --noconfirm -Rdd dropbox3
		pacman --noconfirm -S dropbox
	fi
	if [ "$(grep 'dropbox2' /tmp/cmd2)" == "dropbox2" ]; then
		msg "Replacing dropbox2 with dropbox ..."
		rm /var/lib/pacman/db.lck &> /dev/null
		pacman --noconfirm -Rdd dropbox2
		pacman --noconfirm -S dropbox
	fi

	# update rob's signature
	if [ "$(vercmp $2 20150204-1)" -lt 0 ]; then
		msg "Update Rob's signature ..."
		# running dirmngr helps prevent pacman-key from failing to connect to servers
		dirmngr </dev/null
		pacman-key --refresh-keys 5C0102A6
	fi

	# recreate pacman gnupg master key
	if [ "$(vercmp $2 20141210-1)" -lt 0 ]; then
		pacman -Qq haveged &> /tmp/cmd1
		if [ "$(grep 'haveged' /tmp/cmd1)" != "haveged" ]; then
			msg "Installing haveged"
			rm /var/lib/pacman/db.lck &> /dev/null
			if [[ -d /run/systemd ]];then
				pacman --noconfirm -S haveged
			else
				pacman --noconfirm -S haveged-openrc
			fi
		fi
		msg "Recreate pacman gnupg master key ..."
		if [[ -d /run/systemd ]];then
			systemctl start haveged
		else
			rc-service haveged start
		fi
		rm -fr /etc/pacman.d/gnupg
		pacman-key --init
		pacman -Ss fontconfig-infinality-ultimate | grep bundle &> /tmp/cmd2
		if [[ -n "$(cat /tmp/cmd2)" ]]; then
			msg "Signing infinality keys"
			pacman-key -r 962DDE58
			pacman-key --lsign-key 962DDE58
		fi
		msg "Populate Archlinux and Manjaro gnupg keys ..."
		pacman-key --populate archlinux manjaro
	fi

	# get artoo's new signature
	if [ "$(vercmp $2 20141206-1)" -lt 0 ]; then
		msg "Get new artoo's signature ..."
		pacman-key -r B35859F8
		pacman-key --lsign-key B35859F8
	fi

	# fix cups service name for cups 2.0
	if [ "$(vercmp $2 20141120-1)" -lt 0 ]; then
		if [ -h "/etc/systemd/system/multi-user.target.wants/cups.service" ]; then
			msg "Updating CUPS service name ..."
			rm /etc/systemd/system/multi-user.target.wants/cups.service
			ln -sf /usr/lib/systemd/system/org.cups.cupsd.service /etc/systemd/system/multi-user.target.wants/org.cups.cupsd.service
		fi
	fi

	# fix artoo's signature
	if [ "$(vercmp $2 20141014-1)" -lt 0 ]; then
		msg "Get artoo's signature ..."
		pacman-key -r 5DCB998E
		pacman-key --lsign-key 5DCB998E
	fi

	# fix java-runtime-common replaces java-common (https://www.archlinux.org/news/java-users-manual-intervention-required-before-upgrade/)
	if [ "$(vercmp $2 20141013-1)" -lt 0 ]; then
		pacman -Qq java-common &> /tmp/cmd1
		if [ "$(grep 'java-common' /tmp/cmd1)" == "java-common" ]; then
			msg "Replacing java-common with java-runtime-common ..."
			rm /var/lib/pacman/db.lck &> /dev/null
			archlinux-java unset
			pacman --noconfirm -Rdd java-common
			pacman --noconfirm -Sdd --asdeps java-runtime-common
			archlinux-java fix
		fi
	fi

	# fix kirek's signature
	if [ "$(vercmp $2 20141002-1)" -lt 0 ]; then
		msg "Get kirek's signature ..."
		pacman-key -r AC97B894
		pacman-key --lsign-key AC97B894
	fi

	# nvidia legacy changes (sept-oct 2014 - kernels 3.10-3.17)
	pacman -Qq nvidia-utils &> /tmp/cmd1
	pacman -Qq mhwd-nvidia-340xx &> /tmp/cmd2
	if [ "$(grep 'nvidia-utils' /tmp/cmd1)" == "nvidia-utils" ]; then
		if [ "$(grep 'mhwd-nvidia-340xx' /tmp/cmd2)" != "mhwd-nvidia-340xx" ]; then
			msg "Updating mhwd database"
			rm /var/lib/pacman/db.lck &> /dev/null
			pacman --noconfirm -S mhwd-db
		fi
		mhwd | grep " video-nvidia " &> /tmp/cmd3
		mhwd-gpu | grep nvidia &> /tmp/cmd4
		pacman -Qq | grep nvidia | grep -v mhwd | grep -v toolkit &> /tmp/cmd5
		if [[ -z "$(cat /tmp/cmd3)" && -n "$(cat /tmp/cmd4)" ]]; then
			msg "Maintaining video driver at version nvidia-340xx"
			rm /var/lib/pacman/db.lck &> /dev/null
			pacman --noconfirm -Rdd $(cat /tmp/cmd5)
			pacman --noconfirm -S $(cat /tmp/cmd5 | sed 's|nvidia|nvidia-340xx|g')
			rm -r /var/lib/mhwd/local/pci/video-nvidia/
			cp -a /var/lib/mhwd/db/pci/graphic_drivers/nvidia-340xx/ /var/lib/mhwd/local/pci/
		fi
	fi

	# fix ayceman's signature
	if [ "$(vercmp $2 20140918-1)" -lt 0 ]; then
		msg "Get ayceman's signature ..."
		pacman-key -r 604F8BA2
		pacman-key --lsign-key 604F8BA2
		sed -i -e s'|^.*SyncFirst.*|SyncFirst   = manjaro-system|g' /etc/pacman.conf
	fi

	# fix kwallet
	pacman -Qq kdeutils-kwallet &> /tmp/cmd1
	if [ "$(grep 'kdeutils-kwallet' /tmp/cmd1)" == "kdeutils-kwallet" ]; then
		msg "Replacing kdeutils-kwallet with kdeutils-kwalletmanager ..."
		rm /var/lib/pacman/db.lck &> /dev/null
		pacman --noconfirm -Rdd kdeutils-kwallet
		pacman --noconfirm -S kdeutils-kwalletmanager
	fi


	# fix twisted
	pacman -Qq twisted &> /tmp/cmd1
	pacman -Q twisted &> /tmp/cmd2
	if [ "$(grep 'twisted' /tmp/cmd1)" == "twisted" ]; then
		if [ "$(cat /tmp/cmd2 | cut -d" " -f2 | sed -e 's/\.//g' | sed -e 's/\-//g')" -lt "14001" ]; then
			msg "Fix twisted ..."
			rm /var/lib/pacman/db.lck &> /dev/null
			rm -f /usr/lib/python2.7/site-packages/twisted/plugins/dropin.cache
			pacman --noconfirm -S python2-twisted
		fi
	fi

	# fix terminus-font
	pacman -Qq terminus-font &> /tmp/cmd1
	pacman -Q terminus-font &> /tmp/cmd2
	if [ "$(grep 'terminus-font' /tmp/cmd1)" == "terminus-font" ]; then
		if [ "$(cat /tmp/cmd2 | cut -d" " -f2 | sed -e 's/\.//g' | sed -e 's/\-//g')" -lt "4385" ]; then
			msg "Fix terminus-font ..."
			rm /var/lib/pacman/db.lck &> /dev/null
			rm /etc/fonts/conf.d/75-yes-terminus.conf &> /dev/null
			pacman --noconfirm -S terminus-font
		fi
	fi

	# fix btrfs-progs
	pacman -Qq btrfs-progs &> /tmp/cmd1
	pacman -Q btrfs-progs &> /tmp/cmd2
	if [ "$(vercmp $2 20140414-1)" -lt 0 ] && \
		[ "$(grep 'btrfs-progs' /tmp/cmd1)" == "btrfs-progs" ]; then
		if [ "$(cat /tmp/cmd2 | cut -d" " -f2 | sed -e 's/\.//g' | sed -e 's/\-//g')" -lt "3141" ]; then
			msg "Fix btrfs-progs ..."
			rm /var/lib/pacman/db.lck &> /dev/null
			rm /usr/bin/fsck.btrfs &> /dev/null
			pacman --noconfirm -S btrfs-progs
		fi
	fi

	# fix python-configobj downgrade
	pacman -Qq python-configobj &> /tmp/cmd1
	if [ "$(vercmp $2 20140407-1)" -lt 0 ]; then
		if [ "$(grep 'python-configobj' /tmp/cmd1)" == "python-configobj" ]; then
			msg "Fix python-configobj ..."
			rm /var/lib/pacman/db.lck &> /dev/null
			pacman --noconfirm -S python-configobj
		fi
	fi

	# fix freeimage
	pacman -Qq freeimage &> /tmp/cmd1
	pacman -Q freeimage &> /tmp/cmd2
	if [ "$(grep 'freeimage' /tmp/cmd1)" == "freeimage" ]; then
		if [ "$(cat /tmp/cmd2 | cut -d" " -f2 | sed -e 's/\.//g' | sed -e 's/\-//g')" -lt "31602" ]; then
			msg "Fix freeimage ..."
			rm /var/lib/pacman/db.lck &> /dev/null
			rm /usr/lib/libfreeimageplus.so.3
			pacman --noconfirm -S freeimage
		fi
	fi

	# xorg downgrade
	if [ "$(vercmp $2 20140221-1)" -lt 0 ]; then
		msg "Prepare for Xorg-Server downgrade ..."
		rm /var/lib/pacman/db.lck &> /dev/null
		pacman --noconfirm --force -Suu
	        # check for xorg-server
	        pacman -Qq xorg-server &> /tmp/cmd1
		if [ "$(grep 'xorg-server' /tmp/cmd1)" != "xorg-server" ]; then
			msg "Installing missing Xorg-Server ..."
			pacman --noconfirm -S xorg-server
		fi
	fi

	# fix korrode's signature
	if [ "$(vercmp $2 20140212-1)" -lt 0 ]; then
		msg "Get korrode's signature ..."
		pacman-key -r 5C0102A6
		pacman-key --lsign-key 5C0102A6
	fi

	# remove pyc-files if python-dbus < 1.2.0-2
	pacman -Qq python-dbus &> /tmp/cmd1
	pacman -Q python-dbus &> /tmp/cmd2
	if [ "$(grep 'python-dbus' /tmp/cmd1)" == "python-dbus" ]; then
	   if [ "$(cat /tmp/cmd2 | cut -d" " -f2 | sed -e 's/\.//g' | sed -e 's/\-//g')" -lt "1202" ]; then
		msg "Prepare python-dbus update ..."
		# System operation
		rm -f /usr/lib/python3.3/site-packages/dbus/__pycache__/__init__.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/dbus/__pycache__/_compat.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/dbus/__pycache__/_dbus.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/dbus/__pycache__/_expat_introspect_parser.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/dbus/__pycache__/_version.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/dbus/__pycache__/bus.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/dbus/__pycache__/connection.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/dbus/__pycache__/decorators.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/dbus/__pycache__/exceptions.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/dbus/__pycache__/gi_service.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/dbus/__pycache__/glib.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/dbus/__pycache__/lowlevel.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/dbus/__pycache__/proxies.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/dbus/__pycache__/server.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/dbus/__pycache__/service.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/dbus/__pycache__/types.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/dbus/mainloop/__pycache__/__init__.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/dbus/mainloop/__pycache__/glib.cpython-33.pyc
		rm /var/lib/pacman/db.lck &> /dev/null
		pacman --noconfirm --force -Sdd python-dbus &> /dev/null
	   fi
	fi

	# fix mdm-themes on systems
	pacman -Qq mdm-themes &> /tmp/cmd1
	packages="mdm-themes-extra"
	if [ "$(vercmp $2 20131206-1)" -lt 0 ] && [ "$(grep 'mdm-themes' /tmp/cmd1)" == "mdm-themes" ]; then
		msg "Fixing mdm-themes issue ..."
		rm /var/lib/pacman/db.lck &> /dev/null
		pacman --noconfirm -S ${packages} &> /dev/null
	fi

	# remove pyc-files if python-gobject < 3.10.1
	pacman -Qq python-gobject &> /tmp/cmd1
	pacman -Q python-gobject &> /tmp/cmd2
	if [ "$(grep 'python-gobject' /tmp/cmd1)" == "python-gobject" ]; then
	   if [ "$(cat /tmp/cmd2 | cut -d- -f2 | cut -d" " -f2 | sed -e 's/\.//g')" -lt "3101" ]; then
		msg "Fixing python-gobject ..."
		# System operation
		rm -f /usr/lib/python3.3/site-packages/gi/__pycache__/__init__.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/__pycache__/__init__.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/gi/__pycache__/docstring.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/__pycache__/docstring.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/gi/__pycache__/importer.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/__pycache__/importer.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/gi/__pycache__/module.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/__pycache__/module.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/gi/__pycache__/pygtkcompat.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/__pycache__/pygtkcompat.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/gi/__pycache__/types.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/__pycache__/types.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/gi/_glib/__pycache__/__init__.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/_glib/__pycache__/__init__.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/gi/_glib/__pycache__/option.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/_glib/__pycache__/option.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/gi/_gobject/__pycache__/__init__.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/_gobject/__pycache__/__init__.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/gi/_gobject/__pycache__/constants.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/_gobject/__pycache__/constants.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/gi/_gobject/__pycache__/propertyhelper.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/_gobject/__pycache__/propertyhelper.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/gi/_gobject/__pycache__/signalhelper.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/_gobject/__pycache__/signalhelper.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/gi/overrides/__pycache__/GIMarshallingTests.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/overrides/__pycache__/GIMarshallingTests.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/gi/overrides/__pycache__/GLib.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/overrides/__pycache__/GLib.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/gi/overrides/__pycache__/GObject.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/overrides/__pycache__/GObject.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/gi/overrides/__pycache__/Gdk.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/overrides/__pycache__/Gdk.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/gi/overrides/__pycache__/Gio.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/overrides/__pycache__/Gio.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/gi/overrides/__pycache__/Gtk.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/overrides/__pycache__/Gtk.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/gi/overrides/__pycache__/Pango.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/overrides/__pycache__/Pango.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/gi/overrides/__pycache__/__init__.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/overrides/__pycache__/__init__.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/gi/overrides/__pycache__/keysyms.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/overrides/__pycache__/keysyms.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/gi/repository/__pycache__/__init__.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/gi/repository/__pycache__/__init__.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/pygtkcompat/__pycache__/__init__.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/pygtkcompat/__pycache__/__init__.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/pygtkcompat/__pycache__/generictreemodel.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/pygtkcompat/__pycache__/generictreemodel.cpython-33.pyo
		rm -f /usr/lib/python3.3/site-packages/pygtkcompat/__pycache__/pygtkcompat.cpython-33.pyc
		rm -f /usr/lib/python3.3/site-packages/pygtkcompat/__pycache__/pygtkcompat.cpython-33.pyo
		rm /var/lib/pacman/db.lck &> /dev/null
		pacman --noconfirm --force -Sdd python-gobject &> /dev/null
	   fi
	fi

	# depreciate sysctl.conf
	if [ "$(vercmp $2 20130921-1)" -lt 0 ] && [ -f /etc/sysctl.conf ]; then
		msg "Depreciate sysctl.conf ..."
		if [ -f /etc/sysctl.d/99-sysctl.conf ]; then
			mv /etc/sysctl.d/99-sysctl.conf /etc/sysctl.d/99-sysctl.conf.pacsave
		fi
		mv /etc/sysctl.conf /etc/sysctl.d/99-sysctl.conf
	fi

	# fix pamac on systems without Gnome session
        detectDE
	pacman -Qq pamac &> /tmp/cmd1
	packages="lxpolkit"
	if [ "$(vercmp $2 20130905-1)" -lt 0 ] && [ "$DE" != "gnome" ] && [ "$(grep 'pamac' /tmp/cmd1)" == "pamac" ]; then
		msg "Fixing polkit issue in pamac ..."
		rm /var/lib/pacman/db.lck &> /dev/null
		pacman --noconfirm -S ${packages} &> /dev/null
	fi

	# depreciate linux39
	pacman -Qq linux39 &> /tmp/cmd1
	pacman -Qq linux310 &> /tmp/cmd2
	packages=$(pacman -Qqs linux39 | sed s'|linux39|linux310|'g)
	if [ "$(vercmp $2 20130829-1)" -lt 0 ] && [ "$(grep 'linux39' /tmp/cmd1)" == "linux39" ]; then
		msg "Depreciating linux39 ..."
		rm /var/lib/pacman/db.lck &> /dev/null
		pacman --noconfirm -Rscn linux39 &> /dev/null
		if [ "$(grep 'linux310' /tmp/cmd2)" == "linux310" ]; then
			msg "linux310 found, skipping installation ..."
		else
			msg "Installing linux310 ..."
			pacman --noconfirm -S ${packages} &> /dev/null
		fi
	fi

	# workaround to install octopi 0.2.0
	pacman -Qq octopi &> /tmp/cmd1
	pacman -Q octopi &> /tmp/cmd2
	packages="octopi octopi-notifier"
	if [ "$(vercmp $2 20130824-1)" -lt 0 ] && [ "$(grep 'octopi' /tmp/cmd1)" == "octopi" ]; then
	   if [ "$(cat /tmp/cmd2 | cut -d- -f1 | cut -d"." -f4)" -lt "0825" ]; then
		msg "Updating octopi ..."
		rm /var/lib/pacman/db.lck &> /dev/null
		check_pkgs
		pacman --noconfirm -S ${packages} &> /dev/null
	   fi
	fi

	# workaround for bug: http://bugs.manjaro.org/index.php?do=details&task_id=124
	pacman -Qq bluez4 &> /tmp/cmd1
	pacman -Qq bluez &> /tmp/cmd2
	pacman -Q bluez &> /tmp/cmd3
	if [ "$(vercmp $2 20130820-4)" -lt 0 ] && [ "$(grep 'bluez4' /tmp/cmd1)" != "bluez4" ] && [ "$(grep 'bluez' /tmp/cmd2)" == "bluez" ]; then
	   if [ "$(cat /tmp/cmd3 | cut -d. -f1 | cut -d" " -f2)" -lt "5" ]; then
		msg "Fixing bluez ..."
		rm /var/lib/pacman/db.lck &> /dev/null
		pacman --noconfirm -Rdd bluez &> /dev/null
		pacman --noconfirm -S bluez4 bluez-libs &> /dev/null
	   fi
	fi

	# Update filesystem to /usr/bin
	if [ "$(vercmp $2 20130606-1)" -lt 0 ] && [ ! -L "/bin" ] && [ ! -L "/sbin" ] && [ ! -L "/usr/sbin" ]; then
		msg "Binaries move to /usr/bin ..."
		msg "Please be patient."
		local files="$(find /bin/ /sbin/ /usr/sbin/ | tr "\n" " ")"

		# List unowned files
		for file in $files
		do
			local filename="${file##*/}"
			if [ "${filename}" == "" ]; then continue; fi

			pacman -Qo "${file}" &>/dev/null
			if [ $? -ne 0 ]; then msg "Moving unowned file '${file}' to '/usr/bin'"; fi
		done

		# Update database
		local pkgs="$(pacman -Qqo /bin /sbin /usr/sbin | sort -u | tr "\n" " ")"
		for pkg in ${pkgs}
		do
			if [ "${pkg}" == "filesystem" ]; then continue; fi
			local path="/var/lib/pacman/local/$(pacman -Q ${pkg} | sed 's/ /-/g')/files"
			if [ ! -f "${path}" ]; then continue; fi

			sed -i -e 's|^bin/|usr/bin/|' -e 's|^sbin/|usr/bin/|' -e 's|^usr/sbin/|usr/bin/|' -e 's|^bin$|usr/bin|' -e 's|^sbin$|usr/bin|' -e 's|^usr/sbin$|usr/bin|' "${path}"
		done

		# Move files
		for file in $files
		do
			local filename="${file##*/}"
			if [ "${filename}" == "" ]; then continue; fi

			# Check if file is a symlink
			if [ -L "${file}" ]; then
				local filelink="$(readlink "${file}")"

				# Check if destination file exists. Otherwise move the symlink.
				if [ -e "/usr/bin/${filename}" ]; then
					# Remove link
					unlink "${file}"
				elif [[ "${file}" =~ ^"/bin/".*|^"/sbin/".* ]] && [[ "${filelink}" =~ ^"../usr/bin/".* ]]; then
					# Move link to /usr/bin and update relative path
					filelink="$(echo "${filelink}" | sed 's|^\.\./usr/bin/||')"
					ln -s "${filelink}" "/usr/bin/${filename}"
					unlink "${file}"
				elif [[ "${file}" =~ ^"/bin/".*|^"/sbin/".* ]] && [[ "${filelink}" =~ ^"../".* ]]; then
					# Move link to /usr/bin and update relative path
					filelink="$(echo "${filelink}" | sed 's|^\.\./|\.\./\.\./|')"
					ln -s "${filelink}" "/usr/bin/${filename}"
					unlink "${file}"
				elif [[ "${file}" =~ ^"/usr/sbin/".* ]] && [[ "${filelink}" =~ ^"../bin/".* ]]; then
					# Move link to /usr/bin and update relative path
					filelink="$(echo "${filelink}" | sed 's|^\.\./bin/||')"
					ln -s "${filelink}" "/usr/bin/${filename}"
					unlink "${file}"
				else
					# Move link as it is
					ln -s "${filelink}" "/usr/bin/${filename}"
					unlink "${file}"
				fi
			else
				if [ -L "/usr/bin/${filename}" ]; then
					unlink "/usr/bin/${filename}"
					mv "${file}" "/usr/bin/"
				elif [ -e "/usr/bin/${filename}" ]; then
					err "'/usr/bin/${filename}' already exists! Moving file to '/usr/bin_duplicates/${filename}'"
					if [ ! -d "/usr/bin_duplicates" ]; then mkdir "/usr/bin_duplicates"; fi
					mv "${file}" "/usr/bin_duplicates/"
				else
					mv "${file}" "/usr/bin/"
				fi
			fi
		done

		# Fix /usr/bin/init symlink
		ln -sf "../lib/systemd/systemd" "/usr/bin/init"

		# filesystem should own /bin, /sbin and /usr/sbin
		local filesystem_path="/var/lib/pacman/local/$(pacman -Q filesystem | sed 's/ /-/g')/files"
		sed -i 's|^\%FILES\%|\%FILES\%\nbin\nsbin\nusr/sbin|' "${filesystem_path}"

		# Remove directories and create symlinks
		rm -fr /bin
		rm -fr /sbin
		rm -fr /usr/sbin
		ln -s usr/bin /bin
		ln -s usr/bin /sbin
		ln -s bin /usr/sbin

		msg "Now update your system."
	fi

	# Remove obsolete version file of manjaro-system
	if [ -f /var/lib/manjaro-system/version ]; then
		rm /var/lib/manjaro-system/version
	fi
}
