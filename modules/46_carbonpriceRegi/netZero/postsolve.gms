*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/46_carbonpriceRegi/netZero/postsolve.gms

if(sameAs("%carbonprice%","none"), p46_startInIteration = 0);

if(ord(iteration) > p46_startInIteration, !! start only after 10 iterations when the overall carbon price trajectory is more stable

*** ---------------------------------------------------------------------------  
*** EMISSIONS CALCULATION  
*** ---------------------------------------------------------------------------
*' Define baseline emissions:
p46_emi_refYr(regi) = vm_co2eq.l("2025",regi) / sm_MtCO2_2_GtC;


*' Define emission offset [MtCO2eq/yr], which is the allowed emissions in the net-zero year.
*' Offset may represent a tolerance for net zero or the fact that not all countries of the region have net-zero targets.
Execute_Loadpoint 'input_bau' p46_emi_refRun = vm_co2eq.l; !! read from path_gdx_bau

loop(netZeroTargets(regi,t,targetSpecies),
  p46_emi_offset(regi) =
      (1 - p46_targetCoverage(regi)) * p46_emi_refRun(t,regi) / sm_MtCO2_2_GtC !! offset countries that are not covered
    + p46_targetCoverage(regi) * p46_emi_refYr(regi) * cm_netZeroPercent !! allow covered countries to keep a certain % of their 2025 emissions
    + pm_emiLULUCF_GrassiShift("2020",regi) / sm_MtCO2_2_GtC; !! ensure that the land-use C02 emissions are in line with national accounting
);

display p46_emi_offset;


*' Calculate actual emissions for the target year (excluding bunker emissions)
*' Different calculations for CO2-only vs GHG targets
loop(netZeroTargets(regi,t,targetSpecies),
  p46_emi_targetYr(regi) =
*** for GHG targets
    (vm_co2eq.l(t,regi) / sm_MtCO2_2_GtC + vm_emiFgas.l(t,regi,"emiFgasTotal")) $ sameAs(targetSpecies,"GHG_target")
*** for CO2 targets
  + ((vm_emiTe.l(t,regi,"co2") + vm_emiMac.l(t,regi,"co2") + vm_emiCdr.l(t,regi,"co2")) / sm_MtCO2_2_GtC) $ sameAs(targetSpecies,"CO2_target")
*** subtract bunker emissions
  - sum(se2fe(enty,enty2,te),
      pm_emifac(t,regi,enty,enty2,te,"co2") * vm_demFeSector.l(t,regi,enty,enty2,"trans","other")) / sm_MtCO2_2_GtC;

*** ---------------------------------------------------------------------------  
*** ADAPTIVE LEARNING ALGORITHM  
*** ---------------------------------------------------------------------------  
*' Step 1: Error signal calculation - squared response for non-linear amplification
  p46_targetDeviation(regi) = (p46_emi_targetYr(regi) - p46_emi_offset(regi)) / p46_emi_refYr(regi);
  p46_factorRescaleCO2Tax(regi) = max(0.3, 1 + p46_targetDeviation(regi)) ** 2;

*' Step 2: Iteration-dependent damping - prevents oscillation, ensures convergence
*' Convex curve growing from 0.25 to 1 https://www.desmos.com/calculator/wkjp7mpmrp
  p46_iterDamping = 1 - 0.75 * 1.01 ** (-iteration.val); 

*' Step 3: Price decomposition - adjusts only markup (pm_taxCO2eqRegi), preserves base trajectory (pm_taxCO2eq)
*' Calculate markup adjustment factor by applying p46_factorRescaleCO2Tax to total tax, then isolating markup component 
*' Markup only applies after year cm_LTSstartYr (default 2040 to first meet 2035 NDC targets in NDC-LTS scenario, or 2035 to directly reach net-zero in scenario LTS).
  p46_taxCO2eqTotal(t,regi) = p46_taxCO2eqTotalLast(t,regi) * p46_factorRescaleCO2Tax(regi);

  pm_taxCO2eqRegi(t,regi) $ (t.val > %cm_LTSstartYr%) = max(
    p46_taxCO2eqTotal(t,regi) - pm_taxCO2eq(t,regi),
    p46_taxCO2eqRegiLast(t,regi) * p46_iterDamping
  );
);

); !! ord(iteration) > p46_startInIteration

display p46_emi_targetYr, p46_emi_refYr, p46_factorRescaleCO2Tax, pm_taxCO2eqRegi, p46_taxCO2eqRegiLast;

*** ---------------------------------------------------------------------------  
*** MEMORY AND TRACKING  
*** ---------------------------------------------------------------------------  
*' Store current prices for next iteration's learning algorithm   
*' Track evolution across iterations for debugging and analysis
p46_taxCO2eqRegiLast(t,regi)  = pm_taxCO2eqRegi(t,regi);
p46_taxCO2eqTotalLast(t,regi) = pm_taxCO2eqRegi(t,regi) + pm_taxCO2eq(t,regi);

loop(netZeroTargets(regi,t,targetSpecies),
  p46_taxCO2eqRegi_iter(iteration,t,regi) = pm_taxCO2eqRegi(t,regi);
  p46_taxCO2eq_iter(iteration,t,regi) = pm_taxCO2eq(t,regi);
  p46_emi_targetYr_iter(iteration,t,regi) = p46_emi_targetYr(regi);
);

*** EOF ./modules/46_carbonpriceRegi/netZero/postsolve.gms
