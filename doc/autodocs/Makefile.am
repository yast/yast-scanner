# Makefile.am for scanner/doc/autodocs

htmldir = $(docdir)/autodocs

#index.html: $(srcdir)/../../src/*.ycp $(srcdir)/../../src/*.pm
#	$(ybindir)/ycpdoc -d. $(srcdir)/../../src/*.{ycp,pm}

index.html: $(srcdir)/../../src/*.ycp
	$(ybindir)/ycpdoc -d. $(srcdir)/../../src/*.ycp

html_DATA = index.html $(wildcard *.html)

CLEANFILES = $(html_DATA)
