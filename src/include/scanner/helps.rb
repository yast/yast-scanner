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

# File:	include/scanner/helps.ycp
# Package:	Configuration of scanner
# Summary:	Help texts of all the dialogs
# Authors:	Johannes Meixner <jsmeix@suse.de>
#
# $Id$
module Yast
  module ScannerHelpsInclude
    def initialize_scanner_helps(include_target)
      textdomain "scanner"

      # All helps are here
      @HELPS = {
        "read" =>
          # Read dialog help 1/1:
          _(
            "<p>\n" +
              "<b><big>Initializing Scanner Configuration</big></b><br>\n" +
              "Please wait...\n" +
              "</p>"
          ),
        "write" =>
          # Write dialog help 1/1:
          _(
            "<p>\n" +
              "<b><big>Saving Scanner Configuration</big></b><br>\n" +
              "Please wait...\n" +
              "</p>"
          ),
        "overview" =>
          # Overview dialog help 1/8:
          _(
            "<p>\n" +
              "<b><big>Scanner Configuration</big></b><br>\n" +
              "Set up or change the scanner configuration and show the already active scanners.\n" +
              "</p>"
          ) +
            # Overview dialog help 2/8:
            _(
              "<p>\n" +
                "To set up a new scanner, choose the scanner from the list of\n" +
                "detected scanners and press <b>Edit</b>.\n" +
                "If your scanner has not been detected, use <b>Add</b> for a manual configuration.\n" +
                "</p>"
            ) +
            # Overview dialog help 3/8:
            # Do not change or translate "HP", it is a manufacturer name.
            # Do not change or translate "OfficeJet", it is a model name.
            # Do not change or translate "PSC", it is a model (Printer Scanner Copier) name.
            # Do not change or translate "hp-setup", it is a command name.
            # Do not change or translate "lsusb", it is a command name.
            _(
              "<p>\n" +
                "A normal USB scanner should be detected automatically.\n" +
                "By default, only those USB scanners are shown\n" +
                "for which the USB vendor and product IDs are known.\n" +
                "If a USB scanner is not shown or if there are unexpected results,\n" +
                "try <b>Other</b> and <b>Restart Detection</b>.\n" +
                "It might happen that particular USB devices which are not scanners\n" +
                "are shown too. There is no generic way to reliably distinguish a scanner\n" +
                "from other USB devices because there is no USB device class for scanners.\n" +
                "Try to proceed with <b>Add</b>.\n" +
                "For HP all-in-one devices you may have to run <tt>hp-setup</tt>\n" +
                "via <b>Other</b> and <b>Run hp-setup</b> before you can \n" +
                "configure the scanner unit with this tool.\n" +
                "If you have difficulties configuring your scanner,\n" +
                "check whether it appears in the output of <tt>lsusb</tt>.\n" +
                "If it is not listed there, the USB system cannot communicate with the scanner.\n" +
                "</p>\n"
            ) +
            # Overview dialog help 4/8:
            # Do not change or translate "lsscsi", it is a command name.
            _(
              "<p>\n" +
                "SCSI scanners are normally detected.\n" +
                "If difficulties arise proceeding with <b>Add</b>,\n" +
                "check whether your scanner is shown by the command <tt>lsscsi</tt>.\n" +
                "If not, the SCSI system cannot communicate with the scanner.\n" +
                "Verify that an appropriate kernel module for the SCSI host adapter has been loaded.\n" +
                "</p>"
            ) +
            # Overview dialog help 5/8:
            # Do not change or translate "hp-setup", it is a command name.
            _(
              "<p>\n" +
                "Parallel port scanners cannot be configured with this tool\n" +
                "except for HP all-in-one devices.\n" +
                "Common parallel port scanners must be configured manually.\n" +
                "To set up the scanner unit in a HP all-in-one device,\n" +
                "which is connected to the parallel port,\n" +
                "you may have to run <tt>hp-setup</tt> via <b>Other</b> and <b>Run hp-setup</b>\n" +
                "before you can configure the scanner unit with this tool using <b>Add</b>.\n" +
                "</p>\n"
            ) +
            # Overview dialog help 6/8:
            # Do not confuse a "network scanner" (i.e. a scanner which is directly accessible in the network)
            # with a "network scanner" (i.e. a program which scans the network for other hosts or services)
            # or with a "remote scanner" (i.e. a scanner which is connected to another host in the network).
            # Do not confuse "scanning via network" (i.e. use a remote scanner via another host in the network)
            # with "scanning the network" (i.e. scan the network for other hosts or services).
            # Do not change or translate "hp-setup", it is a command name.
            _(
              "<p>\n" +
                "Network scanners cannot be configured with this tool\n" +
                "except for HP all-in-one devices.\n" +
                "Network scanners must be configured manually.\n" +
                "A network scanner is a scanner that has a network interface\n" +
                "so it is directly accessible in the network.\n" +
                "In contrast, scanning via network means accessing a remote scanner\n" +
                "connected to another host in the network.\n" +
                "To set up the scanner unit in a HP all-in-one device,\n" +
                "which is connected via a built-in network interface,\n" +
                "you may have to run <tt>hp-setup</tt> via <b>Other</b> and <b>Run hp-setup</b>\n" +
                "before it works to configure the scanner unit with this tool using <b>Add</b>.\n" +
                "</p>\n"
            ) +
            # Overview dialog help 7/8:
            # Do not confuse "scanning via network" (i.e. use a remote scanner via another host in the network)
            # with "scanning the network" (i.e. scan the network for other hosts or services).
            # It is not possible to modify or remove an active scanner directly.
            # It is only possible to modify or remove a driver and this way
            # all scanners which are associated with this driver are modified or removed.
            # Do not change or translate "hp-setup", it is a command name.
            _(
              "<p>\n" +
                "The table lists the configured drivers with their associated scanners.\n" +
                "Press <b>Add</b> to select model and driver and enable it.\n" +
                "Press <b>Edit</b> to select and enable a driver.\n" +
                "Press <b>Delete</b> to disable the driver.\n" +
                "If you press <b>Other</b>, you can restart the detection, test enabled drivers,\n" +
                "set up HP all-in-one devices, or set up scanning via network.\n" +
                "</p>"
            ) +
            # Overview dialog help 8/8:
            # The most often problem which is reported by users regarding scanner setup is
            # when a driver was set up but then no scanner was recognized by this driver.
            # If the driver is the right one for the scanner, then in very most cases
            # the reason is a low-level (kernel related) device communication problem
            # (i.e. a low-level USB problem or a low-level SCSI problem).
            # Those problems cannot be fixed from within the YaST scanner setup module
            # but at least the user must be informed.
            # Be careful when you change or translate "No scanner recognized by this driver"
            # because exactly this text is shown here to the user in this case.
            # In particular keep the meaning of "recognize" because the driver actually runs
            # but the running driver fails to recognize the scanner.
            _(
              "<p>\n" +
                "If a driver is set up but no scanner is recognized by the driver, possible reasons are:\n" +
                "The scanner is not connected or switched off,\n" +
                "the driver is not the right one for the particular model\n" +
                "(even small differences in model names or internal differences in\n" +
                "the same model series may require different drivers),\n" +
                "there are low-level (kernel related) device communication problems\n" +
                "(e.g. a low-level USB problem or a low-level SCSI problem).\n" +
                "</p>"
            ),
        "select_model" =>
          # SelectModel dialog help 1/5:
          # Do not change or translate "SANE", it is a project name.
          _(
            "<p>\n" +
              "<b><big>Scanner Model Selection</big></b><br>\n" +
              "All known scanner models, both supported and unsupported, are listed here.\n" +
              "Read all information carefully before selecting a model and pressing <b>Next</b>.\n" +
              "The information is based on data of the SANE project at\n" +
              "<tt>http://www.sane-project.org/</tt>.\n" +
              "</p>"
          ) +
            # SelectModel dialog help 2/5:
            # Do not change or translate "SANE", it is a project name.
            # Do not change or translate "sane-backends", it is a package name.
            _(
              "<p>\n" +
                "A model is supported if there is at least one appropriate scanner driver available.\n" +
                "Most scanner drivers are from the SANE project and provided in the sane-backends package.\n" +
                "The support status for a particular model varies from minimal to complete.<br>\n" +
                "When a driver is shown as 'unmaintained', it does not mean that the driver does not work.\n" +
                "Even an unmaintained driver could work perfectly well.\n" +
                "But it means that there is no longer someone who knows about the driver internals\n" +
                "so that there is usually no help if there are issues with an unmaintained driver.\n" +
                "</p>"
            ) +
            # SelectModel dialog help 3/5:
            _(
              "<p>\n" +
                "Even if a model has no driver available, the manufacturer might have a driver.\n" +
                "Therefore, you should ask the scanner manufacturer for a driver for an unsupported scanner.\n" +
                "</p>"
            ) +
            # SelectModel dialog help 4/5:
            # Add the following sentence to translations:
            # Such comments are only available in English.
            _(
              "<p>\n" +
                "When additional comments are available, they are shown in square brackets.\n" +
                "</p>"
            ) +
            # SelectModel dialog help 4/5:
            # Do not change or translate "^Epson.*", "^Epson.*perfection", "^Epson.*1200":
            # These are intentionally selected actually working examples.
            _(
              "<p>\n" +
                "Use the <b>Search String</b> to find an appropriate entry quickly.\n" +
                "To find some text anywhere in the table, enter it in the field.\n" +
                "A more complicated search using a case-insensitive regular expression is also possible.\n" +
                "If the scanner was detected and the manufacturer name is available in this list,\n" +
                "the search string is preset with the manufacturer name, such as <tt>^Epson.*</tt>.\n" +
                "To refine the search results, append model-specific details to the search string.\n" +
                "For example, append a word that is part of the model name as in <tt>^Epson.*perfection</tt>\n" +
                "or append some digits that are part of the model name as in <tt>^Epson.*1200</tt>.\n" +
                "</p>"
            ),
        "configure_backend" =>
          # ConfigureBackend dialog help 1/4:
          _(
            "<p>\n" +
              "<b><big>Scanner and Driver Setup</big></b><br>\n" +
              "The driver is activated and the associated scanners are probed.\n" +
              "This may take a few seconds, so you must wait until you can press <b>Next</b>.\n" +
              "If you press <b>Back</b>, the driver is deactivated.\n" +
              "</p>"
          ) +
            # ConfigureBackend dialog help 2/4:
            _(
              "<p>\n" +
                "<b><big>Additional Packages</big></b><br>\n" +
                "If the package that provides the driver is not yet installed,\n" +
                "an appropriate dialog is shown to install the package.\n" +
                "Such packages may not be available for all architectures.\n" +
                "</p>"
            ) +
            # ConfigureBackend dialog help 3/4:
            _(
              "<p>\n" +
                "<b><big>Firmware Upload</big></b><br>\n" +
                "Some models require a firmware upload.\n" +
                "In this case, an appropriate explanatory text is shown.\n" +
                "</p>"
            ) +
            # ConfigureBackend dialog help 4/4:
            # Do not change or translate "HP", it is a manufacturer name.
            # Do not change or translate "HPOJ", it is a project name.
            # Do not change or translate "hp-officeJet", it is a package name.
            # Do not change or translate "PTAL", it is a subsystem name.
            # Do not change or translate "ptal", it is a service name.
            # Do not change or translate "HPLIP", it is a project name.
            # Do not change or translate "hpaio", it is a driver name.
            # The "for all" is crucial in "either ... or ... must be used for all HP all-in-one devices".
            _(
              "<p>\n" +
                "<b><big>HP All-in-One Devices</big></b><br>\n" +
                "HP all-in-one devices may require a special setup.\n" +
                "In this case, an appropriate dialog is shown.\n" +
                "There are two software packages that provide support for HP all-in-one devices:\n" +
                "the outdated HPOJ software (package hp-officeJet which is no longer available),\n" +
                "which provides the PTAL system (with the ptal service) to access HP all-in-one devices,\n" +
                "and the up-to-date HPLIP software (package hplip), which provides the hpaio driver.\n" +
                "Both software packages can be installed at the same time\n" +
                "but the ptal service and the hpaio driver cannot run together.\n" +
                "Therefore either the patl service or the hpaio driver\n" +
                "must be used for all HP all-in-one devices.\n" +
                "</p>"
            ),
        "configure_network_scanning" =>
          # ConfigureNetworkScanning dialog help 1/5:
          # Do not confuse "scanning via network" (i.e. use a remote scanner via another host in the network)
          # with "scanning the network" (i.e. scan the network for other hosts or services).
          _(
            "<p>\n" +
              "<b><big>Scanning via Network</big></b><br>\n" +
              "Enter the appropriate information and press <b>Next</b>\n" +
              "to set up scanning via network.\n" +
              "</p>"
          ) +
            # ConfigureNetworkScanning dialog help 2/5:
            # Do not change or translate "saned", it is a program (sane daemon) name.
            # Do not change or translate "CIDR", it is a (sub)-network notation name.
            # Do not change or translate "192.168.1.0/24", it is an intentionally selected actually working example.
            # Do not change or translate "xinetd", it is a program (daemon) name.
            _(
              "<p>\n" +
                "<b><big>Server Settings</big></b><br>\n" +
                "If you have locally connected scanners and want to make them accessible via the network,\n" +
                "set up the saned network scanning daemon so that your host becomes a server.\n" +
                "In <b>Permitted Clients</b>, enter which client hosts are permitted to access saned on your server.\n" +
                "Enter a comma-separated list of client hosts (hostnames or IP addresses)\n" +
                "or subnets (CIDR notation, such as 192.168.1.0/24).\n" +
                "If no client hosts are permitted, saned is not activated.\n" +
                "If saned is activated, xinetd is also activated and set up for saned.\n" +
                "</p>"
            ) +
            # ConfigureNetworkScanning dialog help 3/5:
            # Do not change or translate "saned", it is a program (sane daemon) name.
            # Do not change or translate "sane-port", it is a port name (see /etc/services).
            # Be careful when you change or translate "external", "internal", and "zone"
            # to keep the relationship to the matching terms in the YaST firewall setup module
            # where also "external zone", and "internal zone" is used.
            # Keep the information that external access is useless and insecure (see "man saned").
            _(
              "<p>\n" +
                "<b><big>Regarding Firewall</big></b><br>\n" +
                "A firewall is used to protect running server processes\n" +
                "on your host against unwanted access via network.\n" +
                "For using scanners via network the SANE network daemon (the saned)\n" +
                "is the server process which must run so that remote clients\n" +
                "can access scanners which are connected to your local host.\n" +
                "Client hosts contact the saned via the sane-port (TCP port 6566)\n" +
                "but scanning data is transferred via an additional random port.\n" +
                "Therefore only port 6566 is not sufficient for scanning via network.<br>\n" +
                "Do not open the sane-port 6566 or any other port\n" +
                "regarding using scanners for the external zone in the firewall.\n" +
                "This is dangerous because it allows access to the saned from foreign hosts\n" +
                "so that the firewall does no longer provide any protection for the saned.\n" +
                "Allowing access from the external network (i.e. for the external zone)\n" +
                "does not make sense because scanning documents requires\n" +
                "physical scanner access by trusted users.<br>\n" +
                "On the other hand the default firewall settings allow\n" +
                "any access from an internal (i.e. trusted) network.\n" +
                "To make the saned on your server accessible from an internal network,\n" +
                "assign the network interface which belongs to the internal network\n" +
                "to the internal zone of the firewall.\n" +
                "Use the YaST Firewall setup module to do this fundamental setup\n" +
                "regarding network security and firewall and scanning via network\n" +
                "will work without any further firewall setup.<br>\n" +
                "For details see the openSUSE support database\n" +
                "article 'CUPS and SANE Firewall settings' at<br>\n" +
                "http://en.opensuse.org/SDB:CUPS_and_SANE_Firewall_settings\n" +
                "</p>"
            ) +
            # ConfigureNetworkScanning dialog help 4/5:
            # Do not change or translate "net", it is a metadriver name.
            # Do not simply use "driver" because net is no normal driver but a metadriver.
            # Do not change or translate "saned", it is a program (sane daemon) name.
            _(
              "<p>\n" +
                "<b><big>Client Settings</big></b><br>\n" +
                "If you want to access scanners connected to other hosts (servers) in the network,\n" +
                "set up the net metadriver to access them via the daemon running on the servers.\n" +
                "The saned and the firewall on the servers must permit the access.\n" +
                "In <b>Servers Used</b>, enter which servers should be used.\n" +
                "Enter a comma-separated list of servers (server names or IP addresses).\n" +
                "If no servers are entered, net is not activated.\n" +
                "</p>"
            ) +
            # ConfigureNetworkScanning dialog help 5/5:
            # Be careful when you change or translate "local host configuration"
            # because this term is used also in a message of a Popup::ContinueCancel
            # and as label of a PushButton for a predefined configuration.
            # Do not change or translate "saned", it is a program (sane daemon) name.
            # Do not change or translate "net", it is a metadriver name.
            # Do not simply use "driver" because net is no normal driver but a metadriver.
            # Do not change or translate "localhost", it is a fixed hostname for the local host.
            _(
              "<p>\n" +
                "<b><big>Local Host Configuration</big></b><br>\n" +
                "By using the loopback network, saned and the net metadriver\n" +
                "can be used even on your local host.\n" +
                "In this case, the server and client are the same machine (localhost).\n" +
                "Some scanners, such as parallel port scanners, require root privileges.\n" +
                "When you enter <tt>localhost</tt> for both the server and the client,\n" +
                "you can access such a scanner even as a normal user on your local host.\n" +
                "</p>"
            )
      } 

      # EOF
    end
  end
end
