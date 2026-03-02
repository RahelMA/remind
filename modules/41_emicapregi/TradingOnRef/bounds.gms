*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/TradingOnRef/bounds.gms

*** calculate emission cap in absolute terms
vm_perm.fx(t,regi) = p41_co2eq(t,regi);

display vm_perm.up;

vm_Xport.fx(t,regi,"perm") = 0;
vm_Mport.fx(t,regi,"perm") = 0;

*** Only activate permit trade between 2030 and cm_permitTradeFinalYr
*** cm_permitTradeRatio determines the proportion of emissions that can be traded,
*** between 0 (no permit trade allowed) and 1 (all emissions can be traded)
vm_Xport.up(t,regi,"perm") $ (t.val > 2025 and t.val <= cm_permitTradeFinalYr) = cm_permitTradeRatio * abs(p41_co2eq(t,regi));
vm_Mport.up(t,regi,"perm") $ (t.val > 2025 and t.val <= cm_permitTradeFinalYr) = cm_permitTradeRatio * abs(p41_co2eq(t,regi));

*** EOF ./modules/41_emicapregi/TradingOnRef/bounds.gms
