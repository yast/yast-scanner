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
		      writeNetConf
		      readDllconf
		      writeDllconf
		      writeIndividualConf
		      acquireTestImage 
		      performScanimage 
		      getNetInfo 
		      revertAll
		      enableNetScan 
		      disableNetScan );

use vars qw ( %driver $prefix @devicesToReset );



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
$driver{SCSI}{Apple}{"COLORONESCANNER"} = "apple";

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
$driver{SCSI}{Avision}{"AV100CS"} = "avision";
$driver{SCSI}{Avision}{"AV100IIICS"} = "avision";
$driver{SCSI}{Avision}{"AV100S"} = "avision";
$driver{SCSI}{Avision}{"AV240SC"} = "avision";
$driver{SCSI}{Avision}{"AV260SC"} = "avision";
$driver{SCSI}{Avision}{"AV360CS"} = "avision";
$driver{SCSI}{Avision}{"AV363CS"} = "avision";
$driver{SCSI}{Avision}{"AV420CS"} = "avision";
$driver{SCSI}{Avision}{"AV6120"} = "avision";
$driver{SCSI}{Avision}{"AV620CS"} = "avision";
$driver{SCSI}{Avision}{"AV630CS"} = "avision";
$driver{SCSI}{Avision}{"AV6240"} = "avision";
$driver{SCSI}{Avision}{"AV660S"} = "avision";
$driver{SCSI}{Avision}{"AV680S"} = "avision";
$driver{SCSI}{Avision}{"AV800S"} = "avision";
$driver{SCSI}{Avision}{"AV810C"} = "avision";
$driver{SCSI}{Avision}{"AV820"} = "avision";
$driver{SCSI}{Avision}{"AV820C"} = "avision";
$driver{SCSI}{Avision}{"AV880"} = "avision";
$driver{SCSI}{Avision}{"AV880C"} = "avision";
$driver{SCSI}{Avision}{"AVA3"} = "avision";

$driver{USB}{Minolta}{"FS-V1"} = "avision";
$driver{SCSI}{MITSUBISHI}{"MCA-ADFC"} = "avision";
$driver{SCSI}{MITSUBISHI}{"S1200C"} = "avision";
$driver{SCSI}{MITSUBISHI}{"S600C"} = "avision";
$driver{SCSI}{MITSUBISHI}{"SS600"} = "avision";


$driver{SCSI}{Avision}{"AV 6240"} = "avision";
$driver{SCSI}{Avision}{"AV 630 CS"} = "avision";
$driver{SCSI}{Avision}{"AV 620 CS"} = "avision";

# Bell & Howell
$driver{SCSI}{"B&H SCSI"}{"COPISCAN II 6338"} = "bh";
$driver{SCSI}{"B&H SCSI"}{"COPISCAN II 2135"} = "bh";
$driver{SCSI}{"B&H SCSI"}{"COPISCAN II 2137"} = "bh";
$driver{SCSI}{"B&H SCSI"}{"COPISCAN II 2137A"} = "bh";
$driver{SCSI}{"B&H SCSI"}{"COPISCAN II 2138A"} = "bh";
$driver{SCSI}{"B&H SCSI"}{"COPISCAN II 3238"} = "bh";
$driver{SCSI}{"B&H SCSI"}{"COPISCAN II 3338"} = "bh";

# Canon
$driver{SCSI}{Canon}{"CANOSCAN 300"} = "canon";
$driver{SCSI}{Canon}{"CANOSCAN 600"} = "canon";
$driver{SCSI}{Canon}{"CANOSCAN 620S"} = "canon";
$driver{SCSI}{Canon}{"CANOSCAN 2700F"} = "canon";
$driver{SCSI}{Canon}{"CANOSCAN 2710"} = "canon";

# Canon 630U
$driver{USB}{Canon}{"CANOSCAN FB630U"} = "canon630u";

# Canon PP
# $driver{Parport}{Canon}{"CANOSCAN FB330P"} = "canon_pp";
# $driver{Parport}{Canon}{"CANOSCAN FB630P"} = "canon_pp";
# $driver{Parport}{Canon}{"CANOSCAN N340P" } = "canon_pp";
# $driver{Parport}{Canon}{"CANOSCAN N640P" } = "canon_pp";

# Coolscan
$driver{SCSI}{Nikon}{"LS-20"} = "coolscan";
$driver{SCSI}{Nikon}{"LS-30"} = "coolscan";
$driver{SCSI}{Nikon}{"LS-2000"} = "coolscan";
$driver{SCSI}{Nikon}{"LS-1000"} = "coolscan";

# Coolscan2
$driver{USB}{Nikon}{"LS-40 ED"} = "coolscan2";

# dmc
$driver{SCSI}{Polaroid}{"DMC"} = "dmc";

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
$driver{SCSI}{Epson}{"PERFECTION1200"} = "epson";
$driver{USB}{Epson}{"PERFECTION 1200U"} = "epson";
$driver{USB}{Epson}{"PERFECTION 1200PHOTO"} = "epson";
$driver{SCSI}{Epson}{"PERFECTION 1240"} = "epson";
$driver{SCSI}{Epson}{"PERFECTION 1640"} = "epson";
$driver{USB}{Epson}{"PERFECTION 1240"} = "epson";
$driver{USB}{Epson}{"PERFECTION 1640"} = "epson";
$driver{SCSI}{Epson}{"PERFECTION 1650"} = "epson";
$driver{USB}{Epson}{"PERFECTION 1650"} = "epson";
$driver{USB}{Epson}{"PERFECTION 2450"} = "epson";
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
$driver{USB}{HP}{"HP SCANJET 5200C"} = "hp";

$driver{USB}{HP}{"HP SCANJET 5300C"} = "avision";
$driver{USB}{HP}{"HP SCANJET 5370C"} = "avision";
$driver{USB}{HP}{"HP SCANJET 7400C"} = "avision";

$driver{SCSI}{HP}{"HP SCANJET 6100C"} = "hp";
$driver{SCSI}{HP}{"HP SCANJET 6200C"} = "hp";
$driver{USB}{HP}{"HP SCANJET 6200C"} = "hp";
$driver{SCSI}{HP}{"HP SCANJET 6250C"} = "hp";
$driver{USB}{HP}{"HP SCANJET 6250C"} = "hp";
$driver{SCSI}{HP}{"HP SCANJET 6300C"} = "hp";
$driver{USB}{HP}{"HP SCANJET 6300C"} = "hp";
$driver{SCSI}{HP}{"HP SCANJET 6350C"} = "hp";
$driver{USB}{HP}{"HP SCANJET 6350C"} = "hp";
$driver{SCSI}{HP}{"HP SCANJET 6390C"} = "hp";
$driver{USB}{HP}{"HP SCANJET 6390C"} = "hp";
$driver{SCSI}{HP}{"HP PHOTOSMART PHOTOSCANNER"} = "hp";
# $driver{Parport(ECP) JetDirect}{HP}{HP OfficeJet Pro 1150C} = "hp";
# $driver{Parport(ECP) JetDirect}{HP}{HP OfficeJet Pro 1170C/1175C} = "hp";
# $driver{Parport(ECP) JetDirect}{HP}{HP OfficeJet R series/PSC500} = "hp";
# $driver{Parport(ECP) USB JetDirect}{HP}{HP OfficeJet G series} = "hp";
$driver{USB}{HP}{"HP PSC 700 SERIES"} = "hp";
$driver{USB}{HP}{"HP PSC 900 SERIES"} = "hp";
$driver{USB}{HP}{"HP OFFICEJET K SERIES"} = "hp";
$driver{USB}{HP}{"HP OFFICEJET V SERIES"} = "hp";

# IBM 
# $driver{SCSI}{IBM}{"2456"} = "ibm";
# $driver{SCSI}{Ricoh}{"IS-410"} = "ibm";


# Fujitsu
$driver{SCSI}{"Fujitsu"}{"M3091DCD"} = "fujitsu";
$driver{SCSI}{"Fujitsu"}{"M3096G"} = "fujitsu";
$driver{SCSI}{"Fujitsu"}{"M3093GXim"} = "fujitsu";
$driver{SCSI}{"Fujitsu"}{"M3093GDim"} = "fujitsu";
$driver{SCSI}{"Fujitsu"}{"fi-4340C"} = "fujitsu";

$driver{SCSI}{"Fujitsu"}{"SP15C"} = "sp15c";

$driver{SCSI}{"Fujitsu"}{"SCANPARTNER"} = "avision";
$driver{SCSI}{"Fujitsu"}{"SCANPARTNER 10"} = "avision";
$driver{SCSI}{"Fujitsu"}{"SCANPARTNER 10C"} = "avision";
$driver{SCSI}{"Fujitsu"}{"SCANPARTNER 15C"} = "avision";
$driver{SCSI}{"Fujitsu"}{"SCANPARTNER 300C"} = "avision";
$driver{SCSI}{"Fujitsu"}{"SCANPARTNER 600C"} = "avision";
$driver{SCSI}{"Fujitsu"}{"SCANPARTNER JR"} = "avision";
$driver{SCSI}{"Fujitsu"}{"SCANSTATION"} = "avision";

#
# Leo
#
$driver{SCSI}{"LEO"}{"FS-1130"} = "leo";
$driver{SCSI}{"Across Technologies"}{"FS-1130"} = "leo";
$driver{SCSI}{"Genius"}{"FS-1130 Colorpage Scanner"} = "leo";


#
# Matsushita
# 
$driver{SCSI}{Panasonic}{"KV-SS25"} = "matsushita";
$driver{SCSI}{Panasonic}{"KV-SS25D"} = "matsushita";
$driver{SCSI}{Panasonic}{"KV-SS50"} = "matsushita";
$driver{SCSI}{Panasonic}{"KV-SS55"} = "matsushita";
$driver{SCSI}{Panasonic}{"KV-SS50EX"} = "matsushita";
$driver{SCSI}{Panasonic}{"KV-SS55EX"} = "matsushita";
$driver{SCSI}{Panasonic}{"KV-SS850"} = "matsushita";
$driver{SCSI}{Panasonic}{"KV-SS855"} = "matsushita";

#
# Microtek
#
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

$driver{SCSI}{Microtek}{"Scanmaker 600Z S"} = "microtek";
$driver{SCSI}{Microtek}{"Scanmaker 600ZS"} = "microtek";
$driver{SCSI}{Microtek}{"Scanmaker 600Z"} = "microtek";
$driver{SCSI}{Microtek}{"Scanmaker 600S"} = "microtek";

$driver{SCSI}{Microtek}{"Scanmaker 600G S"} = "microtek";
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
$driver{USB} {Microtek}{"ScanMaker X6USB"}  = "microtek2";
$driver{USB} {Microtek}{"SlimScan C6"}      = "microtek2";

$driver{SCSI}{Microtek}{"ScanMaker V300"}   = "microtek2";
$driver{SCSI}{Microtek}{"ScanMaker V310"} = "microtek2";
$driver{SCSI}{Microtek}{"ScanMaker 330"} = "microtek2";
$driver{SCSI}{Microtek}{"ScanMaker 630"} = "microtek2";
$driver{SCSI}{Microtek}{"ScanMaker 636"} = "microtek2";
$driver{SCSI}{Microtek}{"Phantom 636"} = "microtek2";
$driver{SCSI}{Microtek}{"ScanMaker 9600XL"} = "microtek2";
$driver{SCSI}{Microtek}{"ScanMaker V6USL"} = "microtek2";
$driver{SCSI}{Microtek}{"ScanMaker V600"} = "microtek2";
$driver{SCSI}{Vobis}{"HighScan"} = "microtek2";
$driver{SCSI}{Scanport}{"SQ4836"} = "microtek2";

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


$driver{USB}{Mustek}{"600 CU"} = "mustek_usb";
$driver{USB}{Mustek}{"1200 UB"} = "mustek_usb";
$driver{USB}{Mustek}{"1200 USB"} = "mustek_usb";
$driver{USB}{Mustek}{"1200 CU"} = "mustek_usb";
$driver{USB}{Mustek}{"1200 CU Plus"} = "mustek_usb";
$driver{USB}{Trust}{"Compact Scan USB 19200"} = "mustek_usb";


$driver{SCSI}{Trust}{"Imagery 1200"} = "mustek";
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
$driver{SCSI}{Plustek}{"OpticPro 19200S"} = "plustek";
$driver{USB} {Plustek}{"OpticPro 1212U"}  = "plustek";
$driver{USB} {Plustek}{"OpticPro U12"}    = "plustek";
$driver{USB} {Plustek}{"OpticPro UT12"}   = "plustek";
$driver{USB} {Plustek}{"OpticPro U16"}    = "plustek";
$driver{USB} {Plustek}{"OpticPro U24"}    = "plustek";
$driver{USB} {Plustek}{"OpticPro UT24"}   = "plustek";

$driver{USB}{Genius}{"Colorpage HR6V2"} = "plustek";

$driver{USB}{Mustek}{"BearPaw 1200"} = "plustek";
$driver{USB}{Mustek}{"BearPaw 2400"} = "plustek";
$driver{USB}{Mustek}{"BearPaw 1200"} = "plustek";

$driver{USB}{HP}{"HP ScanJet2100C"} = "plustek";
$driver{USB}{HP}{"HP ScanJet2200C"} = "plustek";

$driver{USB}{Epson}{"Perfection 1250"} = "plustek";
$driver{USB}{Epson}{"Perfection 1250Photo"} = "plustek";
$driver{USB}{Umax}{"UMAX 3400"} = "plustek";

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
# $driver{Parport (SPP, EPP)}{Aries}{Compact 9600 Direct-30} = "plustek";

# Primax
# $driver{Parport (SPP, EPP)}{Primax}{Colorado 4800} = "plustek";
# $driver{Parport (SPP, EPP)}{Primax}{Compact 4800 Direct} = "plustek";
# $driver{Parport (SPP, EPP)}{Primax}{Compact 4800 Direct-30} = "plustek";

# Ricoh
$driver{SCSI}{Ricoh}{"Ricoh IS50"} = "ricoh";
$driver{SCSI}{Ricoh}{"Ricoh IS60"} = "ricoh";

# Sceptre
$driver{SCSI}{Sceptre}{"Vividscan S1200"} = "sceptre";

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
$driver{USB}{Agfa}{"SnapScan 1236u"} = "SnapScan";
$driver{USB}{Agfa}{"SnapScan 1212u"} = "SnapScan";

$driver{USB}{Agfa}{"SnapScan e20"} = "SnapScan";
$driver{USB}{Agfa}{"SnapScan e25"} = "SnapScan";
$driver{USB}{Agfa}{"SnapScan e26"} = "SnapScan";
$driver{USB}{Agfa}{"SnapScan e40"} = "SnapScan";
$driver{USB}{Agfa}{"SnapScan e42"} = "SnapScan";
$driver{USB}{Agfa}{"SnapScan e50"} = "SnapScan";
$driver{USB}{Agfa}{"SnapScan e52"} = "SnapScan";
$driver{USB}{Agfa}{"SnapScan e60"} = "SnapScan";
$driver{SCSI}{Vuego}{"Close SnapScan 310 compatible."} = "SnapScan";

$driver{SCSI}{Acer}{"310s"} = "SnapScan";
$driver{SCSI}{Acer}{"300f"} = "SnapScan";
$driver{SCSI}{Acer}{"310s"} = "SnapScan";
$driver{SCSI}{Acer}{"610s"} = "SnapScan";
$driver{SCSI}{Acer}{"610plus"} = "SnapScan";
$driver{SCSI}{Acer}{"Prisa 620s"} = "SnapScan";
$driver{USB}{Acer}{"Prisa 620u"} = "SnapScan";
$driver{USB}{Acer}{"Prisa 620ut"} = "SnapScan";
$driver{USB}{Acer}{"Prisa 640u"} = "SnapScan";
$driver{USB}{Acer}{"Prisa 640bu"} = "SnapScan";
$driver{USB}{Acer}{"Prisa 1240"} = "SnapScan";
$driver{USB}{Acer}{"Prisa 3300"} = "SnapScan";
$driver{USB}{Acer}{"Prisa 4300"} = "SnapScan";
$driver{USB}{Acer}{"Prisa 5300"} = "SnapScan";
$driver{SCSI}{Guillemot}{"Maxi Scan A4 Deluxe"} ="SnapScan";
$driver{USB}{Guillemot}{"Scan\@home Touch 1248"} ="SnapScan";

# Tamarack
$driver{SCSI}{Tamarack}{"Artiscan 6000C"} = "tamarack";
$driver{SCSI}{Tamarack}{"Artiscan 8000C"} = "tamarack";
$driver{SCSI}{Tamarack}{"Artiscan 12000C"} = "tamarack";

# Umax
# $driver{Parport}{UMAX}{parallel scanners} = "umax_pp";
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
$driver{SCSI}{UMAX}{"Astra 2200 U"} = "umax";
$driver{SCSI}{UMAX}{"Astra 2200 S"} = "umax";
$driver{SCSI}{UMAX}{"Astra 2200"} = "umax";
$driver{SCSI}{UMAX}{"Astra 2400S"} = "umax";
$driver{SCSI}{UMAX}{"Astra MX3"} = "umax";
$driver{USB} {UMAX}{"Astra MX3"} = "umax";
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

$driver{SCSI}{"Linotype Hell"}{"Jade"} = "umax";
$driver{SCSI}{"Linotype Hell"}{"Jade2"} = "umax";
$driver{SCSI}{"Linotype Hell"}{"Saphir"} = "umax";
$driver{SCSI}{"Linotype Hell"}{"Saphir2"} = "umax";
$driver{SCSI}{"Linotype Hell"}{"Saphir Ultra"} = "umax";
$driver{SCSI}{"Linotype Hell"}{"Saphir Ultra II"} = "umax";
$driver{SCSI}{"Linotype Hell"}{"Saphir HiRes"} = "umax";
$driver{SCSI}{"Linotype Hell"}{"Opal"} = "umax";
$driver{SCSI}{"Linotype Hell"}{"Opal Ultra"} = "umax";
$driver{SCSI}{"Linotype Hell"}{"Linoscan 1400"} = "umax";

$driver{SCSI}{"Vobis"}{"Scanboostar Premium"} = "umax";
$driver{SCSI}{"Highscreen"}{"Scanboostar Premium"} = "umax";

$driver{SCSI}{EDGE}{"KTX-9600US"} = "umax";
$driver{SCSI}{Epson}{"Perfection 600"} = "umax";
$driver{SCSI}{Escom}{"Image Scanner 256"} = "umax";
$driver{SCSI}{Escort}{"Galleria 600"} = "umax";
$driver{SCSI}{Genius}{"ColorPage-HR5 Pro"} = "umax";
$driver{SCSI}{Nikon}{"AX-210"} = "umax";

# More parallel-port:
# $driver{}{UMAX}{AX-210} = "umax_pp";
# $driver{Parport (EPP)}{UMAX}{Astra 1220P} = "umax_pp";
# $driver{Parport (EPP)}{UMAX}{Astra 2000P} = "umax_pp";
# $driver{Parport (EPP)}{UMAX}{Astra 1600P} = "umax_pp";
# $driver{Parport (EPP)}{UMAX}{ASTRA 610 P} = "umax_pp";

################################################################################

my @all_drivers = ("abaton","agfafocus","apple","artec","avision","bh","canon", "canon630u",
		   "coolscan", "coolscan2", "dc210","dc240","dc25","dll","dmc","epson","hp", 
		   , "fujitsu" , "leo", "microtek","microtek2", "mustek_usb", 
                   "mustek", "matsushita",
		   "nec", "net","pie","plustek","qcam", "ricoh","s9036","saned", 
		   "sceptre", "sharp", "snapscan","sp15c","st400","tamarack","umax","umax_pp",
		   "v4l" );
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
YAST2_DEVICE
EndOfConf

$config{s9036} = <<"EndOfConf";
YAST2_DEVICE 
EndOfConf

$config{coolscan} = <<"EndOfConf";
scsi Nikon * Scanner
YAST2_DEVICE 
EndOfConf

$config{coolscan2} = <<"EndOfConf";
# coolscan2.conf: sample configuration file for coolscan2 backend
#
# The following entrie checks for your scanner by manufacturer (SCSI)
# and by vendor and product ID (USB). This is what the backend does when
# no configuration file can be found.
#
auto

# You can also configure the backend for specific device files, but this
# should not normally be necessary (under Linux at least).
# Syntax for specific devices: <interface>:<device>
#
# For a SCSI scanner, uncomment and edit the following line:
#scsi:/dev/scanner
#
# For a USB scanner, uncomment and edit the following line:
#usb:/dev/usbscanner
#
# For an IEEE 1394 scanner, use the SBP2 protocol (under Linux, use the
# sbp2 kernel module), and your scanner will be handled as a SCSI device.
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
YAST2_DEVICE
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
# names or IP addresses that are permitted by saned to
# use local SANE devices in a networked configuration.
# The hostname matching is not case-sensitive.
#
#scan-client.somedomain.firm
#192.168.0.1
#
# NOTE: /etc/inetd.conf (or /etc/xinetd.conf) and
# /etc/services must also be properly configured to start
# the saned daemon as documented in saned(1), services(4)
# and inetd.conf(4) (or xinetd.conf(5)).
EndOfConf

$config{pie} = <<"EndOfConf";
scsi DEVCOM * Scanner
scsi PIE * Scanner
scsi Adlib * Scanner
YAST2_DEVICE
EndOfConf

$config{avision} = <<"EndOfConf";
scsi AVISION
scsi MITSBISH MCA-S600C
scsi MITSBISH MCA-SS600
scsi HP
scsi hp

YAST2_DEVICE 

#option disable-gamma-table
#option disable-calibration
#option force-a4

EndOfConf

$config{nec} = <<"EndOfConf";
YAST2_DEVICE
EndOfConf

$config{leo} = <<"EndOfConf";
# The FS-1130 respond to all luns
scsi ACROSS * Scanner * * * 0

YAST2_DEVICE
EndOfConf


$config{mustek} = <<"EndOfConf";
# See sane-mustek(5) for documentation.

#--------------------------- Global options ---------------------------------
#option strip-height 1           # some SCSI adapters need this; scanning may 
                                 # be faster without this option
#option force-wait               # wait for scanner to be ready (only necessary
                                 # when scanner freezes)
#option disable-double-buffering # try this if you have SCSI trouble

#-------------------------- SCSI scanners -----------------------------------
scsi MUSTEK * Scanner
# option linedistance-fix        # stripes may go away in color mode
# option buffersize 1024         # set non standard buffer size (in kb)
# option blocksize 2048          # set non standard block size (in kb)
# option lineart-fix             # lineart may be faster with this option off.
# option disable-backtracking    # faster, but may produce stripes

scsi SCANNER
# option linedistance-fix        # stripes may go away in color mode
# option buffersize 1024         # set non standard buffer size (in kb)
# option blocksize 2048          # set non standard block size (in kb)
# option lineart-fix             # lineart may be faster with this option off.
# option disable-backtracking    # faster, but may produce stripes

YAST2_DEVICE
# option linedistance-fix        # stripes may go away in color mode
# option buffersize 1024         # set non standard buffer size (in kb)
# option blocksize 2048          # set non standard block size (in kb)
# option lineart-fix             # lineart may be faster with this option off.
# option disable-backtracking    # faster, but may produce stripes

#-------------------------- 600 II N ----------------------------------------
#0x2eb
                                # For the 600 II N try one of 0x26b, 0x2ab,
                                # 0x2eb, 0x22b, 0x32b, 0x36b,  0x3ab, 0x3eb.
# option linedistance-fix       # only neccessary with firmware 2.x
EndOfConf

$config{ricoh} = <<"EndOfConf";
scsi RICOH IS60
YAST2_DEVICE 
EndOfConf

$config{plustek} = <<"EndOfConf";
# Plustek-SANE Backend configuration file
# For use with Plustek parallel-port scanners and
# LM9831/2/3 based USB scanners
#
# For parport devices use the parport section
#
[parport]
device /dev/pt_drv

#
# leave the default values as specified in /etc/modules.conf
#
option warmup    -1
option lOffOnEnd -1
option lampOff   -1


#
# The USB section:
# each device needs at least two lines:
# - [usb] vendor-ID and product-ID
# - device devicename
# i.e. for Plustek (0x07B3) UT12/16/24 (0x0017)
# [usb] 0x07B3 0x0017
# device /dev/usbscanner
#
# additionally you can specify some options
# warmup, lOffOnEnd, lampOff
#
# For autodetection use
# [usb]
# device /dev/usbscanner
#
# NOTE: autodetection is safe, as it uses the info it got
#       from the USB subsystem. If you're not using the
#       autodetection, you MUST have attached that device
#       at your USB-port, that you have specified...
#

[usb]

#
# options for the previous USB entry
#
# switch lamp off after xxx secs, 0 disables the feature
option lampOff 0

# warmup period in seconds, 0 means no warmup
option warmup 30

# 0 means leave lamp-status untouched, not 0 means switch off
# on sane_close
option lOffOnEnd 0

#
# options to tweak the image start-position
# (WARNING: there's no internal range check!!!)
#
# for the normal scan area
#
option posOffX 0
option posOffY 0

# for transparencies
option tpaOffX 0
option tpaOffY 0

# for negatives
option negOffX 0
option negOffY 0

#
# for adjusting the default gamma values
#
option redGamma         1.0
option greenGamma       1.0
option blueGamma        1.0
option grayGamma        1.0

#
# and of course the device-name
#
device YAST2_DEVICE

#
# to define a new device, start with a new section:
# [usb] or [parport]
#

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


$config{sceptre} = <<"EndOfConf";
scsi "KINPO   " "Vividscan S120  "
YAST2_DEVICE
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
YAST2_DEVICE
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
canon630u
coolscan
#dc25
#dc210
#dc240
dmc
epson
hp
ibm
m3096g
m3091
microtek
microtek2
mustek
#mustek_pp
mustek_usb
nec
pie
pint
plustek
#pnm
qcam
ricoh
s9036
sharp
snapscan
sp15c
tamarack
umax
#umax_pp
umax_pp
umax1220u
v4l
EndOfConf

$config{agfafocus} = <<"EndOfConf";
YAST2_DEVICE

EndOfConf

$config{snapscan} = <<"EndOfConf";
#------------------------------ General -----------------------------------

# Change to the fully qualified filename of your firmware file, if
# firmware upload is needed by the scanner
firmware /path/to/your/firmware/file.bin

# If not automatically found you may manually specify a device name.

# For USB scanners also specify bus=usb, e.g.
# /dev/usb/scanner0 bus=usb

# For SCSI scanners specify the generic device, e.g. /dev/sg0 on Linux.
# /dev/sg0

#---------------------------------------------------------------------------
# No changes should be necessary below this line
#---------------------------------------------------------------------------

#-------------------------- SCSI scanners ----------------------------------
# These SCSI devices will be probed automatically
scsi AGFA * Scanner
scsi COLOR * Scanner
scsi Color * Scanner
scsi ACERPERI * Scanner

#--------------------------- USB scanners -----------------------------------
# These USB devices will be probed automatically
# (This will currently work only on Linux)

# Benq/Acer/Vuego 320U
usb 0x04a5 0x2022
# Benq/Acer/Vuego 620U / 620UT
usb 0x04a5 0x1a2a
usb 0x04a5 0x2040
# Benq/Acer/Vuego 640U
usb 0x04a5 0x2060
# Benq/Acer/Vuego 640BU
usb 0x04a5 0x207e
# Benq/Acer/Vuego 1240U
usb 0x04a5 0x20c0
# Benq/Acer/Vuego 3300 / 4300
usb 0x04a5 0x20b0
# Benq/Acer/Vuego 4300
usb 0x04a5 0x20de
# Agfa 1236U
usb 0x06bd 0x0002
# Agfa 1212U
usb 0x06bd 0x0001
usb 0x06bd 0x2061
# Agfa Snapscan e20
usb 0x06bd 0x2091
# Agfa Snapscan e25
usb 0x06bd 0x2095
# Agfa Snapscan e26
usb 0x06bd 0x2097
# Agfa Snapscan e40
usb 0x06bd 0x208d
# Agfa Snapscan e42
usb 0x06bd 0x20ff
# Agfa Snapscan e50
usb 0x06bd 0x208f
# Agfa Snapscan e52
usb 0x06bd 0x20fd

EndOfConf

$config{dmc} = <<"EndOfConf";
YAST2_DEVICE 
EndOfConf

$config{net} = <<"EndOfConf";
# This is the net config file.  Each line names a host to attach to.
# If you list "localhost" then your backends can be accessed either
# directly or through the net backend.  Going through the net backend
# may be necessary to access devices that need special privileges.
# localhost
EndOfConf

$config{qcam} =<<"EndOfConf";
#
# In order to use the qcam backend, you'll need to enable to line with
# the port address for your scanner.  You can enable multiple lines if
# you really have a QuickCam connect to each port.
#
#u0x37b # /dev/lp0 forced in unidir mode
#u0x378 # /dev/lp1 forced in unidir mode
#u0x278 # /dev/lp2 forced in unidir mode
#0x37b  # /dev/lp0
#0x378  # /dev/lp1
#0x278  # /dev/lp2
0x3bc   # /dev/lp0

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
#

# define scsi queueing depth
#option scsi-maxqueue 2

# define scsi buffer size in bytes
#option scsi-buffer-size-min 65536
#option scsi-buffer-size-max 262144

# define scan lines that shall be read in one block
#option scan-lines 100
#option preview-lines 20

# define how to handle bad sense codes
#   0 = handle as device busy
#   1 = handle as ok
#   2 = handle as i/o error
#   3 = ignore bad error code - continue sense handler,  
#option handle-bad-sense-error 0

# define if a request sense command shall be executed
#option execute-request-sense 0

# define if the preview bit shall be set when scanning in rgb mode
#option force-preview-bit-rgb 0

# define if slow speed flag shall be set
# BE CAREFUL WITH THIS OPTION, IT MAY DESTROY YOUR SCANNER WHEN SET FALSE
# -1 = automatically set by driver - if known
#  0 = disabled
#  1 = enabled
#option slow-speed 0

# define if care-about-smeraring flag shall be set
# BE CAREFUL WITH THIS OPTION, IT MAY DESTROY YOUR SCANNER WHEN SET FALSE
# -1 = automatically set by driver - if known
#  0 = disabled
#  1 = enabled
#option care-about-smearing 0

# define if the calibration shall be done for selected scanarea or for each ccd pixel
# -1 = automatically set by driver - if known
#  0 = disabled
#  1 = enabled    
#option calibration-full-ccd 1

# define if an offset of the calculate calibration with has to be used
# -99999 = auto
#option calibration-width-offset -99999

# define the number of pixels that is used for calibration
# -1 = disabled
#  0 = not set
#  1 = 1 byte/pixel,
#  2 = 2 bytes/pixel  
#option calibration-bytes-pixel -1

# define if shading data shall be inverted befor sending it back to the scanner
# -1 = automatically set by driver - if known
#  0 = disabled
#  1 = enabled 
#option invert-shading-data

# define if the scanner supports lamp control commands
# 0 = automatically set by driver - if known
# 1 = enabled 
#option lamp-control-available 0

# define how 16 bit gamma data is padded
# -1 = automatically set by driver - if known
#  0 = gamma data is msb padded
#  1 = gamma data is lsb padded 
#option gamma-lsb-padded 0

# define connection type of following devices
# 1 = scsi
# 2 = usb
#option connection-type 1

# linux device identification:
#scsi vendor model type bus channel id lun
scsi UMAX * Scanner
scsi LinoHell JADE
scsi LinoHell Office
scsi LinoHell Office2
scsi LinoHell SAPHIR2
scsi HDM LS4H1S
scsi Nikon AX-110
scsi Nikon AX-210
scsi KYE ColorPage-HR5
scsi EPSON Perfection600
scsi ESCORT "Galleria 600S"

# Umax Astra 2200 via USB:
# usb vendor product
usb 0x1606 0x0230

# scsi device list
IF bus = scsi option connection-type 1
IF bus = usb  option connection-type 2

YAST2_DEVICE

EndOfConf

$config{apple} = <<"EndOfConf";
scsi APPLE
YAST2_DEVICE 
EndOfConf

# Seems nothing to contain.
$config{m3091} = "";

$config{m3096g} = <<"EndOfConf";
scsi FUJITSU
EndOfConf

$config{fujitsu} = <<"EndOfConf";

#option force-model fi-4340Cdi
#/dev/sg1
scsi FUJITSU

YAST2_DEVICE
EndOfConf

$config{hp} = <<"EndOfConf";
scsi HP
YAST2_DEVICE 
EndOfConf

# $config{ibm} <<"EndOfConf";


$config{bh} = <<"EndOfConf";
scsi "B&H SCSI"
YAST2_DEVICE
EndOfConf

$config{canon} = <<"EndOfConf";
#canon.conf
YAST2_DEVICE
#/dev/sg0
EndOfConf


$config{canon630u} = <<"EndOfConf";
# Options for the canonusb backend

# Autodetect the Canon CanoScan FB630u
usb 0x04a9 0x2204

# device list for non-linux-systems (enable if autodetect fails):
# YAST2_DEVICE
#/dev/usb/scanner0
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

$config{mustek_usb} = <<"EndOfConf";
# mustek_usb.conf: Configuration file for Mustek USB scanner
# Read man sane-mustek_usb for documentation
 
# Autodetect 1200 UB and Trust Compact Scan USB 19200
usb 0x055f 0x0006
 
# Autodetect 1200 CU
usb 0x055f 0x0001
 
# Autodetect 1200 CU Plus
usb 0x055f 0x0008
 
# Autodetect 600 CU
usb 0x055f 0x0002
 
# If autodetection doesn't work uncomment or add your device file and one
# suitable option (1200ub is also for Trust Compact Scan USB 19200).
 
#/dev/usb/scanner0
#option 1200ub
#option 1200cu
#option 1200cu_plus
#option 600cu
 
#/dev/usbscanner0
#option 1200ub
#option 1200cu
#option 1200cu_plus
#option 600cu

EndOfConf


$config{tamarack} = <<"EndOfConf";
scsi TAMARACK
YAST2_DEVICE
EndOfConf

$config{abaton} = <<"EndOfConf";
scsi ABATON
YAST2_DEVICE 
EndOfConf

$config{epson} = <<"EndOfConf";
#
# here are some examples for how to configure the EPSON backend
#
# SCSI scanner:
IF bus = scsi scsi EPSON
IF bus = usb # scsi EPSON
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
    my ($hkey) = grep( /^$searchkey$/i, @hkeys ); # key must fit exactly (exception: ignore case)

    if( defined $hkey )
    {
	$entry = $$hashref{ $hkey };
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
	    y2debug( "Could not create file <$file>" );
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


#
# modifies /var/lib/sane/devices, which holds a list of devices read by
# rcsane. If the device is not known, its added.
#
sub modify_rc_cmdfile( $ )
{
    my ($dev) = @_;
    my @lines;

    if( open( FILE, "$prefix/var/lib/sane/devices" ) )
    {
	@lines = <FILE>;
	close FILE;
    }

    my $oriline = shift @lines;
    
    y2debug( "Found in /var/lib/sane/devices: <$oriline>" );
    
    my @devs = split( /\s+/, $oriline );

    my $line = "";
    my $already_known = 0;

    foreach my $known_dev ( @devs ){
	if( -e $known_dev ) {
	    $line .= " $dev";
	    $already_known = 1 if( $known_dev =~ /^$dev$/ );
	}
	else
	{
	    y2debug("WRN: Have a nonexisting devicefile in devicelist" );
	}
    }
    $line .= " $dev" if( ! $already_known );

    # Check if directory exists and create if neccessary.
    unless( -e "$prefix/var/lib/sane" )
    {
	system( "/bin/mkdir -p $prefix/var/lib/sane" );
    }

    if( open( FILE, ">$prefix/var/lib/sane/devices" ))
    {
	print FILE "$line\n";
	close FILE;
    }
    else
    {
	y2debug("ERR: Directory <$prefix/var/lib/sane/devices> does not exist and could not be created !" );
    }
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

    my %foundscanner = ();

    y2debug("getModel called with <$bus> <$vendor>" );

    if( !defined $vendor || $vendor =~ /^\s*$/ ) {
	y2debug( "getModel: Vendor is empty - can not find model!" );
    }
    else
    {
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
	my $nstats = join( "\n", @$net_stations );
	y2debug("Writing net stations: $nstats" );
	print F $nstats;
	$res = close F;
    }
    else
    {
	y2debug( "Open of /etc/sane.d/net.conf failed: $!" );
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

	    # Check for IF-conditions 
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

	    # The device line may not contain a comment
	    # Wipe out comments in case there are other chars 
	    # in front of the #-sign. If not, the whole line is
	    # a comment line, that is OK 
	    $cfg_line =~ s/\s*#.*$//g unless( $cfg_line =~ /^\s*#.*/ );

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

    if( $res )
    {
	# Change the device permission to 666, remember the device.
	if( $bus =~ /scsi/i )
	{
	    if( defined( $device ) && -c $device )
	    {
		y2debug("Setting permissions of device <$device> to 666");
		push @devicesToReset, $device;
		my $mode = 0666;
		chmod $mode, $device;
	    
		# In case it is an scsi device, add it to /var/lib/sane/devices.
		modify_rc_cmdfile( $device );
	    }
	    else
	    {
		y2debug("ERR <$device> is not a character device !" );
	    }
	}
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

    my $cmd = sprintf( "/usr/X11R6/bin/scanimage -d %s > %s", $usedev, $tmpfile );

    y2debug( "Scanning test image with command <$cmd>" );
 
    system( $cmd );
    return( $tmpfile );

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

    y2debug("Enabling net scanner for <$host>" );
    if( enableNetScan( $host ) )
    {
	# now the net station should be enalbed.
	y2debug("Netscanning for <$host> enabled successfully");
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
	my $referto = $$scanref{host};

	y2debug( "Found scanner on host <$referto>" );

	if ( $referto =~ /^$host$/i )
	{
	    y2debug( "adding network-scanner <$referto>" );
	    push @hostscanners, $scanref;
	}
    }
    
    # copy the original files back to dll.conf and net.conf
    if( -e "$prefix/etc/sane.d/dll.conf.yast2-$PID" )
    {
	y2debug( "Reverting to original dll.conf" );
	move( "$prefix/etc/sane.d/dll.conf.yast2-$PID",
	      "$prefix/etc/sane.d/dll.conf" );
    }

    if( -e "$prefix/etc/sane.d/net.conf.yast2-$PID" )
    {
	y2debug( "Reverting to original net.conf" );
	move( "$prefix/etc/sane.d/net.conf.yast2-$PID",
	      "$prefix/etc/sane.d/net.conf" ) ;
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
    y2debug( "Reverted $countfiles configuration-files" );
    
    # look in /var/lib/sane for to restore things
    $path = "$prefix/var/lib/sane/devices.yast2-$PID";
    if( -e $path )
    {
	y2debug("Restoring devices-file in <$path>");
	move ( $path, "$prefix/var/lib/sane/devices" );
    }
    

    # Now check for changed permissions on scsi-files
    while( my $file = shift @devicesToReset )
    {
	if( -c $file )
	{
	    y2debug("Resetting device <$file> to 640" );
	    chmod 0640, $file;
	    
	}
    }
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
    my $cmd = '/usr/X11R6/bin/scanimage -f $\'"%d" "%v" "%m" "%t"\n\'';
    y2debug( "Using command <$cmd>!" );

    my @scanners = ();

    if( open( CMD, "$cmd |" ) )
    {
	my $cnt = 0;
	while( <CMD> )
	{
 	    next if( /^\s*$/ );
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
		  scanner_driver => trim($driver),
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
@devicesToReset = ();

1;

# EOF
