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

# File:	include/scanner/wizards.ycp
# Package:	Configuration of scanner
# Summary:	Wizards definitions
# Authors:	Johannes Meixner <jsmeix@suse.de>
#
# $Id$
module Yast
  module ScannerWizardsInclude
    def initialize_scanner_wizards(include_target)
      Yast.import "UI"

      textdomain "scanner"

      Yast.import "Sequencer"
      Yast.import "Wizard"
      Yast.import "Label"

      Yast.include include_target, "scanner/dialogs.rb"
    end

    # Add a configuration of scanner
    # @return sequence result
    def AddSequence
      aliases = { "config1" => lambda { SelectModelDialog() }, "config2" => lambda(
      ) do
        ConfigureBackendDialog()
      end }
      sequence = {
        "ws_start" => "config1",
        "config1"  => { :abort => :abort, :next => "config2" },
        "config2"  => { :abort => :abort, :next => :next }
      }
      Sequencer.Run(aliases, sequence)
    end

    # Main workflow of the scanner configuration
    # @return sequence result
    def MainSequence
      aliases = {
        "overview"  => lambda { OverviewDialog() },
        "network"   => lambda { ConfigureNetworkScanningDialog() },
        "configure" => [lambda { AddSequence() }, true],
        "add"       => [lambda { AddSequence() }, true],
        "edit"      => [lambda { AddSequence() }, true]
      }
      sequence = {
        "ws_start"  => "overview",
        "overview"  => {
          :abort             => :abort,
          :next              => :next,
          :add               => "add",
          :configure         => "configure",
          :edit              => "edit",
          :delete            => "overview",
          :test              => "overview",
          :restart_detection => "overview",
          :network_scanning  => "network",
          :run_hpsetup       => "overview"
        },
        "configure" => { :abort => :abort, :next => "overview" },
        "network"   => { :abort => :abort, :next => "overview" },
        "add"       => { :abort => :abort, :next => "overview" },
        "edit"      => { :abort => :abort, :next => "overview" }
      }
      ret = Sequencer.Run(aliases, sequence)
      deep_copy(ret)
    end

    # Whole configuration of scanner
    # @return sequence result
    def ScannerSequence
      aliases = {
        "read"  => [lambda { ReadDialog() }, true],
        "main"  => lambda { MainSequence() },
        "write" => [lambda { WriteDialog() }, true]
      }
      sequence = {
        "ws_start" => "read",
        "read"     => { :abort => :abort, :next => "main" },
        "main"     => { :abort => :abort, :next => "write" },
        "write"    => { :abort => :abort, :next => :next }
      }
      Wizard.CreateDialog
      Wizard.SetDesktopIcon("scanner")
      ret = Sequencer.Run(aliases, sequence)
      UI.CloseDialog
      deep_copy(ret)
    end

    # Whole configuration of scanner but without reading and writing.
    # For use with autoinstallation.
    # @return sequence result
    def ScannerAutoSequence
      caption = _("Scanner Configuration")
      # Label of the dialog for ScannerAutoSequence:
      contents = Label(_("Initializing..."))
      Wizard.CreateDialog
      Wizard.SetContentsButtons(
        caption,
        contents,
        "",
        Label.BackButton,
        Label.NextButton
      )
      Wizard.SetDesktopIcon("scanner")
      ret = MainSequence()
      UI.CloseDialog
      deep_copy(ret)
    end
  end
end
