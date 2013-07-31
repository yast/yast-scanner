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

# File:        include/scanner/dialogs.ycp
# Package:     Configuration of scanner
# Summary:     Dialogs definitions
# Authors:     Johannes Meixner <jsmeix@suse.de>
#
# $Id$
# $Id$
module Yast
  module ScannerDialogsInclude
    def initialize_scanner_dialogs(include_target)
      Yast.import "UI"

      textdomain "scanner"

      Yast.import "Label"
      Yast.import "Popup"
      Yast.import "Wizard"
      Yast.import "Arch"
      Yast.import "Scanner"
      Yast.import "WizardHW"
      Yast.import "Confirm"

      Yast.include include_target, "scanner/helps.rb"
    end

    # Ask for user confirmation if necessary before aborting.
    # At present full transaction semantics (with roll-back) is not implemented.
    # What is implemented is that it does not leave the system in an inconsistent state.
    # It does one setup completely or not at all (i.e. all or nothing semantics regarding one setup.)
    # "One setup" means the smallest amount of setup actions
    # which lead from one consistent state to another consistent state.
    # "Consistent state" is meant from the user's point of view
    # (i.e. set up one SANE backend completely or set up the saned completely)
    # and not from a low-level (e.g. filesystem or kernel) point of view.
    # If the user does malicious stuff (e.g. killing YaST)
    # or if the user ignores warning messages then it is possible (and it is accepted)
    # that the user can force to set up even an inconsistent state
    # (e.g. activate a backend but don't activate a required service).
    # At present all what is needed for one setup is committed to the system instantly.
    # For example:
    # Install additional packages (like hp-officeJet),
    # then set up and start special required services (like ptal),
    # then activate the backend in /etc/sane/dll.conf
    # finally determine which scanners have become actually active
    # (see the ActivateBackend and DeactivateBackend functions).
    # It is necessary to commit instantly to be able to test a scanner
    # and to show a true feedback to the user which scanners are actually active.
    # @return true if nothing was committed or if user confirms to abort
    def ReallyAbort
      # Scanner::Modified() returns true if something was committed to the system.
      !Scanner.Modified || Popup.ReallyAbort(false)
    end

    # Read settings dialog
    # @return `abort if aborted and `next otherwise
    def ReadDialog
      # Otherwise the user is asked for confirmation whether he want's to continue
      # despite the fact that the module might not work correctly
      return :abort if !Confirm.MustBeRoot
      # According to the YaST Style Guide (dated Tue, 04 Nov 2008)
      # the "abort" button in a single configuration dialog must now be named "cancel":
      Wizard.SetAbortButton(:abort, Label.CancelButton)
      # No "back" or "next" button at all makes any sense here
      # because there is no dialog where to go "back"
      # and the "next" dialog (i.e. the Overview dialog) is launced automatically
      Wizard.HideBackButton
      Wizard.HideNextButton
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "read", ""))
      ret = Scanner.Read
      ret ? :next : :abort
    end

    # Write settings dialog
    # @return `abort if aborted and `next otherwise
    def WriteDialog
      Wizard.HideAbortButton
      Wizard.HideBackButton
      Wizard.HideNextButton
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "write", ""))
      ret = Scanner.Write
      ret ? :next : :abort
    end

    # Overview dialog
    # does what the two dialogs SummaryDialog() and OverviewDialog() did before:
    # A dialog showing the detected scanners and allowing to configure them.
    # @return [Object] The value of the resulting UserInput.
    def OverviewDialog
      # (the same as the caption of the matching help text)
      caption = _("Scanner Configuration")
      WizardHW.CreateHWDialog(
        caption,
        Ops.get_string(@HELPS, "overview", ""),
        [
          # where scanners and associated drivers are listed:
          _("Driver"),
          # Header for a column of the overview table
          # where scanners and associated drivers are listed:
          _("Scanner")
        ], # Header for a column of the overview table
        [
          [
            :restart_detection,
            # Label of a button to restart autodetection of scanners:
            _("&Restart Detection")
          ],
          [
            :test,
            # Label of a button to test a scanner:
            _("&Test")
          ],
          [
            :run_hpsetup,
            # Label of a button to run hp-setup.
            # Do not change or translate "hp-setup", it is a program name:
            _("Run &hp-setup")
          ],
          [
            :network_scanning,
            # Label of a button to go to the network scanning dialog.
            # Do not confuse "scanning via network"
            # (i.e. use a remote scanner via another host in the network)
            # with "scanning the network"
            # (i.e. scan the network for other hosts or services):
            _("Scanning via &Network...")
          ]
        ]
      )
      WizardHW.SetContents(Scanner.OverviewContents)
      # In the Overview dialog the "next" button is used to finish the whole module.
      # According to YaST Style Guide (dated Tue, 04 Nov 2008)
      # the "finish" button in an Overview dialog must now be named "OK":
      Wizard.SetNextButton(:next, Label.OKButton)
      # In the Overview dialog it does not make sense to have a button with "back" functionality
      # which is named "Cancel" according to the YaST Style Guide (dated Tue, 04 Nov 2008)
      # because there is nothing to "cancel" in the Overview dialog because it
      # only shows information about the current state of the configuration
      # but the Overview dialog itself does not do any change of the configuration.
      # The Overview dialog has actually the same meaning for the user
      # as a plain notification popup which has only a "OK" button.
      # If the user does not agree to what is shown in the Overview dialog
      # he must launch a configuration sub-dialog to change the configuration.
      # If the user accepted in such a configuration sub-dialog what he changed
      # via the "OK" button there, the change is applied and the Overview dialog
      # shows the new current state of the configuration, see
      # http://en.opensuse.org/Archive:YaST_Printer_redesign#Basic_Implementation_Principles:
      # so that it is not possible to "cancel" the change in the Overview dialog.
      # Any change of the configuration is done in sub-dialogs which are called
      # from the Overview dialog (even the "Confirm Deletion" popup is such a sub-dialog)
      # and in all those sub-dialogs there is a button with "cancel" functionality.
      Wizard.HideBackButton
      # According to the YaST Style Guide (dated Tue, 04 Nov 2008)
      # there is no longer a "abort" functionality which exits the whole module.
      # Instead this button is now named "Cancel" and its functionality is
      # to go back to the Overview dialog (i.e. what the "back" button would do)
      # because it reads "Cancel - Closes the window and returns to the overview."
      # In this case this does not make sense because this is already the "overview".
      # Therefore the button with the "abort" functionality is not shown at all:
      Wizard.HideAbortButton
      ret = nil
      while true
        ret = UI.UserInput
        # back or abort
        if ret == :abort || ret == :cancel
          next if !ReallyAbort()
          break
        end
        # next or back
        break if ret == :next || ret == :back
        # add
        if ret == :add
          # to have it no longer preselected in the select model dialog:
          Scanner.selected_autodetected_scanners_index = -1
          # Unselect a previously selected model in the database
          # to have it no longer preselected in the select model dialog:
          Scanner.selected_model_database_index = -1
          # Exit this dialog and run the AddSequence() via the sequencer in wizards.ycp:
          break
        end
        # edit
        if ret == :edit
          selected_item_id = WizardHW.SelectedItem
          Builtins.y2milestone(
            "selected_item_id in OverviewDialog: %1",
            selected_item_id
          )
          if selected_item_id == ""
            Popup.AnyMessage(
              _("Nothing Selected"),
              # Body of a Popup::AnyMessage when nothing was selected:
              _("Select an entry.")
            )
            next
          end
          # The selected_item_id can be one of the following (see the OverviewContents function):
          # "autodetected_scanner:[0-9]*" where [0-9]* is the autodetected_scanners_index
          # (i.e. the index in the autodetected_scanners list to which the selected item matches)
          # "active_scanner:[0-9]*" where [0-9]* is the active_scanners_index
          # (i.e. the index in the active_scanners list to which the selected item matches)
          # "active_backend:[0-9]*" where [0-9]* is the active_backends_index
          # (i.e. the index in the active_backends list to which the selected item matches)
          # "nothing" which is used as fallback only if none of the above was set
          # (i.e. if neither a scanner was autodetected nor an active scanner nor an active backend exists)
          if Builtins.issubstring(selected_item_id, "autodetected_scanner:")
            Scanner.selected_autodetected_scanners_index = Builtins.tointeger(
              Builtins.filterchars(selected_item_id, "0123456789")
            )
            Builtins.y2milestone(
              "Selected autodetected scanners index in OverviewDialog is: %1",
              Scanner.selected_autodetected_scanners_index
            )
            if Ops.less_than(Scanner.selected_autodetected_scanners_index, 0)
              ret = :add
            else
              # to have it no longer preselected in the select model dialog
              # when the user has selected a not yet configured autodetected scanner:
              Scanner.selected_model_database_index = -1
              ret = :configure
            end
            # Exit this dialog and run the AddSequence() via the sequencer in wizards.ycp:
            break
          end
          if Builtins.issubstring(selected_item_id, "active_scanner:")
            # Unselect a previously selected autodetected scanner
            # to have it no longer preselected in the select model dialog
            # but keep a possibly previously selected model in the database
            # because this model was normally added, configured, or edited before
            # (in particular if there is only one scanner connected):
            Scanner.selected_autodetected_scanners_index = -1
            # Test if the active scanner is a remote scanner
            # (i.e. when it is accessed via the 'net' meta-backend):
            active_scanners_index = Builtins.tointeger(
              Builtins.filterchars(selected_item_id, "0123456789")
            )
            if "net" ==
                Ops.get(
                  Scanner.active_scanners,
                  [active_scanners_index, "backend"],
                  ""
                )
              ret = :network_scanning
              break
            end
            # Exit this dialog and run the AddSequence() via the sequencer in wizards.ycp:
            ret = :edit
            break
          end
          if Builtins.issubstring(selected_item_id, "active_backend:")
            active_backends_index = Builtins.tointeger(
              Builtins.filterchars(selected_item_id, "0123456789")
            )
            # Test if the active backend is the 'net' meta-backend:
            if "net" ==
                Ops.get(Scanner.active_backends, active_backends_index, "")
              ret = :network_scanning
              break
            end
            # A selected active backend (without a matching active scanner) cannot be edited.
            # A selected active backend (without a matching active scanner) can only be deleted.
            Popup.AnyMessage(
              # without a matching active scanner was selected
              # and then the user clicked the [Edit] button.
              # Translate 'Edit' to the exact label of the [Edit] button.
              _("Edit Not Possible"),
              # Body of a Popup::AnyMessage when an active driver
              # without a matching active scanner was selected
              # and then the user clicked the [Edit] button:
              # Translate 'delete' to the exact label of the [Delete] button.
              _(
                "It is only possible to delete a driver without a matching scanner."
              )
            )
            next
          end
          if "nothing" == selected_item_id
            Popup.AnyMessage(
              # when there is neither a detected scanner nor an active scanner or driver
              # and then the user clicked the [Edit] button.
              # Translate 'Edit' to the exact label of the [Edit] button.
              _("Edit Not Possible"),
              # Body of a Popup::AnyMessage when there is only the fallback entry
              # when there is neither a detected scanner nor an active scanner or driver
              # and then the user clicked the [Edit] button.
              # Translate 'add' to the exact label of the [Add] button.
              _("It is only possible to add a scanner.")
            )
            next 
            # Alternatively:
            #        // Do the same as if the user had clicked the [Add] button:
            #        // Unselect a previously selected autodetected scanner
            #        // to have it no longer preselected in the select model dialog:
            #        Scanner::selected_autodetected_scanners_index = -1;
            #        // Unselect a previously selected model in the database
            #        // to have it no longer preselected in the select model dialog:
            #        Scanner::selected_model_database_index = -1;
            #        // Exit this dialog and run the AddSequence() via the sequencer in wizards.ycp:
            #        ret = `add;
            #        break;
          end
          Builtins.y2milestone(
            "selected_item_id is none of 'autodetected_scanner:...' 'active_scanner:...' 'active_backend:...' 'nothing'"
          )
          next
        end
        # delete
        if ret == :delete
          selected_item_id = WizardHW.SelectedItem
          Builtins.y2milestone(
            "Selected item id in OverviewDialog: %1",
            selected_item_id
          )
          if selected_item_id == ""
            Popup.AnyMessage(
              _("Nothing Selected"),
              # Body of a Popup::AnyMessage when nothing was selected:
              _("Select an entry.")
            )
            next
          end
          # The selected_item_id can be one of the following (see the OverviewContents function):
          # "autodetected_scanner:[0-9]*" where [0-9]* is the autodetected_scanners_index
          # (i.e. the index in the autodetected_scanners list to which the selected item matches)
          # "active_scanner:[0-9]*" where [0-9]* is the active_scanners_index
          # (i.e. the index in the active_scanners list to which the selected item matches)
          # "active_backend:[0-9]*" where [0-9]* is the active_backends_index
          # (i.e. the index in the active_backends list to which the selected item matches)
          # "nothing" which is used as fallback only if none of the above was set
          # (i.e. if neither a scanner was autodetected nor an active scanner nor an active backend exists)
          if Builtins.issubstring(selected_item_id, "autodetected_scanner:")
            # A selected autodetected scanner can be edited.
            Popup.AnyMessage(
              # which is not yet configured was selected
              # and then the user clicked the [Delete] button.
              # Translate 'Delete' to the exact label of the [Delete] button.
              _("Delete Not Possible"),
              # Body of a Popup::AnyMessage when an autodetected scanner
              # which is not yet configured was selected
              # and then the user clicked the [Delete] button:
              # Translate 'edit' to the exact label of the [Edit] button.
              _("It is only possible to edit a detected scanner.")
            )
            next
          end
          if "nothing" == selected_item_id
            Popup.AnyMessage(
              # when there is neither a detected scanner nor an active scanner or driver
              # and then the user clicked the [Delete] button.
              # Translate 'Delete' to the exact label of the [Delete] button.
              _("Delete Not Possible"),
              # Body of a Popup::AnyMessage when there is only the fallback entry
              # when there is neither a detected scanner nor an active scanner or driver
              # and then the user clicked the [Delete] button.
              # Translate 'add' to the exact label of the [Add] button.
              _("It is only possible to add a scanner.")
            )
            next
          end
          # The selected_item_id is either "active_scanner:..." or "active_backend:...":
          backend_name = ""
          if Builtins.issubstring(selected_item_id, "active_scanner:")
            active_scanners_index = Builtins.tointeger(
              Builtins.filterchars(selected_item_id, "0123456789")
            )
            backend_name = Ops.get(
              Scanner.active_scanners,
              [active_scanners_index, "backend"],
              ""
            )
            # Test if the active scanner is a remote scanner
            # (i.e. when it is accessed via the 'net' meta-backend):
            if "net" == backend_name
              ret = :network_scanning
              break
            end
          end
          if Builtins.issubstring(selected_item_id, "active_backend:")
            active_backends_index = Builtins.tointeger(
              Builtins.filterchars(selected_item_id, "0123456789")
            )
            backend_name = Ops.get(
              Scanner.active_backends,
              active_backends_index,
              ""
            )
            # Test if the active backend is the 'net' meta-backend:
            if "net" == backend_name
              ret = :network_scanning
              break
            end
          end
          Builtins.y2milestone(
            "Selected backend to be deleted (i.e. deactivated) is: %1",
            backend_name
          )
          if "" == backend_name
            Popup.AnyMessage(
              _("Nothing Selected"),
              # Body of a Popup::AnyMessage when nothing was selected:
              _("Select an entry.")
            )
            next
          end
          if !Popup.YesNo(
              Builtins.sformat(
                # where %1 will be replaced by the driver name:
                _("Deactivate %1?"),
                backend_name
              ) # Question of a Popup::YesNo
            )
            next
          end
          Wizard.DisableNextButton
          if !Scanner.DeactivateBackend(backend_name, -1, true)
            Popup.Error(
              # where %1 will be replaced by the driver (backend) name.
              # Only a simple message because before the function Scanner::DeactivateBackend
              # was called and this function would have shown more specific messages.
              Builtins.sformat(_("Failed to deactivate %1."), backend_name)
            )
          end
          Wizard.EnableNextButton
          # Exit this dialog and run it again via the sequencer in wizards.ycp
          # to get it updated after the delete via calling OverviewContents():
          ret = :delete
          break
        end
        # test
        if ret == :test
          selected_item_id = WizardHW.SelectedItem
          Builtins.y2milestone(
            "Selected item id in OverviewDialog: %1",
            selected_item_id
          )
          if selected_item_id == ""
            Popup.AnyMessage(
              _("Nothing Selected"),
              # Body of a Popup::AnyMessage when nothing was selected:
              _("Select an entry.")
            )
            next
          end
          # The selected_item_id can be one of the following (see the OverviewContents function):
          # "autodetected_scanner:[0-9]*" where [0-9]* is the autodetected_scanners_index
          # (i.e. the index in the autodetected_scanners list to which the selected item matches)
          # "active_scanner:[0-9]*" where [0-9]* is the active_scanners_index
          # (i.e. the index in the active_scanners list to which the selected item matches)
          # "active_backend:[0-9]*" where [0-9]* is the active_backends_index
          # (i.e. the index in the active_backends list to which the selected item matches)
          # "nothing" which is used as fallback only if none of the above was set
          # (i.e. if neither a scanner was autodetected nor an active scanner nor an active backend exists)
          if Builtins.issubstring(selected_item_id, "autodetected_scanner:")
            # A selected autodetected scanner can be edited.
            Popup.AnyMessage(
              # which is not yet configured was selected
              # and then the user clicked the [Test] button.
              # Translate 'Test' to the exact label of the [Test] button.
              _("Test Not Possible"),
              # Body of a Popup::AnyMessage when an autodetected scanner
              # which is not yet configured was selected
              # and then the user clicked the [Test] button:
              # Translate 'edit' to the exact label of the [Edit] button.
              _("It is only possible to edit a detected scanner.")
            )
            next
          end
          if Builtins.issubstring(selected_item_id, "active_backend:")
            # A selected active backend without a matching active scanner can only be deleted.
            Popup.AnyMessage(
              # without a matching active scanner was selected
              # and then the user clicked the [Test] button.
              # Translate 'Test' to the exact label of the [Test] button.
              _("Test Not Possible"),
              # Body of a Popup::AnyMessage when an active driver
              # without a matching active scanner was selected
              # and then the user clicked the [Test] button:
              # Translate 'delete' to the exact label of the [Delete] button.
              _(
                "It is only possible to delete a driver without a matching scanner."
              )
            )
            next
          end
          if "nothing" == selected_item_id
            Popup.AnyMessage(
              # when there is neither a detected scanner nor an active scanner or driver
              # and then the user clicked the [Test] button.
              # Translate 'Test' to the exact label of the [Test] button.
              _("Test Not Possible"),
              # Body of a Popup::AnyMessage when there is only the fallback entry
              # when there is neither a detected scanner nor an active scanner or driver
              # and then the user clicked the [Test] button.
              # Translate 'add' to the exact label of the [Add] button.
              _("It is only possible to add a scanner.")
            )
            next
          end
          if Builtins.issubstring(selected_item_id, "active_scanner:")
            active_scanners_index = Builtins.tointeger(
              Builtins.filterchars(selected_item_id, "0123456789")
            )
            backend_name = Ops.get(
              Scanner.active_scanners,
              [active_scanners_index, "backend"],
              ""
            )
            Builtins.y2milestone(
              "Selected backend to be tested is: %1",
              backend_name
            )
            if nil == backend_name || "" == backend_name
              Popup.AnyMessage(
                _("Nothing Selected"),
                # Body of a Popup::AnyMessage when nothing was selected:
                _("Select an entry.")
              )
              next
            end
            if !Scanner.TestBackend(backend_name)
              Popup.Error(
                # Only a simple message because before the function Scanner::TestBackend
                # was called and this function would have shown more specific messages.
                Builtins.sformat(_("Failed to test %1."), backend_name)
              )
            end
          end
          # Exit this dialog and run it again via the sequencer in wizards.ycp
          # to get it updated after the test via calling OverviewContents().
          # Even if normally nothing in the dialog content should have changed
          # because of a test, it might have happened that for example
          # during the test somehow the USB or SCSI system had crashed
          # and then the scanner would be no longer an active scanner.
          ret = :test
          break
        end
        # network scanning
        break if ret == :network_scanning
        # restart the whole autodetection
        if ret == :restart_detection
          if Scanner.ignore_unknown_USB_scanners
            Scanner.ignore_unknown_USB_scanners = false
          else
            Scanner.ignore_unknown_USB_scanners = true
          end
          # Scanner::RestartDetection results true in any case, see the function comment.
          Scanner.RestartDetection
          # Exit this dialog and run it again via the sequencer in wizards.ycp
          # to show the new autodetection results:
          break
        end
        # run hp-setup
        if ret == :run_hpsetup
          # Scanner::RunHpsetup() returns false only if hp-setup cannot be run.
          # It returns true in any other case because there is no usable exit code of hp-setup
          # (always zero even in case of error).
          # The hp-setup exit code does not matter because the autodetection will show
          # an appropriate result (e.g. no HP all-in-one device if hp-setup failed):
          if !Scanner.RunHpsetup
            Popup.Error(
              # Only a simple message because before the function Scanner::RunHpsetup
              # was called and this function would have shown more specific messages.
              # Do not change or translate "hp-setup", it is a program name:
              _("Failed to run hp-setup.")
            )
            next
          end
          # Scanner::RestartDetection results true in any case, see the function comment.
          Scanner.RestartDetection
          # Exit this dialog and run it again via the sequencer in wizards.ycp
          # to show the new autodetection results:
          break
        end
        Builtins.y2milestone(
          "Ignoring unexpected returncode in OverviewDialog: %1",
          ret
        )
        next
      end
      Builtins.y2milestone("OverviewDialog returns: %1", ret)
      deep_copy(ret)
    end

    # Select model dialog
    # @return dialog result
    def SelectModelDialog
      caption = _("Scanner Model and Driver Selection")
      # If there is an autodetected scanner selected
      # then preset the filter_string with the autodetected manufacturer
      # if the autodetected manufacturer exists in the database
      # to avoid an empty model selection list.
      # If there is no autodetected manufacturer or if its value is the empty string
      # or if the autodetected manufacturer does not exist in the database
      # then the empty filter_string results no filtering at all:
      filter_string = ""
      if Ops.greater_or_equal(Scanner.selected_autodetected_scanners_index, 0)
        autodetected_manufacturer = Ops.get(
          Scanner.autodetected_scanners,
          [Scanner.selected_autodetected_scanners_index, "manufacturer"],
          ""
        )
        autodetected_connection = Ops.get(
          Scanner.autodetected_scanners,
          [Scanner.selected_autodetected_scanners_index, "connection"],
          ""
        )
        # Unify known ambiguous autodetected manufacturer names:
        if "hp" == Builtins.tolower(autodetected_manufacturer)
          autodetected_manufacturer = "Hewlett-Packard"
        end
        # Preset the filter_string only if the autodetected manufacturer exists in the database.
        # The leading "^" avoids to find entries which do not really belong to this manufacturer
        # (e.g. when the manufacturer name is mentioned only in a comment of another model)
        # because the actual manufacturer name is the first part of the model string.
        # The trailing ".*" is only to have a user-friendly preset regular expression
        # so that it works when the user simply appends more stuff (e.g. a part of the model name):
        Builtins.foreach(Scanner.database_manufacturers) do |database_manufacturer|
          if Builtins.tolower(database_manufacturer) ==
              Builtins.tolower(autodetected_manufacturer)
            filter_string = Ops.add(
              Ops.add("^", autodetected_manufacturer),
              ".*"
            )
          end
        end 

        # If it is an autodetected SCSI scanner, append "\(SCSI" to the filter_string
        # (the filter_string may be the empty string if no manufacturer matched above)
        # to suppress that tons of USB-only scanners are also shown to the user.
        # The "(" is used to match only to the interface_and_usbid_string (see Scanner.ycp)
        # to avoid that plain "SCSI" is found when it is only mentioned in a comment but actually
        # no "SCSI" is specified as supported interface in the description file (e.g. see avision.desc).
        # One "\" is needed to quote the "(" which has a special meaning in a regular expression and
        # the leftmost "\" is needed to quote the next "\" which has a special meaning in YCP strings.
        if "SCSI" == autodetected_connection
          filter_string = Ops.add(filter_string, "\\(SCSI")
        end
      end
      contents = VBox(
        HBox(
          TextEntry(
            Id(:filter_input),
            # Header of a TextEntry user input field to enter a search string:
            _("S&earch String"),
            filter_string
          ),
          PushButton(
            Id(:apply_filter),
            # This button must be the default
            # (it is activated when the user pressed the Enter key)
            # because when the user has clicked into TextEntry to enter something
            # it is normal to finish entering by pressing the Enter key
            # but if the Enter key was linked to 'Next' or 'Back',
            # the user would get the wrong action.
            Opt(:default),
            # Label of a PushButton to search a list for a search string:
            _("&Search")
          ),
          PushButton(
            Id(:ignore_filter),
            # Label of a PushButton to show all entries of a list:
            _("Show Complete &List")
          )
        ),
        ReplacePoint(
          Id(:model_selection_replace_point),
          SelectionBox(
            Id(:model_selection),
            # Header of a SelectionBox with a list of models:
            _("Scanner &Models"),
            Scanner.ModelItems(filter_string)
          )
        )
      )
      Wizard.SetContentsButtons(
        caption,
        contents,
        Ops.get_string(@HELPS, "select_model", ""),
        Label.BackButton,
        Label.NextButton
      )
      # According to the YaST Style Guide (dated Tue, 04 Nov 2008)
      # the button with the "back" functionality must be disabled
      # only when it is the first dialog of a wizard stlye dialog sequence.
      Wizard.HideBackButton
      # According to the YaST Style Guide (dated Tue, 04 Nov 2008)
      # there is no longer a "abort" functionality which exits the whole module.
      # Instead this button is now named "Cancel" and its functionality is
      # to go back to the Overview dialog (i.e. what the "back" button would do)
      # because it reads "Cancel - Closes the window and returns to the overview."
      Wizard.SetAbortButton(:back, Label.CancelButton)
      ret = nil
      while true
        ret = UI.UserInput
        break if ret == :back
        # apply a filter to the model list
        if ret == :apply_filter
          filter_string = Convert.to_string(
            UI.QueryWidget(Id(:filter_input), :Value)
          )
          UI.ReplaceWidget(
            Id(:model_selection_replace_point),
            SelectionBox(
              Id(:model_selection),
              # Header of a SelectionBox with a list of models:
              _("Scanner &Models"),
              Scanner.ModelItems(filter_string)
            )
          )
          next
        end
        # ignore the filter for the model list
        if ret == :ignore_filter
          filter_string = Convert.to_string(
            UI.QueryWidget(Id(:filter_input), :Value)
          )
          UI.ReplaceWidget(
            Id(:model_selection_replace_point),
            SelectionBox(
              Id(:model_selection),
              # Header of a SelectionBox with the complete list of models:
              _("All Scanner &Models"),
              Scanner.ModelItems("")
            )
          )
          next
        end
        # select a scanner
        if ret == :next
          Scanner.selected_model_database_index = Convert.to_integer(
            UI.QueryWidget(Id(:model_selection), :CurrentItem)
          )
          if nil == Scanner.selected_model_database_index
            Popup.AnyMessage(
              _("Nothing Selected"),
              # Body of a Popup::AnyMessage when no model was selected:
              _("Select an entry.")
            )
            next
          end
          # Compare how the ModelItems function builds the matching status_strings by using the same logic:
          if "unsupported" ==
              Ops.get(
                Scanner.database,
                [Scanner.selected_model_database_index, "status"],
                "unknown"
              )
            backend = Ops.get(
              Scanner.database,
              [Scanner.selected_model_database_index, "backend"],
              "unknown"
            )
            if "unsupported" == backend
              Popup.AnyMessage(
                _("Unsupported Model"),
                # Body of a Popup::AnyMessage when an unsupported model was selected:
                _(
                  "This model is not supported.\nAsk the manufacturer for a Linux driver."
                )
              )
            else
              Popup.AnyMessage(
                Builtins.sformat(
                  # which is listed as "unsupported" for a particular driver:
                  # %1 will be replaced by the backend (scanner driver) name
                  _("Model Not Supported by the Driver %1"),
                  backend
                ), # Header of a Popup::AnyMessage when a model was selected
                # Body of a Popup::AnyMessage when a model was selected
                # which is listed as "unsupported" for a particular driver:
                _(
                  "Check if another driver supports it,\n" +
                    "select a compatible model,\n" +
                    "or ask the manufacturer for a Linux driver."
                )
              )
            end
            next
          end
          # The epkowa backend in the package iscan-free is available for all architectures.
          # In contrast the epkowa backend in the package iscan which is provided by Epson
          # (formerly Avasys, see https://bugzilla.novell.com/show_bug.cgi?id=746038)
          # is only available for i386-compatible architectures:
          # True 32-bit i386 and also 64-bit x86_64.
          # For some models it might be only available for 32-bit i386 architecture.
          # Some scanners require additionally proprietary libraries which are provided by
          # Epson (formerly Avasys) as additional model dependant iscan-plugin-<model-name> RPMs.
          # For those scanners there is in the database "backend"="epkowa" and "package"="iscan".
          # The scanners which work with iscan-free have "backend"="epkowa" and "package"="iscan-free".
          # It would be possible to test for non-i386-compatible architecture in the ModelItems function
          # and suppress the epkowa backend entries in the model list but intentionally this is not done.
          # All available known model information is always shown to the user.
          # There is never known information secretly hidden from the user.
          # If something is not supported in a special case, an additional information message is shown.
          # Otherwise a user on a non-i386-compatible architecture would not understand
          # when others (who use i386) tell him that "model XYZ is listed and works perfectly"
          # until after a long discusssion they find out that it depends on the architecture.
          if "epkowa" ==
              Ops.get(
                Scanner.database,
                [Scanner.selected_model_database_index, "backend"],
                "unknown"
              ) &&
              "iscan" ==
                Ops.get(
                  Scanner.database,
                  [Scanner.selected_model_database_index, "package"],
                  "unknown"
                ) &&
              !Arch.i386
            if !Arch.x86_64
              Popup.AnyMessage(
                # on a non-i386-compatible architecture (i.e. neither i386 nor x86_64).
                _("Unsupported Driver"),
                # Body of a Popup::AnyMessage when the epkowa driver was selected
                # on a non-i386-compatible architecture (i.e. neither i386 nor x86_64).
                # Do not change or translate "epkowa", it is a driver name.
                # Do not change or translate "i386", it is an architecture name.
                _(
                  "The epkowa driver is only available for i386-compatible architectures (32-bit i386 and also 64-bit x86_64)."
                )
              )
              next
            end
            if !Popup.ContinueCancelHeadline(
                # when the epkowa driver was selected on x86_64:
                _("Possibly Problematic Driver"),
                # Body of a Popup::ContinueCancelHeadline
                # when the epkowa driver was selected on x86_64.
                # Do not change or translate "epkowa", it is a driver name.
                _(
                  "The epkowa driver may cause problems on 64-bit x86_64 architecture."
                )
              )
              next
            end
          end
          # Tell the user that the hpoj backend is outdated and no longer maintained:
          if "hpoj" ==
              Ops.get(
                Scanner.database,
                [Scanner.selected_model_database_index, "backend"],
                "unknown"
              )
            if !Popup.ContinueCancelHeadline(
                # when the outdated hpoj driver was selected:
                _("Outdated Driver"),
                # Body of a Popup::ContinueCancelHeadline
                # when the outdated hpoj driver was selected.
                # Do not change or translate "hpoj", it is a driver name.
                # Do not change or translate "hpaio", it is a driver name.
                _(
                  "The hpoj driver should work but it is no longer maintained.\nTry to use the up-to-date driver hpaio."
                )
              )
              next
            end
          end
          # Leve this dialog and do the "next" step according to the sequences in wizards.ycp:
          break
        end
        Builtins.y2milestone(
          "Ignoring unexpected returncode in SelectModelDialog: %1",
          ret
        )
        next
      end
      deep_copy(ret)
    end

    # Configure backend dialog
    # @return dialog result
    def ConfigureBackendDialog
      caption = _("Scanner and Driver Setup")
      Builtins.y2milestone(
        "Selected model is: %1",
        Ops.get(Scanner.database, Scanner.selected_model_database_index, {})
      )
      backend_name = Ops.get(
        Scanner.database,
        [Scanner.selected_model_database_index, "backend"],
        "unknown"
      )
      # The content here is only a dummy.
      # The real content is what the "Progress:..." shows in ActivateBackend().
      contents = Label("")
      # According to the YaST Style Guide (dated Tue, 04 Nov 2008)
      # the button with the "back" functionality is unchanged
      # when it is not the first dialog of a wizard stlye dialog sequence.
      # According to the YaST Style Guide (dated Tue, 04 Nov 2008)
      # the last "next" button of a wizard-style dialog sequence must be named "finish":
      Wizard.SetContentsButtons(
        caption,
        contents,
        Ops.get_string(@HELPS, "configure_backend", ""),
        Label.BackButton,
        Label.FinishButton
      )
      # According to the YaST Style Guide (dated Tue, 04 Nov 2008)
      # there is no longer a "abort" functionality which exits the whole module
      # for a wizard stlye dialog sequence.
      # Instead within a wizard stlye dialog sequence the button with the
      # "abort" functionality is now named "Cancel" and it does not abort the whole module
      # but goes back to the Overvied dialog because it reads
      # "Cancel - Closes the window and returns to the overview."
      # But in this special case it does not make sense to just return to the overview
      # because it is not clear if the right now enabled backend should be disabled
      # (the same backend could be already used for another scanner)
      # so that I do not show any "abort"/"cancel" button here at all:
      Wizard.HideAbortButton
      Wizard.DisableBackButton
      Wizard.DisableNextButton
      if !Scanner.ActivateBackend(
          "",
          Scanner.selected_model_database_index,
          true
        )
        Popup.Error(
          Builtins.sformat(
            # Only a simple message because before the function Scanner::ActivateBackend
            # was called and this function would have shown more specific messages.
            _("Failed to activate %1."),
            backend_name
          ) # Message of a Popup::Error where %1 will be replaced by the driver (backend) name.
        )
        Wizard.EnableBackButton
        Wizard.EnableNextButton
      else
        # and then automatically proceed to the 'next' dialog which is the overview dialog.
        # Therefore there is no way 'back' when Scanner::ActivateBackend(...) was successful
        # (which makes sense because why should the user undo right now what was successful)
        # so that 'back' is only possible if Scanner::ActivateBackend(...) failed or when it
        # was aborted by the user (e.g. when the user aborted to install a required package):
        Wizard.EnableNextButton
        Builtins.sleep(2000)
        UI.FakeUserInput(:next)
      end
      ret = nil
      while true
        ret = UI.UserInput
        if ret == :back
          Wizard.DisableBackButton
          Wizard.DisableNextButton
          if !Scanner.DeactivateBackend(
              "",
              Scanner.selected_model_database_index,
              false
            )
            Popup.Error(
              Builtins.sformat(
                # Only a simple message because before the function Scanner::DeactivateBackend
                # was called and this function would have shown more specific messages.
                _("Failed to deactivate %1."),
                backend_name
              ) # Message of a Popup::Error where %1 will be replaced by the driver (backend) name.
            )
          end
          Wizard.EnableBackButton
          Wizard.EnableNextButton
          break
        end
        break if ret == :next
        Builtins.y2milestone(
          "Ignoring unexpected returncode in ConfigureBackendDialog: %1",
          ret
        )
        next
      end
      deep_copy(ret)
    end

    # Network scanning dialog
    # @return dialog result
    def ConfigureNetworkScanningDialog
      firewall_popup_was_shown = false
      # Determine the network scanning config
      # but don't care if this fails because then empty strings are used as secure fallback
      # and empty strings will disable scanning via network (i.e. the net backend and the saned):
      Scanner.DetermineNetworkScanningConfig
      net_backend_hosts = Ops.get(
        Scanner.network_scanning_config,
        "net_backend_hosts",
        ""
      )
      saned_hosts = Ops.get(Scanner.network_scanning_config, "saned_hosts", "")
      # Caption of the ConfigureNetworkScanningDialog:
      caption = _("Set Up Scanning via Network")
      # Header of a TextEntry user input field.
      # Do not change or translate "saned", it is a program (sane daemon) name.
      saned_hosts_input_label = _("Permitted &Clients for saned")
      # Header of a TextEntry user input field.
      # Do not change or translate "net", it is a metadriver name.
      # Do not simply use "driver" because net is no normal driver but a metadriver.
      net_backend_hosts_input_label = _("&Servers Used for the net Metadriver")
      # Predefibed values for the so called "local host configuration":
      # The trailing ',' is intentional:
      # It results a nice linefed at the end of the config file and
      # the user can simply append something without the need to add a ',' as seperator:
      saned_hosts_input_local_host_config_value = "127.0.0.0/8,"
      net_backend_hosts_input_local_host_config_value = "localhost,"
      # All contenst of the scanning via network dialog:
      contents = VBox(
        VStretch(),
        Frame(
          _("Server Settings"),
          TextEntry(
            Id(:saned_hosts_input),
            saned_hosts_input_label,
            saned_hosts
          )
        ), # Label of a Frame for the server settings for scanning via network.
        VStretch(),
        Frame(
          _("Client Settings"),
          TextEntry(
            Id(:net_backend_hosts_input),
            net_backend_hosts_input_label,
            net_backend_hosts
          )
        ), # Label of a Frame for the client settings for scanning via network.
        VStretch(),
        Frame(
          _("Predefined Configurations"),
          VBox(
            Left(
              PushButton(
                Id(:local_host_config),
                # Label of a PushButton for a predefined configuration.
                # Be careful when you change or translate "local host configuration"
                # because this term is used also in the help text
                # and in a message of a Popup::ContinueCancel
                _("&Local Host Configuration")
              )
            ),
            Left(
              PushButton(
                Id(:disable_scanning_via_network),
                # Label of a PushButton to disable scanning via network.
                # Do not confuse "scanning via network"
                # (i.e. use a remote scanner via another host in the network)
                # with "scanning the network"
                # (i.e. scan the network for other hosts or services).
                _("&Disable Scanning via Network")
              )
            )
          )
        ), # Label of a Frame for predefined configurations.
        VStretch()
      )
      # According to the YaST Style Guide (dated Tue, 04 Nov 2008)
      # there is no longer a "abort" functionality which exits the whole module.
      # Instead this button is now named "Cancel" and its functionality is
      # to go back to the Overview dialog (i.e. what the "back" button would do)
      # because it reads "Cancel - Closes the window and returns to the overview."
      # Therefore the button with the "abort" functionality is not shown at all
      # and the button with the "back" functionality is named "Cancel".
      # According to the YaST Style Guide (dated Tue, 04 Nov 2008)
      # the "finish" button in a single (step) configuration dialog must now be named "OK".
      Wizard.SetContentsButtons(
        caption,
        contents,
        Ops.get_string(@HELPS, "configure_network_scanning", ""),
        Label.CancelButton,
        Label.OKButton
      )
      Wizard.HideAbortButton
      if ("" != Builtins.filterchars(net_backend_hosts, Scanner.alnum_chars) ||
          "" != Builtins.filterchars(saned_hosts, Scanner.alnum_chars)) &&
          (net_backend_hosts_input_local_host_config_value != net_backend_hosts ||
            saned_hosts_input_local_host_config_value != saned_hosts)
        # or when the current saned_hosts value is effectively non-empty
        # and when at least one is not only those of a "Local Host Configuration"
        # test whether or not a firewall seems to be active and
        # if yes show a popup regarding firewall:
        firewall_popup_was_shown = true if Scanner.ShowFirewallPopup
      end
      ret = nil
      while true
        ret = UI.UserInput
        # local host configuration
        if ret == :local_host_config
          UI.ChangeWidget(
            Id(:saned_hosts_input),
            :Value,
            saned_hosts_input_local_host_config_value
          )
          UI.ChangeWidget(
            Id(:net_backend_hosts_input),
            :Value,
            net_backend_hosts_input_local_host_config_value
          )
          next
        end
        # disable scanning via network
        if ret == :disable_scanning_via_network
          UI.ChangeWidget(Id(:saned_hosts_input), :Value, "")
          UI.ChangeWidget(Id(:net_backend_hosts_input), :Value, "")
          next
        end
        # set up the configuration
        if ret == :next
          net_backend_hosts = Convert.to_string(
            UI.QueryWidget(Id(:net_backend_hosts_input), :Value)
          )
          saned_hosts = Convert.to_string(
            UI.QueryWidget(Id(:saned_hosts_input), :Value)
          )
          if ("" != Builtins.filterchars(net_backend_hosts, Scanner.alnum_chars) ||
              "" != Builtins.filterchars(saned_hosts, Scanner.alnum_chars)) &&
              (net_backend_hosts_input_local_host_config_value != net_backend_hosts ||
                saned_hosts_input_local_host_config_value != saned_hosts)
            # or when the current saned_hosts value is effectively non-empty
            # and when at least one is not only those of a "Local Host Configuration"
            # test whether or not a firewall seems to be active and
            # if yes show a popup regarding firewall if it was not yet shown:
            if !firewall_popup_was_shown
              firewall_popup_was_shown = true if Scanner.ShowFirewallPopup
            end
          end
          Ops.set(
            Scanner.network_scanning_config,
            "net_backend_hosts",
            net_backend_hosts
          )
          Ops.set(Scanner.network_scanning_config, "saned_hosts", saned_hosts)
          Wizard.DisableBackButton
          Wizard.DisableNextButton
          if !Scanner.SetupNetworkScanningConfig
            Wizard.EnableBackButton
            Wizard.EnableNextButton
            next
          end
          Wizard.EnableBackButton
          Wizard.EnableNextButton
          break
        end
        break if ret == :back
        Builtins.y2milestone(
          "Ignoring unexpected returncode in ConfigureNetworkScanningDialog: %1",
          ret
        )
        next
      end
      deep_copy(ret)
    end
  end
end
