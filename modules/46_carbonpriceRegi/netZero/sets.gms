*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/46_carbonpriceRegi/netZero/sets.gms

sets

targetSpecies "Gases included in national net-zero targets" / CO2_target, GHG_target /

netZeroTargets(all_regi,ttot,targetSpecies) "Region, year, and gases of net-zero targets"
/
    CAZ . 2050 . GHG_target
    EUR . 2050 . GHG_target
    JPN . 2050 . GHG_target
    LAM . 2050 . CO2_target

    MEA . 2055 . CO2_target
    NEU . 2055 . CO2_target
    OAS . 2055 . CO2_target
    SSA . 2055 . CO2_target

    CHA . 2060 . CO2_target
    REF . 2060 . CO2_target

    IND . 2070 . GHG_target
/
;

*** EOF ./modules/46_carbonpriceRegi/netZero/sets.gms
