
/*
 * Johannes Meixner <jsmeix@suse.de>, 2008, 2010
 *
 * Copyright (c) 2010 Novell, Inc.
 * All Rights Reserved.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of version 2 of the GNU General Public License as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, contact Novell, Inc.
 *
 * To contact Novell about this file by physical or electronic mail,
 * you may find current contact information at www.novell.com
 */

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

