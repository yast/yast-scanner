#
# scannerDB
# This script is part of the YaST2 Scanner installation module
#
# This module contains the scanner database - here is the decision which
# scanner does the work for which scanner.
# 
# Copyright SuSE Gmbh - 2001
# 
# Author: Klaas Freitag <freitag@suse.de>
#         Gabi Strattner <gs@suse.de>
#
# $Id$
#
package scannerDB;

use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION);
use Exporter;
use File::Copy;
use ycp;
use English;

@ISA            = qw(Exporter);
@EXPORT         = qw( getModel 
		      getVendorList
		      findInHash
		      trim
		      readNetconf
		      writeNetconf
		      readDllconf
		      writeDllconf
		      writeIndividualConf
		      acquireTestImage 
		      performScanimage 
		      getNetInfo 
		      revertAll
		      enableNetScan 
		      disableNetScan );

use vars qw ( %driver $prefix);


# Abaton
$driver{SCSI}{Abaton}{"SCAN 300/GS"} = "abaton";
$driver{SCSI}{Abaton}{"SCAN 300/S"} = "abaton";

# Agfa


$driver{SCSI}{Agfa}{"FOCUS GS SCANNER"} = "agfafocus";
$driver{SCSI}{Agfa}{"FOCUS LINEART SCANNER"} = "agfafocus";
$driver{SCSI}{Agfa}{"FOCUS II"} = "agfafocus";
$driver{SCSI}{Agfa}{"FOCUS COLOR"} = "agfafocus";

$driver{SCSI}{Siemens}{"FOCUS COLOR PLUS"} = "agfafocus";

# Apple
$driver{SCSI}{Apple}{"APPLE SCANNER"} = "apple";
$driver{SCSI}{Apple}{"ONESCANNER"} = "apple";

# Artec and Ultima
$driver{SCSI}{"Artec"}{"ColorOneScanner"} = "artec";
$driver{SCSI}{"Artec"}{"AT3"} = "artec";
$driver{SCSI}{"Artec"}{"A6000C"} = "artec";
$driver{SCSI}{"Artec"}{"A6000C PLUS"} = "artec";
$driver{SCSI}{"Artec"}{"AT6"} = "artec";
$driver{SCSI}{"Artec"}{"AT12"} = "artec";
$driver{SCSI}{"Artec"}{"AM12S"} = "artec";
$driver{SCSI}{"Ultima"}{"ColorOneScanner"} = "artec";
$driver{SCSI}{"Ultima"}{"AT3"} = "artec";
$driver{SCSI}{"Ultima"}{"A6000C"} = "artec";
$driver{SCSI}{"Ultima"}{"A6000C PLUS"} = "artec";
$driver{SCSI}{"Ultima"}{"AT6"} = "artec";
$driver{SCSI}{"Ultima"}{"AT12"} = "artec";
$driver{SCSI}{"Ultima"}{"AM12S"} = "artec";

$driver{SCSI}{BlackWidow}{"BW4800SP"} = "artec";
$driver{SCSI}{Plustek}{"OpticPro 19200S"} = "artec";

# avision
$driver{SCSI}{Avision}{"AV 6240"} = "avision";
$driver{SCSI}{Avision}{"AV 630 CS"} = "avision";
$driver{SCSI}{Avision}{"AV 620 CS"} = "avision";

# Bell & Howell
$driver{SCSI}{"B&H SCSI"}{"COPISCAN II 6338"} = "bh";
$driver{SCSI}{"B&H SCSI"}{"COPISCAN II 2135"} = "bh";
$driver{SCSI}{"B&H SCSI"}{"COPISCAN II 2137(A)"} = "bh";
$driver{SCSI}{"B&H SCSI"}{"COPISCAN II 2138A"} = "bh";
$driver{SCSI}{"B&H SCSI"}{"COPISCAN II 3238"} = "bh";
$driver{SCSI}{"B&H SCSI"}{"COPISCAN II 3338"} = "bh";

# Canon
$driver{SCSI}{Canon}{"CANOSCAN 300"} = "canon";
$driver{SCSI}{Canon}{"CANOSCAN 600"} = "canon";
$driver{SCSI}{Canon}{"CANOSCAN 2700F"} = "canon";

# Coolscan
$driver{SCSI}{Nikon}{"LS-20"} = "coolscan";
$driver{SCSI}{Nikon}{"LS-30"} = "coolscan";
$driver{SCSI}{Nikon}{"LS-2000"} = "coolscan";
$driver{SCSI}{Nikon}{"LS-1000"} = "coolscan";

# Epson: Parport not supported yet.
# 
# $driver{Parport}{Epson}{GT-5000} = "epson";
# $driver{Parport}{Epson}{Actionscanner II} = "epson";
# $driver{Parport}{Epson}{GT-6000} = "epson";
# $driver{Parport}{Epson}{ES-300C} = "epson";

$driver{SCSI}{Epson}{"GT-5500"} = "epson";
# $driver{Parport}{Epson}{GT-6500} = "epson";
# $driver{Parport}{Epson}{ES-600C} = "epson";
# $driver{Parport}{Epson}{ES-1200C} = "epson";
$driver{SCSI}{Epson}{"GT-7000"} = "epson";
$driver{SCSI}{Epson}{"GT-8000"} = "epson";
$driver{SCSI}{Epson}{"ES-8500"} = "epson";
$driver{SCSI}{Epson}{"PERFECTION 636S"} = "epson";
$driver{USB}{Epson}{"PERFECTION 636U"} = "epson";
$driver{USB}{Epson}{"PERFECTION 610"} = "epson";
$driver{USB}{Epson}{"PERFECTION 640"} = "epson";
$driver{SCSI}{Epson}{"PERFECTION 1200S"} = "epson";
$driver{USB}{Epson}{"PERFECTION 1200U"} = "epson";
$driver{USB}{Epson}{"PERFECTION 1200PHOTO"} = "epson";
$driver{SCSI}{Epson}{"PERFECTION 1240"} = "epson";
$driver{SCSI}{Epson}{"PERFECTION 1640"} = "epson";
$driver{USB}{Epson}{"PERFECTION 1240"} = "epson";
$driver{USB}{Epson}{"PERFECTION 1640"} = "epson";
$driver{SCSI}{Epson}{"EXPRESSION 636"} = "epson";
$driver{SCSI}{Epson}{"EXPRESSION 800"} = "epson";

$driver{SCSI}{Epson}{"EXPRESSION 1600"} = "epson";
$driver{USB}{Epson}{"EXPRESSION 1600"} = "epson";

$driver{SCSI}{Epson}{"EXPRESSION 1680"} = "epson";
$driver{USB}{Epson}{"EXPRESSION 1680"} = "epson";

$driver{SCSI}{Epson}{"FILMSCAN 200"} = "epson";

# Hewlett Packard
# $driver{Propietary}{HP}{HP ScanJet Plus} = "hp";
$driver{SCSI}{HP}{"HP SCANJET IIC"} = "hp";
$driver{SCSI}{HP}{"HP SCANJET IIP"} = "hp";
$driver{SCSI}{HP}{"HP SCANJET IICX"} = "hp";
$driver{SCSI}{HP}{"HP SCANJET 3C"} = "hp";
$driver{SCSI}{HP}{"HP SCANJET 3P"} = "hp";
$driver{SCSI}{HP}{"HP SCANJET 4C"} = "hp";
$driver{SCSI}{HP}{"HP SCANJET 4P"} = "hp";
$driver{USB}{HP}{"HP SCANJET 4100C"} = "hp";
$driver{SCSI}{HP}{"HP ScanJet 5p"} = "hp";
# $driver{Parport}{HP}{HP ScanJet 5100C} = "hp";
# $driver{Parport 
$driver{USB}{HP}{"HP ScanJet 5200C"} = "hp";
$driver{SCSI}{HP}{"HP ScanJet 6100C"} = "hp";
$driver{SCSI}{HP}{"HP ScanJet 6200C"} = "hp";
$driver{USB}{HP}{"HP ScanJet 6200C"} = "hp";
$driver{SCSI}{HP}{"HP ScanJet 6250C"} = "hp";
$driver{USB}{HP}{"HP ScanJet 6250C"} = "hp";
$driver{SCSI}{HP}{"HP ScanJet 6300C"} = "hp";
$driver{USB}{HP}{"HP ScanJet 6300C"} = "hp";
$driver{SCSI}{HP}{"HP ScanJet 6350C"} = "hp";
$driver{USB}{HP}{"HP ScanJet 6350C"} = "hp";
$driver{SCSI}{HP}{"HP ScanJet 6390C"} = "hp";
$driver{USB}{HP}{"HP ScanJet 6390C"} = "hp";
$driver{SCSI}{HP}{"HP PhotoSmart PhotoScanner"} = "hp";
# $driver{Parport(ECP) JetDirect}{HP}{HP OfficeJet Pro 1150C} = "hp";
# $driver{Parport(ECP) JetDirect}{HP}{HP OfficeJet Pro 1170C/1175C} = "hp";
# $driver{Parport(ECP) JetDirect}{HP}{HP OfficeJet R series/PSC500} = "hp";
# $driver{Parport(ECP) USB JetDirect}{HP}{HP OfficeJet G series} = "hp";
$driver{USB}{HP}{"HP PSC 700 series"} = "hp";

# $driver{Parport(ECP) USB JetDirect}{HP}{HP OfficeJet K series} = "hp";
# $driver{}{HP}{HP OfficeJet V series} = "hp";


$driver{HP}{HP}{"HP4200"} = "hp4200";

$driver{SCSI}{"Fujitsu"}{"M3096G"} = "m3096g";
$driver{SCSI}{"Fujitsu"}{"SP15C"} = "sp15c";

$driver{SCSI}{Microtek}{"Scanmaker E6"} = "microtek";
$driver{SCSI}{Microtek}{"Scanmaker E3"} = "microtek";
$driver{SCSI}{Microtek}{"Scanmaker E2"} = "microtek";
$driver{SCSI}{Microtek}{"Scanmaker 35t+"} = "microtek";
$driver{SCSI}{Microtek}{"Scanmaker 45t"} = "microtek";
$driver{SCSI}{Microtek}{"Scanmaker 35"} = "microtek";
$driver{SCSI}{Microtek}{"Scanmaker III"} = "microtek";
$driver{SCSI}{Microtek}{"Scanmaker IISP"} = "microtek";
$driver{SCSI}{Microtek}{"Scanmaker IIHR"} = "microtek";
$driver{SCSI}{Microtek}{"Scanmaker IIG"} = "microtek";
$driver{SCSI}{Microtek}{"Scanmaker II"} = "microtek";

$driver{SCSI}{Microtek}{"Scanmaker 600Z(S)"} = "microtek";
$driver{SCSI}{Microtek}{"Scanmaker 600ZS"} = "microtek";
$driver{SCSI}{Microtek}{"Scanmaker 600Z"} = "microtek";
$driver{SCSI}{Microtek}{"Scanmaker 600S"} = "microtek";

$driver{SCSI}{Microtek}{"Scanmaker 600G(S)"} = "microtek";
$driver{SCSI}{Microtek}{"Scanmaker 600S"} = "microtek";
$driver{SCSI}{Microtek}{"Scanmaker 600G"} = "microtek";
$driver{SCSI}{Microtek}{"Scanmaker 600GS"} = "microtek";

# $driver{SCSI (Parport)}{Agfa}{Color PageWiz} = "microtek";

$driver{SCSI}{Agfa}{"Arcus II"} = "microtek";
$driver{SCSI}{Agfa}{"StudioScan"} = "microtek";
$driver{SCSI}{Agfa}{"StudioScan II"} = "microtek";
$driver{SCSI}{Agfa}{"StudioScan IIsi"} = "microtek";
$driver{SCSI}{Agfa}{"DuoScan"} = "microtek";

#  Mikrotek 2
$driver{SCSI}{Microtek}{"ScanMaker E3plus"} = "microtek2";
$driver{SCSI}{Microtek}{"ScanMaker X6"}     = "microtek2";
$driver{SCSI}{Microtek}{"ScanMaker X6EL"}   = "microtek2";
$driver{USB} {Microtek}{"ScanMaker X6USB"}   = "microtek2";
$driver{SCSI}{Microtek}{"ScanMaker V300"}   = "microtek2";
$driver{SCSI}{Microtek}{"ScanMaker V310"} = "microtek2";
$driver{SCSI}{Microtek}{"ScanMaker 330"} = "microtek2";
$driver{SCSI}{Microtek}{"ScanMaker 630"} = "microtek2";
$driver{SCSI}{Microtek}{"ScanMaker 636"} = "microtek2";
$driver{SCSI}{Microtek}{"Phantom 636"} = "microtek2";
$driver{SCSI}{Microtek}{"ScanMaker 9600XL"} = "microtek2";
$driver{SCSI}{Microtek}{"ScanMaker V6USL"} = "microtek2";
$driver{SCSI}{Microtek}{"ScanMaker V600"} = "microtek2";
$driver{SCSI}{Vobis}{"E3plus based"} = "microtek2";

# $driver{Parport}{Microtek}{ScanMaker V300} = "microtek2";
# $driver{Parport}{Microtek}{ScanMaker V310} = "microtek2";
# $driver{Parport}{Microtek}{ScanMaker V600} = "microtek2";
# $driver{Parport}{Microtek}{Phantom 330CX} = "microtek2";
# $driver{Parport}{Microtek}{SlimScan C3} = "microtek2";
# $driver{Parport}{Microtek}{Phantom 636CX} = "microtek2";


# Mustek SCSI
$driver{SCSI}{Mustek}{"Paragon MFS-6000CX"} = "mustek";
$driver{SCSI}{Mustek}{"Paragon MFS-12000CX"} = "mustek";
$driver{SCSI}{Mustek}{"Paragon MFC-600S"} = "mustek";
$driver{SCSI}{Mustek}{"Paragon 600 II CD"} = "mustek";
$driver{SCSI}{Mustek}{"ScanMagic 600 II SP"} = "mustek";
$driver{SCSI}{Mustek}{"Paragon MFC-800S"} = "mustek";
$driver{SCSI}{Mustek}{"Paragon 800 II SP"} = "mustek";
$driver{SCSI}{Mustek}{"Paragon MFS-6000SP"} = "mustek";
$driver{SCSI}{Mustek}{"Paragon MFS-8000SP"} = "mustek";
$driver{SCSI}{Mustek}{"Paragon MFS-1200SP"} = "mustek";
$driver{SCSI}{Mustek}{"Paragon MFS-12000SP"} = "mustek";
$driver{SCSI}{Mustek}{"ScanExpress 6000SP"} = "mustek";
$driver{SCSI}{Mustek}{"ScanExpress 12000SP"} = "mustek";
$driver{SCSI}{Mustek}{"ScanExpress 12000SP Plus"} = "mustek";
$driver{SCSI}{Mustek}{"Paragon 1200 III SP"} = "mustek";
$driver{SCSI}{Mustek}{"Paragon 1200 LS"} = "mustek";
$driver{SCSI}{Mustek}{"ScanMagic 9636S"} = "mustek";
$driver{SCSI}{Mustek}{"ScanMagic 9636S Plus"} = "mustek";
$driver{SCSI}{Mustek}{"ScanExpress A3 SP"} = "mustek";
$driver{SCSI}{Mustek}{"Paragon 1200 SP Pro"} = "mustek";
$driver{SCSI}{Mustek}{"Paragon 1200 A3 Pro"} = "mustek";

$driver{USB}{Mustek}{"1200 UB"} = "mustek_usb";
$driver{USB}{Mustek}{"1200 CU"} = "mustek_usb";
$driver{USB}{Mustek}{"1200 CU Plus"} = "mustek_usb";




$driver{SCSI}{Trust}{"Imagery 1200 SP"} = "mustek";
$driver{SCSI}{Trust}{"Imagery 4800 SP"} = "mustek";
$driver{SCSI}{Trust}{"SCSI Connect 19200"} = "mustek";
$driver{SCSI}{Trust}{"SCSI excellence series 19200"} = "mustek";

# Mustek Parallel Port 
# $driver{Parport (EPP)}{Mustek}{ScanExpress 6000 P} = "mustek_pp";
# $driver{Parport (EPP)}{Mustek}{ScanMagic 4800 P} = "mustek_pp";
# $driver{Parport (EPP)}{Mustek}{ScanExpress 1200 ED Plus} = "mustek_pp";
# $driver{Parport (EPP)}{Mustek}{ScanMagic 1200 ED Plus} = "mustek_pp";
# $driver{Parport (EPP)}{Mustek}{ScanExpress 12000 P} = "mustek_pp";
# $driver{Parport (SPP,EPP)}{Mustek}{600 III EP Plus} = "mustek_pp";
# $driver{Parport (EPP)}{Medion}{ScanExpress 600 SEP} = "mustek_pp";
# $driver{Parport (SPP)}{Medion}{MD9848} = "mustek_pp";
# $driver{Parport (EPP)}{Tevion}{MD985x} = "mustek_pp";
# $driver{Parport (EPP)}{LifeTec}{MD985x} = "mustek_pp";
# $driver{Parport (EPP)}{LifeTec}{LT9891} = "mustek_pp";

# NEC
$driver{SCSI}{NEC}{"PC-IN500/4C"} = "nec";

# Pie
$driver{SCSI}{Devcom}{"9636PRO"} = "pie";
$driver{SCSI}{Devcom}{"9636S"} = "pie";
$driver{SCSI}{Pie}{"9630S"} = "pie";

$driver{SCSI}{Pie}{"ScanAce 1236S"} = "pie";
$driver{SCSI}{Pie}{"ScanAce 1230S"} = "pie";
$driver{SCSI}{Pie}{"ScanAce II"} = "pie";
$driver{SCSI}{Pie}{"ScanAce III"} = "pie";
$driver{SCSI}{Pie}{"ScanAce Plus"} = "pie";
$driver{SCSI}{Pie}{"ScanAce II Plus"} = "pie";
$driver{SCSI}{Pie}{"ScanAce III Plus"} = "pie";
$driver{SCSI}{Pie}{"ScanAce V"} = "pie";
$driver{SCSI}{Pie}{"ScanAce ScanMedia"} = "pie";
$driver{SCSI}{Pie}{"ScanAce ScanMedia II"} = "pie";
$driver{SCSI}{Pie}{"ScanAce 630S"} = "pie";
$driver{SCSI}{Pie}{"ScanAce 636S"} = "plustek";

# Plustek
# $driver{Parport (SPP, EPP)}{Plustek}{OpticPro 4800P} = "plustek";
# $driver{Parport (SPP, EPP)}{Plustek}{OpticPro 4830P} = "plustek";
# $driver{Parport (SPP, EPP)}{Plustek}{OpticPro 600P/6000P} = "plustek";
# $driver{Parport (SPP, EPP)}{Plustek}{OpticPro 4831P} = "plustek";
# $driver{Parport (SPP, EPP)}{Plustek}{OpticPro 9630P} = "plustek";
# $driver{Parport (SPP, EPP)}{Plustek}{OpticPro 9630PL} = "plustek";
# $driver{Parport (SPP, EPP)}{Plustek}{OpticPro 9600P} = "plustek";
# $driver{Parport (SPP, EPP)}{Plustek}{OpticPro 1236P} = "plustek";
# $driver{Parport (SPP, EPP)}{Plustek}{OpticPro 12000P/96000P} = "plustek";
# $driver{Parport (SPP, EPP)}{Plustek}{OpticPro 9636P} = "plustek";
# $driver{Parport (SPP, EPP)}{Plustek}{OpticPro 9636P+/Turbo} = "plustek";
# $driver{Parport (SPP, EPP)}{Plustek}{OpticPro 9636T} = "plustek";
# $driver{Parport (SPP, EPP)}{Plustek}{OpticPro 12000T} = "plustek";
# $driver{Parport (SPP, EPP)}{Plustek}{OpticPro AI3} = "plustek";
# $driver{Parport}{Plustek}{OpticPro P8} = "plustek";
# $driver{Parport (SPP, EPP)}{Plustek}{OpticPro P12} = "plustek";
# $driver{Parport (SPP, EPP)}{Plustek}{OpticPro PT12} = "plustek";
# $driver{Parport (SPP, EPP)}{Primax}{Colorado 4800} = "plustek";
# $driver{Parport (SPP, EPP)}{Primax}{Compact 4800 Direct} = "plustek";
# $driver{Parport (SPP, EPP)}{Primax}{Compact 4800 Direct-30} = "plustek";
# $driver{Parport (SPP, EPP)}{Aries}{Compact 9600 Direct-30} = "plustek";

# Ricoh
$driver{SCSI}{Ricoh}{"Ricoh IS50"} = "ricoh";
$driver{SCSI}{Ricoh}{"Ricoh IS60"} = "ricoh";

# Siemens
$driver{SCSI}{Siemens}{"9036 Flatbed scanner"} = "s9036";
$driver{SCSI}{Siemens}{"ST800"} = "st400";
$driver{SCSI}{Siemens}{"ST400"} = "st400";

# Sharp
$driver{SCSI}{Sharp}{"9036 Flatbed scanner"} = "sharp";
$driver{SCSI}{Sharp}{"JX-610"} = "sharp";
$driver{SCSI}{Sharp}{"JX-250"} = "sharp";
$driver{SCSI}{Sharp}{"JX-320"} = "sharp";
$driver{SCSI}{Sharp}{"JX-330"} = "sharp";
$driver{SCSI}{Sharp}{"JX-350"} = "sharp";

# Snapscan
$driver{SCSI}{Agfa}{"SnapScan 300"} = "SnapScan";
$driver{SCSI}{Agfa}{"SnapScan 310"} = "SnapScan";
$driver{SCSI}{Agfa}{"SnapScan 600"} = "SnapScan";
$driver{SCSI}{Agfa}{"SnapScan 1236s"} = "SnapScan";
$driver{USB}{Agfa}{"SnapScan 1212u"} = "SnapScan";

$driver{USB}{Agfa}{"SnapScan e20"} = "SnapScan";
$driver{USB}{Agfa}{"SnapScan e40"} = "SnapScan";
$driver{USB}{Vuego}{"SnapScan e50"} = "SnapScan";
$driver{SCSI}{"Close SnapScan 310 compatible."} = "SnapScan";

$driver{SCSI}{Acer}{"310s"} = "SnapScan";
$driver{SCSI}{Acer}{"300f"} = "SnapScan";
$driver{SCSI}{Acer}{"310s"} = "SnapScan";
$driver{SCSI}{Acer}{"610s"} = "SnapScan";
$driver{SCSI}{Acer}{"610plus"} = "SnapScan";
$driver{SCSI}{Acer}{"Prisa 620s"} = "SnapScan";
$driver{USB}{Acer}{"Prisa 620u"} = "SnapScan";
$driver{USB}{Acer}{"Prisa 640u"} = "SnapScan";
$driver{USB}{Acer}{"Prisa 640bu"} = "SnapScan";
$driver{USB}{Guillemot}{"Maxi Scan A4 Deluxe (SCSI)"} ="SnapScan";

# Tamarack
$driver{SCSI}{Tamarack}{"Artiscan 6000C"} = "tamarack";
$driver{SCSI}{Tamarack}{"Artiscan 8000C"} = "tamarack";
$driver{SCSI}{Tamarack}{"Artiscan 12000C"} = "tamarack";

# Umax
# $driver{Parport}{UMAX}{parallel scanners} = "umax";
# $driver{Firewire}{UMAX}{USB scanners} = "umax";
$driver{SCSI}{UMAX}{"Vista S6"} = "umax";
$driver{SCSI}{UMAX}{"Vista S6E"} = "umax";
$driver{SCSI}{UMAX}{"UMAX S-6E"} = "umax";
$driver{SCSI}{UMAX}{"UMAX S-6EG"} = "umax";
$driver{SCSI}{UMAX}{"Vista-S8"} = "umax";
$driver{SCSI}{UMAX}{"Supervista S-12"} = "umax";
$driver{SCSI}{UMAX}{"UMAX S-12"} = "umax";
$driver{SCSI}{UMAX}{"UMAX S-12G"} = "umax";
$driver{SCSI}{UMAX}{"Astra 600S"} = "umax";
$driver{SCSI}{UMAX}{"Astra 610S"} = "umax";
$driver{SCSI}{UMAX}{"Astra 1200S"} = "umax";
$driver{SCSI}{UMAX}{"Astra 1220S"} = "umax";
$driver{SCSI}{UMAX}{"Astra 2100S"} = "umax";
$driver{SCSI}{UMAX}{"Astra 2200 (SU)"} = "umax";
$driver{SCSI}{UMAX}{"Astra 2400S"} = "umax";
$driver{SCSI}{UMAX}{"Mirage D-16L"} = "umax";
$driver{SCSI}{UMAX}{"Mirage II"} = "umax";
$driver{SCSI}{UMAX}{"Mirage IIse"} = "umax";
$driver{SCSI}{UMAX}{"PSD"} = "umax";
$driver{SCSI}{UMAX}{"PowerLook"} = "umax";
$driver{SCSI}{UMAX}{"PL-II"} = "umax";
$driver{SCSI}{UMAX}{"PowerLook III"} = "umax";
$driver{SCSI}{UMAX}{"PowerLook 2000"} = "umax";
$driver{SCSI}{UMAX}{"PowerLook 3000"} = "umax";
$driver{SCSI}{UMAX}{"Gemini D-16"} = "umax";
$driver{SCSI}{UMAX}{"UMAX VT600"} = "umax";
$driver{SCSI}{UMAX}{"Vista-T630"} = "umax";
$driver{SCSI}{UMAX}{"UC 630"} = "umax";
$driver{SCSI}{UMAX}{"UG 630"} = "umax";
$driver{SCSI}{UMAX}{"UG 80"} = "umax";
$driver{SCSI}{UMAX}{"UC 840"} = "umax";
$driver{SCSI}{UMAX}{"UC 1200S"} = "umax";
$driver{SCSI}{UMAX}{"UC 1200SE"} = "umax";
$driver{SCSI}{UMAX}{"UC 1260"} = "umax";
$driver{SCSI}{UMAX}{"Jade"} = "umax";
$driver{SCSI}{UMAX}{"Jade"} = "umax";
$driver{SCSI}{UMAX}{"Jade2"} = "umax";
$driver{SCSI}{UMAX}{"Saphir"} = "umax";
$driver{SCSI}{UMAX}{"Saphir2"} = "umax";
$driver{SCSI}{UMAX}{"Saphir Ultra"} = "umax";
$driver{SCSI}{UMAX}{"Saphir Ultra II"} = "umax";
$driver{SCSI}{UMAX}{"Saphir HiRes"} = "umax";
$driver{SCSI}{UMAX}{"Opal"} = "umax";
$driver{SCSI}{UMAX}{"Opal Ultra"} = "umax";
$driver{SCSI}{UMAX}{"Linoscan 1400"} = "umax";

$driver{SCSI}{"Vobis"}{"Scanboostar Premium"} = "umax";
$driver{SCSI}{"Highscreen"}{"Scanboostar Premium"} = "umax";

$driver{SCSI}{Escom}{"Image Scanner 256"} = "umax";
$driver{SCSI}{Escort}{"Galleria 600"} = "umax";
$driver{SCSI}{Genius}{"ColorPage-HR5 (Pro)"} = "umax";
$driver{SCSI}{Nikon}{"AX-210"} = "umax";

# More parallel-port:
# $driver{}{UMAX}{AX-210} = "umax_pp";
# $driver{Parport (EPP)}{UMAX}{Astra 1220P} = "umax_pp";
# $driver{Parport (EPP)}{UMAX}{Astra 2000P} = "umax_pp";
# $driver{Parport (EPP)}{UMAX}{Astra 1600P} = "umax_pp";
# $driver{Parport (EPP)}{UMAX}{ASTRA 610 P} = "umax_pp";

################################################################################

my @all_drivers = ("abaton","agfafocus","apple","artec","avision","bh","canon",
		   "coolscan","dc210","dc240","dc25","dll","dmc","epson","hp",
		   "m3096g","microtek","microtek2","mustek","mustek_pp","nec",
		   "net","pie","plustek","qcam","ricoh","s9036","saned","sharp",
		   "snapscan","sp15c","st400","tamarack","umax","umax_pp","v4l"
		   );
# Here starts the configuration database.
#
#
#
my %config;

$config{microtek} = <<"EndOfConf";
# Uncomment following line to disable "real calibration" routines...
#norealcal
# Uncomment following line to disable "clever precalibration" routines...
#noprecal
#   Using "norealcal" will revert backend to pre-0.11.0 calibration code.
scsi * * Scanner
YAST2_DEVICE # /dev/scanner
EndOfConf

$config{s9036} = <<"EndOfConf";
YAST2_DEVICE # /dev/scanner
EndOfConf

$config{coolscan} = <<"EndOfConf";
scsi Nikon * Scanner
YAST2_DEVICE # /dev/scanner
EndOfConf

$config{microtek2} = <<"EndOfConf";
# See sane-microtek2(5) for a description of the options

option dump 1
# option lightlid-35 on
# option no-backtrack-option on
scsi * * Scanner
EndOfConf

$config{artec} = <<"EndOfConf";
scsi ULTIMA
YAST2_DEVICE # /dev/scanner
EndOfConf

$config{sp15c} = <<"EndOfConf";
scsi FCPA
EndOfConf

$config{dc25} = <<"EndOfConf";
# Serial port where the camera is connected
## Linux
port=/dev/ttyS0
## IRIX
#port=/dev/ttyd1
## Solaris
#port=/dev/term/a
## HP-UX
#port=/dev/tty0p0
## Digital UNIX
#port=/dev/tty01
# Max baud rate for download.  Camera always starts at 9600 baud, then
# switches to the higher rate
## This works for Linux and some versions of IRIX (6.3 or higher)
baud=115200
## This works for most UNIX's
#baud=38400
# Prints some extra information during the init phase.  This can be
# handy, but note that printing anything to stderr breaks the saned 
# network scanning.
#dumpinquiry
EndOfConf

$config{dc210} = <<"EndOfConf";
# Serial port where the camera is connected
## Linux
port=/dev/ttyS0
## IRIX
#port=/dev/ttyd1
## Solaris
#port=/dev/term/a
## HP-UX
#port=/dev/tty0p0
## Digital UNIX
#port=/dev/tty01
# Max baud rate for download.  Camera always starts at 9600 baud, then
# switches to the higher rate
## This works for Linux and some versions of IRIX (6.3 or higher)
baud=115200
## This works for most UNIX's
#baud=38400
# Prints some extra information during the init phase.  This can be
# handy, but note that printing anything to stderr breaks the saned 
# network scanning.
#dumpinquiry
# How many usec (1,000,000ths of a) between writing the command and reading the
# result. 125000 seems to be the lowest I could go reliably.
cmdrespause=125000
# How many usec (1,000,000ths of a) between sending the "back to default" break
# sending commands.
breakpause=1000000;
EndOfConf


$config{v4l} = <<"EndOfConf";
#
# In order to use the v4linux backend you have to give the device
# You can enable multiple lines if
# you really have multible v4l devices.
#
/dev/bttv0
/dev/video0
/dev/video1
/dev/video2
/dev/video3
EndOfConf

$config{qcam} = <<"EndOfConf";
#
# In order to use the qcam backend, you'll need to enable to line with
# the port address for your scanner.  You can enable multiple lines if
# you really have a QuickCam connect to each port.
#
#u0x37b # /dev/lp0 forced in unidir mode
#u0x378	# /dev/lp1 forced in unidir mode
#u0x278	# /dev/lp2 forced in unidir mode
#0x37b	# /dev/lp0
#0x378	# /dev/lp1
#0x278	# /dev/lp2
0x3bc	# /dev/lp0
EndOfConf

$config{saned} = <<"EndOfConf";
#
# saned.conf
#
# The contents of the saned.conf file is a list of host
# names that are permitted by saned to use local SANE
# devices in a networked configuration.  The hostname
# matching is NO LONGER case-sensitive.
#
#scan-client.somedomain.firm
#localhost
#
# NOTE: saned.conf and /etc/services must also
# be properly configured to start the saned daemon as
# documented in saned(1), services(4) and inetd.conf(4)
#
# for example, /etc/services might contain a line:
# sane	6566/tcp	# network scanner daemon
#
# and /etc/inetd.conf might contain a line:
# sane stream tcp nowait root /usr/local/sbin/saned saned
EndOfConf

$config{pie} = <<"EndOfConf";
scsi DEVCOM * Scanner
scsi PIE * Scanner
scsi ADLIB * Scanner
YAST2_DEVICE # /dev/scanner
EndOfConf

$config{avision} = <<"EndOfConf";
scsi AVISION
YAST2_DEVICE # /dev/scanner
EndOfConf

$config{nec} = <<"EndOfConf";
YAST2_DEVICE #/dev/scanner
EndOfConf

$config{mustek} = <<"EndOfConf";
# See sane-mustek(5) for documentation.

#--------------------------- Global options ---------------------------------
option strip-height 1           # some SCSI adapters need this; scanning may 
                                # be faster without this option
#option force-wait              # wait for scanner to be ready (only necessary
                                # when scanner freezes)

#-------------------------- SCSI scanners -----------------------------------
scsi MUSTEK * Scanner
# option linedistance-fix       # stripes may go away in color mode
# option buffersize 1024        # set non standard buffer size (in kb)
# option blocksize 2048         # set non standard block size (in kb)
  option lineart-fix		# lineart may be faster with this option off.

scsi SCANNER
# option linedistance-fix       # stripes may go away in color mode
# option buffersize 1024        # set non standard buffer size (in kb)
# option blocksize 2048         # set non standard block size (in kb)
  option lineart-fix		# lineart may be faster with this option off.

YAST2_DEVICE #/dev/scanner
# option linedistance-fix       # stripes may go away in color mode
# option buffersize 1024        # set non standard buffer size (in kb)
# option blocksize 2048         # set non standard block size (in kb)
  option lineart-fix		# lineart may be faster with this option off.

#-------------------------- 600 II N ----------------------------------------
#0x2eb
                                # For the 600 II N try one of 0x26b, 0x2ab,
                                # 0x2eb, 0x22b, 0x32b, 0x36b,  0x3ab, 0x3eb.
# option linedistance-fix       # only neccessary with firmware 2.x
EndOfConf

$config{ricoh} = <<"EndOfConf";
scsi RICOH IS60
YAST2_DEVICE #/dev/scanner
EndOfConf

$config{plustek} = <<"EndOfConf";
# Plustek-SANE Backend configuration file
#
# for multiple devices use
# /dev/pt_drv0
# /dev/pt_drv1
# /dev/pt_drv2
#

/dev/pt_drv
EndOfConf

$config{umax_pp} = <<"EndOfConf";
# For documentation see sane-umax_pp(5)

# GLOBAL #

# size (in bytes) of scan buffer (default: 2 megabyte)
option buffer 2097152


# DEVICES #

# specify the port your scanner is connected to. Possible are 0x378 (lp1)
# 0x278 (lp2) and 0x3c8 (lp0)
port 0x378

# the following options are local to this scanner
# gain for red channel, if not given, will be automatically computed
# must be between 0 and 15
option red-gain 8
# gain for red channel, if not given, will be automatically computed
# must be between 0 and 15
option green-gain 4
# gain for red channel, if not given, will be automatically computed
# must be between 0 and 15
option blue-gain 8

# highlight for red channel, if not given, will default to 0
# must be between 0 and 15
option red-highlight 2
# highlight for red channel, if not given, will default to 0
# must be between 0 and 15
option green-highlight 1
# highlight for red channel, if not given, will default to 0
# must be between 0 and 15
option blue-highlight 1


#
#
# model number
#
# valid values are 610, 1220, 1600 and 2000
#
option astra 1220
EndOfConf

$config{sharp} = <<"EndOfConf";
# The options are only meaningful if the backend was
# compiled with USE_FORK defined
#
# option buffersize: size of one buffer allocated as shared
#    memory for data transfer between the reader process
#    and the parent process
# option buffers: number of these buffers
#    The minimum is 2
# option readqueue: number of queued read requests. This is
#    with the current SANE version (1.01) only useful for
#    Linux, since queued read requests are not supported
#    for other operating systems. 
#
#    For Linux, a value of 2 is recommended, at least if a
#    JX-250 is used. Bigger values are only a waste of memory.
#
#    For other operationg systems, set this value to zero
#    
# global options:
option buffers 4
option buffersize 131072
option readqueue 2
# look for all devices with vendor ID "SHARP" and type "Scanner"
scsi SHARP * Scanner
# no options specific to these devices listed -> use global options
YAST2_DEVICE #/dev/scanner
# options specific to /dev/scanner
  option buffers 6
  option buffersize 262144
  option readqueue 2
# example for another (Linux) device name:
#/dev/sg1
EndOfConf

$config{dll} = <<"EndOfConf";
# enable the next line if you want to allow access through the network:
net
abaton
agfafocus
apple
avision
artec
as6e
bh
canon
coolscan
#dc25
#dc210
#dc240
dmc
epson
hp
m3096g
microtek
microtek2
mustek
#mustek_pp
nec
pie
pint
plustek
#pnm
qcam
ricoh
s9036
sharp
sm3600
snapscan
sp15c
tamarack
umax
#umax_pp
v4l
EndOfConf

$config{agfafocus} = <<"EndOfConf";
YAST2_DEVICE #/dev/scanner

EndOfConf

$config{snapscan} = <<"EndOfConf";
scsi AGFA
scsi COLOR
scsi ACERPERI

# If not automatically found from above, then you may manually specify
# a device name.
YAST2_DEVICE #/dev/scanner
#/dev/usbscanner
#/dev/sga
EndOfConf

$config{dmc} = <<"EndOfConf";
YAST2_DEVICE #/dev/camera
EndOfConf

$config{net} = <<"EndOfConf";
# This is the net config file.  Each line names a host to attach to.
# If you list "localhost" then your backends can be accessed either
# directly or through the net backend.  Going through the net backend
# may be necessary to access devices that need special privileges.
# localhost
EndOfConf

$config{dc240} = <<"EndOfConf";
# Serial port where the camera is connected
## Linux
port=/dev/ttyS0
## IRIX
#port=/dev/ttyd1
## Solaris
#port=/dev/term/a
## HP-UX
#port=/dev/tty0p0
## Digital UNIX
#port=/dev/tty01
# Max baud rate for download.  Camera always starts at 9600 baud, then
# switches to the higher rate
## This works for Linux and some versions of IRIX (6.3 or higher)
baud=115200
## This works for most UNIX's
#baud=38400
# Prints some extra information during the init phase.  This can be
# handy, but note that printing anything to stderr breaks the saned 
# network scanning.
#dumpinquiry
# How many usec (1,000,000ths of a) between writing the command and reading the
# result. 125000 seems to be the lowest I could go reliably.
cmdrespause=125000
# How many usec (1,000,000ths of a) between sending the "back to default" break
# sending commands.
breakpause=1000000;
EndOfConf

$config{umax} = <<"EndOfConf";
#
# Options for the umax backend
#option scsi-maxqueue 2
#option scsi-buffer-size-min 65536
#option scsi-buffer-size-max 262144
#option scan-lines 100
#option preview-lines 20
#option handle-bad-sense-error 0
#option execute-request-sense 0
#option force-preview-bit-rgb 0
#option lamp-control-available 0
#
# linux device identification:
#scsi vendor model type bus channel id lun
scsi UMAX * Scanner
scsi LinoHell JADE
scsi LinoHell Office
scsi LinoHell Office2
scsi LinoHell SAPHIR2
scsi HDM LS4H1S
scsi Nikon AX-210
scsi KYE ColorPage-HR5
scsi EPSON Perfection600
scsi ESCORT "Galleria 600S"

#
# device list for non-linux-systems:
YAST2_DEVICE #/dev/scanner

EndOfConf

$config{apple} = <<"EndOfConf";
scsi APPLE
YAST2_DEVICE #/dev/scanner
EndOfConf

$config{m3096g} = <<"EndOfConf";
scsi FUJITSU
EndOfConf

$config{hp} = <<"EndOfConf";
scsi HP
YAST2_DEVICE #/dev/scanner
EndOfConf

$config{bh} = <<"EndOfConf";
scsi "B&H SCSI"
YAST2_DEVICE #/dev/scanner
EndOfConf

$config{canon} = <<"EndOfConf";
#
YAST2_DEVICE #/dev/scanner
#/dev/sg0
EndOfConf

$config{st400} = <<"EndOfConf";
# the ST400 is fixed to ID 3
scsi SIEMENS "ST 400" Scanner * * 3 *
scsi SIEMENS "ST 800" Scanner * * 3 *

# The following options are for testing and bug-hunting.  If your scanner
# needs one of these options to function reliably, please let me know.

# Maximum amount of data to read in a single SCSI command.  If not set
# (or set to 0), the backend will read as much data as allowed by the
# scanner model or the OS.  WARNING: Using this option overrides the
# hardcoded # maxread limits for all scanner models!  With more than
# 65536 bytes, my ST400 locks up (itself, the SCSI bus, the sg driver,
# and the machine). Use with caution.
#option maxread 65536

# Use this to switch the scanner lights on with a separate MODE SELECT call
# and wait for some time before starting to scan (to allow the lights to go
# to full intensity).  The time is in 1/10 seconds (i.e. 20 means 2 seconds).
# If not set, scanning starts immediately (works with my ST400).
#option delay 20

# The following are hacks that affect all scanners of the same model as the
# last attached device.  Used like this (assume ST800's had 8bit depth and
# 4MB internal buffer):
#   scsi SIEMENS "ST 400" Scanner * * 3 *
#   option scanner_bufsize 2097152
#   option scanner_bits 6
#   scsi SIEMENS "ST 800" Scanner * * 3 *
#   option scanner_bufsize 4194304
#   option scanner_bits 8
# Currently, the backend has entries for ST400, ST800 and "everything else".
# To add more scanners, you have to add a line in the st400_models array.
# Please note that these options are only for testing unknown devices with
# this backend.

# Internal scanner buffer:
#option scanner_bufsize 2097152

# Bit depth:
#option scanner_bits 6

# Maximum bytes to read in a single SCSI command (see also maxread above).
#option scanner_maxread 65536

# Supported resolutions (upto 15 different values).  If you specify an
# illegal value here, most likely the scanner will not report an error,
# but only scan a small sub-area of the requested area (at least my ST400
# does this).
#option scanner_resolutions 200 300 400

# This option causes the SCSI inquiry response to be written to
# "/tmp/st400.dump" (as binary data).  For debugging purposes.
#option dump_inquiry
EndOfConf

$config{mustek_pp} = <<"EndOfConf";
# For documentation see sane-mustek_pp(5)

# GLOBAL #

# option io-mode [mode] must come before all port definitions, or it won't
# have the effect you'd expect

# enable this option, if you think your scanner supports the UNI protocol
# note however that this might disable the better EPP protocol
#option io-mode try_mode_uni

# choose between two different ways to lock to port
option io-mode alt_lock

# set the maximal height (in lines) of a strip scanned (default: no limit)
#option strip-height 0

# wait n msecs for bank to change (default: 700 msecs)
# if this value is to low, stripes my appear in the scanned image
#option wait-bank 700

# size (in bytes) of scan buffer (default: 1 megabyte)
#option buffer 1048576

# try to avoid to heavy load. Note that this reduces scan speed
option niceload

# Define the time the lamp has to be on before scan starts (default 5 secs)
#option wait-lamp 5


# DEVICES #

# specify the port your scanner is connected to. Possible are 0x378 (lp1)
# 0x278 (lp2) and 0x3bc (lp0)
port 0x378

 # the following options are local to this scanner

# WELL KNOWN OPTIONS #

 # most scanners only need 200 - 250 msecs to change bank -> try it out

 # Mustek ScanExpress 6000 P
 # name SE-6000P
 # vendor Mustek
 # option wait-lamp 15

 # Mustek ScanExpress 600 SEP
 # name SE-600SEP
 # vendor Mustek
 # option wait-lamp 15

 # Mustek ScanMagic 4800 P
 # name SM-4800P
 # vendor Mustek
 # option wait-lamp 15

 # Mustek 600 III EP Plus
 # name 600IIIEPP
 # vendor Mustek
 # option wait-lamp 15 # some models only need 5 secs...

 # Mustek ScanMagic/Express 1200 ED Plus (this scanner isn't yet supported!!!)
 # name SM-1200EDP
 # name SE-1200EDP
 # vendor Mustek
 # this scanner has an optical resolution of 600 dpi
 # option use600
 # this scanner *must* use option niceload
 # option niceload

 # Fidelity Imaging Solutions Inc. Gallery 4800
 # name Gallery-4800
 # vendor Fidelity-Imaging-Solutions

 # Viviscan Compact II
 # name Compact-II
 # vendor Viviscan

 # Medion MD9848 (aka Aldi-Scanner)
  name MD9848
  vendor Medion
  option wait-bank 250

 # scan maximal 16 lines for one sane_read() call
 option strip-height 16

 # we just need 16 lines * 3 (rgb) colors * 300 dpi * 8.5 inch bytes
 option buffer 122400

 # Enable this option, if you want user authentification *and* if it's
 # enabled at compile time
 #option auth

 # use this option to define the maximal black value for lineart scans
 #option bw 127
EndOfConf

$config{tamarack} = <<"EndOfConf";
scsi TAMARACK
YAST2_DEVICE #/dev/scanner
EndOfConf

$config{abaton} = <<"EndOfConf";
scsi ABATON
YAST2_DEVICE #/dev/scanner
EndOfConf

$config{epson} = <<"EndOfConf";
#
# here are some examples for how to configure the EPSON backend
#
# SCSI scanner:
scsi EPSON
#
# Parallel port scanner:
#pio 0x278
#pio 0x378
#pio 0x3BC
#
# USB scanner - only enable this if you have an EPSON scanner. It could
#               otherwise block your non-EPSON scanner from being 
#               recognized.
#usb /dev/usbscanner0
IF BUS=USB usb YAST2_DEVICE 

EndOfConf




################################################################################
# case INsensitive search function in a hash
#
#

=head1 NAME

findInHash - case insensitive hash search

=head1 SYNOPSIS

    my $value = findInHash( 'goofy', \%bighash );

=head1 DESCRIPTION

findInHash searches the keys of a given hash for the 
given searchkey parameter caseinsensitive and returns the
entry, if it finds one.

That means, that the string 'goofy' would be found even if
it is stored with the key 'GOOFY' in the hash.

=head1 PRARMETER

The first parameter is the string which is searched for the 
hash keys.

The second parameter is a reference to a hash.

=head1 RETURN VALUE

The value of the found key if it exists, an empty string else.

=cut

sub findInHash( $$ )
{
    my ( $searchkey, $hashref ) = @_;

    my @hkeys = keys %$hashref;
    
    # y2debug( "findInHash: Keys: " . join( "-", @hkeys ));

    my $entry = "";
    my ($hkey) = grep( /$searchkey/i, @hkeys );

    if( defined $hkey )
    {
	$entry = %$hashref->{ $hkey };
	# y2debug( "Found key <$searchkey> entry <$entry>" );
    }
    else
    {
	y2debug("Could not find entry for key <$searchkey>" );
    }

    return( $entry );
}


sub createBackup( $ )
{
    my( $file ) = @_;

    if( !defined( $file ) || $file eq "" )
    {
	y2debug( "WRN: Can not backup empty file" );
	return "";
    }

    unless( -e $file )
    {
	y2debug("File <$file> does not exists, but who cares, creating it !" ) ;
	unless( open (FILE, $file) )
	{
	    y2error( "Could not create file <$file>" );
	    return "";
	}
	print FILE "";
	close FILE;
    }

    my $backupfile = $file . ".yast2-$PID";

    if( -e $backupfile )
    {
	y2debug( "backupfile for PID $PID already exists. Not overwriting" );
    }
    else
    {
	y2debug( "Copying to Backupfile: <$backupfile>" );
	copy( $file, $backupfile );
    }
    return( $backupfile );
}



=head1 NAME

getModel - find a hash of scanner - drivers

=head1 SYNOPSIS

    my %modelsnDrivers = getModel( 'SCSI', 'Umax' );

=head1 DESCRIPTION

getModel is a specialised utility function that returns a hash
containing scanner driver data related to scanner models.

The hash is taken from the scanner driver 'database'.

The function is case insensitive, you do not have to care
about.

=head1 PRARMETER

The first parameter is the name of the bus, e.g. "SCSI" or "USB"
The second parameter is the vendor string.

=head1 RETURN VALUE

a hash that contains the name of the driver to use for all models
at the given bus of the given vendor.

=cut


sub getModel( $$ )
{
    my ( $bus, $vendor ) = @_;

    y2debug("getModel called with <$bus> <$vendor>" );

    if( !defined $vendor || $vendor =~ /^\s*$/ ) {
	y2debug( "getModel: Vendor is empty !" );
	exit;
    }

    my %foundscanner = ();
    
    if( $bus !~ /net/i )
    {
	my $bus_scanners = findInHash( $bus, \%driver ); # { uc $bus };
	if( ref( $bus_scanners ) eq "HASH" )
	{
	    my $mfg_scanner_ref = findInHash( $vendor, $bus_scanners ); # ->{ uc $vendor};

	    if( ref($mfg_scanner_ref)  eq "HASH" ) # defined $mfg_scanner_ref )
	    {
		%foundscanner = %$mfg_scanner_ref;
	    }
	    else
	    {
		if( $vendor =~ /generic/i )
		{
                    # In case of generic all entries are required with
                    # all the same items as driver entry ;)
		    foreach my $d ( sort @all_drivers )
		    {
			$foundscanner{ $d } = $d;
		    }
		}
		else
		{
		    y2debug( "Can not find scanner for Vendor " . uc $vendor );
		}
	    }
	}
	else
	{
	    y2debug( "Can not find scanner for bus " . uc $bus );
	}
    }
    else
    {
	y2debug(" No models available for Network scanner !" );
    }
    return %foundscanner;
}


=head1 NAME

getVendorList - return a list of scanner vendors

=head1 SYNOPSIS

    my @vendors = getVendorList( 'SCSI' );

=head1 DESCRIPTION

returns a list of the vendors for which sane provides a driver for
the specific bus.

=head1 PRARMETER

the string naming the bus, eg. SCSI or USB

=head1 RETURN VALUE

a list of strings

=cut

sub getVendorList( $ )
{
    my ($bus) = @_;
    
    y2debug( "Searching vendors providing for <$bus>" );
    
    my $bus_scanners = findInHash( $bus, \%driver ); #$driver{ uc $bus };

    my @vendorlist = ();

    if( ref( $bus_scanners ) eq "HASH" )
    {
	@vendorlist = keys %$bus_scanners;
	unshift @vendorlist, 'Generic';
    }
    else
    {
	y2debug( "Could not find scanners for bus <$bus>" );
    }

    return @vendorlist;

}


=head1 NAME

trim - cut off whitespaces from a string

=head1 SYNOPSIS

    my $trimmedstring = trim( '    untrimmed    ' );

=head1 DESCRIPTION

trim takes a string and returns it after having cut off all whitespace
in front and at the end.

=head1 PRARMETER

the string to trim

=head1 RETURN VALUE

the trimmed string

=cut

sub trim( $ )
{
    my ($str) = @_;
    $str =~ s/\"//g;
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;
    y2debug("Trim: Trimmed string to <$str>");
    return( $str );
}


#
=head1 NAME

writeNetConf - writes SANEs net.conf file

=head1 SYNOPSIS

    if( writeNetConf( \@hosts ) ) ...

=head1 DESCRIPTION

takes a reference of a list of host names which are written
to /etc/sane.d/net.cof. Mind that /etc/sane.d/net.conf is 
completely rewritten, thus L<readNetConf> needs to be called
first to get the existing net stations.

=head1 PRARMETER

a reference to a list of stations.

=head1 RETURN VALUE

a bool inicating success.

=head1 SEE ALSO

readNetConf

=cut

sub writeNetConf( $ )
{
    my ($net_stations) = @_;
    my $res = 0;

    my $fi = "$prefix/etc/sane.d/net.conf";
    createBackup( $fi );
    
    y2debug( "Try to open <$fi>" );

    if( open( F, "> $fi" ) )
    {
	my $t = localtime;
	print F "#
#
# SANE net config
# written by YaST2, $t
#
";

	print F join( "\n", @$net_stations );
	$res = close F;
    }
    else
    {
	y2debug( "Open of /etc/sane.d/dll.conf failed: $!" );
	$res = 0;
    }
    
    return $res;
    
}

=head1 NAME

readNetConf - read SANEs net.conf file

=head1 SYNOPSIS

    my @netConf = readNetConf();

=head1 DESCRIPTION

reads SANEs net configuration file /etc/sane.d/net.conf and
returns a list of all net stations configured there.

=head1 RETURN VALUE

a list of all stations.

=head1 SEE ALSO

writeNetConf

=cut

sub readNetConf
{
    my @res;

    if( open( F, "$prefix/etc/sane.d/net.conf" ))
    {
	foreach my $l ( <F> )
	{
	    next if( $l =~ /\s*\#/ );
	    next if( $l =~ /^\s*$/ );

	    push @res, trim($l);
	}
	close F;
    }
    else
    {
	y2debug( "Could not open file $prefix/etc/sane.d/net.conf: $!" );
    }
    return( @res );
}


=head1 NAME

writeDllconf - 

=head1 SYNOPSIS

    my @conf = ( "umax", "agfa" );
    writeDllconf( \@conf );

=head1 DESCRIPTION

writes a complete configuration file for SANEs dynamic backend
loading. The resulting file contains all backends as in the original
one, but the ones given in the parameter list are uncommented.

=head1 RETURN VALUE

a bool indicating success.

=head1 SEE ALSO

writeNetConf

=cut

sub writeDllconf( $ )
{
    my ($be_ref) = @_;
    my $res = 0;

    my $fi = "$prefix/etc/sane.d/dll.conf";
    createBackup( $fi );

    y2debug( "Try to open <$fi>" );

    if( open( F, "> $fi" ) )
    {
	my $t = localtime;
	print F "#
#
# SANE Dynamic library loader config
# written by YaST2, $t
#
";

	    foreach my $driver (@all_drivers )
	    {
		if( grep( /$driver/i, @$be_ref  ) )
		{
                    # driver is in the array to configure
		    print F sprintf( "%s\n", $driver );
		}
		else
		{
		    print F sprintf( "# %s\n", $driver );
		}
	    }
	print F "\n# EOF\n";
	$res = close F;

    }
    else
    {
	y2debug( "Open of /etc/sane.d/dll.conf failed: $!" );
	$res = 0;
    }
    
    return $res;
}




=head1 NAME

writeIndividualConf - write config for on scanner

=head1 SYNOPSIS

    writeIndividualConf( "SCSI", "umax", "/dev/sg0");

=head1 DESCRIPTION

writes a configuration file for one scanner. 

=head1 RETURN VALUE

Param. 1 is the bus (SCSI or USB), param. 2 the vendor.
Param. 3 is the device file to use.

=head1 SEE ALSO

writeNetConf, readNetConf

=cut

sub writeIndividualConf( $$$ )
{
    my ( $bus, $vendor, $device ) = @_;
    my $res = 0;

    $vendor = lc $vendor;

    unless( exists( $config{ $vendor } ) )
    {
	y2debug( "ERROR: Can not find a config for <$vendor>" );
	return 0;
    }

    my $cfg = $config{ $vendor };
    my @cfg = split( /\n/, $cfg );

    y2debug( "Writing $cfg" );
    
    my $cfg_file = "$prefix/etc/sane.d/$vendor.conf";

    createBackup( $cfg_file );
    
    if( open( F, ">$cfg_file" ) )
    {
	foreach my $cfg_line ( @cfg )
	{
	    y2debug( "Handling line <$cfg_line> from cfg-template" );
	    if( $cfg_line =~ /^IF\s+(.+)\s*=\s*(\w+?)\s+(.+)\s*/ )
	    {
		my $tag = $1;
		my $val = $2;
		my $line = $3;
		y2debug( "If-condition found: <$tag> = <$val> ? <$line>" );
		if( $tag =~ /bus/i )
		{
		    # The tag is BUS. Print the line if val equal to our bus variable
		    unless( lc $val eq lc $bus )
		    {
			next;
		    }
		    else
		    {
			$cfg_line = $line;
		    }
		}
	    }
	    $cfg_line =~ s/YAST2_DEVICE/$device/im;
	    $cfg_line =~ s/YAST2_BUS/$bus/im;
	    
	    print F "$cfg_line\n";
	}
	$res = close F;
    }
    else
    {
	y2debug( "ERROR: Could not write config: $!" );
	$res = 0;
    }
    return $res;
}
# ################################################################################

=head1 NAME

readDllconf - read the list of backends

=head1 SYNOPSIS

    my @dlls = readDllconf();

=head1 DESCRIPTION

read the list of enabled backends to read dynamically.

=head1 RETURN VALUE

a list of loadable backends 

=head1 SEE ALSO

writeNetConf, readNetConf

=cut

# ################################################################################
sub readDllconf()
{
    my $f = "$prefix/etc/sane.d/dll.conf";
    my @res = ();

    if( open( F, $f )  )
    {
	while( <F> )
	{
	    chomp;
	    next if( /^\s*\#/ );
	    next if( /^\s*$/ );
	    s/\#.*$//g;
	    my $be = trim($_);
	    y2debug("pushing <$be> to existing Backend list");
	    push @res, $be;
	}
        close F;
    }
    else
    {
	y2debug( "$f not existing" );
    }
    return @res;
    
}

# ################################################################################

=head1 NAME

acquireTestImage - scan a test image.

=head1 SYNOPSIS

    my $file = aquireTestImage( "umax:/dev/sg0", "/tmp" );

=head1 DESCRIPTION

tries to scan a test image from a scanner pointed to by the first parameter string.
Mind that the string must be compatible to pass it to scanimage directly.

=head1 PARAMETERS

The first parameter is a device specification string, the second parameter gives
a temp directory where the image can be stored.

=head1 RETURN VALUE

The full filename of the image.

=cut

# ################################################################################

sub acquireTestImage( $$ )
{
    my ($usedev, $tmpdir) = @_;

    y2debug( "Scanning test image from <$usedev>" );

    my $tmpfile = "$prefix" . "$tmpdir/y2testimage_$PID.pnm";
    my $tmpfile2 = "$prefix" . "$tmpdir/y2testimage_$PID.png";
    my $w = 210; my $h = 295;
 
       my $cmd = sprintf( "/usr/X11R6/bin/scanimage -d %s > %s && /usr/bin/convert -border 3x3 -bordercolor darkgreen -geometry %dx%d "
		       ." %s %s", $usedev, $tmpfile, $w, $h, $tmpfile, $tmpfile2 );

    y2debug( "Scanning test image with command <$cmd>" );
 
    system( $cmd );
    unlink( $tmpfile );

    return( $tmpfile2 );

}

#
# enable one single station to be scanned from
#
sub enableNetScan( $ )
{
    my ($host) = @_;

    my $ok = 1;

    my @already_conf = readNetConf();

    unless( grep( /$host/i, @already_conf ))
    {
	push @already_conf, $host;
	$ok = writeNetConf( \@already_conf );
    }
	    
    # Add net to dll.conf
    my @cfg_backends = readDllconf( );

    unless( grep ( /net/i, @cfg_backends ))
    {
	push @cfg_backends, "net";
	$ok = writeDllconf( \@cfg_backends );
    }
    return( $ok );
}


sub disableNetScan( $ )
{
    my ($host) = @_;

    my $ok = 1;

    my @already_conf = readNetConf();

    # Take all _but_ host from the list
    @already_conf = grep ( !/$host/i, @already_conf );

    $ok = writeNetConf( \@already_conf );

    return( $ok );
    
}


sub getNetInfo( $ )
{
    my ($host) = @_;

    y2debug( "Querying host <$host>" );

    # first, add the host to net.conf and enable net-scanning.

    my @origNetStations = readNetConf();

    if( enableNetScan( $host ) )
    {
	# now the net station should be enalbed.
	
    }

    
    unless( grep ( /$host/i, @origNetStations ))
    {
	# if not yet in the host list, add and write config.
	my @stations = @origNetStations;
	push @stations, $host;
	writeNetConf( \@stations );
    }
    
    # Now the net configuration should be fine.
    my @scanners = performScanimage( 1 );  # Net only.
    
    my @hostscanners;
    
    # Sort out which scanners are connected to the required station
    foreach my $scanref ( @scanners )
    {
	my $referto = %$scanref->{host};

	y2debug( "Found scanner on host <$referto>" );

	if ( $referto =~ /^$host$/i )
	{
	    y2debug( "adding network-scanner <$referto>" );
	    push @hostscanners, $scanref;
	}
    }
    return( @hostscanners );
}

# ################################################################################

=head1 NAME

revertAll - revert all configuration files.

=head1 SYNOPSIS

    revertAll();

=head1 DESCRIPTION

this function reverts all configuration changes. It copies the backup files
back.

=cut

# ################################################################################

sub revertAll
{
    # reverting: search for all files ending on yast2-$PID
    # and remove them to their old name 
 
    my $path = "$prefix/etc/sane.d/*.yast2-$PID";
    y2debug( "Globbing for <$path>" );

    my @files = glob($path);
    my $countfiles = @files;

    foreach my $bfile ( @files )
    {
	my $origfile = $bfile;
	$origfile =~ s/\.yast2-$PID$//;
	y2debug( "Reverting file <$bfile> to <$origfile>" );

	move ( $bfile, $origfile );
    }
    y2debug( "Reverted $countfiles files" );
}


# ################################################################################

=head1 NAME

performScanimage - invoke scanimage from SANE for information

=head1 SYNOPSIS

    my @scanners = performScanimage();

=head1 DESCRIPTION

This is one of the most important functions. It invokes SANEs command scanimage
to get a list of the scanners known by sane. It fills a hash for every scanner
and pushes the reference to the hash to an array. 

=head1 PARAMETERS

The first optional parameter indicates if only net scanners should be returned.
If no parameter is there, all known scanners are returned.

=head1 RETURN VALUE

an array with references to hashes.

=cut

# ################################################################################

sub performScanimage( ;$ )
{
    my ($netOnly) = @_;

    y2debug( "Searching for configured scanners!" );
    my $cmd = "/usr/X11R6/bin/scanimage -s";
    my @scanners = ();

    if( open( CMD, "$cmd |" ) )
    {
	my $cnt = 0;
	while( <CMD> )
	{
	    chomp;
	    my ($name, $vendor, $model, $class ) = split( /"\s+"/ );
	    $name =~ s/\"//g;
	    $name =~ s/^\s+|\s+$//g;
	    
	    my ($driver, $devfile);
            # bus defaults to SCSI, switched later
	    my $bus = "SCSI";
	    my $host = uc "localhost";
	    
	    if( $name =~ /(\S+):(\S+):(\S+):(\S+)/ )
	    {
                # A Network scanner was found with a name like 
                # net:d213.suse.de:umax:/dev/sg0
		$bus = "Net";
		$host =  $2;
		$driver =  $3;
		$devfile =  $4;
		y2debug( "Found new network scanner: $bus:$host:$driver:$devfile" );
	    }
	    else
	    {
                # split up a name-string like umax:/dev/scanner to driver and device
		($driver, $devfile) = split( /:/, $name );
	    }
	    
	    if( $bus ne "Net" && $devfile =~ /dev.+usb/i )
	    {
		$bus = "USB";
	    }
	    y2debug( "Found scanner $vendor $model on $devfile" );
	    
            # Push anonym hashes to the array. The array contains references to
            # the hashes then.
	    if( $bus ne "Net" && defined( $netOnly ) && $netOnly )
	    {
		y2debug("Found non-net-scanner, but netOnly required -> skip" );
		next ;
	    }

	    push ( @scanners , 
	    { bus => $bus, 
		  class_id => "",
		  device => trim($model),
		  device_id => "",
		  resource =>"",
		  rev => "",
		  sub_class_id => "",
		  sub_device => trim($model),
		  sub_vendor => trim($vendor),
		  unique_key => "",
		  vendor => trim($vendor),
		  vendor_id => "",
		  dev_name => trim($devfile),
		  class => trim($class),
		  driver => trim($driver),
		  host => $host 
		  } );
	    $cnt++;
	}
	close CMD;
	y2debug( "found $cnt configured scanners !" );
    }
    else
    {
	y2debug( "ERROR: Could not open scanimage!" );
	@scanners = ();
    }
    return( @scanners );
}


#
#
# This enables debug. Just set the environment PREFIX_DIR to any
# directory which acts as prefix to /etc/sane.d
$prefix = "";
$prefix = $ENV{PREFIX_DIR} if( exists $ENV{PREFIX_DIR} );


1;

# EOF
