#
# Makefile.am for scanner/src
#

#YCPCFLAGS = -I.

yncludedir = @yncludedir@/scanner

client_DATA =			\
	scanner.ycp		\
	scanner_auto.ycp	\
	scanner_proposal.ycp

ynclude_DATA =			\
	scanner_overview.ycp	\
	scanner_new.ycp		\
	scanner_install.ycp	\
	scanner_manual.ycp	\
	scanner_scsi.ycp	\
	scanner_usb.ycp		\
	scanner_net.ycp		\
	scanner_notfound.ycp	\
	scanner_functions.ycp	\
	wizards.ycp		\
	dialogs.ycp

desktop_DATA =			\
	scanner.desktop

module_DATA =			\
	Scanner.ycp

agent_SCRIPTS = ag_scanner ag_sane scannerDB.pm

EXTRA_DIST = $(client_DATA) $(ynclude_DATA) $(agent_SCRIPTS) $(desktop_DATA) $(module_DATA)

scanner:
	ln -sf . scanner

ycpchook = scanner

include $(top_srcdir)/Makefile.am.common
