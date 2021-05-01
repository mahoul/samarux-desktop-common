Name:           samarux-desktop-common
Version:        0.1
Release:        4
Summary:        Common Samarux scripts and fixes
License:        GPL
Source: 	%{name}-%{version}.tar.gz
BuildRoot: 	%{_tmppath}/%{name}-%{version}-root
Packager: 	Enrique Gil (mahoul@gmail.com)
BuildArch:	noarch
BuildRequires:	rsync

%description
Common Samarux scripts and fixes.
Includes service for gettting BING POTD and firstboot script.

%prep
#[ -d %{name} ] && rm -Rfv %{name}
#[ -d %{_topdir}/SOURCES ] && rsync -avP --exclude '.git' --delete %{_topdir}/SOURCES/ .
%autosetup


%install
%{__install} -D -m644 etc/systemd/system/get-bing-potd.service	%{buildroot}/etc/systemd/system/get-bing-potd.service
%{__install} -D -m644 etc/systemd/system/get-bing-potd.timer	%{buildroot}/etc/systemd/system/get-bing-potd.timer
%{__install} -D -m644 etc/systemd/system/samarux-first-boot.service 	%{buildroot}/etc/systemd/system/samarux-first-boot.service
%{__install} -D -m755 usr/bin/get-bing-potd.sh	 	 %{buildroot}/usr/bin/get-bing-potd.sh
%{__install} -D -m755 usr/bin/samarux-first-boot.sh	 	 %{buildroot}/usr/bin/samarux-first-boot.sh

%post
systemctl enable get-bing-potd.timer

%clean


%files
%defattr(-, root, root)
/etc/systemd/system/get-bing-potd.service
/etc/systemd/system/get-bing-potd.timer  
/etc/systemd/system/samarux-first-boot.service
/usr/bin/get-bing-potd.sh
/usr/bin/samarux-first-boot.sh

%changelog
* Sat May 01 2021 Enrique Gil <mahoul@gmail.com> - 0.1-4
- Increased release

* Sat May 01 2021 Enrique Gil <mahoul@gmail.com> - 0.1-3
- Increased released

* Sat May 01 2021 Enrique Gil <mahoul@gmail.com> - 0.1-2
- Increased released

* Sat May 01 2021 Enrique Gil (mahoul@gmail.com) - 0.1-1
- Initial release.

