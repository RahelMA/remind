*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/26_agCosts/costs/declarations.gms
parameter
pm_totLUcosts(tall,all_regi)           "total landuse costs (agriculture, bioenergy, MAC, etc), in standalone runs MAC costs are substituted by costs from teh REMIND-MAC"
p26_totLUcosts_withMAC(tall,all_regi)  "total landuse costs including MAC (agriculture, bioenergy, MAC, etc)"
p26_macCostLu(tall,all_regi)           "Land use emissions MAC cost"
pm_NXagr(tall,all_regi)                "net agricultural exports"
;

*** EOF ./modules/26_agCosts/costs/declarations.gms
