#
# Makefile.am for y2c_scanner/src
#

clientsdir = $(YAST2DIR)/clients
includedir = $(YAST2DIR)/include/scanner
menudir = $(YAST2DIR)/menuentries

clients_DATA =		\
	scanner.ycp

include_DATA =		\
	scanner_start.ycp	\
	scanner_start_ui.ycp	\
	scanner_overview.ycp	\
	scanner_overview_ui.ycp \
	scanner_new.ycp		\
	scanner_options.ycp	\
	scanner_options_ui.ycp	\
	scanner_new_ui.ycp	\
	scanner_install.ycp	\
	scanner_install_ui.ycp	\
	scanner_manual.ycp	\
	scanner_manual_ui.ycp	\
	scanner_functions.ycp

menu_DATA = menuentry_scanner.ycp

EXTRA_DIST = $(clients_DATA) $(include_DATA) $(menu_DATA)
