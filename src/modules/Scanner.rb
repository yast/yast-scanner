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

# File:        modules/Scanner.ycp
# Package:     Configuration of scanner
# Summary:     Scanner settings, input and output functions
# Authors:     Johannes Meixner <jsmeix@suse.de>
#
# $Id$
#
# Representation of the configuration of scanner.
# Input and output routines.
require "yast"

module Yast
  class ScannerClass < Module
    def main
      Yast.import "UI"
      textdomain "scanner"

      Yast.import "Progress"
      Yast.import "Popup"
      Yast.import "Package"
      Yast.import "Label"
      Yast.import "Service"
      Yast.import "Arch"

      # Something was committed to the system?
      # True if system may have been modified.
      @modified = false


      @proposal_valid = false

      # Write only, used during autoinstallation.
      # Don't run services and SuSEconfig, it's all done at one place.
      @write_only = false

      # Settings:
      # Define all variables needed for configuration of scanner:

      # Explicite listing of all alphanumeric ASCII characters.
      # The reason is that in certain special locales for example [a-z] is not equivalent
      # to "abcdefghijklmnopqrstuvwxyz" because in certain special languages the 'z' is
      # not the last character in the alphabet, e.g. the Estonian alphabet ends
      # with ... s ... z ... t u v w ... x y (non-ASCII characters omitted here)
      # so that [a-z] would exclude t u v w x y in an Estonian locale.
      # Therefore uppercase and lowercase characters are both explicitly listed
      # to avoid any unexpected result e.g. of "tolower(uppercase_characters)".
      @number_chars = "0123456789"
      @upper_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      @lower_chars = "abcdefghijklmnopqrstuvwxyz"
      @letter_chars = Ops.add(@upper_chars, @lower_chars)
      @alnum_chars = Ops.add(@number_chars, @letter_chars)
      @lower_alnum_chars = Ops.add(@number_chars, @lower_chars)

      # Scanner database:
      # When package version of sane-backends/hplip/iscan/iscan-free changes
      # the database is created anew in Scanner::Read() which calls the bash script
      # "/usr/lib/YaST2/bin/create_scanner_database YCP"
      # which outputs on stdout a YCP list of {#scanner_model_map}
      # where the last list entry is an emtpy map.
      #
      # **Structure:**
      #
      #     scanner_model_map
      #      $[ "package":"The package which provides the backend: sane-backends/hplip/iscan/iscan-free (required)",
      #         "backend":"The name of the backend (required)",
      #         "version":"The backend's arbitrary version string or 'unmaintained' (may be the empty string)",
      #         "manufacturer":"The manufacturer name of the scanner (required)",
      #         "model":"The model name of the scanner (required)",
      #         "firmware":"Whether or not firmware upload is required (value is 'required' or the empty string)",
      #         "interface":"None or one or more scanner interfaces (may be the empty string)",
      #         "usbid":"USBvendorID:USBproductID" e.g. "0x0a1b:0x2c3d" (may be the empty string)",
      #         "status":"The support status: basic/complete/good/minimal/unsupported/untested (required)",
      #         "comment":"An optional comment (may be the empty string)"
      #       ]
      @database = []

      # Manufacturer list:
      # List of unique manufacturer names.
      # Derived during startup from the scanner database
      # (in the Read function stage "Read or create the scanner database").
      @database_manufacturers = []

      # Known USB scanner USB IDs list:
      # List of known USB scanner USB vendor and product IDs.
      # Derived during startup from the scanner database
      # (in the Read function stage "Read or create the scanner database").
      @database_usbids = []

      # Active scanners:
      # Determined at runtime via Scanner::DetermineActiveScanners() which calls the bash script
      # "/usr/lib/YaST2/bin/determine_active_scanners YCP"
      # which outputs on stdout a YCP list of {#active_scanner_map}
      # where the last list entry is an emtpy map.
      #
      # **Structure:**
      #
      #     active_scanner_map
      #      $[ "backend":"The name of the backend (required)",
      #         "sane_device":"The SANE device (required)",
      #         "manufacturer":"The manufacturer name of the scanner (required)",
      #         "model":"The model name of the scanner (required)",
      #       ]
      @active_scanners = []

      # Active backends:
      # Determined at runtime via Scanner::DetermineActiveBackends() which calls the bash script
      # "/usr/lib/YaST2/bin/determine_active_scanner_backends YCP"
      # which outputs on stdout a YCP list of backends
      # [ "The name of the backend", ... "" ]
      # where the last list entry is an empty string.
      @active_backends = []

      # Autodetected scanners:
      # Determined at runtime via Scanner::AutodetectScanners()
      # which calls the bash script /usr/lib/YaST2/bin/autodetect_scanners YCP
      # which calls "sane-find-scanner" and (if available) "hp-probe"
      # which may result for example the description strings in the example below.
      # Only in case of USB an automated extraction of manufacturer is possible.
      # If there are two '[...]' substrings then the first one is the manufacturer
      # and the second one is the model (but there may be only one or none substring).
      # The result is a YCP list of {#autodetected_scanner_map}
      # where the last list entry is an emtpy map.
      #
      # **Structure:**
      #
      #     autodetected_scanner_map
      #      $[ "connection":"Either USB or SCSI or NETWORK (required)",
      #         "device":"The device, e.g. '/dev/sg0' or 'libusb:001:002' (may be the empty string)"
      #         "manufacturer":"The manufacturer name of the scanner (may be the empty string)",
      #         "usb_vendor_id":"The vendor ID (e.g. 0x04b8) of a USB scanner (may be the empty string)",
      #         "model":"The model name of the scanner (may be the empty string)",
      #         "usb_product_id":"The product ID (e.g. 0x010b) of a USB scanner (may be the empty string)",
      #         "description":"The sane-find-scanner output description string (required)"
      #       ]
      # @example
      # SCSI processor 'HP C6270A 3846' at /dev/sg0
      # USB scanner (vendor=0x05da, product=0x20b0) at libusb:002:005
      # USB scanner (vendor=0x03f0 [Hewlett-Packard], product=0x0201 [HP ScanJet 6200C]) at libusb:002:006
      # USB scanner (vendor=0x04a9 [Canon], product=0x220e [CanoScan], chip=LM9832/3) at libusb:001:005
      # USB scanner (vendor=0x04b8 [EPSON], product=0x010b [Perfection1240]) at libusb:001:004
      # USB scanner (vendor=0x03f0 [HP], product=0x0000 [HP LaserJet 1220])
      # NETWORK scanner (vendor [HP], product [Officejet 7200 series])
      @autodetected_scanners = []

      # Network scanning configuration:
      # Determined at runtime via Scanner::DetermineNetworkScanningConfig() which calls the bash script
      # "/usr/lib/YaST2/bin/determine_network_scanner_config YCP"
      # which outputs on stdout a YCP map {#network_scanner_config}
      #
      # **Structure:**
      #
      #     network_scanner_config
      #      $[ "net_backend_hosts":"Comma seperated list of hosts in /etc/sane.d/net.conf",
      #         "saned_hosts":"Comma seperated list of hosts or subnets in /etc/sane.d/saned.conf"
      #       ]
      @network_scanning_config = {}

      # Environment values:
      # It is a map of {#environment_values}
      #
      # **Structure:**
      #
      #     environment_values
      #      $[ "sane-backends_version":"What 'rpm -q sane-backends' returns (required)",
      #         "hplip_version":"What 'rpm -q hplip' returns (required)",
      #         "iscan_version":"What 'rpm -q iscan' returns (required)"
      #         "iscan-free_version":"What 'rpm -q iscan-free' returns (required)"
      #       ]
      @actual_environment = {
        "sane-backends_version" => "",
        "hplip_version"         => "",
        "iscan_version"         => "",
        "iscan-free_version"    => ""
      }
      @stored_environment = {
        "sane-backends_version" => "",
        "hplip_version"         => "",
        "iscan_version"         => "",
        "iscan-free_version"    => ""
      }

      # Other global variables:

      # Selected model database index:
      # The index in the scanner database list (of model maps)
      # for the model which was selected by the user in the SelectModelDialog.
      # Preset to -1 which indicates that no model is selected.
      @selected_model_database_index = -1

      # Selected autodetected scanners index:
      # The index in the autodetected scanners list (of autodetected scanner maps)
      # for the model which was selected by the user in the OverviewDialog.
      # Preset to -1 which indicates that no model is selected.
      @selected_autodetected_scanners_index = -1

      # Ignore unknown USB scanners:
      # Whether or not unknown USB scanners should be ignored during AutodetectScanners.
      # As there is no USB device class for scanners (they have the unspecific USB device class 255),
      # sane-find-scanner can only do some best guess to determine if a USB device is a scanner or not.
      # Therefore also other USB devices with the device class 255 are reported as possible USB scanners.
      # Preset to true so that initially only scanners for which the USB IDs are known by SANE are shown.
      # It changes to false (i.e. show all USB devices with the device class 255 as possible USB scanners)
      # when the user explicitly requests a "Restart Detection" in the OverviewDialog.
      # A second "Restart Detection" changes it back to true so that "Restart Detection" toggles it.
      # The idea behind is that the user can simply "Restart Detection" as often as he likes
      # until the result is o.k. for him because "Restart Detection" does not cause harm and
      # it avoids a separated button or check-box to determine the autodetection behaviour
      # which would require additional explanatory (complicated) help text about the whole stuff.
      # Examples:
      # Assume there is a known powered-off USB scanner and another USB device with class 255:
      # Initially nothing is shown.
      # After the first "Restart Detection" only the other USB device with class 255 is shown.
      # This unexpected result makes the user think about what is wrong and he powers-on the scanner.
      # After the second "Restart Detection" only the USB scanner is shown.
      # Assume there is an unknown powered-off USB scanner and another USB device with class 255.
      # Initially nothing is shown.
      # After the first "Restart Detection" only the other USB device with class 255 is shown.
      # This unexpected result makes the user think about what is wrong and he powers-on the scanner.
      # After the second "Restart Detection" nothing is shown.
      # A third "Restart Detection" shows both the USB scanner and the other USB device with class 255.
      # This is the best possible result because it is not possible to show only the unknown USB scanner.
      @ignore_unknown_USB_scanners = true

      # Local variables:
      @environment_filename = "/var/lib/YaST2/stored_scanner_environment.ycp"
      @database_filename = "/var/lib/YaST2/scanner_database.ycp"
      @create_database_commandline = Ops.add(
        "/usr/lib/YaST2/bin/create_scanner_database YCP >",
        @database_filename
      )
      @active_scanners_filename = "/var/lib/YaST2/active_scanners.ycp"
      @determine_active_scanners_commandline = Ops.add(
        "/usr/lib/YaST2/bin/determine_active_scanners YCP >",
        @active_scanners_filename
      )
      @active_backends_filename = "/var/lib/YaST2/active_scanner_backends.ycp"
      @determine_active_scanner_backends_commandline = Ops.add(
        "/usr/lib/YaST2/bin/determine_active_scanner_backends YCP >",
        @active_backends_filename
      )
      @autodetected_scanners_filename = "/var/lib/YaST2/autodetected_scanners.ycp"
      @autodetect_scanners_commandline = Ops.add(
        "/usr/lib/YaST2/bin/autodetect_scanners YCP >",
        @autodetected_scanners_filename
      )
      @activate_backend_commandline = "/usr/lib/YaST2/bin/activate_scanner_backend"
      @deactivate_backend_commandline = "/usr/lib/YaST2/bin/deactivate_scanner_backend"
      @test_backend_commandline = "/usr/lib/YaST2/bin/test_scanner_backend"
      @setup_ptal_scanner_service_commandline = "/usr/lib/YaST2/bin/setup_ptal_scanner_service"
      @setup_hplip_scanner_service_commandline = "/usr/lib/YaST2/bin/setup_hplip_scanner_service"
      @network_scanning_config_filename = "/var/lib/YaST2/network_scanning_config.ycp"
      @determine_network_scanning_config_commandline = Ops.add(
        "/usr/lib/YaST2/bin/determine_network_scanner_config YCP >",
        @network_scanning_config_filename
      )
      @setup_network_scanning_config_commandline = "/usr/lib/YaST2/bin/setup_network_scanner_config"
      @test_and_set_scanner_access_permissions_commandline = "/usr/lib/YaST2/bin/test_and_set_scanner_access_permissions"
      # The result map is used as a simple common local store for whatever additional results
      # (in particular commandline exit code, stdout, stderr, and whatever messages)
      # so that the local functions in this module can be of	easy-to-use boolean type.
      # The following keys are used:
      # result["exit"]:<integer> for exit codes
      # result["stdout"]:<string> for stdout and whatever non-error-messages
      # result["stderr"]:<string> for stderr and whatever error-messages
      @result = { "exit" => 0, "stdout" => "", "stderr" => "" }
    end

    # Something was committed to the system?
    # @return true if system may have been modified
    def Modified
      @modified
    end

    # Abort function
    # @return true if not modified and user requested abort
    def Abort
      !Modified() && UI.PollInput == :abort
    end

    # Local functions:

    # Unify various kind of a hexadecimal string like
    # "0x01a2", "0x1A2", "0x01A2" to one kind "0x1a2"
    # so that string comparison is possible:
    def UnifyHexString(hexstring)
      Builtins.tolower(Builtins.tohexstring(Builtins.tointeger(hexstring)))
    end

    # Wrapper for SCR::Execute to execute a bash command to increase verbosity via y2milestone.
    # It reports the command via y2milestone in any case and it reports exit code, stdout
    # and stderr via y2milestone in case of non-zero exit code.
    # @param [String] bash_commandline string of the bash command to be executed
    # @return true on success
    def ExecuteBashCommand(bash_commandline)
      Builtins.y2milestone("Executing bash commandline: %1", bash_commandline)
      # Enforce a hopefully sane environment before running the actual command:
      bash_commandline = Ops.add(
        "export PATH='/sbin:/usr/sbin:/usr/bin:/bin' ; export LC_ALL='POSIX' ; export LANG='POSIX' ; umask 022 ; ",
        bash_commandline
      )
      @result = Convert.to_map(
        SCR.Execute(path(".target.bash_output"), bash_commandline)
      )
      if Ops.get_integer(@result, "exit", 9999) != 0
        Builtins.y2milestone(
          "'%1' exit code is: %2",
          bash_commandline,
          Ops.get_integer(@result, "exit", 9999)
        )
        Builtins.y2milestone(
          "'%1' stdout is: %2",
          bash_commandline,
          Ops.get_string(@result, "stdout", "")
        )
        Builtins.y2milestone(
          "'%1' stderr is: %2",
          bash_commandline,
          Ops.get_string(@result, "stderr", "")
        )
        return false
      end
      true
    end

    # Test whether an error message is meaningful (i.e. when it contains at least one letter character).
    # If yes, add a preceding "The error message is:" otherwise return the empty string.
    # @param [String] error_message string of the error message
    # @return [String] of a meaningful error message with preceding "The error message is:" or "" otherwise
    def OnlyMeaningfulErrorMessage(error_message)
      if "" != Builtins.filterchars(error_message, @letter_chars)
        return Builtins.sformat(
          # to add a preceding "The error message is:" comment
          # to display an error message where
          # %1 will be replaced by the actual error message:
          _("The error message is:\n\n%1"),
          error_message
        ) # Only a simple message because it is only used
      end
      ""
    end

    # Determine the version of an installed package by calling a bash command (rpm).
    # @param [String] package_name string of the package name
    # @return [String] of the version of an installed package or "failed to determine" otherwise
    def InstalledPackageVersion(package_name)
      return "not installed" if !Package.Installed(package_name)
      if !ExecuteBashCommand(
          Ops.add(
            Ops.add("/bin/rpm -q ", package_name),
            " | /usr/bin/tr -d '\n'"
          )
        )
        Popup.ErrorDetails(
          Builtins.sformat(
            # Only a simple message because this error does not happen on a normal system
            # (i.e. a system which is not totally broken or totally messed up).
            _("Failed to determine the version of package %1."),
            package_name
          ), # Message of a Popup::ErrorDetails where %1 will be replaced by the package name.
          Ops.get_string(@result, "stderr", "")
        )
      end
      Ops.get_string(@result, "stdout", "failed to determine")
    end

    # Test whether the package is installed (Package::Installed) and
    # if not then test whether the package is available to be installed (Package::Available) and
    # if yes then install it (Package::Install).
    # @param [String] package_name string of the package name
    # @return true on success
    def TestAndInstallPackage(package_name)
      iscan_message =
        # Message of a Popup::Error for models which require
        # the third-party Image Scan (IScan) driver software from Epson
        # (formerly Avasys, see https://bugzilla.novell.com/show_bug.cgi?id=746038).
        # Do not change or translate "Image Scan", it is a driver software name.
        # Do not change or translate "Avasys", it is a manufacturer name.
        # Do not change or translate "Epson", it is a manufacturer name.
        _(
          "The third-party Image Scan driver software from Epson/Avasys is required.\n" +
            "The Image Scan driver software is made and provided by Epson (formerly Avasys)\n" +
            "http://download.ebz.epson.net/dsc/search/01/search/?OSC=LXEpson\n" +
            "(formerly Avasys http://avasys.jp/eng/linux_driver/)\n" +
            "where RPM packages for 32-bit (i386) and 64-bit (x86_64) architecture\n" +
            "can be downloaded (if you accept the Epson/Avasys license agreements).\n" +
            "The Image Scan driver contains proprietary binary-only software.\n" +
            "For some models it is only available for 32-bit (i386) architecture\n" +
            "which does not work when you have a 64-bit system installation.\n" +
            "Some scanners are also supported by another (free-software) driver.\n" +
            "When your scanner model requires a DFSG non-free (proprietary) module,\n" +
            "you have to download and install two packages from Epson/Avasys:\n" +
            "The 'iscan' package for the base software and an additional\n" +
            "model dependant 'iscan-plugin' package with the proprietary module.\n"
        )
      return true if Package.Installed(package_name)
      if "iscan-free" == package_name && Package.Installed("iscan")
        # 'iscan' is the package name of the primary RPM which is provided by Epson/Avasys
        # (there are also additional iscan-plugin-<model-name> provided by Epson/Avasys).
        # If iscan is already installed, there is no need to switch to iscan-free.
        # Because iscan contains proprietary software it is not provided by openSUSE.
        # Therefore the user must have had downloaded it from Epson/Avasys
        # and then installed intentionally and manually.
        return true
      end
      if "iscan" == package_name
        Builtins.y2milestone(
          "Third-party Image Scan driver software from Epson/Avasys required."
        )
        Popup.Error(iscan_message)
        return false
      end
      # Is the package available to be installed?
      # Package::Available returns nil if no package source is available.
      package_available = Package.Available(package_name)
      if nil == package_available
        Builtins.y2milestone(
          "Required package %1 is not installed and there is no package repository available.",
          package_name
        )
        Popup.Error(
          Builtins.sformat(
            _(
              "Required package %1 is not installed and there is no package repository available."
            ),
            package_name
          ) # Message of a Popup::Error where %1 will be replaced by the package name:
        )
        return false
      end
      if !package_available
        Builtins.y2milestone(
          "Required package %1 is not installed and not available in the repository.",
          package_name
        )
        Popup.Error(
          Builtins.sformat(
            _(
              "Required package %1 is not installed and not available in the repository."
            ),
            package_name
          ) # Message of a Popup::Error where %1 will be replaced by the package name:
        )
        return false
      end
      if !Package.Install(package_name)
        Builtins.y2milestone(
          "Failed to install required package %1.",
          package_name
        )
        Popup.Error(
          # Only a simple message because:
          # Either the user has explicitly rejected to install the package,
          # or this error does not happen on a normal system
          # (i.e. a system which is not totally broken or totally messed up).
          Builtins.sformat(
            _("Failed to install required package %1."),
            package_name
          )
        )
        return false
      end
      true
    end

    # Determine the active scanners by calling a bash script
    # which calls "scanimage -L" and processes its output
    # and stores the results as YCP list in a temporary file
    # and then read the temporary file (SCR::Read)
    # to get the YCP list of {#active_scanner_map}
    # @return true on success
    def DetermineActiveScanners
      no_response_from_scanimage_message =
        # Message of a Popup::Error when there is no response from the 'scanimage' command.
        # Do not change or translate "net", it is a metadriver name.
        # Do not simply use "driver" because net is no normal driver but a metadriver.
        # Do not change or translate "scanimage -L", it is a fixed command.
        _(
          "Failed to determine the active scanners.\n" +
            "If the net metadriver is activated while there is a problem\n" +
            "with the network, the 'scanimage -L' command may not respond. For example,\n" +
            "this may happen if communication with a server used by the net metadriver\n" +
            "gets distorted because a firewall drops some network traffic.\n" +
            "In this case, disable the net metadriver until the issue in the network is fixed.\n"
        )
      if !ExecuteBashCommand(@determine_active_scanners_commandline)
        if 10 == Ops.get_integer(@result, "exit", 9999)
          # that there was no response from the 'scanimage' command
          # so that it was killed after a timeout (usually 60 seconds).
          # Do not show result["stderr"] which is the same as
          # the no_response_from_scanimage_message but untranslated:
          Popup.Error(no_response_from_scanimage_message)
          return false
        end
        Popup.ErrorDetails(
          # Only a simple message because this error does not happen on a normal system
          # (i.e. a system which is not totally broken or totally messed up).
          # Do not confuse this error with the case when no active scanner was determined.
          # The latter results no error.
          _("Failed to determine the active scanners."),
          Ops.get_string(@result, "stderr", "")
        )
        return false
      end
      if -1 == SCR.Read(path(".target.size"), @active_scanners_filename)
        Builtins.y2milestone(
          "Error: %1: file does not exist.",
          @active_scanners_filename
        )
        Popup.Error(
          Builtins.sformat(
            # Only a simple message because this error does not happen on a normal system
            # (i.e. a system which is not totally broken or totally messed up).
            _("File %1 does not exist."),
            @active_scanners_filename
          ) # Message of a Popup::Error where %1 will be replaced by the file name.
        )
        return false
      end
      @active_scanners = Convert.convert(
        SCR.Read(path(".target.ycp"), @active_scanners_filename),
        :from => "any",
        :to   => "list <map <string, string>>"
      )
      if nil == @active_scanners
        Builtins.y2milestone(
          "Error: Failed to read %1",
          @active_scanners_filename
        )
        Popup.Error(
          Builtins.sformat(
            # Only a simple message because this error does not happen on a normal system
            # (i.e. a system which is not totally broken or totally messed up).
            _("Failed to read %1."),
            @active_scanners_filename
          ) # Message of a Popup::Error where %1 will be replaced by the file name.
        )
        @active_scanners = []
        return false
      end
      Builtins.y2milestone("Active scanners: %1", @active_scanners)
      true
    end

    # Determine the active backends by calling a bash script
    # which calls "grep ... /etc/sane.d/dll.conf" and processes its output
    # and stores the results as YCP list in a temporary file
    # and then read the temporary file (SCR::Read)
    # to get the YCP list of active backends.
    # @return true on success
    def DetermineActiveBackends
      if !ExecuteBashCommand(@determine_active_scanner_backends_commandline)
        Popup.ErrorDetails(
          # Only a simple message because this error does not happen on a normal system
          # (i.e. a system which is not totally broken or totally messed up).
          # Do not confuse this error with the case when no active driver was determined.
          # The latter results no error.
          _("Failed to determine the active drivers."),
          Ops.get_string(@result, "stderr", "")
        )
        return false
      end
      if -1 == SCR.Read(path(".target.size"), @active_backends_filename)
        Builtins.y2milestone(
          "Error: %1: file does not exist.",
          @active_backends_filename
        )
        Popup.Error(
          Builtins.sformat(
            # Only a simple message because this error does not happen on a normal system
            # (i.e. a system which is not totally broken or totally messed up).
            _("File %1 does not exist."),
            @active_backends_filename
          ) # Message of a Popup::Error where %1 will be replaced by the file name.
        )
        return false
      end
      @active_backends = Convert.convert(
        SCR.Read(path(".target.ycp"), @active_backends_filename),
        :from => "any",
        :to   => "list <string>"
      )
      if nil == @active_backends
        Builtins.y2milestone(
          "Error: Failed to read %1",
          @active_backends_filename
        )
        Popup.Error(
          Builtins.sformat(
            # Only a simple message because this error does not happen on a normal system
            # (i.e. a system which is not totally broken or totally messed up).
            _("Failed to read %1."),
            @active_backends_filename
          ) # Message of a Popup::Error where %1 will be replaced by the file name.
        )
        @active_backends = []
        return false
      end
      Builtins.y2milestone("Active backends: %1", @active_backends)
      true
    end

    # Try to autodetect USB and SCSI scanners and HP all-in-one USB and NETWORK scanners
    # by calling a bash script which calls "sane-find-scanner"
    # and (if available) "hp-probe" and processes its output
    # and stores the results as YCP list in a temporary file
    # and then read the temporary file (SCR::Read)
    # to get the YCP list of {#autodetected_scanner_map}
    # @return true on success
    def AutodetectScanners
      if !ExecuteBashCommand(@autodetect_scanners_commandline)
        Popup.ErrorDetails(
          # Only a simple message because this error does not happen on a normal system
          # (i.e. a system which is not totally broken or totally messed up).
          # Do not confuse this error with the case when no scanner was autodetected.
          # The latter results no error.
          _("Failed to detect scanners automatically."),
          Ops.get_string(@result, "stderr", "")
        )
        return false
      end
      if -1 == SCR.Read(path(".target.size"), @autodetected_scanners_filename)
        Builtins.y2milestone(
          "Error: %1: file does not exist.",
          @autodetected_scanners_filename
        )
        Popup.Error(
          Builtins.sformat(
            # Only a simple message because this error does not happen on a normal system
            # (i.e. a system which is not totally broken or totally messed up).
            _("File %1 does not exist."),
            @autodetected_scanners_filename
          ) # Message of a Popup::Error where %1 will be replaced by the file name.
        )
        return false
      end
      @autodetected_scanners = Convert.convert(
        SCR.Read(path(".target.ycp"), @autodetected_scanners_filename),
        :from => "any",
        :to   => "list <map <string, string>>"
      )
      if nil == @autodetected_scanners
        Builtins.y2milestone(
          "Error: Failed to read %1",
          @autodetected_scanners_filename
        )
        Popup.Error(
          Builtins.sformat(
            # Only a simple message because this error does not happen on a normal system
            # (i.e. a system which is not totally broken or totally messed up).
            _("Failed to read %1."),
            @autodetected_scanners_filename
          ) # Message of a Popup::Error where %1 will be replaced by the file name.
        )
        @autodetected_scanners = []
        return false
      end
      if @ignore_unknown_USB_scanners
        # Therefore for unknown USB scanners the description is set to the empty string.
        autodetected_scanners_index = -1
        Builtins.foreach(@autodetected_scanners) do |autodetected_scanner|
          # of the actual autodetected_scanner in autodetected_scanners:
          autodetected_scanners_index = Ops.add(autodetected_scanners_index, 1)
          # Use local variables to have shorter variable names:
          usb_vendor_id = Ops.get(autodetected_scanner, "usb_vendor_id", "")
          usb_product_id = Ops.get(autodetected_scanner, "usb_product_id", "")
          if "" != usb_vendor_id && "" != usb_product_id
            usb_id = Ops.add(
              Ops.add(UnifyHexString(usb_vendor_id), ":"),
              UnifyHexString(usb_product_id)
            )
            if !Builtins.contains(@database_usbids, usb_id)
              Ops.set(
                @autodetected_scanners,
                [autodetected_scanners_index, "description"],
                ""
              )
              Builtins.y2milestone(
                "No USB ID in database for %1",
                autodetected_scanner
              )
            end
          end
        end
      end
      Builtins.y2milestone("Autodetected scanners: %1", @autodetected_scanners)
      true
    end

    # Test whether there exist a print queue which depends on the specified SANE backend.
    # Examples:
    # hpaio (package hplip):
    # Setting up the hpaio backend activates also the hplip service.
    # It may happen that the conflicting service ptal is in use by the CUPS printing system.
    # I.e. there may be a print queue which uses the ptal CUPS backend.
    # hpoj (package hp-officeJet):
    # Setting up the hpoj backend requires to initialize/activate/start the ptal service.
    # It may happen that the conflicting service hplip is in use.
    # I.e. there may be a print queue which uses the hp CUPS backend.
    # Note:
    # The test is only implememnted for the CUPS printing system.
    # A dependant print queue can exists only for the SANE backends hpaio and hpoj.
    # For all other backends no dependant print queue can exists.
    # @param [String] backend_name string of the SANE backend name
    # @return true if a dependant CUPS print queue exists for the backends hpaio or hpoj
    def DependantPrintQueueExists(backend_name)
      #   device for Queue1: hp:/usb/DeskJet_990C?serial=MX09R1T14QLH
      #   device for Queue2: hp:/net/Officejet_7200_series?ip=10.10.100.100
      # Example of a "/usr/bin/lpstat -v" output when the hpfax CUPS backend is used:
      #   device for Queue3: hpfax:/net/Officejet_7200_series?ip=10.10.100.100
      # Examples of a "/usr/bin/lpstat -v" output when the ptal CUPS backend is used:
      #   device for Queue4: ptal:/mlc:par:HP_LaserJet_1220
      #   device for Queue5: ptal:/mlc:usb:HP_LaserJet_1220
      # If /usr/bin/lpstat (from the package cups-client) is not installed
      # or if it is not from CUPS (e.g. from LPRng or from a third-party printing system)
      # and doesn't support the -v parameter or results a different output
      # then it returns "false" which is perfectly o.k. because then
      # there is no CUPS printing system installed (because cups requires cups-client)
      # and then no print queue exists which uses a CUPS backend.
      # Note that therefore it is not detected when the hplip service or the ptal service
      # is required by a print queue for LPRng or for a third-party printing system.
      if "hpaio" == backend_name
        return ExecuteBashCommand(
          "/usr/bin/lpstat -v | /bin/egrep -q ': hp:/|: hpfax:/'"
        )
      end
      if "hpoj" == backend_name
        return ExecuteBashCommand(
          "/usr/bin/lpstat -v | /bin/grep -q ': ptal:/'"
        )
      end
      # Fallback to false i.e. assume that there is no conflicting print queue:
      false
    end

    # Global functions:

    # Read all scanner settings:
    # - Check installed packages
    # - Read or create the scanner database
    # - Determine active scanners
    # - Determine active backends
    # - Try to autodetect USB and SCSI scanners and HP all-in-one USB and NETWORK scanners
    # @return true on success
    def Read
      Progress.New(
        _("Initializing Scanner Configuration"),
        " ",
        5,
        [
          _("Check installed packages"),
          # 2. progress stage name of a Progress::New:
          _("Read or create the scanner database"),
          # 3. progress stage name of a Progress::New:
          _("Determine active scanners"),
          # 4. progress stage name of a Progress::New:
          _("Determine active drivers"),
          # 5. progress stage name of a Progress::New:
          _("Detect scanners")
        ], # 1. progress stage name of a Progress::New:
        [
          _("Checking installed packages..."),
          # 2. progress step progress bar title of a Progress::New:
          _("Reading or creating the scanner database..."),
          # 3. progress step progress bar title of a Progress::New:
          _("Determining active scanners..."),
          # 4. progress step progress bar title of a Progress::New:
          _("Determining active drivers..."),
          # 5. progress step progress bar title of a Progress::New:
          _("Detecting scanners..."),
          # Last progress step progress bar title of a Progress::New:
          _("Finished")
        ], # 1. progress step progress bar title of a Progress::New:
        ""
      )
      # Progress 1. stage (Check installed packages):
      return false if Abort()
      Progress.NextStage
      # Make sure the package sane is installed (otherwise abort):
      return false if !TestAndInstallPackage("sane-backends")
      # Check installed package version of sane-backends, hplip, iscan, iscan-free:
      Ops.set(
        @actual_environment,
        "sane-backends_version",
        InstalledPackageVersion("sane-backends")
      )
      Ops.set(
        @actual_environment,
        "hplip_version",
        InstalledPackageVersion("hplip")
      )
      Ops.set(
        @actual_environment,
        "iscan_version",
        InstalledPackageVersion("iscan")
      )
      Ops.set(
        @actual_environment,
        "iscan-free_version",
        InstalledPackageVersion("iscan-free")
      )
      Builtins.y2milestone(
        "Version of sane-backends, hplip, iscan, iscan-free: %1, %2, %3, %4",
        Ops.get(@actual_environment, "sane-backends_version", "failed"),
        Ops.get(@actual_environment, "hplip_version", "failed"),
        Ops.get(@actual_environment, "iscan_version", "failed"),
        Ops.get(@actual_environment, "iscan-free_version", "failed")
      )
      # Read stored environment:
      if -1 != SCR.Read(path(".target.size"), @environment_filename)
        @stored_environment = Convert.convert(
          SCR.Read(path(".target.ycp"), @environment_filename),
          :from => "any",
          :to   => "map <string, string>"
        )
        if @stored_environment == nil
          Builtins.y2milestone(
            "Warning: Failed to read the stored environment."
          )
          @stored_environment = {
            "sane-backends_version" => "failed to read",
            "hplip_version"         => "failed to read",
            "iscan_version"         => "failed to read",
            "iscan-free_version"    => "failed to read"
          }
        end
      end
      # Progress 2. stage (Read or create the scanner database):
      return false if Abort()
      Progress.NextStage
      if Ops.get(@actual_environment, "sane-backends_version", "0") !=
          Ops.get(@stored_environment, "sane-backends_version", "1") ||
          Ops.get(@actual_environment, "hplip_version", "0") !=
            Ops.get(@stored_environment, "hplip_version", "1") ||
          Ops.get(@actual_environment, "iscan_version", "0") !=
            Ops.get(@stored_environment, "iscan_version", "1") ||
          Ops.get(@actual_environment, "iscan-free_version", "0") !=
            Ops.get(@stored_environment, "iscan-free_version", "1") ||
          -1 == SCR.Read(path(".target.size"), @database_filename)
        feedback_message = _("Creating scanner database...")
        progress_feedback = UI.HasSpecialWidget(:DownloadProgress)
        if progress_feedback
          # Empty an existing database file so that the DownloadProgress starts at the beginning.
          ExecuteBashCommand(Ops.add("cat /dev/null >", @database_filename))
          UI.OpenDialog(
            MinSize(
              60,
              3,
              ReplacePoint(
                Id(:create_database_progress_replace_point),
                DownloadProgress(
                  feedback_message,
                  @database_filename,
                  # On my openSUSE 11.4 the size is about 930000 bytes.
                  # The number 1024000 results exactly "1000.0 KB" in the
                  # YaST Gtk user inteface for a DownloadProgress:
                  1024000
                )
              )
            )
          )
        else
          Popup.ShowFeedback("", feedback_message)
        end
        if !ExecuteBashCommand(@create_database_commandline)
          if progress_feedback
            UI.CloseDialog
          else
            Popup.ClearFeedback
          end
          Popup.ErrorDetails(
            # Only a simple message because this error does not happen on a normal system
            # (i.e. a system which is not totally broken or totally messed up).
            _("Aborting: Failed to create the scanner database."),
            Ops.get_string(@result, "stderr", "")
          )
          return false
        end
        if progress_feedback
          # ExpectedSize to 1 (setting it to 0 results wrong output) by calling
          # UI::ChangeWidget( `id(`create_database_progress), `ExpectedSize, 1 )
          # results bad looking output because the DownloadProgress widget is visible re-drawn
          # first with a small 1% initially starting progress bar which then jumps up to 100%
          # but what is intended is that the current progress bar jumps directly up to 100%.
          # Therefore DownloadProgress is not used at all but replaced by a 100% ProgressBar.
          # Because ProgressBar has a different default width than DownloadProgress,
          # a MinWidth which is sufficient for both is set above.
          # The size is measured in units roughly equivalent to the size of a character
          # in the respective UI (1/80 of the full screen width horizontally,
          # 1/25 of the full screen width vertically) where full screen size
          # is 640x480 pixels (y2qt) or 80x25 characters (y2ncurses).
          UI.ReplaceWidget(
            Id(:create_database_progress_replace_point),
            ProgressBar(feedback_message, 100, 100)
          )
          # Sleep half a second to let the user notice that the progress is finished:
          Builtins.sleep(500)
          UI.CloseDialog
        else
          Popup.ClearFeedback
        end
      end
      @database = Convert.convert(
        SCR.Read(path(".target.ycp"), @database_filename),
        :from => "any",
        :to   => "list <map <string, string>>"
      )
      if @database == nil
        Builtins.y2milestone("Aborting: Failed to read %1", @database_filename)
        Popup.Error(
          Builtins.sformat(
            # Only a simple message because this error does not happen on a normal system
            # (i.e. a system which is not totally broken or totally messed up).
            _("Aborting: Failed to read %1."),
            @database_filename
          ) # Message of a Popup::Error where %1 will be replaced by the file name.
        )
        return false
      end
      # Extract a (sorted) list of unique manufacturer names and
      # another list of known USB scanner USB vendor and product IDs
      # from the scanner database.
      # The latter makes sense because it is needed in AutodetectScanners
      # because ignore_unknown_USB_scanners is set to true by default.
      usbid = ""
      ids = []
      Builtins.foreach(@database) do |database_entry|
        @database_manufacturers = Builtins.add(
          @database_manufacturers,
          Ops.get(database_entry, "manufacturer", "unknown")
        )
        usbid = Builtins.tolower(Ops.get(database_entry, "usbid", ""))
        if Builtins.regexpmatch(usbid, "0x[0-9a-f]+:0x[0-9a-f]+")
          ids = Builtins.splitstring(usbid, ":")
          @database_usbids = Builtins.add(
            @database_usbids,
            Ops.add(
              Ops.add(UnifyHexString(Ops.get(ids, 0, "")), ":"),
              UnifyHexString(Ops.get(ids, 1, ""))
            )
          )
        end
      end 

      @database_manufacturers = Builtins.toset(@database_manufacturers)
      @database_usbids = Builtins.toset(@database_usbids)
      # Progress 3. stage (Determine active scanners):
      return false if Abort()
      Progress.NextStage
      @active_scanners = [] if !DetermineActiveScanners()
      # Progress 4. stage (Determine active drivers):
      return false if Abort()
      Progress.NextStage
      @active_backends = [] if !DetermineActiveBackends()
      # Progress 5. stage (Detect scanners):
      return false if Abort()
      Progress.NextStage
      if !AutodetectScanners()
        @autodetected_scanners = []
      else
        # Sometimes AutodetectScanners (i.e. "sane-find-scanner") doesn't detect a scanner
        # but usually it works well for a second attempt when it is run a bit later.
        # At the moment the exact reason is unknown.
        # Therefore AutodetectScanners is simply called a second time (after waiting a bit)
        # if it ran without errors but didn't detect a scanner on the first run.
        # At least one sane-find-scanner output description string must exist
        # if sane-find-scanner had detected a scanner:
        if "no description" ==
            Ops.get(
              @autodetected_scanners,
              [0, "description"],
              "no description"
            )
          Builtins.y2milestone(
            "No autodetected scanners on the first run. To be safe wait a bit and then run AutodetectScanners a second time."
          )
          # Show feedback because it takes a few seconds:
          Popup.ShowFeedback(
            "",
            # Busy message:
            # Body of a Popup::ShowFeedback:
            _("Detecting scanners...")
          )
          # Wait 10 seconds:
          Builtins.sleep(10000)
          Popup.ClearFeedback
          @autodetected_scanners = [] if !AutodetectScanners()
        end
      end
      # Progress last stage (progress finished):
      return false if Abort()
      Progress.Finish
      # Sleep one second to let the user notice that the progress has finished:
      Builtins.sleep(1000)
      return false if Abort()
      true
    end

    # Write scanner settings:
    # - Save the actual environment
    # @return true on success
    def Write
      Progress.New(
        _("Writing Scanner Configuration"),
        " ",
        1,
        [_("Save the actual environment")], # 1. progress stage name of a Progress::New:
        [
          _("Saving the actual environment..."),
          # Last progress step progress bar title of a Progress::New:
          _("Finished")
        ], # 1. progress step progress bar title of a Progress::New:
        ""
      )
      # Progress first stage (Save the actual environment):
      return false if Abort()
      Progress.NextStage
      if !SCR.Write(
          path(".target.ycp"),
          @environment_filename,
          @actual_environment
        )
        Builtins.y2milestone("Warning: Failed to save the actual environment.")
      end
      # Progress last stage (progress finished):
      return false if Abort()
      Progress.Finish
      # Sleep one second to let the user notice that the progress has finished:
      Builtins.sleep(1000)
      return false if Abort()
      true
    end

    # Restart the whole autodetection by calling all autodetection functions
    # in the same order as during the initial Read():
    # DetermineActiveScanners results a new active_scanners map
    # which is empty if nothing was detected or if DetermineActiveScanners fails.
    # DetermineActiveBackends results a new active_backends list
    # which is empty if nothing was detected or if DetermineActiveBackends fails.
    # AutodetectScanners results a new autodetected_scanners map
    # which is empty if nothing was detected or if AutodetectScanners fails.
    # RestartDetection is called when the user restarts the detection in the OverviewDialog
    # and if testing of an active scanner failed (see the TestBackend function).
    # The result is that all information in the OverviewDialog is recreated.
    # @return true in any case (errors result only empty maps or list).
    def RestartDetection
      Popup.ShowFeedback(
        "",
        # Busy message:
        # Body of a Popup::ShowFeedback:
        _("Detecting scanners...")
      )
      @active_scanners = [] if !DetermineActiveScanners()
      @active_backends = [] if !DetermineActiveBackends()
      @autodetected_scanners = [] if !AutodetectScanners()
      Popup.ClearFeedback
      true
    end

    # Run hp-setup:
    # @return false if hp-setup cannot be run and return true in any other case
    # because there is no usable exit code of hp-setup (always zero even in case of error).
    def RunHpsetup
      ptal_in_use_conflict_message =
        # Message of a Popup::Error when hp-setup should be run.
        # Do not change or translate "ptal", it is a service name.
        # Do not change or translate "hp-setup", it is a program name.
        # Do not change or translate "HPLIP", it is a subsystem name.
        _(
          "There is at least one printer configuration that uses the ptal service.\n" +
            "It is possible to proceed but then the running ptal service could prevent\n" +
            " hp-setup from working correctly.\n" +
            "It is recommended to abort the scanner configuration now,\n" +
            "stop the ptal service, change the printer configuration to use HPLIP,\n" +
            "and start the scanner configuration again afterwards.\n"
        )
      displaytest_failed_message =
        # Message of a Popup::Error when hp-setup should be run.
        # Do not change or translate "hp-setup", it is a program name:
        _(
          "Cannot run hp-setup because no graphical display can be opened.  \n" +
            "This happens if YaST runs in text-only mode, or the user who runs YaST \n" +
            "has no DISPLAY environment variable set, or if the YaST process is not \n" +
            "allowed to access the graphical display.  In this case, abort the scanner \n" +
            "configuration, run hp-setup manually, and start the scanner configuration\n" +
            "again afterwards.\n"
        )
      install_hplip_message =
        # Message of a Popup::YesNo when hplip should be installed.
        # Do not change or translate "hp-setup", it is a program name.
        # Do not change or translate "hplip", it is a package name:
        _(
          "It seems hplip is not installed, which is required to run hp-setup.\nShould the hplip package be installed?\n"
        )
      hpsetup_not_executable_message =
        # Message of a Popup::Error when hp-setup should be run.
        # Do not change or translate "hp-setup", it is a program name:
        _(
          "Cannot run hp-setup because\n" +
            "/usr/bin/hp-setup is not executable\n" +
            "or does not exist.\n"
        )
      hpsetup_busy_message =
        # Body of a Popup::ShowFeedback.
        # Do not change or translate "hp-setup", it is a program name:
        _(
          "Launched hp-setup.\nYou must finish hp-setup before you can proceed with the scanner configuration.\n"
        )
      if DependantPrintQueueExists("hpoj")
        Builtins.y2milestone(
          "Error: hp-setup is not launched because of conflict: PTAL is in use by a CUPS queue."
        )
        Popup.Error(ptal_in_use_conflict_message)
        return false
      end
      if !ExecuteBashCommand("/usr/lib/YaST2/bin/displaytest")
        # In particular when YaST runs in text-only mode, hp-setup must not be launched
        # because it would run without any contact to the user "in the background"
        # while in the foreground YaST waits for hp-setup to be finished
        # which is imposible for the user so that the result is a deadlock.
        # All the user could do is to kill the hp-setup process.
        # It does not matter if displaytest fails orderly because XOpenDisplay fails
        # or if it crashes because of missing libX11.so on a minimal installation without X
        # because any non-zero exit code indicates that no graphical window can be opened.
        # Therefore the yast2-scanner RPM should not require a full installed X system.
        # Nevertheless the RPM build AutoReqProv creates a requirement for libX11.so
        # so that a few xorg-x11-lib* packages (xorg-x11-libX11, xorg-x11-libxcb, xorg-x11-libXau)
        # are enforced by RPM to be installed.
        Builtins.y2milestone(
          "Error: hp-setup is not launched because /usr/lib/YaST2/bin/displaytest failed."
        )
        Popup.Error(displaytest_failed_message)
        return false
      end
      if "not installed" ==
          Ops.get(@actual_environment, "hplip_version", "not installed") ||
          "failed to determine" ==
            Ops.get(@actual_environment, "hplip_version", "failed to determine")
        Builtins.y2milestone(
          "hplip not installed or failed to determine its version. Therefore testing and installing hplip."
        )
        if !Popup.YesNo(install_hplip_message)
          Builtins.y2milestone(
            "Error: hp-setup cannot run because user rejected to install hplip."
          )
          return false
        end
        if !TestAndInstallPackage("hplip")
          Builtins.y2milestone(
            "Error: hp-setup cannot run because YaST failed to install hplip."
          )
          return false
        end
      end
      if !ExecuteBashCommand("test -x /usr/bin/hp-setup")
        Builtins.y2milestone(
          "Error: /usr/bin/hp-setup not executable or does not exist."
        )
        Popup.Error(hpsetup_not_executable_message)
        return false
      end
      Popup.ShowFeedback(
        "",
        # Busy message:
        hpsetup_busy_message
      )
      ExecuteBashCommand("/usr/bin/hp-setup")
      Popup.ClearFeedback
      true
    end

    # Create the content for WizardHW::SetContents
    # @return a list of maps with keys
    # "id" : string = the identification of the device,
    # "rich_descr" : string = RichText description of the device
    # "table_descr" : list<string> = fields of the table
    def OverviewContents
      overview_contents = []
      # The id_prefix can be one of the following:
      # "autodetected_scanner:", "active_scanner:", "active_backend:", "nothing".
      # An index number will be appended to the id_prefix except when it is "nothing"
      # which results an unique id for each overview_content entry.
      # Therefore the id can be one of the following:
      # "autodetected_scanner:[0-9]*" where [0-9]* is the autodetected_scanners_index
      # (i.e. the index in the autodetected_scanners list to which the overview_content entry matches)
      # "active_scanner:[0-9]*" where [0-9]* is the active_scanners_index
      # (i.e. the index in the active_scanners list to which the overview_content entry matches)
      # "active_backend:[0-9]*" where [0-9]* is the active_backends_index
      # (i.e. the index in the active_backends list to which the overview_content entry matches)
      # "nothing" which is used as fallback only if none of the above was set
      # (i.e. if neither a scanner was autodetected nor an active scanner nor an active backend exists)
      id_prefix = ""
      # On top of the table list the autodetected but not yet configured scanners
      # i.e. those scanners which are in autodetected_scanners but not in active_scanners
      # except remote active scanners which are accessed via the "net" meta-backend:
      id_prefix = "autodetected_scanner:"
      # Process the autodetected_scanners list:
      autodetected_scanners_index = -1
      Builtins.foreach(@autodetected_scanners) do |autodetected_scanner|
        # of the actual autodetected_scanner in autodetected_scanners:
        autodetected_scanners_index = Ops.add(autodetected_scanners_index, 1)
        # Use local variables to have shorter variable names:
        manufacturer = Ops.get(autodetected_scanner, "manufacturer", "")
        model = Ops.get(autodetected_scanner, "model", "")
        description = Ops.get(autodetected_scanner, "description", "")
        device = Ops.get(autodetected_scanner, "device", "")
        # The last entry in the autodetected_scanners list is an empty map.
        # Skip at least this last entry:
        if "" != description
          # except remote active scanners which are accessed via the "net" meta-backend.
          # For HP all-in-one devices the device entry is empty
          # (therefore the test for non-empty device before the substring test)
          # but here the model entry is a substring of the sane_device, for example
          # "HP LaserJet 1220" in "hpaio:/usb/HP_LaserJet_1220?serial=00XXXXXXXXXX"
          # "Officejet 7200 series" in "hpaio:/net/Officejet_7200_series?ip=10.10.100.100"
          # which shows that it is crucial to unify both strings before the substring test.
          # Even if there are two "HP_LaserJet_1220" connected to the USB
          # or two "Officejet_7200_series" with different IP addresses,
          # this should work correctly because once the hpaio driver is activated
          # it recognizes all HP all-in-one devices which have a CUPS queue
          # but only those are autodetected, see the autodetect_scanners script.
          # If an autodetected_scanner is one of the active_scanners,
          # there is no need to set it up again
          # and then don't show it in the list of detected_scanners:
          show_as_detected_scanner = true
          Builtins.foreach(@active_scanners) do |active_scanner|
            backend = Ops.get(active_scanner, "backend", "")
            sane_device = Ops.get(active_scanner, "sane_device", "unknown")
            if "net" != backend
              if "hpaio" != backend && "" != device &&
                  Builtins.issubstring(sane_device, device) ||
                  "hpaio" == backend && "" != model &&
                    Builtins.issubstring(
                      Builtins.filterchars(
                        Builtins.tolower(sane_device),
                        @alnum_chars
                      ),
                      Builtins.filterchars(
                        Builtins.tolower(model),
                        @alnum_chars
                      )
                    )
                show_as_detected_scanner = false
              end
            end
          end 

          if show_as_detected_scanner
            id = Ops.add(
              id_prefix,
              Builtins.tostring(autodetected_scanners_index)
            )
            rich_descr = ""
            model_string = ""
            # Avoid that the manufacturer name is shown duplicated
            # when the autodetected manufacturer name
            # is also a part of the autodetected model name.
            # E.g.: "EPSON" "Epson Perfection 123"
            # Use a simple case insensitive substring test and ignore false positives
            # (e.g.: "HP" "High Performance Scanner HPS 1234")
            # because it is sufficient to show only the model name
            # because different manufacturers use different model names.
            if "" != manufacturer &&
                !Builtins.issubstring(
                  Builtins.tolower(model),
                  Builtins.tolower(manufacturer)
                )
              model_string = Ops.add(manufacturer, " ")
            end
            if "" != model
              model_string = Ops.add(Ops.add(model_string, model), " ")
            end
            model_string = Ops.add(model_string, description)
            table_descr = [
              # where autodetected scanners are listed in the second column
              # to denote those scanners which are not configured yet:
              _("Not Configured:"),
              model_string
            ] # A prefix for the first column of a table
            overview_content = {
              "id"          => id,
              "rich_descr"  => rich_descr,
              "table_descr" => table_descr
            }
            overview_contents = Builtins.add(
              overview_contents,
              overview_content
            )
          end
        end
      end 

      # In the middle of the table list the active scanners
      # i.e. those scanners which are in active_scanners:
      id_prefix = "active_scanner:"
      # Process the autodetected_scanners list:
      active_scanners_index = -1
      Builtins.foreach(@active_scanners) do |active_scanner|
        # of the actual active_scanner in active_scanners:
        active_scanners_index = Ops.add(active_scanners_index, 1)
        # Use local variables to have shorter variable names:
        backend = Ops.get(active_scanner, "backend", "")
        # Fallback device name if the real device name is missing:
        sane_device = Ops.get(
          active_scanner,
          "sane_device",
          _("Unknown device")
        )
        # Fallback manufacturer name if the real manufacturer name is missing:
        manufacturer = Ops.get(
          active_scanner,
          "manufacturer",
          _("Unknown manufacturer")
        )
        # Fallback model name if the real model name is missing:
        model = Ops.get(active_scanner, "model", _("Unknown model"))
        # Avoid that the manufacturer name is shown duplicated
        # when the autodetected manufacturer name
        # is also a part of the autodetected model name.
        # E.g.: "EPSON" "Epson Perfection 123"
        # Use a simple case insensitive substring test and ignore false positives
        # (e.g.: "HP" "High Performance Scanner HPS 1234")
        # because it is sufficient to show only the model name
        # because different manufacturers use different model names.
        if Builtins.issubstring(
            Builtins.tolower(model),
            Builtins.tolower(manufacturer)
          )
          manufacturer = ""
        end
        # The last entry in the active_scanners list is an empty map.
        # Skip at least this last entry:
        if "" != backend
          id = Ops.add(id_prefix, Builtins.tostring(active_scanners_index))
          rich_descr = ""
          active_scanner_text = Builtins.sformat(
            # %1 will be replaced by the manufacturer name
            # %2 will be replaced by the model name
            # %3 will be replaced by the device name
            # where the scanner is connected to:
            _("%1 %2 at %3"),
            manufacturer,
            model,
            sane_device
          ) # Active scanner entry where
          table_descr = [backend, active_scanner_text]
          overview_content = {
            "id"          => id,
            "rich_descr"  => rich_descr,
            "table_descr" => table_descr
          }
          overview_contents = Builtins.add(overview_contents, overview_content)
        end
      end 

      # At the bottom of the table list the active backends without an active scanner
      # i.e. those backends which are in active_backends but not in active_scanners:
      id_prefix = "active_backend:"
      # Process the active_backends list:
      active_backends_index = -1
      Builtins.foreach(@active_backends) do |active_backend|
        # of the actual active_backend in active_backends:
        active_backends_index = Ops.add(active_backends_index, 1)
        # The last entry in the active_backends list is an empty string.
        # Skip this last entry:
        if "" != active_backend
          # If yes, then there is no need to show it again:
          show_as_active_backend = true
          Builtins.foreach(@active_scanners) do |active_scanner|
            if active_backend == Ops.get(active_scanner, "backend", "unknown")
              show_as_active_backend = false
            end
          end 

          if show_as_active_backend
            id = Ops.add(id_prefix, Builtins.tostring(active_backends_index))
            rich_descr = ""
            table_descr = [
              active_backend,
              # A suffix for the second column of a table
              # where active scanner drivers are listed in the first column
              # to denote those drivers for which there is no matching active scanner:
              _("No scanner recognized by this driver")
            ]
            overview_content = {
              "id"          => id,
              "rich_descr"  => rich_descr,
              "table_descr" => table_descr
            }
            overview_contents = Builtins.add(
              overview_contents,
              overview_content
            )
          end
        end
      end 

      # If the overview_contents list is still empty, set a fallback
      # so that there is no empty table shown to the user:
      if Ops.less_than(Builtins.size(overview_contents), 1)
        table_descr = [
          "",
          # A fallback list entry so that there is no empty list shown to the user
          # when neither a scanner was autodetected
          # nor an active scanner was found
          # nor an active driver was found:
          _("No scanner was detected and no active scanner or driver exists.")
        ]
        overview_contents = [
          {
            "id"          => "nothing",
            "rich_descr"  => "",
            "table_descr" => table_descr
          }
        ]
      end
      # Return the overview_contents list:
      Builtins.y2milestone("Overview contents: %1", overview_contents)
      deep_copy(overview_contents)
    end

    # Create a list of items from the database entries
    # which is used for the SelectionBox in the SelectModelDialog
    # @param [String] filter_string string of a search string to return only matching models
    #        (retunr all models if filter_string is the empty string)
    # @return [Array] of model strings (manufacturer, model, backend, comment)
    def ModelItems(filter_string)
      # and take the filter_string into account (if it is not the empty string)
      # and try to preselect a model according to a selected autodetected scanner:
      database_index = -1
      model_string = ""
      interface_and_usbid_string = ""
      package_string = ""
      status_string = ""
      # Scanner model list firmware entry for models which require a firmware upload:
      firmware_string = _("Firmware upload required.")
      # Scanner model list entry for models which require
      # the third-party Image Scan (IScan) driver software from Epson/Avasys.
      # Do not change or translate "Image Scan", it is a driver software name.
      # Do not change or translate "Avasys", it is a manufacturer name.
      # Do not change or translate "Epson", it is a manufacturer name.
      iscan_string = _(
        "Third-party Image Scan driver software from Epson/Avasys required."
      )
      model_items = []
      Builtins.foreach(@database) do |database_entry|
        database_index = Ops.add(database_index, 1)
        # Use local variables to have shorter variable names:
        manufacturer = Ops.get(
          database_entry,
          "manufacturer",
          "unknown manufacturer"
        )
        model = Ops.get(database_entry, "model", "unknown model")
        backend = Ops.get(database_entry, "backend", "unknown")
        version = Ops.get(database_entry, "version", "")
        package = Ops.get(database_entry, "package", "unknown")
        status = Ops.get(database_entry, "status", "unknown")
        interface = Ops.get(database_entry, "interface", "")
        usbid = Ops.get(database_entry, "usbid", "")
        comment = Ops.get(database_entry, "comment", "")
        firmware = Ops.get(database_entry, "firmware", "unknown")
        # Build the model_string:
        if manufacturer != "unknown manufacturer" && model != "unknown model" &&
            backend != "unknown" &&
            package != "unknown" &&
            status != "unknown"
          # Enclose it in parenthesis to seperate it from the rest of the model_string
          # because the interface_and_usbid_string is untranslatable stuff like
          # the acronyms "SCSI" and/or "USB or the hexadecimal numbers of the USB-ID:
          if Builtins.issubstring(Builtins.tolower(interface), "scsi")
            if usbid != ""
              interface_and_usbid_string = Ops.add(
                Ops.add("(SCSI, USB-ID ", usbid),
                ")"
              )
            else
              if Builtins.issubstring(Builtins.tolower(interface), "usb")
                interface_and_usbid_string = "(SCSI, USB)"
              else
                interface_and_usbid_string = "(SCSI)"
              end
            end
          else
            if usbid != ""
              interface_and_usbid_string = Ops.add(
                Ops.add("(USB-ID ", usbid),
                ")"
              )
            else
              if Builtins.issubstring(Builtins.tolower(interface), "usb")
                interface_and_usbid_string = "(USB)"
              else
                interface_and_usbid_string = ""
              end
            end
          end
          # Enclose a comment in brackets to seperate it from the rest of the model_string
          # because the comment is untranslatable English text from the *desc files:
          comment = Ops.add(Ops.add("[", comment), "]") if "" != comment
          # Build a translatable package_string:
          if "iscan" == package
            package_string = iscan_string
          else
            package_string = Builtins.sformat(
              # %1 will be replaced by the RPM package name
              # which provides the driver for the particular model:
              _("Package %1"),
              package
            ) # Scanner model list package name entry:
            package_string = Ops.add(Ops.add("(", package_string), ")")
          end
          # Build a translatable status_string:
          # These are the exiting status values according to the *desc files in sane-1.0.15 (9.3)
          # and how often each value apppears:
          #   "good"        (452)
          #   "unsupported" (257)
          #   "complete"    (227)
          #   "untested"    (151)
          #   "basic"       (66)
          #   "minimal"     (14)
          # Enclose the backend name and the package name in single quotes to seperate them
          # from the rest of the model_string because they are untranslatable English words.
          if "good" == status
            if "unmaintained" == version
              status_string = Builtins.sformat(
                # but where the backend (scanner driver) is unmaintained:
                # %1 will be replaced by the backend (scanner driver) name
                _("Unmaintained driver %1 may provide good functionality."),
                backend
              ) # Scanner model list status entry for "good" supported models
            else
              status_string = Builtins.sformat(
                # %1 will be replaced by the backend (scanner driver) name
                _("Driver %1 should provide good functionality."),
                backend
              ) # Scanner model list status entry for "good" supported models:
            end
          else
            if "unsupported" == status
              if "unsupported" == backend
                status_string = _("This scanner is not supported.")
              else
                status_string = Builtins.sformat(
                  # which are listed as "unsupported" for a particular driver:
                  # %1 will be replaced by the backend (scanner driver) name
                  _("This scanner is not supported by the driver %1."),
                  backend
                ) # Scanner model list status entry for models
              end
            else
              if "complete" == status
                if "unmaintained" == version
                  status_string = Builtins.sformat(
                    # but where the backend (scanner driver) is unmaintained:
                    # %1 will be replaced by the backend (scanner driver) name
                    _(
                      "Unmaintained driver %1 may provide complete functionality."
                    ),
                    backend
                  ) # Scanner model list status entry for "complete" supported models
                else
                  status_string = Builtins.sformat(
                    # %1 will be replaced by the backend (scanner driver) name
                    _("Driver %1 should provide complete functionality."),
                    backend
                  ) # Scanner model list status entry for "complete" supported models:
                end
              else
                if "untested" == status
                  status_string = Builtins.sformat(
                    # %1 will be replaced by the backend (scanner driver) name
                    _("Driver %1 may work, but was not tested."),
                    backend
                  ) # Scanner model list status entry for "untested" models:
                else
                  if "basic" == status
                    if "unmaintained" == version
                      status_string = Builtins.sformat(
                        # but where the backend (scanner driver) is unmaintained:
                        # %1 will be replaced by the backend (scanner driver) name
                        _(
                          "Unmaintained driver %1 may provide basic functionality."
                        ),
                        backend
                      ) # Scanner model list status entry for "basic" supported models
                    else
                      status_string = Builtins.sformat(
                        # %1 will be replaced by the backend (scanner driver) name
                        _("Driver %1 should provide basic functionality."),
                        backend
                      ) # Scanner model list status entry for "basic" supported models:
                    end
                  else
                    if "minimal" == status
                      if "unmaintained" == version
                        status_string = Builtins.sformat(
                          # but where the backend (scanner driver) is unmaintained:
                          # %1 will be replaced by the backend (scanner driver) name
                          _(
                            "Unmaintained driver %1 may provide minimal functionality."
                          ),
                          backend
                        ) # Scanner model list status entry for "minimal" supported models
                      else
                        status_string = Builtins.sformat(
                          # %1 will be replaced by the backend (scanner driver) name
                          _("Driver %1 should provide minimal functionality."),
                          backend
                        ) # Scanner model list status entry for "minimal" supported models:
                      end
                    else
                      status_string = Builtins.sformat(
                        # which are listed but without a known support status:
                        # %1 will be replaced by the backend (scanner driver) name
                        _(
                          "Driver %1 may work, but the functionality is unknown."
                        ),
                        backend
                      ) # Fallback scanner model list status entry for models
                    end
                  end
                end
              end
            end
          end
          if "required" == firmware
            model_string = Builtins.sformat(
              "%1 %2 : %3 %4 %5 %6 %7",
              manufacturer,
              model,
              firmware_string,
              package_string,
              status_string,
              interface_and_usbid_string,
              comment
            )
          else
            model_string = Builtins.sformat(
              "%1 %2 : %3 %4 %5 %6",
              manufacturer,
              model,
              package_string,
              status_string,
              interface_and_usbid_string,
              comment
            )
          end
          # If there is an autodetected USB scanner selected,
          # test whether an USB-ID in the database matches to the selected autodetected scanner
          # and select it in the model_items list if it is at least "good supported"
          # where "good supported" means that the support status is "complete" or "good"
          # and there is no special (manual) setup for firmware upload required
          # (automated firmware upload as e.g. "epkowa" does is "good").
          # Do not select a model if it is less than "good supported" to avoid that
          # there is another driver entry in the database which has no USB-ID
          # but which provides much better support (e.g. the model entry with USB-ID
          # provides minimal support but an entry without USB-ID provides good support)
          # and to avoid that the user clicks too fast [Next] without having a look
          # what there was selected (e.g. ignoring any comment regarding the model).
          # If more than one model in the database matches, select those model
          # with the better support status (complete > good).
          # It even the support status are the same, select those model with the driver
          # which is considered better regarding how well the scanner is supported
          # (e.g.: hpaio > any other driver in particular hpaio is better than outdated hpoj)
          # regardless whether or not the driver is free software (epkowa > any other driver).
          # If no model matches then leave the selected_model_database_index unchanged
          # to select an already selected model in the model_items list again.
          # This happens for example when going 'back' to the model selection screen.
          if Ops.greater_or_equal(@selected_autodetected_scanners_index, 0)
            autodetected_usbid = Ops.add(
              Ops.add(
                Ops.get(
                  @autodetected_scanners,
                  [@selected_autodetected_scanners_index, "usb_vendor_id"],
                  ""
                ),
                ":"
              ),
              Ops.get(
                @autodetected_scanners,
                [@selected_autodetected_scanners_index, "usb_product_id"],
                ""
              )
            )
            # There is no false match when one or both USB-IDs are missing
            # because autodetected_usbid is not the empty string but at least ":"
            # and usbid is either a complete "0x0a1b:0x2c3d" USB-ID or the empty string.
            # There is a special magic USB ID "0x03f0:0x0000" in hpaio.desc
            # for the following fallback entry for HP all-in-one devices:
            #   :model "Any all-in-one device"
            #   :usbid "0x03f0" "0x0000"
            #   :status :untested
            #   :comment "fallback entry for HP all-in-one devices"
            # This USB ID is used as fallback by the YaST scanner autodetection
            # via /usr/lib/YaST2/bin/autodetect_scanners which calls "hp-probe -busb -escan"
            # because hp-probe does not show the USB ID.
            # Therefore this fallback entry matches to any autodetected HPLIP
            # USB all-in-one device (the "-escan" excludes plain printers)
            # so that the usually right driver (hpaio) is preselected.
            # Nevertheless, to be on the safe side, the support status is set to "untested"
            # which requires the special exceptional test for this particular USB ID here:
            if autodetected_usbid == usbid && firmware != "required" &&
                (status == "complete" || status == "good" ||
                  usbid == "0x03f0:0x0000")
              if -1 == @selected_model_database_index
                # Select the current model:
                @selected_model_database_index = database_index
                Builtins.y2milestone("Selected model: %1", model_string)
              else
                # Test which has the better support status:
                selected_status = Ops.get(
                  @database,
                  [@selected_model_database_index, "status"],
                  "unknown"
                )
                if status != selected_status
                  if "complete" == status
                    @selected_model_database_index = database_index
                    Builtins.y2milestone(
                      "Selected other model: %1",
                      model_string
                    )
                  end
                else
                  # Test which has the better driver:
                  selected_backend = Ops.get(
                    @database,
                    [@selected_model_database_index, "backend"],
                    "unknown"
                  )
                  if backend != selected_backend
                    if backend == "epkowa"
                      # than any other driver (in particular better than epson, plustek, or snapscan).
                      # Select the current model:
                      @selected_model_database_index = database_index
                      Builtins.y2milestone(
                        "Selected other model: %1",
                        model_string
                      )
                    else
                      if backend == "hpaio"
                        # than any other driver (in particular better than the outdated hpoj).
                        # Select the current model:
                        @selected_model_database_index = database_index
                        Builtins.y2milestone(
                          "Selected other model: %1",
                          model_string
                        )
                      end
                    end
                  else
                    if backend == "epkowa"
                      # One name is the "overseas version" of the Japanese name.
                      # This is mentioned in the comment, e.g. the "Perfection 1200U PHOTO" has the comment
                      # "overseas version of the GT-7600UF, Perfection 1200U with TPU option bundled".
                      # Prefer the "overseas version" entry because most users are "overseas"
                      # (from the Japanese point of view) and even users in Japan find their model name
                      # in the comment (which is not true the other way round):
                      if Builtins.regexpmatch(
                          Builtins.tolower(comment),
                          Builtins.tolower("overseas version")
                        )
                        @selected_model_database_index = database_index
                        Builtins.y2milestone(
                          "Selected other model: %1",
                          model_string
                        )
                      end
                    end
                  end
                end
              end
            end
          end
          # Take the filter_string into account:
          if "" == filter_string
            model_items = Builtins.add(
              model_items,
              Item(Id(database_index), model_string)
            )
          else
            # test whether the model_string matches to the filter_string:
            if Builtins.regexpmatch(
                Builtins.tolower(model_string),
                Builtins.tolower(filter_string)
              )
              model_items = Builtins.add(
                model_items,
                Item(Id(database_index), model_string)
              )
            end
          end
        end
      end 

      # Preselect the entry in the model_items list which matches
      # to the current value of selected_model_database_index
      # if such an entry exists in the model_items list (e.g. because of the
      # filter_string there may be no such entry in the model_items list):
      model_items_index = -1
      selected_model_items_index = -1
      dummy = Id(0)
      # Determine if such an entry exists:
      Builtins.foreach(model_items) do |model_item|
        model_items_index = Ops.add(model_items_index, 1)
        # model_item[0] is the term `id(database_index) and id[0] is the database_index
        # so that model_item[0,0] is the database_index:
        if @selected_model_database_index ==
            Ops.get_integer(model_item, [0, 0], -1)
          selected_model_items_index = model_items_index
        end
      end 

      if Ops.greater_or_equal(selected_model_items_index, 0)
        # model_items[selected_model_items_index] is a model_item and
        # model_item[1] is the model_string and
        # model_item[0,0] is the database_index (see the previous comment) so that
        # model_items[selected_model_items_index,0,0] is the database_index:
        database_index = Ops.get_integer(
          model_items,
          [selected_model_items_index, 0, 0],
          -1
        )
        model_string = Ops.get_string(
          model_items,
          [selected_model_items_index, 1],
          ""
        )
        Ops.set(
          model_items,
          selected_model_items_index,
          Item(Id(database_index), model_string, true)
        )
        Builtins.y2milestone(
          "Preselected model shown to the user: %1",
          model_string
        )
      else
        Builtins.y2milestone(
          "No preselected model shown to the user. The filter_string is: '%1'",
          filter_string
        )
      end
      # Return a list which is sorted according to the model_string entries
      # (model_item[0] is `id(database_index) and model_item[1] is the model_string):
      Builtins.sort(model_items) do |one_model_item, another_model_item|
        Ops.less_than(
          Ops.get_string(one_model_item, 1, ""),
          Ops.get_string(another_model_item, 1, "")
        )
      end
    end

    # Activate the backend in /etc/sane.d/dll.conf
    # according to the specified backend_name
    # or if the specified backend_name is the empty string
    # then set the backend_name according to a specified database_index.
    # @param [String] backend_name string of a backend which should be activated
    #        (if backend_name is the empty string then database_index must be >= 0)
    # @param [Fixnum] database_index integer which points to an entry in the model database
    #        (if backend_name is the empty string then the backend according to the database_index is used)
    # @param [Boolean] user_confirmation boolean true if user confirmation popup in case of problems is requested
    # @return true on success
    def ActivateBackend(backend_name, database_index, user_confirmation)
      firmware_message =
        # The body of a Popup::AnyMessage for scanners which require a firmware upload
        # Below this message on a seperated line a special command will be shown.
        # The "somewhere" is important because normally the firmware file is not simply
        # stored on the manufacturer's CD but often it is buried in a weird Windows-only
        # driver archive format. The text must indicate this.
        # Do not change or translate "SANE", it is a project name.
        _(
          "A firmware file contains software that must be uploaded to the scanner's memory.\n" +
            "Without firmware, the scanner cannot work.\n" +
            "\n" +
            "Because firmware is licensed by the scanner manufacturer, we cannot distribute it.\n" +
            "Usually the firmware file is stored somewhere on the manufacturer's CD.\n" +
            "Alternatively, it may be possible to download it from the manufacturer's web site.\n" +
            "Ask the manufacturer how to get the firmware file for your particular scanner.\n" +
            "Find additional useful information on the SANE web site at\n" +
            "http://www.sane-project.org/.\n" +
            "\n" +
            "After you get the firmware file, you must configure the driver manually.\n" +
            "The man page of the driver describes how to configure it for firmware upload.\n" +
            "The following command shows the man page for your driver:\n"
        )
      ptal_in_use_conflict_message =
        # Message of a Popup::ContinueCancel for scanners which should be set up with the hpaio driver.
        # Do not change or translate "ptal", it is a service name.
        # Do not change or translate "HPLIP", it is a subsystem name.
        _(
          "There is at least one printer configuration that uses the ptal service.\n" +
            "It is possible to proceed but then the ptal service would be stopped\n" +
            "and all print queues that use the ptal service would no longer work.\n" +
            "If you proceed, change the printer configuration to use HPLIP.\n"
        )
      hpoj_message =
        # Message of a Popup::YesNo for scanners which should be set up with the hpoj driver
        # Do not change or translate "hpoj", it is a driver name.
        # Do not change or translate "PTAL", it is a subsystem name.
        # Do not change or translate "ptal", it is a service name.
        # Do not change or translate "hplip", it is a service name.
        _(
          "The hpoj driver requires the PTAL system to be set up and running.\n" +
            "In particular, the ptal service must be up and running.\n" +
            "\n" +
            "Before the ptal service can be started, the PTAL system must be initialized.\n" +
            "Additionally, the ptal service should be activated for start when booting.\n" +
            "The PTAL system and the hplip service exclude each other.\n" +
            "Therefore a running hplip service would be stopped and deactivated\n" +
            "before the the PTAL system is initialized, activated, and started.\n" +
            "An automated initialization of the PTAL system is only safe for USB.\n" +
            "If you have a non-USB device or if the automated initialization for USB fails,\n" +
            "set up the PTAL system manually.\n" +
            "If you have an all-in-one device (scanner+printer), note that\n" +
            "a running ptal service monopolizes the USB device file (e.g., /dev/usb/lp0),\n" +
            "so the printer can no longer be addressed via the USB device file.\n" +
            "\n" +
            "Should the PTAL system for USB be initialized, activated, and started now?\n"
        )
      hplip_in_use_conflict_message =
        # Message of a Popup::ContinueCancel for scanners which should be set up with the hpoj driver.
        # Do not change or translate "hplip", it is a service name.
        # Do not change or translate "hpaio", it is a driver name.
        # Do not change or translate "ptal", it is a service name.
        _(
          "There is at least one printer configuration that uses the hplip service.\n" +
            "It is possible to proceed but then the hplip service would be stopped\n" +
            "and all print queues that use the hplip service would no longer work.\n" +
            "If the scanner is also supported by the hpaio driver, do not proceed.\n" +
            "Instead use hpaio to set up the scanner.\n" +
            "Alternatively proceed and change the printer configuration to use the ptal service.\n"
        )
      # Here the real code starts with proper indentation:
      if backend_name == ""
        if Ops.less_than(database_index, 0)
          Builtins.y2milestone(
            "Error: Scanner database_index is: %1",
            database_index
          )
          return false
        end
        backend_name = Ops.get(
          @database,
          [database_index, "backend"],
          "unknown"
        )
        if "unknown" == backend_name
          Builtins.y2milestone(
            "Error: Cannot activate backend: %1",
            backend_name
          )
          return false
        end
      end
      # To be safe assume that something will really be modified.
      # If there is in fact nothing modified, it doesn't harm if 'modified' is 'true':
      @modified = true
      # Define the progress stages:
      Progress.New(
        # %1 will be replaced by the backend name
        Builtins.sformat(_("Setting Up Driver %1"), backend_name),
        " ",
        5,
        [
          _("Check whether additional packages must be installed"),
          # 2. progress stage name of a Progress::New:
          _("Check whether firmware upload is required"),
          # 3. progress stage name of a Progress::New:
          _("Test and set up special requirements for particular drivers"),
          # 4. progress stage name of a Progress::New:
          _("Activate the driver"),
          # 5. progress stage name of a Progress::New:
          _("Determine active scanners")
        ], # 1. progress stage name of a Progress::New:
        [
          _("Checking whether additional packages must be installed..."),
          # 2. progress step progress bar title of a Progress::New:
          _("Checking whether firmware upload is required..."),
          # 3. progress step progress bar title of a Progress::New:
          _(
            "Testing and setting up special requirements for particular drivers..."
          ),
          # 4. progress step progress bar title of a Progress::New:
          _("Activating the driver..."),
          # 5. progress step progress bar title of a Progress::New:
          _("Determining active scanners..."),
          # Last progress step progress bar title of a Progress::New:
          _("Finished")
        ], # 1. progress step progress bar title of a Progress::New:
        ""
      )
      # Test if the package which provides the backend is installed
      # and if not then try to install it.
      # This makes only sense if a database_index was specified
      # because which package is required for which backend is stored in the database
      # and additionally user confirmation must be requested.
      # Otherwise skip this section.
      Progress.NextStage
      package_name = Ops.get(@database, [database_index, "package"], "unknown")
      if package_name != "unknown" && user_confirmation
        if !TestAndInstallPackage(package_name)
          # the third-party Image Scan driver software from Epson/Avasys:
          if package_name != "iscan"
            Popup.AnyMessage(
              _("Required Package Not Installed"),
              # Body of a Popup::AnyMessage where
              # %1 will be replaced by the backend name
              # %2 will be replaced by the package name
              # Only a simple message because before there was a dialog
              # which let the user install the package so that this message is shown
              # if the user has explicitly rejected to install it.
              Builtins.sformat(
                _("The driver %1 requires the package %2."),
                backend_name,
                package_name
              )
            )
          end
          Progress.Title(_("Aborted"))
          return false
        end
      end
      # Some scanners require a firmware upload to become ready to operate.
      # When building the sane package ':firmware "required"' entries have been
      # added for the respective scanners to the appropriate descriptions files.
      # See the sane.spec file of the sane package.
      # This makes only sense if a database_index was specified
      # because which scanner requires firmware upload is stored in the database
      # and additionally user confirmation must be requested.
      # Otherwise skip this section.
      Progress.NextStage
      firmware_entry = Ops.get(
        @database,
        [database_index, "firmware"],
        "unknown"
      )
      if "required" == firmware_entry && user_confirmation
        Popup.AnyMessage(
          _("Firmware Upload Required"),
          Ops.add(Ops.add(firmware_message, "\n    man sane-"), backend_name)
        )
      end
      # Set up special requirements for particular backends (e.g. "hpaio", "hpoj"):
      Progress.NextStage
      # The hpaio backend (from the package hplip) recommends the hplip service to be up and running.
      # Since HPLIP version 2.7.6 one part of the hplip service hpiod is replaced
      # by new direct device I/O (via hpmud library), only hpssd (for device status) still exists
      # but hpssd is not strictly required but without it hp-toolbox cannot show the device status
      # so that the hplip service (since HPLIP 2.7.6 only hpssd) is still recommended to run:
      # This makes only sense if user confirmation is requested.
      # Otherwise skip this section.
      if "hpaio" == backend_name
        if user_confirmation
          # The ptal service is associated with the hpoj backend.
          if DependantPrintQueueExists("hpoj")
            if !Popup.ContinueCancel(ptal_in_use_conflict_message)
              Builtins.y2milestone(
                "Set up hpaio SANE backend aborted by user because of conflict: PTAL is in use by a CUPS queue."
              )
              Progress.Title(_("Aborted"))
              return false
            end
          end
        end
        # No conflicting print queue was found or
        # a conflicting print queue was found but the user forced to proceed.
        # Since HPLIP version 2.8.4 there are no longer any startup daemons.
        # The hplip init script was adapted to provide backward compatibility:
        # It still exists to avoid that printer/scanner setup tools fail
        # when they try to enable the "hplip" service but all it does
        # is to stop a possibly running hpssd.
        # All what /usr/lib/YaST2/bin/setup_hplip_scanner_service still does
        # is to disable both ptal and hplip completely if such a service exists.
        # There is no need to care about the exit code because it exits successfully in any case:
        ExecuteBashCommand(@setup_hplip_scanner_service_commandline)
      end
      # The hpoj backend (from the package hp-officeJet) requires the PTAL service to be up and running.
      # Before starting the PTAL service works it must have been initialized.
      # Automated initialization of the PTAL stuff is only safe for USB.
      # This makes only sense if user confirmation is requested.
      # Otherwise skip this section.
      if "hpoj" == backend_name && user_confirmation
        if !Popup.YesNo(hpoj_message)
          # Don't abort (i.e. return false) in this case because it is no error
          # when the user has decided not to initialize/activate/start the PTAL system
          # because it may be already up and running or the user may want to set it up manually.
          # Regardless of the state of the PTAL system the backend can be activated in /etc/sane.d/dll.conf
          Popup.Warning(
            # Message of a Popup::Warning for scanners which should be set up with the hpoj backend.
            # Only a simple message because before there was a Popup::YesNo
            # which asked the user whether he wants to let YaST activate the ptal service
            # so that this message is shown if the user has explicitly rejected to do it.
            # Do not change or translate "ptal", it is a service name.
            _("If the ptal service is not running, the scanner cannot work.")
          )
        else
          # It may happen that the conflicting service hplip is in use by the printing system.
          # The hplip service is associated with the hpaoi backend.
          if DependantPrintQueueExists("hpaio")
            if !Popup.ContinueCancel(hplip_in_use_conflict_message)
              Builtins.y2milestone(
                "Set up hpoj SANE backend aborted by user because of conflict: HPLIP is in use by a CUPS queue."
              )
              Progress.Title(_("Aborted"))
              return false
            end
          end
          # No conflicting print queue was found or
          # a conflicting print queue was found but the user forced to proceed:
          if !ExecuteBashCommand(@setup_ptal_scanner_service_commandline)
            Popup.ErrorDetails(
              # Only a simple message because this error does not happen on a normal system
              # (i.e. a system which is not totally broken or totally messed up).
              # Do not change or translate "PTAL", it is a subsystem name.
              _("Failed to set up the PTAL system."),
              Ops.get_string(@result, "stderr", "")
            )
            Progress.Title(_("Aborted"))
            return false
          end
        end
      end
      # Activate the backend via bash script:
      Progress.NextStage
      if !ExecuteBashCommand(
          Ops.add(Ops.add(@activate_backend_commandline, " "), backend_name)
        )
        Progress.Title(_("Aborted"))
        return false
      end
      # Determine active scanners and active backends anew
      # and set USB and SCSI scanner access permissions anew.
      # Return successfully regardless of the result of this steps
      # because the backend was successfully activated.
      Progress.NextStage
      @active_scanners = [] if !DetermineActiveScanners()
      @active_backends = [] if !DetermineActiveBackends()
      Progress.Finish
      true
    end

    # Deactivate the backend in /etc/sane.d/dll.conf
    # according to the specified backend_name
    # or if the specified backend_name is the empty string
    # then set the backend_name according to a specified database_index.
    # @param [String] backend_name string of a backend which should be deactivated
    #        (if backend_name is the empty string then database_index must be >= 0)
    # @param [Fixnum] database_index integer which points to an entry in the model database
    #        (if backend_name is the empty string then the backend according to the database_index is used)
    # @param [Boolean] user_confirmation boolean true if user confirmation popup in case of problems is requested
    # @return true on success
    def DeactivateBackend(backend_name, database_index, user_confirmation)
      if backend_name == ""
        if Ops.less_than(database_index, 0)
          Builtins.y2milestone(
            "Error: Scanner database_index is: %1",
            database_index
          )
          return false
        end
        backend_name = Ops.get(
          @database,
          [database_index, "backend"],
          "unknown"
        )
        if "unknown" == backend_name
          Builtins.y2milestone(
            "Error: Cannot deactivate backend: %1",
            backend_name
          )
          return false
        end
      end
      # To be safe assume that something will really be modified.
      # If there is in fact nothing modified, it doesn't harm if 'modified' is 'true':
      @modified = true
      # Determine which of the active scanners will be deactivated.
      scanners_to_deactivate = []
      Builtins.foreach(@active_scanners) do |active_scanner|
        if Ops.get(active_scanner, "backend", "unknown") == backend_name
          scanners_to_deactivate = Builtins.add(
            scanners_to_deactivate,
            active_scanner
          )
        end
      end 

      # If more than one active scanners will be deactivated
      # then list the active scanners which will be deactivated
      #      and show them to the user
      #      and ask the user for confirmation:
      if Ops.greater_than(Builtins.size(scanners_to_deactivate), 1)
        if !user_confirmation
          # without asking the user for confirmation because it is the intended behaviour
          # not to deactivate more than one scanner without explicite user confirmation.
          # This happens for example when DeactivateBackend is called from dialogs.ycp
          # when the user goes back from ConfigureBackendDialog to SelectModelDialog.
          return true
        end
        entry = ""
        # Header message for a list of scanners which will be deactivated:
        message = _(
          "The following scanners use the same driver.\nTherefore all those scanners will be deactivated:"
        )
        Builtins.foreach(scanners_to_deactivate) do |scanner_to_deactivate|
          entry = Builtins.sformat(
            # %1 will be replaced by the manufacturer name
            # %2 will be replaced by the model name
            # %3 will be replaced by the device name where the scanner is connected to:
            _("%1 %2 at %3"),
            Ops.get(
              # Fallback manufacturer name if the real manufacturer name is missing:
              scanner_to_deactivate,
              "manufacturer",
              _("Unknown manufacturer")
            ),
            Ops.get(
              # Fallback model name if the real model name is missing:
              scanner_to_deactivate,
              "model",
              _("Unknown model")
            ),
            Ops.get(
              # Fallback device name if the real device name is missing:
              scanner_to_deactivate,
              "sane_device",
              _("Unknown device")
            )
          ) # Entries of a list of scanners which will be deactivated.
          message = Ops.add(Ops.add(message, "\n"), entry)
        end 

        if !Popup.ContinueCancel(message)
          # when the user has decided not to deactivate the backend:
          return true
        end
      end
      # Deactivate the backend via bash script:
      if !ExecuteBashCommand(
          Ops.add(Ops.add(@deactivate_backend_commandline, " "), backend_name)
        )
        Popup.ErrorDetails(
          Builtins.sformat(
            # Only a simple message because this error does not happen on a normal system
            # (i.e. a system which is not totally broken or totally messed up).
            _("Failed to deactivate %1."),
            backend_name
          ), # Message of a Popup::ErrorDetails where %1 will be replaced by the driver name.
          Ops.get_string(@result, "stderr", "")
        )
        return false
      end
      # Unset the special requirements for particular backends (e.g. "hpaio", "hpoj")
      # if they are not needed otherwise (i.e. by the printing system):
      if "hpoj" == backend_name
        # (i.e. if there is no print queue which uses the ptal service).
        # The ptal service is associated with the hpoj backend.
        if DependantPrintQueueExists("hpoj")
          # Don't abort (i.e. return false) in this case because it is perfectly o.k.
          # but show a user notification why the ptal service must be still active.
          if user_confirmation
            Popup.Notify(
              # Only a simple message because everything is perfectly o.k.
              # but the user should get a notification
              # why the ptal service must be still active.
              # This works only if the CUPS printing system is used.
              # Do not change or translate "hpoj", it is a driver name.
              # Do not change or translate "ptal", it is a service name.
              # Do not change or translate "CUPS", it is a subsystem name.
              _(
                "The driver hpoj is deactivated but the associated service ptal is not deactivated because it is needed by the CUPS printing system."
              )
            )
          end
        else
          # Therefore the ptal service will be stopped and disabled if it exists:
          # Don't abort (i.e. return false) if this fails but show an error message to the user.
          if Ops.greater_or_equal(Service.Status("ptal"), 0)
            if !Service.Stop("ptal")
              Builtins.y2milestone("Service::Stop('ptal') failed.")
              if user_confirmation
                Popup.ErrorDetails(
                  # (i.e. a system which is not totally broken or totally messed up).
                  # Do not change or translate "ptal", it is a service name.
                  _("Failed to stop the ptal service."),
                  Service.Error
                )
              end
            end
            if !Service.Disable("ptal")
              Builtins.y2milestone("Service::Disable('ptal') failed.")
              if user_confirmation
                Popup.ErrorDetails(
                  # (i.e. a system which is not totally broken or totally messed up).
                  # Do not change or translate "ptal", it is a service name.
                  _("Failed to disable the ptal service."),
                  Service.Error
                )
              end
            end
          end
        end
      end
      # Determine active scanners and active backends anew
      # and set USB and SCSI scanner access permissions anew.
      # Return successfully regardless of the result of this steps
      # because the backend was successfully deactivated.
      @active_scanners = [] if !DetermineActiveScanners()
      @active_backends = [] if !DetermineActiveBackends()
      true
    end

    # Test the backend according to the specified backend_name.
    # @param [String] backend_name string of a backend which should be tested
    # @return true on success
    def TestBackend(backend_name)
      sane_device = ""
      # It is not possible to test a backend without a matching active scanner.
      # Build the table of active scanners of the backend (see ModelItems above):
      scanners_to_be_tested = []
      preselect = true
      Builtins.foreach(@active_scanners) do |active_scanner|
        if backend_name == Ops.get(active_scanner, "backend", "unknown")
          sane_device = Ops.get(active_scanner, "sane_device", "unknown")
          if sane_device != "unknown"
            model_string = Ops.add(
              Ops.add(
                Ops.add(
                  Ops.add(
                    Ops.get(active_scanner, "manufacturer", "unknown"),
                    " "
                  ),
                  Ops.get(active_scanner, "model", "unknown")
                ),
                " at "
              ),
              sane_device
            )
            scanners_to_be_tested = Builtins.add(
              scanners_to_be_tested,
              Item(Id(sane_device), model_string, preselect)
            )
            # preselect must be true only for the first matching active scanner:
            preselect = false
          end
        end
      end 

      Builtins.y2milestone("scanners_to_be_tested: %1", scanners_to_be_tested)
      # If there is no active scanner for the backend
      # then show a message but exit successfully because
      # it is no error when there is no active scanner for the backend:
      if Ops.less_than(Builtins.size(scanners_to_be_tested), 1)
        Popup.AnyMessage(
          Builtins.sformat(_("No Scanner for %1"), backend_name), # Header of a Popup::AnyMessage where %1 will be replaced by the driver name:
          # Body of a Popup::AnyMessage:
          _("It is not possible to test without a matching active scanner.")
        )
        return true
      end
      # If there is more than one active scanner for the backend
      # then ask the user which of the active scanners should be tested.
      # If there is exactly one active scanner for the backend
      # then don't ask because sane_device is already set to this one.
      if Ops.greater_than(Builtins.size(scanners_to_be_tested), 1)
        UI.OpenDialog(
          VBox(
            HSpacing(60),
            SelectionBox(
              Id(:device_selection),
              # Header of a SelectionBox with a list of scanners:
              _("&Scanner to Test"),
              scanners_to_be_tested
            ),
            ButtonBox(
              PushButton(Id(:cancel_button), Label.CancelButton),
              PushButton(Id(:ok_button), Opt(:default), Label.OKButton)
            )
          )
        )
        if UI.UserInput != :ok_button
          # when the user has decided not to do the test:
          UI.CloseDialog
          return true
        end
        sane_device = Convert.to_string(
          UI.QueryWidget(Id(:device_selection), :CurrentItem)
        )
        UI.CloseDialog
      end
      # Test the device:
      Builtins.y2milestone("sane_device which will be tested: %1", sane_device)
      Popup.ShowFeedback(
        Builtins.sformat(_("Testing %1"), backend_name), # Header of a Popup::ShowFeedback where %1 will be replaced by the driver name:
        # Body of a Popup::ShowFeedback where %1 will be replaced by the SANE device identifier.
        # Do not change or translate "scanimage -d %1 -v", it is a fixed command.
        Builtins.sformat(_("Testing with 'scanimage -d %1 -v'..."), sane_device)
      )
      if !ExecuteBashCommand(
          Ops.add(Ops.add(@test_backend_commandline, " "), sane_device)
        )
        Popup.ClearFeedback
        Popup.Error(
          Builtins.sformat(
            # %1 will be replaced by the SANE device identifier
            # %2 will be replaced by the actual test results
            #    which are usually only available in English.
            # Do not change or translate "scanimage -d %1 -v", it is a fixed command.
            _(
              "Test with 'scanimage -d %1 -v' failed.\n" +
                "The results are:\n" +
                "\n" +
                "%2"
            ),
            sane_device,
            Ops.get_locale(
              # Fallback message if the real results are missing:
              @result,
              "stderr",
              _("(no results available)")
            )
          ) # Message of a Popup::Error where
        )
        # If the test failed, do the whole autodetection anew.
        # Even if normally nothing should have changed because of a failed test,
        # it might have happened that for example during the test somehow
        # the scanner had fallen into coma or the USB or SCSI system had crashed
        # and then the scanner would be no longer an active scanner nor could it be autodetected.
        # To simulate such an event, simply unplug an USB scanner while it is being tested.
        RestartDetection()
        return false
      end
      Popup.ClearFeedback
      Popup.AnyMessage(
        Builtins.sformat(_("Successfully Tested %1"), backend_name), # Header of a Popup::AnyMessage where %1 will be replaced by the driver name:
        Builtins.sformat(
          # %1 will be replaced by the SANE device identifier
          # %2 will be replaced by the actual test results
          #    which are usually only available in English.
          # Do not change or translate "scanimage -d %1 -v", it is a fixed command.
          _(
            "Test with 'scanimage -d %1 -v' succeeded.\n" +
              "The results are:\n" +
              "\n" +
              "%2"
          ),
          sane_device,
          Ops.get_locale(
            # Fallback message if the real results are missing:
            @result,
            "stderr",
            _("(no results available)")
          )
        ) # Body of a Popup::AnyMessage where
      )
      true
    end

    # Determine the network scanning config by calling a bash script
    # which calls "grep ... /etc/sane.d/net.conf" and "grep ... /etc/sane.d/saned.conf"
    # and processes its output and stores the results as YCP map in a temporary file
    # and then read the temporary file (SCR::Read) to get the YCP map.
    # @return true on success
    def DetermineNetworkScanningConfig
      if !ExecuteBashCommand(@determine_network_scanning_config_commandline)
        Popup.ErrorDetails(
          # Only a simple message because this error does not happen on a normal system
          # (i.e. a system which is not totally broken or totally messed up).
          # Do not confuse this error with the case when no scanning via network was configured.
          # The latter results no error.
          _("Failed to determine the configuration for scanning via network."),
          Ops.get_string(@result, "stderr", "")
        )
        return false
      end
      if -1 == SCR.Read(path(".target.size"), @network_scanning_config_filename)
        Builtins.y2milestone(
          "Error: %1: file does not exist.",
          @network_scanning_config_filename
        )
        Popup.Error(
          Builtins.sformat(
            # Only a simple message because this error does not happen on a normal system
            # (i.e. a system which is not totally broken or totally messed up).
            _("File %1 does not exist."),
            @network_scanning_config_filename
          ) # Message of a Popup::Error where %1 will be replaced by the file name.
        )
        return false
      end
      @network_scanning_config = Convert.convert(
        SCR.Read(path(".target.ycp"), @network_scanning_config_filename),
        :from => "any",
        :to   => "map <string, string>"
      )
      if nil == @network_scanning_config
        Builtins.y2milestone(
          "Error: Failed to read %1",
          @network_scanning_config_filename
        )
        Popup.Error(
          Builtins.sformat(
            # Only a simple message because this error does not happen on a normal system
            # (i.e. a system which is not totally broken or totally messed up).
            _("Failed to read %1."),
            @network_scanning_config_filename
          ) # Message of a Popup::Error where %1 will be replaced by the file name.
        )
        @network_scanning_config = {}
        return false
      end
      Builtins.y2milestone(
        "Network scanning config: %1",
        @network_scanning_config
      )
      true
    end

    # Setup the network scanning config by calling a bash script which
    # activates or deactivates the "net" backend and which writes into
    # /etc/sane.d/net.conf, /etc/sane.d/saned.conf, and /etc/xinetd.d/sane-port
    # and reloads or starts the xinetd dependig on whether it is running or not.
    # @return true on success
    def SetupNetworkScanningConfig
      # If there is in fact nothing modified, it doesn't harm if 'modified' is 'true':
      @modified = true
      # Build the commandline and then call it:
      commandline = Ops.add(
        Ops.add(
          Ops.add(
            Ops.add(
              Ops.add(@setup_network_scanning_config_commandline, " '"),
              Ops.get(@network_scanning_config, "net_backend_hosts", "")
            ),
            "' '"
          ),
          Ops.get(@network_scanning_config, "saned_hosts", "")
        ),
        "'"
      )
      if !ExecuteBashCommand(commandline)
        Popup.ErrorDetails(
          # Only a simple message because this error does not happen on a normal system
          # (i.e. a system which is not totally broken or totally messed up).
          # Do not confuse this error with the case when no scanning via network is to be set up.
          # The latter results no error.
          _("Failed to set up scanning via network."),
          Ops.get_string(@result, "stderr", "")
        )
        return false
      end
      # Determine active scanners and active backends anew.
      # Return successfully regardless of the result of this steps
      # because scanning via network was successfully set up.
      @active_scanners = [] if !DetermineActiveScanners()
      @active_backends = [] if !DetermineActiveBackends()
      true
    end

    # Determine if any kind of firewall seems to be active by calling
    # "iptables -n -L | egrep -q 'DROP|REJECT'"
    # to find out if there are currently dropping or rejecting packet filter rules.
    # One might use a more specific test via
    # "iptables -n -L | grep -v '^LOG' | egrep -q '^DROP|^REJECT'"
    # to match only for DROP and REJECT targets and exclude LOG targets
    # but it does not cause real problems when there is a false positive result here
    # because all what happens it that then a needless firewall info popup would be shown.
    # If any kind of firewall seems to be active, show a popup message
    # regarding scanning via network and firewall.
    # @return true if any kind of firewall seems to be active
    def ShowFirewallPopup
      if ExecuteBashCommand("iptables -n -L | egrep -q 'DROP|REJECT'")
        Builtins.y2milestone("A firewall seems to be active.")
        Popup.MessageDetails(
          _("Check that your firewall allows scanning via network."),
          # Popup::MessageDetails information regarding details:
          _("For details regarding firewall see the help text of this dialog.")
        )
        return true
      end
      # Return 'false' also as fallback value when the above command fails
      # because of whatever reason because this fallback value is safe
      # because it only results that no firewall info popup is shown
      # the "Print via Network" and/or "Share Printers" dialogs
      # but also the help text of those dialogs explains firewall stuff
      # so that sufficient information is available in any case:
      false
    end

    # Autoinstallation stuff:
    #

    # Get all scanner settings from the first parameter.
    # For use by autoinstallation.
    # @param [Hash] settings The YCP structure to be imported.
    # @return true on success
    def Import(settings)
      settings = deep_copy(settings)
      true
    end

    # Dump the scanner settings to a single map.
    # For use by autoinstallation.
    # @return [Hash] Dumped settings (later acceptable by Import ())
    def Export
      {}
    end

    # Return packages needed to be installed and removed during
    # autoinstallation to ensure module has all needed software installed.
    # @return [Hash] with 2 lists.
    def AutoPackages
      { "install" => [], "remove" => [] }
    end

    publish :variable => :modified, :type => "boolean"
    publish :variable => :proposal_valid, :type => "boolean"
    publish :variable => :write_only, :type => "boolean"
    publish :function => :Modified, :type => "boolean ()"
    publish :function => :Abort, :type => "boolean ()"
    publish :variable => :number_chars, :type => "string"
    publish :variable => :upper_chars, :type => "string"
    publish :variable => :lower_chars, :type => "string"
    publish :variable => :letter_chars, :type => "string"
    publish :variable => :alnum_chars, :type => "string"
    publish :variable => :lower_alnum_chars, :type => "string"
    publish :variable => :database, :type => "list <map <string, string>>"
    publish :variable => :database_manufacturers, :type => "list <string>"
    publish :variable => :database_usbids, :type => "list <string>"
    publish :variable => :active_scanners, :type => "list <map <string, string>>"
    publish :variable => :active_backends, :type => "list <string>"
    publish :variable => :autodetected_scanners, :type => "list <map <string, string>>"
    publish :variable => :network_scanning_config, :type => "map <string, string>"
    publish :variable => :actual_environment, :type => "map <string, string>"
    publish :variable => :stored_environment, :type => "map <string, string>"
    publish :variable => :selected_model_database_index, :type => "integer"
    publish :variable => :selected_autodetected_scanners_index, :type => "integer"
    publish :variable => :ignore_unknown_USB_scanners, :type => "boolean"
    publish :function => :Read, :type => "boolean ()"
    publish :function => :Write, :type => "boolean ()"
    publish :function => :RestartDetection, :type => "boolean ()"
    publish :function => :RunHpsetup, :type => "boolean ()"
    publish :function => :OverviewContents, :type => "list <map <string, any>> ()"
    publish :function => :ModelItems, :type => "list (string)"
    publish :function => :ActivateBackend, :type => "boolean (string, integer, boolean)"
    publish :function => :DeactivateBackend, :type => "boolean (string, integer, boolean)"
    publish :function => :TestBackend, :type => "boolean (string)"
    publish :function => :DetermineNetworkScanningConfig, :type => "boolean ()"
    publish :function => :SetupNetworkScanningConfig, :type => "boolean ()"
    publish :function => :ShowFirewallPopup, :type => "boolean ()"
    publish :function => :Import, :type => "boolean (map)"
    publish :function => :Export, :type => "map ()"
    publish :function => :AutoPackages, :type => "map ()"
  end

  Scanner = ScannerClass.new
  Scanner.main
end
