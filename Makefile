#
# Makefile, based on the Asterisk Makefile, Coypright (C) 1999, Mark Spencer
#
# Copyright (C) 2002,2003 Junghanns.NET GmbH
#
# Klaus-Peter Junghanns <kapejod@ns1.jnetdns.de>
#
# This program is free software and may be modified and
# distributed under the terms of the GNU Public License.
#

.EXPORT_ALL_VARIABLES:

#
# app_konference defines which can be passed on the command-line
#

INSTALL_PREFIX :=
INSTALL_MODULES_DIR := $(INSTALL_PREFIX)/usr/lib/asterisk/modules

ASTERISK_INCLUDE_DIR ?= ../asterisk/include

RELEASE = 1.4

#
# func_dns objects to build
#

OBJS = func_dns.o
TARGET = func_dns.so


#
# standard compile settings
#

PROC = $(shell uname -m)
INSTALL = install

INCLUDE = -I$(ASTERISK_INCLUDE_DIR)
DEBUG := -g

CFLAGS = -pipe -Wall -Wmissing-prototypes -Wmissing-declarations -MD -MP $(DEBUG)
CPPFLAGS = $(INCLUDE) -D_REENTRANT -D_GNU_SOURCE -DRELEASE=\"$(RELEASE)\"
#CFLAGS += -O2
#CFLAGS += -O3 -march=pentium3 -msse -mfpmath=sse,387 -ffast-math
# PERF: below is 10% faster than -O2 or -O3 alone.
#CFLAGS += -O3 -ffast-math -funroll-loops
# below is another 5% faster or so.
#CFLAGS += -O3 -ffast-math -funroll-all-loops -fsingle-precision-constant
#CFLAGS += -mcpu=7450 -faltivec -mabi=altivec -mdynamic-no-pic
# adding -msse -mfpmath=sse has little effect.
#CFLAGS += -O3 -msse -mfpmath=sse
#CFLAGS += $(shell if $(CC) -march=$(PROC) -S -o /dev/null -xc /dev/null >/dev/null 2>&1; then echo "-march=$(PROC)"; fi)
CFLAGS += $(shell if uname -m | grep -q ppc; then echo "-fsigned-char"; fi)
CFLAGS += -fPIC

OSARCH=$(shell uname -s)
ifeq (${OSARCH},Darwin)
SOLINK=-dynamic -bundle -undefined suppress -force_flat_namespace
else
SOLINK=-shared -Xlinker -x
endif

DEPS += $(subst .o,.d,$(OBJS))

#
# targets
#

all: $(TARGET)

.PHONY: clean
clean:
	$(RM) $(OBJS) $(DEPS)

.PHONY: distclean
distclean: clean
	$(RM) $(TARGET)

$(TARGET): $(OBJS)
	$(CC) -pg $(SOLINK) -o $@ $(OBJS)

install:
	mkdir -p $(INSTALL_MODULES_DIR)
	$(INSTALL) -m 755 $(TARGET) $(INSTALL_MODULES_DIR)


# config: all
# 	cp conf.conf /etc/asterisk/

-include $(DEPS)

.PHONY: dist
dist:
	rm -rf dist/ asterisk-func_dns.tar.gz
	mkdir -p dist/asterisk-func_dns
	cp Makefile dist/asterisk-func_dns
	cp func_dns.c dist/asterisk-func_dns
	(cd dist && tar czvf ../asterisk-func_dns.tar.gz asterisk-func_dns)

rpm: dist
	TOPDIR=`mktemp -d`; \
	for i in SPECS RPMS SRPMS BUILD SOURCES; do \
		mkdir $$TOPDIR/$$i; \
	done; \
	mv asterisk-func_dns.tar.gz $$TOPDIR/SOURCES; \
	rpmbuild -ba asterisk-func_dns.spec --define "_topdir $$TOPDIR" --define "release 1"; \
	mv $$TOPDIR/SRPMS/*.rpm $$TOPDIR/RPMS/*/*.rpm .; \
	rm -rf $$TOPDIR

