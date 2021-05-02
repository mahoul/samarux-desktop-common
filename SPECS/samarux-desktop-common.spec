Name:           samarux-desktop-common
Version:        0.1
Release:        14
Summary:        Common Samarux scripts and fixes
License:        GPL
Source: 	%{name}-%{version}.tar.gz
BuildRoot: 	%{_tmppath}/%{name}-%{version}-root
Packager: 	Enrique Gil (mahoul@gmail.com)
BuildArch:	noarch
BuildRequires:	rsync
Requires:	dconf-editor, exa, fira-code-fonts, guake, gnome-tweaks, google-chrome-stable, gvfs-nfs, gvfs-smb, htop, ImageMagick, mozilla-fira-sans-fonts, nemo, openssl, pavucontrol, python3-dnf-plugin-snapper, snapper, tmux, tmux-powerline, vim, vim-powerline, vim, vlc

%description
Common Samarux scripts and fixes.
Includes service for gettting BING POTD and firstboot script.

%prep
#[ -d %{name} ] && rm -Rfv %{name}
#[ -d %{_topdir}/SOURCES ] && rsync -avP --exclude '.git' --delete %{_topdir}/SOURCES/ .
%autosetup


%install
%{__install} -D -m644 etc/systemd/system/get-bing-potd.service		%{buildroot}/etc/systemd/system/get-bing-potd.service
%{__install} -D -m644 etc/systemd/system/get-bing-potd.timer		%{buildroot}/etc/systemd/system/get-bing-potd.timer
%{__install} -D -m644 etc/systemd/system/samarux-first-boot.service 	%{buildroot}/etc/systemd/system/samarux-first-boot.service
%{__install} -D -m755 usr/bin/get-bing-potd.sh	 	 		%{buildroot}/usr/bin/get-bing-potd.sh
%{__install} -D -m755 usr/bin/samarux-first-boot.sh	 	 	%{buildroot}/usr/bin/samarux-first-boot.sh
%{__install} -D -m644 etc/dconf/db/distro.d/00-samarux-terminal 	%{buildroot}/etc/dconf/db/distro.d/00-samarux-terminal
%{__install} -D -m644 etc/dconf/db/distro.d/00-samarux 			%{buildroot}/etc/dconf/db/distro.d/00-samarux
%{__install} -Dd -m755 etc/skel/.config/powerline			%{buildroot}/etc/skel/.config/powerline
%{__install} -Dd -m755 etc/skel/.vim					%{buildroot}/etc/skel/.vim
%{__install} -Dd -m644 etc/skel/.tmux.conf 				%{buildroot}/etc/skel/.tmux.conf
%{__install} -Dd -m644 etc/skel/.vimrc 					%{buildroot}/etc/skel/.vimrc


%post
systemctl enable get-bing-potd.timer
systemctl enable samarux-first-boot
[ -s /etc/dconf/db/distro ] && dconf update

%clean


%files
%defattr(-, root, root)
/etc/skel/.config/powerline
/etc/skel/.vim
/etc/skel/.tmux.conf
/etc/skel/.vimrc
/etc/systemd/system/get-bing-potd.service
/etc/systemd/system/get-bing-potd.timer  
/etc/systemd/system/samarux-first-boot.service
/etc/dconf/db/distro.d/00-samarux-terminal
/etc/dconf/db/distro.d/00-samarux
/usr/bin/get-bing-potd.sh
/usr/bin/samarux-first-boot.sh

%changelog
* Sun May 02 2021 Enrique Gil <mahoul@gmail.com> - 0.1-14
- Added powerline dependencies and default user config

* Sun May 02 2021 Enrique Gil <mahoul@gmail.com> - 0.1-13
- Added additional repo configuration on post

* Sun May 02 2021 Enrique Gil <mahoul@gmail.com> - 0.1-12
- Added fallback for get-bing-potd.sh

* Sun May 02 2021 Enrique Gil <mahoul@gmail.com> - 0.1-11
- Run only dconf update if distro DB exists

* Sun May 02 2021 Enrique Gil <mahoul@gmail.com> - 0.1-10
- Fixed 00-samarux dconf file

* Sun May 02 2021 Enrique Gil <mahoul@gmail.com> - 0.1-9
- Added exa as a pkg requirement

* Sun May 02 2021 Enrique Gil <mahoul@gmail.com> - 0.1-8
- Added required packages

* Sun May 02 2021 Enrique Gil <mahoul@gmail.com>
- Added required packages

* Sun May 02 2021 Enrique Gil <mahoul@gmail.com> - 0.1-6
- Added dconf update on post

* Sun May 02 2021 Enrique Gil <mahoul@gmail.com> - 0.1-5
- Added default theming for GNOME and terminal

* Sat May 01 2021 Enrique Gil <mahoul@gmail.com> - 0.1-4
- Increased release

* Sat May 01 2021 Enrique Gil <mahoul@gmail.com> - 0.1-3
- Increased released

* Sat May 01 2021 Enrique Gil <mahoul@gmail.com> - 0.1-2
- Increased released

* Sat May 01 2021 Enrique Gil (mahoul@gmail.com) - 0.1-1
- Initial release.

