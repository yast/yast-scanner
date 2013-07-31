# encoding: utf-8

# Copyright (c) 2010 Novell, Inc.
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of version 2 of the GNU General Public License as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact Novell, Inc.
#
# To contact Novell about this file by physical or electronic mail,
# you may find current contact information at www.novell.com

# File:	clients/scanner.ycp
# Package:	Configuration of scanner
# Summary:	Main file
# Authors:	Johannes Meixner <jsmeix@suse.de>
#
# $Id$
#
# Main file for scanner configuration. Uses all other files.
module Yast
  class ScannerClient < Client
    def main
      Yast.import "UI"

      #**
      # <h3>Configuration of scanner</h3>

      textdomain "scanner"

      # The main ()
      Builtins.y2milestone("----------------------------------------")
      Builtins.y2milestone("Scanner module started")

      Yast.import "CommandLine"
      Yast.import "Scanner"

      Yast.include self, "scanner/wizards.rb"

      @command_line_description = {
        "id"         => "scanner",
        # Text for the command_line_description:
        "help"       => _(
          "Scanner Configuration"
        ),
        "guihandler" => fun_ref(method(:ScannerSequence), "any ()"),
        "initialize" => fun_ref(Scanner.method(:Read), "boolean ()"),
        "finish"     => fun_ref(Scanner.method(:Write), "boolean ()"),
        "actions"    => {},
        "options"    => {},
        "mappings"   => {}
      }

      # is this propose mode or not?
      @propose_mode = false
      @args = WFM.Args
      if Ops.greater_than(Builtins.size(@args), 0)
        if Ops.is_string?(WFM.Args(0)) && WFM.Args(0) == "propose"
          Builtins.y2milestone("Using propose mode")
          @propose_mode = true
        end
      end

      # main ui function
      @ret = nil

      if @propose_mode
        Builtins.y2milestone("Calling ScannerAutoSequence()")
        @ret = ScannerAutoSequence()
        Builtins.y2milestone(
          "Return value of ScannerAutoSequence() is: %1",
          @ret
        )
      else
        Builtins.y2milestone(
          "Calling CommandLine::Run(%1)",
          @command_line_description
        )
        @ret = CommandLine.Run(@command_line_description)
        Builtins.y2milestone(
          "Return value of CommandLine::Run(%1) is: %2",
          @command_line_description,
          @ret
        )
      end

      # Finish
      Builtins.y2milestone("Finishing scanner module")
      Builtins.y2milestone("Return value will be: %1", @ret)
      Builtins.y2milestone("----------------------------------------")

      deep_copy(@ret) 

      # EOF
    end
  end
end

Yast::ScannerClient.new.main
