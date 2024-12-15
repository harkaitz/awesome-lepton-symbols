.POSIX:
.SUFFIXES:
.PHONY: all clean install check

PROJECT   =eda-lepton-symbols
VERSION   =1.0.0
PREFIX    =/usr/local
BUILDDIR ?=.build
UNAME_S  ?=$(shell uname -s)
EXE      ?=$(shell uname -s | awk '/Windows/ || /MSYS/ || /CYG/ { print ".exe" }')

all:
clean:
install: install-symbols
check:

install-symbols:
	mkdir -p $(DESTDIR)$(PREFIX)/share/lepton-eda/sym-awesome
	mkdir -p $(DESTDIR)$(PREFIX)/share/doc/lepton-eda/awesome-symbols
	mkdir -p $(DESTDIR)$(PREFIX)/share/lepton-eda/scheme/autoload
	cp -r sym-awesome/* $(DESTDIR)$(PREFIX)/share/lepton-eda/sym-awesome
	cp scm/config-awesome-symbol-library.scm $(DESTDIR)$(PREFIX)/share/lepton-eda/scheme/autoload
	cp lic/*.txt $(DESTDIR)$(PREFIX)/share/doc/lepton-eda/awesome-symbols
