# Sources for scanner

module_DATA = \
  modules/Scanner.rb

client_DATA = \
  clients/scanner.rb

yncludedir = @yncludedir@/scanner
ynclude_DATA = \
  include/scanner/wizards.rb \
  include/scanner/dialogs.rb \
  include/scanner/helps.rb

desktop_DATA = \
  desktop/org.opensuse.yast.Scanner.desktop

symbolicdir = @icondir@/hicolor/symbolic/apps
symbolic_DATA = \
  icons/hicolor/symbolic/apps/yast-scanner-symbolic.svg

scalabledir = @icondir@/hicolor/scalable/apps
scalable_DATA = \
  icons/hicolor/scalable/apps/yast-scanner.svg

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(desktop_DATA) $(symbolic_DATA) $(scalable_DATA)

include $(top_srcdir)/Makefile.am.common
