*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/AbilityToPay/datainput.gms


*** read in data of cost-optimal reference climate policy run

Execute_Loadpoint "input_ref" p41_co2eq_in = vm_emiAll.l;
p41_co2eq(t, regi) = p41_co2eq_in(t,regi,"co2");


*** read in data of baseline run
Execute_Loadpoint "input_bau" p41_co2eq_bau = vm_co2eq.l;


*** initialization of pm_shPermit
pm_shPerm(t,regi) = p41_co2eq(t,regi)/sum(regi2, p41_co2eq(t,regi2));		
pm_emicapglob(t) = sum(regi, p41_co2eq(t,regi));

		 
*** EOF ./modules/41_emicapregi/AbilityToPay/datainput.gms
