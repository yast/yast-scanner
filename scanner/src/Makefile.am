# Makefile.am for scanner/src

yncludedir = @yncludedir@/scanner

#client_DATA =			\
#	scanner.ycp		\
#	scanner_auto.ycp	\
#	scanner_proposal.ycp

client_DATA =			\
	scanner.ycp

#ynclude_DATA =			\
#	helps.ycp		\
#	wizards.ycp		\
#	dialogs.ycp		\
#	complex.ycp

ynclude_DATA =			\
	helps.ycp		\
	wizards.ycp		\
	dialogs.ycp

desktop_DATA =			\
	scanner.desktop

# module_DATA =			\
#	Scanner.ycp		\
# 	Scanner.pm

module_DATA =			\
	Scanner.ycp

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common
