#
# Makefile.am for y2c_scanner/src
#

clientsdir = $(YAST2DIR)/clients
includedir = $(YAST2DIR)/include/scanner
menudir = $(YAST2DIR)/menuentries
agentdir = $(YAST2DIR)/servers_non_y2

clients_DATA =		\
	scanner.ycp

include_DATA =		\
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

menu_DATA = menuentry_scanner.y2cc
agent_SCRIPTS = ag_scanner ag_sane scannerDB.pm

EXTRA_DIST = $(clients_DATA) $(include_DATA) $(menu_DATA) $(agent_SCRIPTS)
