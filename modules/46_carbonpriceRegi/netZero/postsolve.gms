*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/46_carbonpriceRegi/netZero/postsolve.gms

if(sameAs("%carbonprice%","none"), p46_startInIteration = 1);
if(iteration.val > p46_startInIteration, !! let the carbon price stabilise over 10 iterations before adding regional markups

*** ---------------------------------------------------------------------------
*' #### 1. Calculating emissions
*** ---------------------------------------------------------------------------
*' Define reference emissions:
*'   - 2025 serves to normalise regional emissions and to allow for incomplete net-zero targets with `cm_netZeroPercent`
*'   - the baseline run indicates the emissions of countries without net-zero targets
 !! read from path_gdx_bau
  Execute_Loadpoint 'input_bau' p46_refRun_co2eq = vm_co2eq.l, p46_refRun_emiFgas = vm_emiFgas.l, p46_refRun_emiTe = vm_emiTe.l, p46_refRun_emiMac = vm_emiMac.l, p46_refRun_emiCdr = vm_emiCdr.l;

  loop((regi,t,targetSpecies) $ p46_netZeroTargetCoverage(regi,t,targetSpecies),
    if(sameAs(targetSpecies,"GHG_target"),
      p46_emi_targetYr(regi) =       vm_co2eq.l(t,regi) / sm_MtCO2_2_GtC +       vm_emiFgas.l(t,regi,"emiFgasTotal");
      p46_emi_refYr(regi)    =  vm_co2eq.l("2025",regi) / sm_MtCO2_2_GtC +  vm_emiFgas.l("2025",regi,"emiFgasTotal");
      p46_emi_refRun(regi)   = p46_refRun_co2eq(t,regi) / sm_MtCO2_2_GtC + p46_refRun_emiFgas(t,regi,"emiFgasTotal");
    elseif sameAs(targetSpecies,"CO2_target"),
      p46_emi_targetYr(regi) = (      vm_emiTe.l(t,regi,"co2") +       vm_emiMac.l(t,regi,"co2") +       vm_emiCdr.l(t,regi,"co2")) / sm_MtCO2_2_GtC;
      p46_emi_refYr(regi)    = ( vm_emiTe.l("2025",regi,"co2") +  vm_emiMac.l("2025",regi,"co2") +  vm_emiCdr.l("2025",regi,"co2")) / sm_MtCO2_2_GtC;
      p46_emi_refRun(regi)   = (p46_refRun_emiTe(t,regi,"co2") + p46_refRun_emiMac(t,regi,"co2") + p46_refRun_emiCdr(t,regi,"co2")) / sm_MtCO2_2_GtC;
    );
    
*' Define emission offset [MtCO2eq/yr], which are the emissions not covered by the target.
*' Offset represents the fact that not all countries, species and sectors are included in the net-zero target.
    p46_emi_offset(regi) =
        (1 - p46_netZeroTargetCoverage(regi,t,targetSpecies)) * p46_emi_refRun(regi) !! offset countries that are not covered
      + pm_emiLULUCF_GrassiShift("2020",regi) / sm_MtCO2_2_GtC !! ensure that the land-use C02 emissions are in line with national accounting
      + sum(se2fe(enty,enty2,te), !! bunker emissions are not included in any of the targets
          pm_emifac(t,regi,enty,enty2,te,"co2") * vm_demFeSector.l(t,regi,enty,enty2,"trans","other")) / sm_MtCO2_2_GtC;

*** ---------------------------------------------------------------------------  
*' #### 2. Calculating regional markup carbon tax
*** ---------------------------------------------------------------------------  
*' Step 1: Error signal calculation with tolerance share (cm_netZeroPercent) for squared price response
    p46_targetDeviation(regi) = (p46_emi_targetYr(regi) - p46_emi_offset(regi)) / p46_emi_refYr(regi) - cm_netZeroPercent;
    p46_factorRescaleCO2Tax(regi) = max(0.3, 1 + p46_targetDeviation(regi)) ** 2;
  );

*' Step 2: Iteration-dependent damping - prevents oscillation, ensures convergence
*' Concave curve growing from 0 at iteration 0 to 1 at cm_iteration_max https://www.desmos.com/calculator/ekpauw9fxx
  p46_iterDamping = 1 - (1 - iteration.val / cm_iteration_max) ** 2;

*' Step 3: Price decomposition - adjusts only markup (pm_taxCO2eqRegi), preserves base trajectory (pm_taxCO2eq and pm_taxCO2eqSCC).
*' Calculate markup adjustment factor by applying p46_factorRescaleCO2Tax to total tax, then isolating markup component.
*' Markup only applies after year cm_LTSstartYr (default 2040 to first meet 2035 NDC targets in NDC-LTS scenario, or 2035 to directly reach net-zero in scenario LTS).
  p46_taxCO2eqRegi_iter(iteration,t,regi) = 0; !! initialisation required for compilation
  pm_taxCO2eqRegi(t,regi) = max(
    pm_taxCO2eqSum(t,regi) * p46_factorRescaleCO2Tax(regi) - pm_taxCO2eq(t,regi) - pm_taxCO2eqSCC(t,regi),
    p46_taxCO2eqRegi_iter(iteration-1,t,regi) * p46_iterDamping
  );

  display p46_emi_offset, p46_emi_targetYr, p46_emi_refYr, p46_factorRescaleCO2Tax, pm_taxCO2eqRegi;
); !! iteration.val > p46_startInIteration

*** ---------------------------------------------------------------------------  
*' #### 3. Tracking across iterations
*** ---------------------------------------------------------------------------  
*' Store current prices for next iteration's learning algorithm   
*' Track evolution across iterations for debugging and analysis
loop((regi,t,targetSpecies) $ p46_netZeroTargetCoverage(regi,t,targetSpecies),
  p46_taxCO2eqRegi_iter(iteration,t,regi) = pm_taxCO2eqRegi(t,regi);
  p46_taxCO2eq_iter(iteration,t,regi) = pm_taxCO2eq(t,regi);
  p46_emi_targetYr_iter(iteration,t,regi) = p46_emi_targetYr(regi);
);

*** EOF ./modules/46_carbonpriceRegi/netZero/postsolve.gms
