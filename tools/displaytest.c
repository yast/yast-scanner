/*
 *  gcc -Wall -o display display.c -L/usr/X11R6/lib -lX11 
 */

#include <stdio.h>
#include <stdlib.h>
#include <X11/Xlib.h>

int main (void)
{ char *display_name;
  Display *d;

  display_name=getenv( "DISPLAY" );
  d = XOpenDisplay( display_name );
  if( d == NULL )
  { fprintf( stderr, "Unable to open Display: %s\n", display_name );
    exit(1);
  }
  XCloseDisplay(d);
  return 0;
}
