Name: asterisk-func_dns
Obsoletes: asterisk14-func_dns
Version: 1.0.1
Release: 001
Summary: DNS lookup function for Asterisk
Group: Applications/System
License: GPLv2
Packager: Chase Venters <chase.venters@gmail.com>
Source0: asterisk-func_dns.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: asterisk
BuildRequires: asterisk-devel

%description
This third-party Asterisk addon provides the DNS() function which looks up
a host's IP address(es) and returns them as a comma-separated list.

%prep
%setup -q -n asterisk-func_dns

%install
rm -rf %{buildroot}
mkdir %{buildroot}
make
make install INSTALL_PREFIX=%{buildroot}

%clean
rm -rf %{buildroot}

%files
%{_libdir}/asterisk/modules/func_dns.so

