#
# Makefile.am for scanner/src
#

client_DATA =	\
	scanner.ycp

scannerdir = @yncludedir@/scanner
scanner_DATA =			\
	scanner_start.ycp	\
	scanner_overview.ycp	\
	scanner_new.ycp		\
	scanner_install.ycp	\
	scanner_manual.ycp	\
	scanner_scsi.ycp	\
	scanner_usb.ycp		\
	scanner_net.ycp		\
	scanner_notfound.ycp	\
	scanner_functions.ycp

config_DATA = scanner.y2cc

agent_SCRIPTS = ag_scanner ag_sane scannerDB.pm

EXTRA_DIST = $(client_DATA) $(scanner_DATA) $(config_DATA) $(agent_SCRIPTS)
