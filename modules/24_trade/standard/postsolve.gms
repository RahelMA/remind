*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/standard/postsolve.gms

pm_Xport0(ttot,regi,tradePe) = vm_Xport.l(ttot,regi,tradePe);

* Cumulative export of permits
p24_XportPermCum(tall,all_regi) =
    sum(tall2$(ord(tall2) <= ord(tall)),
        vm_Xport.l(tall2,all_regi,"perm"));


* Cumulative import of permits
p24_MportPermCum(tall,all_regi) =
    sum(tall2$(ord(tall2) <= ord(tall)),
        vm_Mport.l(tall2,all_regi,"perm"));



* Cumulative net
p24_NetPermCum(tall,all_regi) =
    p24_XportPermCum(tall,all_regi) - p24_MportPermCum(tall,all_regi);


*** EOF ./modules/24_trade/standard/postsolve.gms
