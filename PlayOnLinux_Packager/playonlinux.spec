Name: playonlinux
Version: 
Summary: PlayOnLinux is a front-end for wine. It permits you to install Windows Games and softwares on Linux.
License: see /usr/share/doc/playonlinux/copyright
BuildArch:noarch
Release: fedora0
Distribution: Fedora
Group: PlayOnLinux
URL:http://www.playonlinux.com/
VenDor:PlayOnLinux
Packager:MulX <os2mule@gmail.com>
Buildroot: /Users/Tinou/Documents/GIT/PlayOnLinux_Tools/playonlinux-
Requires:unzip, wine, wget, xterm, python > 2.4 ,wxPython, bash, ImageMagick, cabextract,  gettext

%define _rpmdir ../
%define _rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm
%define _unpackaged_files_terminate_build 0
%description
PlayOnLinux is able to install Windows
games on your Linux Distro.

%files
%defattr(-,root,root)
%dir "/"
%dir "/usr/"
/usr/*
