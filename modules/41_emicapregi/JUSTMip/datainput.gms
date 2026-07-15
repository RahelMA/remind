*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/JUSTMip/datainput.gms


*** read in data of cost-optimal reference climate policy run
*' load CO2 emissions from reference run to assign the allocated permits

* Load a starting value for p41_co2eq from the cost optimal reference run.

Execute_Loadpoint "input_ref" p41_co2eq = vm_co2eq.l;



*** initialization of pm_shPermit and vm_perm for bounds
pm_emicapglob(t) = sum(regi, max(0, p41_co2eq(t,regi)));
pm_shPerm(t,regi) = 0;
pm_shPerm(t,regi)$(pm_emicapglob(t) > 0) =
    max(0, p41_co2eq(t,regi)) / pm_emicapglob(t);

vm_perm.fx(t,regi) = 0;

*** get global GDP
p41_gdpGlob(t) =
    sum(regi, pm_gdp(t,regi));
	 
*** EOF ./modules/41_emicapregi/JUSTMip/datainput.gms
