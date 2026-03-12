*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/46_carbonpriceRegi/netZero/declarations.gms

Parameter 
p46_emi_targetYr(all_regi)                          "greenhouse gas or CO2 emissions in target year [MtCO2eq/yr]"
p46_emi_targetYr_iter(iteration,ttot,all_regi)      "Track the changes of p46_emi_targetYr over the iterations [MtCO2eq/yr]"
p46_emi_offset(all_regi)                            "allowed emissions in net-zero year [MtCO2eq/yr]"
p46_emi_refYr(all_regi)                             "2025 reference emissions value for normalization of deviation from zero [MtCO2eq/yr]"
p46_emi_refRun(ttot,all_regi)                       "emissions in reference run"
p46_taxCO2eqRegiLast(tall,all_regi)                 "Additional markup carbon price to reach net-zero target in last iteration [T$/GtC]"
p46_taxCO2eqTotal(ttot,all_regi)                    "Total CO2 price including general trajectory and regional markup [T$/GtC]"
p46_taxCO2eqTotalLast(ttot,all_regi)                "Total CO2 price including general trajectory and regional markup in last iteration [T$/GtC]"
p46_targetDeviation(all_regi)                       "Deviation from net-zero target rescaled to reference emission [1]"
p46_factorRescaleCO2Tax(all_regi)                   "Required change of overall tax rate to assure net-zero emission [1]"
p46_iterDamping	                                    "Lower bound on the price rescaling to avoid oscillations and favour convergence"
p46_taxCO2eq_iter(iteration,ttot,all_regi)          "CO2eq tax non-regi tracked over iterations [T$/GtC]"
p46_taxCO2eqRegi_iter(iteration,ttot,all_regi)      "CO2eq tax regi tracked over iterations [T$/GtC]"
pm_taxCO2eqRegi(ttot,all_regi)                      "Additional regional CO2 tax path calulated in in 46_carbonpriceRegi module to reach regional emissions targets [T$/GtC]. To get $/tCO2, multiply with 272 = 1 / sm_DptCO2_2_TDpGtC"
p46_taxCO2eqRegiMax(ttot)                           "Maximum value of the additional regional CO2 tax, depending on the date of the net zero target [T$/GtC]. To get $/tCO2, multiply with 272 = 1 / sm_DptCO2_2_TDpGtC"
pm_taxCO2eqSum(ttot,all_regi)                       "sum of pm_taxCO2eq, pm_taxCO2eqRegi, pm_taxCO2eqSCC [T$/GtC]. To get $/tCO2, multiply with 272 = 1 / sm_DptCO2_2_TDpGtC"
p46_targetCoverage(all_regi)                        "Share of the region that is covered by a net-zero target [1]"
;

Scalar  
p46_zeroYear                                       "Year at which pm_taxCO2eqRegi drops to zero after having decreased linearly since the net-zero year [year]"
p46_startInIteration                               "first iteration to start adapting pm_taxCO2eqRegi [1]" / 10 /
;

*** EOF ./modules/46_carbonpriceRegi/netZero/declarations.gms


