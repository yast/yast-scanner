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
#
# $Id$
#
package scannerDB;

use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION);
use Exporter;
use ycp;

@ISA            = qw(Exporter);
@EXPORT         = qw( getModel 
		      getVendorList
		      findInHash
		      trim);

use vars qw ( %driver );


# Abaton
$driver{SCSI}{ABATON}{"SCAN 300/GS"} = "abaton";
$driver{SCSI}{ABATON}{"SCAN 300/S"} = "abaton";

# Agfa


$driver{SCSI}{AGFA}{"FOCUS GS SCANNER"} = "agfafocus";
$driver{SCSI}{AGFA}{"FOCUS LINEART SCANNER"} = "agfafocus";
$driver{SCSI}{AGFA}{"FOCUS II"} = "agfafocus";
$driver{SCSI}{AGFA}{"FOCUS COLOR"} = "agfafocus";

$driver{SCSI}{SIEMENS}{"FOCUS COLOR PLUS"} = "agfafocus";

# Apple
$driver{SCSI}{APPLE}{"APPLE SCANNER"} = "apple";
$driver{SCSI}{APPLE}{"ONESCANNER"} = "apple";

# Artec and Ultima
$driver{SCSI}{"Artec|Ultima"}{"ColorOneScanner"} = "artec";
$driver{SCSI}{"Artec|Ultima"}{"AT3"} = "artec";
$driver{SCSI}{"Artec|Ultima"}{"A6000C"} = "artec";
$driver{SCSI}{"Artec|Ultima"}{"A6000C PLUS"} = "artec";
$driver{SCSI}{"Artec|Ultima"}{"AT6"} = "artec";
$driver{SCSI}{"Artec|Ultima"}{"AT12"} = "artec";
$driver{SCSI}{"Artec|Ultima"}{"AM12S"} = "artec";

$driver{SCSI}{BlackWidow}{"BW4800SP"} = "artec";
$driver{SCSI}{Plustek}{"OpticPro 19200S"} = "artec";

$driver{USB}{TestEntry}{"BlubberEntry"} = "testi";
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


# continue here to verify.

# $driver{SCSI}{Canon}{"CanoScan 300"} = "canon";
# $driver{SCSI}{Canon}{"CanoScan 600"} = "canon";
# $driver{SCSI}{Nikon}{"CanoScan 2700F"} = "coolscan";
# $driver{SCSI}{Nikon}{"LS-20"} = "coolscan";
# $driver{SCSI}{Nikon}{"LS-30"} = "coolscan";
# $driver{SCSI}{Nikon}{"LS-2000"} = "coolscan";
# $driver{}{Kodak}{"LS-1000"} = "dc210";
# $driver{Serial port}{Kodak}{"DC210"} = "dc240";
# $driver{Serial port}{Kodak}{DC240} = "dc25";
# $driver{Serial port}{Kodak}{DC25} = "dc25";
# $driver{}{Polaroid}{DC20} = "dmc";
# $driver{}{Epson}{DMC} = "epson";
# $driver{Parport}{Epson}{GT-5000} = "epson";
# $driver{Parport}{Epson}{Actionscanner II} = "epson";
# $driver{Parport}{Epson}{GT-6000} = "epson";
# $driver{Parport}{Epson}{ES-300C} = "epson";
# $driver{SCSI}{Epson}{GT-5500} = "epson";
# $driver{Parport}{Epson}{GT-6500} = "epson";
# $driver{Parport}{Epson}{ES-600C} = "epson";
# $driver{Parport}{Epson}{ES-1200C} = "epson";
# $driver{SCSI}{Epson}{GT-7000} = "epson";
# $driver{SCSI}{Epson}{GT-8000} = "epson";
# $driver{SCSI}{Epson}{ES-8500} = "epson";
# $driver{SCSI}{Epson}{Perfection 636S} = "epson";
# $driver{USB}{Epson}{Perfection 636U} = "epson";
# $driver{USB}{Epson}{Perfection 610} = "epson";
$driver{USB}{EPSON}{"PERFECTION 640"} = "epson";
# $driver{SCSI}{Epson}{Perfection 1200S} = "epson";
# $driver{USB}{Epson}{Perfection 1200U} = "epson";
# $driver{USB}{Epson}{Perfection 1200Photo} = "epson";
# $driver{SCSI USB}{Epson}{Perfection 1240} = "epson";
# $driver{SCSI USB}{Epson}{Perfection 1640} = "epson";
# $driver{SCSI}{Epson}{Expression 636} = "epson";
# $driver{SCSI}{Epson}{Expression 800} = "epson";
# $driver{SCSI USB IEEE-1394}{Epson}{Expression 1600} = "epson";
# $driver{SCSI USB IEEE-1394}{Epson}{Expression 1680} = "epson";
# $driver{}{HP}{FilmScan 200} = "hp";
# $driver{Propietary}{HP}{HP ScanJet Plus} = "hp";
# $driver{SCSI}{HP}{HP ScanJet IIc} = "hp";
# $driver{SCSI}{HP}{HP ScanJet IIp} = "hp";
# $driver{SCSI}{HP}{HP ScanJet IIcx} = "hp";
# $driver{SCSI}{HP}{HP ScanJet 3c} = "hp";
# $driver{SCSI}{HP}{HP ScanJet 3p} = "hp";
# $driver{SCSI}{HP}{HP ScanJet 4c} = "hp";
# $driver{SCSI}{HP}{HP ScanJet 4p} = "hp";
# $driver{USB}{HP}{HP ScanJet 4100C} = "hp";
# $driver{SCSI}{HP}{HP ScanJet 5p} = "hp";
# $driver{Parport}{HP}{HP ScanJet 5100C} = "hp";
# $driver{Parport USB}{HP}{HP ScanJet 5200C} = "hp";
# $driver{SCSI}{HP}{HP ScanJet 6100C} = "hp";
# $driver{SCSI USB}{HP}{HP ScanJet 6200C} = "hp";
# $driver{SCSI USB}{HP}{HP ScanJet 6250C} = "hp";
# $driver{SCSI USB}{HP}{HP ScanJet 6300C} = "hp";
# $driver{SCSI USB}{HP}{HP ScanJet 6350C} = "hp";
# $driver{SCSI USB}{HP}{HP ScanJet 6390C} = "hp";
# $driver{SCSI}{HP}{HP PhotoSmart PhotoScanner} = "hp";
# $driver{Parport(ECP) JetDirect}{HP}{HP OfficeJet Pro 1150C} = "hp";
# $driver{Parport(ECP) JetDirect}{HP}{HP OfficeJet Pro 1170C/1175C} = "hp";
# $driver{Parport(ECP) JetDirect}{HP}{HP OfficeJet R series/PSC500} = "hp";
# $driver{Parport(ECP) USB JetDirect}{HP}{HP OfficeJet G series} = "hp";
# $driver{USB JetDirect}{HP}{HP PSC 700 series} = "hp";
# $driver{Parport(ECP) USB JetDirect}{HP}{HP OfficeJet K series} = "hp";
# $driver{}{HP}{HP OfficeJet V series} = "hp4200";
# $driver{}{Fujitsu}{HP4200} = "m3091";
# $driver{}{Fujitsu}{M3091DCd} = "m3096g";
# $driver{}{Microtek}{M3096G} = "microtek";
# $driver{SCSI}{Microtek}{Scanmaker E6} = "microtek";
# $driver{SCSI}{Microtek}{Scanmaker E3} = "microtek";
# $driver{SCSI}{Microtek}{Scanmaker E2} = "microtek";
# $driver{SCSI}{Microtek}{Scanmaker 35t+} = "microtek";
# $driver{SCSI}{Microtek}{Scanmaker 45t} = "microtek";
# $driver{SCSI}{Microtek}{Scanmaker 35} = "microtek";
# $driver{SCSI}{Microtek}{Scanmaker III} = "microtek";
# $driver{SCSI}{Microtek}{Scanmaker IISP} = "microtek";
# $driver{SCSI}{Microtek}{Scanmaker IIHR} = "microtek";
# $driver{SCSI}{Microtek}{Scanmaker IIG} = "microtek";
# $driver{SCSI}{Microtek}{Scanmaker II} = "microtek";
# $driver{SCSI}{Microtek}{Scanmaker 600Z(S)} = "microtek";
# $driver{SCSI}{Microtek}{Scanmaker 600G(S)} = "microtek";
# $driver{SCSI (Parport)}{Agfa}{Color PageWiz} = "microtek";
# $driver{SCSI}{Agfa}{Arcus II} = "microtek";
# $driver{SCSI}{Agfa}{StudioScan} = "microtek";
# $driver{SCSI}{Agfa}{StudioScan II} = "microtek";
# $driver{SCSI}{Agfa}{StudioScan IIsi} = "microtek";
# $driver{}{Microtek}{DuoScan} = "microtek2";
# $driver{Parport}{Microtek}{ScanMaker E3plus} = "microtek2";
# $driver{SCSI}{Microtek}{ScanMaker E3plus} = "microtek2";
# $driver{SCSI}{Microtek}{ScanMaker X6} = "microtek2";
# $driver{SCSI}{Microtek}{ScanMaker X6EL} = "microtek2";
# $driver{USB}{Microtek}{ScanMaker X6USB} = "microtek2";
# $driver{SCSI}{Microtek}{ScanMaker V300} = "microtek2";
# $driver{Parport}{Microtek}{ScanMaker V300} = "microtek2";
# $driver{SCSI}{Microtek}{ScanMaker V310} = "microtek2";
# $driver{Parport}{Microtek}{ScanMaker V310} = "microtek2";
# $driver{SCSI}{Microtek}{ScanMaker V600} = "microtek2";
# $driver{Parport}{Microtek}{ScanMaker V600} = "microtek2";
# $driver{SCSI}{Microtek}{ScanMaker 330} = "microtek2";
# $driver{SCSI}{Microtek}{ScanMaker 630} = "microtek2";
# $driver{SCSI}{Microtek}{ScanMaker 636} = "microtek2";
# $driver{SCSI}{Microtek}{ScanMaker 9600XL} = "microtek2";
# $driver{Parport}{Microtek}{Phantom 330CX} = "microtek2";
# $driver{Parport}{Microtek}{SlimScan C3} = "microtek2";
# $driver{SCSI}{Microtek}{Phantom 636} = "microtek2";
# $driver{Parport}{Microtek}{Phantom 636CX} = "microtek2";
# $driver{SCSI}{Vobis}{ScanMaker V6USL} = "microtek2";
# $driver{}{Mustek}{HighScan} = "mustek";
# $driver{SCSI}{Mustek}{Paragon MFS-6000CX} = "mustek";
# $driver{SCSI}{Mustek}{Paragon MFS-12000CX} = "mustek";
# $driver{SCSI}{Mustek}{Paragon MFC-600S} = "mustek";
# $driver{SCSI}{Mustek}{Paragon 600 II CD} = "mustek";
# $driver{SCSI}{Mustek}{ScanMagic 600 II SP} = "mustek";
# $driver{SCSI}{Mustek}{Paragon MFC-800S} = "mustek";
# $driver{SCSI}{Mustek}{Paragon 800 II SP} = "mustek";
# $driver{SCSI}{Mustek}{Paragon MFS-6000SP} = "mustek";
# $driver{SCSI}{Mustek}{Paragon MFS-8000SP} = "mustek";
# $driver{SCSI}{Mustek}{Paragon MFS-1200SP} = "mustek";
# $driver{SCSI}{Mustek}{Paragon MFS-12000SP} = "mustek";
# $driver{SCSI}{Mustek}{ScanExpress 6000SP} = "mustek";
# $driver{SCSI}{Mustek}{ScanExpress 12000SP} = "mustek";
# $driver{SCSI}{Mustek}{ScanExpress 12000SP Plus} = "mustek";
# $driver{SCSI}{Mustek}{Paragon 1200 III SP} = "mustek";
# $driver{SCSI}{Mustek}{Paragon 1200 LS} = "mustek";
# $driver{SCSI}{Mustek}{ScanMagic 9636S} = "mustek";
# $driver{SCSI}{Mustek}{ScanMagic 9636S Plus} = "mustek";
# $driver{SCSI}{Mustek}{ScanExpress A3 SP} = "mustek";
# $driver{SCSI}{Mustek}{Paragon 1200 SP Pro} = "mustek";
# $driver{SCSI}{Mustek}{Paragon 1200 A3 Pro} = "mustek";
# $driver{Proprietary}{Trust}{Paragon 600 II N} = "mustek";
# $driver{SCSI}{Trust}{Imagery 1200 SP} = "mustek";
# $driver{SCSI}{Trust}{Imagery 4800 SP} = "mustek";
# $driver{SCSI}{Trust}{SCSI Connect 19200} = "mustek";
# $driver{}{Mustek}{SCSI excellence series 19200} = "mustek_pp";
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
# $driver{}{NEC}{Gallery 4800} = "nec";
# $driver{SCSI}{NEC}{PC-IN500/4C} = "nec";
# $driver{}{Devcom}{PC-IN600,700,800 series} = "pie";
# $driver{Parport}{Devcom}{parallel scanners} = "pie";
# $driver{USB}{Devcom}{USB scanners} = "pie";
# $driver{SCSI}{Devcom}{9636PRO} = "pie";
# $driver{SCSI}{Devcom}{9636S} = "pie";
# $driver{SCSI}{PIE}{9630S} = "pie";
# $driver{Parport}{PIE}{parallel scanners} = "pie";
# $driver{USB}{PIE}{USB scanners} = "pie";
# $driver{SCSI}{PIE}{ScanAce 1236S} = "pie";
# $driver{SCSI}{PIE}{ScanAce 1230S} = "pie";
# $driver{SCSI}{PIE}{ScanAce II} = "pie";
# $driver{SCSI}{PIE}{ScanAce III} = "pie";
# $driver{SCSI}{PIE}{ScanAce Plus} = "pie";
# $driver{SCSI}{PIE}{ScanAce II Plus} = "pie";
# $driver{SCSI}{PIE}{ScanAce III Plus} = "pie";
# $driver{SCSI}{PIE}{ScanAce V} = "pie";
# $driver{SCSI}{PIE}{ScanAce ScanMedia} = "pie";
# $driver{SCSI}{PIE}{ScanAce ScanMedia II} = "pie";
# $driver{SCSI}{PIE}{ScanAce 630S} = "pie";
# $driver{}{Plustek}{ScanAce 636S} = "plustek";
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
# $driver{SCSI}{Plustek}{OpticPro 19200S} = "plustek";
# $driver{USB}{Primax}{OpticPro 1212U/U12/UT12} = "plustek";
# $driver{Parport (SPP, EPP)}{Primax}{Colorado 4800} = "plustek";
# $driver{Parport (SPP, EPP)}{Primax}{Compact 4800 Direct} = "plustek";
# $driver{Parport (SPP, EPP)}{Primax}{Compact 4800 Direct-30} = "plustek";
# $driver{Parport (SPP, EPP)}{Aries}{Compact 9600 Direct-30} = "plustek";
# $driver{}{Connectix}{Scan-It Pro 4800} = "qcam";
# $driver{Parport}{Connectix}{Color QuickCam} = "qcam";
# $driver{}{Ricoh}{Greyscale QuickCam} = "ricoh";
# $driver{SCSI}{Ricoh}{Ricoh IS50} = "ricoh";
# $driver{}{Siemens}{Ricoh IS60} = "s9036";
# $driver{}{SHARP}{9036 Flatbed scanner} = "sharp";
# $driver{}{SHARP}{JX-610} = "sharp";
# $driver{}{SHARP}{JX-250} = "sharp";
# $driver{}{SHARP}{JX-320} = "sharp";
# $driver{}{SHARP}{JX-330} = "sharp";
# $driver{}{Microtek}{JX-350} = "sm3600";
# $driver{}{AGFA}{ScanMaker 3600} = "SnapScan";
# $driver{SCSI}{AGFA}{SnapScan 300} = "SnapScan";
# $driver{SCSI}{AGFA}{SnapScan 310} = "SnapScan";
# $driver{SCSI}{AGFA}{SnapScan 600} = "SnapScan";
# $driver{SCSI}{AGFA}{SnapScan 1236s} = "SnapScan";
# $driver{USB}{AGFA}{SnapScan 1212u} = "SnapScan";
# $driver{USB}{AGFA}{SnapScan e40} = "SnapScan";
# $driver{USB}{Vuego}{SnapScan e50} = "SnapScan";
# $driver{SCSI}{Acer}{310s} = "SnapScan";
# $driver{SCSI}{Acer}{300f} = "SnapScan";
# $driver{SCSI}{Acer}{310s} = "SnapScan";
# $driver{SCSI}{Acer}{610s} = "SnapScan";
# $driver{SCSI}{Acer}{610plus} = "SnapScan";
# $driver{SCSI}{Acer}{Prisa 620s} = "SnapScan";
# $driver{USB}{Acer}{Prisa 620u} = "SnapScan";
# $driver{USB}{Acer}{Prisa 640u} = "SnapScan";
# $driver{USB}{Acer}{Prisa 640bu} = "SnapScan";
# $driver{}{}{Maxi Scan A4 Deluxe (SCSI)} = "sp15c";
# $driver{}{Siemens}{SP15C} = "st400";
# $driver{SCSI}{Siemens}{ST400} = "st400";
# $driver{}{Tamarack}{ST800} = "tamarack";
# $driver{SCSI}{Tamarack}{Artiscan 6000C} = "tamarack";
# $driver{SCSI}{Tamarack}{Artiscan 8000C} = "tamarack";
# $driver{}{UMAX}{Artiscan 12000C} = "umax";
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
# $driver{SCSI}{Epson}{Scanboostar Premium} = "umax";
# $driver{SCSI}{Escom}{Perfection 600} = "umax";
# $driver{SCSI}{Escort}{Image Scanner 256} = "umax";
# $driver{SCSI}{Genius}{Galleria 600} = "umax";
# $driver{SCSI}{Nikon}{ColorPage-HR5 (Pro)} = "umax";
# $driver{}{UMAX}{AX-210} = "umax_pp";
# $driver{Parport (EPP)}{UMAX}{Astra 1220P} = "umax_pp";
# $driver{Parport (EPP)}{UMAX}{Astra 2000P} = "umax_pp";
# $driver{Parport (EPP)}{UMAX}{Astra 1600P} = "umax_pp";
# $driver{Parport (EPP)}{UMAX}{ASTRA 610 P} = "umax_pp";

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
    
    y2debug( "findInHash: Keys: " . join( "-", @hkeys ));

    my $entry = "";
    my ($hkey) = grep( /$searchkey/i, @hkeys );
    y2debug("HKey: $hkey" ) if( defined $hkey );

    if( defined $hkey )
    {
	$entry = %$hashref->{ $hkey };
	y2debug( "Found key <$searchkey> entry <$entry>" );
    }
    else
    {
	y2debug("Could not find entry for key <$searchkey>" );
    }

    return( $entry );
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
    
    my $bus_scanners = $driver{ uc $bus };
    if( defined $bus_scanners )
    {
	my $mfg_scanner_ref = $bus_scanners->{ uc $vendor};

	if( defined $mfg_scanner_ref )
	{
	    %foundscanner = %$mfg_scanner_ref;
	}
	else
	{
	    y2debug( "Can not find scanner for Vendor " . uc $vendor );
	}
    }
    else
    {
	y2debug( "Can not find scanner for bus " . uc $vendor );
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
    
    my $bus_scanners = $driver{ uc $bus };

    my @vendorlist = keys %$bus_scanners;
    unshift @vendorlist, 'Generic';

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
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;
    y2debug("Trim: Trimmed string to <$str>");
    return( $str );
}


1;

