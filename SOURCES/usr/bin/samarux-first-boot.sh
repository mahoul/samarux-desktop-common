#!/bin/bash

die(){
	logger $1
	exit $2
}

get_root_sub_id(){
	btrfs sub show / | awk '/Subvolume ID/ {print $NF}'
}

get_default_sub_id(){
	btrfs sub get-default / | awk '{print $2}'
}

set_default_sub_id(){
	local vol_id=$1
	btrfs sub set-default $vol_id /
}

get_kernel_flags(){
	grubby --info=ALL
}

rootflags_in_kargs(){
	get_kernel_flags | grep -q 'args.*rootflags=subvol=root'
}

remove_rootflags_kargs(){
	grubby --update-kernel=ALL --remove-args="rootflags=subvol=root"
}

root_subvol_in_fstab(){
	grep -q "subvol=root" /etc/fstab
}

patch_root_subvol_fstab(){
	sed -i 's/subvol=root/defaults/g' /etc/fstab
}

sysconfig_snapper_configured(){
	grep -q 'SNAPPER_CONFIGS="root"' /etc/sysconfig/snapper
}

set_sysconfig_snapper(){
	sed -i 's/SNAPPER_CONFIG.*/SNAPPER_CONFIGS="root"/g' /etc/sysconfig/snapper
}

wayland_is_enabled(){
	grep -q '^#WaylandEnable=false' /etc/gdm/custom.conf
}

disable_wayland(){
	sed -i 's/^#WaylandEnable.*/WaylandEnable=false/g' /etc/gdm/custom.conf
}

rootfs_on_btrfs(){
	local root_dev=$(awk '/btrfs/ {if ($2 == "/") { print $1; }}' /etc/mtab)
	if [ -n "$root_dev" ]; then
		return 0
	else
		return 1
	fi
}

running_on_live(){
	grep -q "rd.live.image" /proc/cmdline
}

get_copr_repos(){
        dnf copr list
}

copr_repo_enabled(){
        local repo=$1
        get_copr_repos | grep -q $repo
}

enable_copr_repo(){
        local repo=$1
        dnf copr enable -y $repo
}

enable_flathub(){
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

COPR_REPOS="mahoul/samarux-desktop sbakker/perl"

SM_FLAG_FILE=/root/.samarux_first_boot

if running_on_live; then
	die "Running on live media system. Quitting." 0
fi

if [ ! -f $SM_FLAG_FILE ]; then
	export LC_ALL=C

	CURRENT_DEFAULT_ID=$(get_default_sub_id)
	ROOT_SUB_ID=$(get_root_sub_id)

	# Configure snapper if rootfs is on btrfs
	#
	if rootfs_on_btrfs; then
		if [ $CURRENT_DEFAULT_ID -ne $ROOT_SUB_ID ]; then
			set_default_sub_id $ROOT_SUB_ID
		fi

		if rootflags_in_kargs; then
			remove_rootflags_kargs
		fi

		if root_subvol_in_fstab; then
			patch_root_subvol_fstab
		fi

		if ! sysconfig_snapper_configured; then
			set_sysconfig_snapper
		fi

		if [ ! -s /etc/snapper/configs/root ]; then
			cp -f /etc/snapper/config-templates/default /etc/snapper/configs/root
		fi
	fi

	# Disable wayland on GDM
	#
	if wayland_is_enabled; then
		disable_wayland
	fi

	# Enable Flathub flatpak repository and addtional copr repositories
	#
	enable_flathub

	for repo in $COPR_REPOS; do
		enable_copr_repo $repo
	done

	touch $SM_FLAG_FILE
	sync
	systemctl reboot

fi

