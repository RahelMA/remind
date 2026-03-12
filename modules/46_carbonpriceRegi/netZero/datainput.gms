*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/46_carbonpriceRegi/netZero/datainput.gms

p46_zeroYear = 2200;

*** Define the maximale added carbon price at net zero, depending on the target year [$/tCO2 converted to T$/GtC]
p46_taxCO2eqRegiMax("2050") = 20 * sm_DptCO2_2_TDpGtC; 
p46_taxCO2eqRegiMax("2055") = 24 * sm_DptCO2_2_TDpGtC; 
p46_taxCO2eqRegiMax("2060") = 28 * sm_DptCO2_2_TDpGtC; 
p46_taxCO2eqRegiMax("2070") = 29 * sm_DptCO2_2_TDpGtC;

loop(netZeroTargets(regi,t,targetSpecies),
  pm_taxCO2eqRegi(t2,regi) $ (2030 < t2.val and t2.val <= t.val) = macro_interpolate(t2,2030,t,0,p46_taxCO2eqRegiMax(t));
  pm_taxCO2eqRegi(t2,regi) $ (t.val < t2.val) = macro_interpolate(t2,t,p46_zeroYear,p46_taxCO2eqRegiMax(t),0);
);

*** Coverage shares are calculated using PBL's Net-Zero Calculator based on https://zerotracker.net/
*** (methodology and more information at https://zerotracker.net/methodology) and further
*** adaptations based on Climate Action Tracker information, literature or expert opinion.
*** Net-zero claculator "ELEVATE T6.3 Scenario Protocol NDC and LTS information v3.xlsx"
*** The current protocol includes policies until March 2025 (see https://github.com/NewClimateInstitute/policy-modelling/issues/6#event-22523859766)
*** "The current CPDB is informed by the annual update cycle for 2025. It contains policies adopted up to and including March 2025." Luka (NCI)
p46_targetCoverage(regi) = 1;
p46_targetCoverage(regi) $ (sameAs(regi, "LAM")) = 0.83;
p46_targetCoverage(regi) $ (sameAs(regi, "MEA")) = 0.41;
p46_targetCoverage(regi) $ (sameAs(regi, "NEU")) = 0.80;
p46_targetCoverage(regi) $ (sameAs(regi, "OAS")) = 0.86;
p46_targetCoverage(regi) $ (sameAs(regi, "SSA")) = 0.56;
p46_targetCoverage(regi) $ (sameAs(regi, "REF")) = 0.87;


*** Parameter initialisation
p46_taxCO2eqRegiLast(t,regi)  = 0;
p46_taxCO2eqTotalLast(t,regi) = 0;

*** EOF ./modules/46_carbonpriceRegi/netZero/datainput.gms

