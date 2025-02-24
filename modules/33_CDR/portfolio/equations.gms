*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/portfolio/equations.gms

*' @equations
***---------------------------------------------------------------------------
*' #### Equations concerning two or more options

***---------------------------------------------------------------------------
*'  CDR Final Energy Balance
***---------------------------------------------------------------------------
q33_demFeCDR(t,regi,entyFe)$(entyFe2Sector(entyFe,"cdr"))..
    sum(fe2cdr(entyFe,entyFe2,te_used33),
        v33_FEdemand(t,regi,entyFe,entyFe2,te_used33)
    )
    =e=
    sum((entySe,te)$se2fe(entySe,entyFe,te),
        vm_demFeSector_afterTax(t,regi,entySe,entyFe,"cdr","ETS")
    )
    ;

***---------------------------------------------------------------------------
*'  Sum of all CDR emissions other than BECCS and afforestation, which are calculated in the core.
*'  The negative emissions are discounted by emissions that are released due to <100 percent capture
*'  rate, as they are unavoidable (1-s33_capture_rate of the emissions that are possible to capture).
*'  Note that this includes all atmospheric CO2 captured in this module that enters the CCUS chain.
***---------------------------------------------------------------------------
q33_emiCDR(t,regi)..
    vm_emiCdr(t,regi,"co2")
    =e=
    sum(te_used33, vm_emiCdrTeDetail(t,regi,te_used33))
    + (1 - s33_capture_rate) * (
        sum(te_ccs33, v33_co2emi_non_atm_gas(t, regi, te_ccs33))
        + sum(te_oae33, v33_co2emi_non_atm_calcination(t, regi, te_oae33))
    )
    ;

***---------------------------------------------------------------------------
*'  Calculation of gross (negative) CO2 emissions from capacity.
*'  Negative emissions from enhanced weathering also result from decaying rock
*'  spread in previous timesteps, so emissions do not equal to the capacity
*'  (i.e., how much rock is spread in a given timestep).
***---------------------------------------------------------------------------
q33_capconst(t, regi, te_used33)$(not sameAs(te_used33, "weathering"))..
    vm_emiCdrTeDetail(t, regi, te_used33)
    =e=
    - sum(teNoTransform2rlf33(te_used33, rlf),
        vm_capFac(t, regi, te_used33) * vm_cap(t, regi, te_used33, rlf)
    )
    ;

***---------------------------------------------------------------------------
*'  The CO2 captured from gas used for heat production (DAC, OAE).
***---------------------------------------------------------------------------
q33_co2emi_non_atm_gas(t, regi, te_ccs33)..
    v33_co2emi_non_atm_gas(t, regi, te_ccs33)
    =e=
    fm_dataemiglob("pegas","seh2","gash2c","cco2") !! conversion from PE to emissions
        * (1 / pm_eta_conv(t,regi,"gash2c")) !! conversion from PE to FE
        * sum(fe2cdr("fegas", entyFe2, te_ccs33), v33_FEdemand(t, regi,"fegas", entyFe2, te_ccs33)) !! FE gas used
    ;

***---------------------------------------------------------------------------
*'  Preparation of captured emissions to enter the CCUS chain.
*'  The first part of the equation describes emissons captured from the ambient air,
*'  the second part is non-atmospheric CO2 (e.g., from energy usage and calcination),
*'  assuming a capture rate s33_capture_rate.
***---------------------------------------------------------------------------
q33_ccsbal(t, regi, ccs2te(ccsCo2(enty), enty2, te))..
    sum(teCCS2rlf(te, rlf), vm_co2capture_cdr(t, regi, enty, enty2, te, rlf))
    =e=
    - vm_emiCdrTeDetail(t, regi, "dac")
    + s33_capture_rate * (
        sum(te_ccs33, v33_co2emi_non_atm_gas(t, regi, te_ccs33))
        + sum(te_oae33, v33_co2emi_non_atm_calcination(t, regi, te_oae33))
    )
    ;

***---------------------------------------------------------------------------
*'  Limit the amount of H2 from biomass to the demand without CDR.
*'  It's a sustainability bound to prevent a large demand for biomass.
***---------------------------------------------------------------------------
q33_H2bio_lim(t,regi)..
    sum(pe2se("pebiolc","seh2",te), vm_prodSE(t,regi,"pebiolc","seh2",te))
    =l=
    vm_prodFe(t,regi,"seh2","feh2s","tdh2s")
    - sum(fe2cdr("feh2s",entyFe2,te_used33), v33_FEdemand(t,regi,"feh2s",entyFe2,te_used33))
    ;

***---------------------------------------------------------------------------
*' #### DAC equations

***---------------------------------------------------------------------------
*'  Calculation of FE demand for DAC, i.e., electricity demand for ventilation,
*'  and heat demand.
***---------------------------------------------------------------------------
q33_DAC_FEdemand(t,regi,entyFe2)$sum(entyFe, fe2cdr(entyFe,entyFe2,"dac"))..
    sum(fe2cdr(entyFe,entyFe2,"dac"), v33_FEdemand(t,regi,entyFe,entyFe2,"dac"))
    =e=
    p33_fedem("dac", entyFe2) * sm_EJ_2_TWa * (- vm_emiCdrTeDetail(t,regi,"dac"))
    ;

***---------------------------------------------------------------------------
*' #### EW equations

***---------------------------------------------------------------------------
*'  Calculation of the amount of ground rock spread in timestep t.
***---------------------------------------------------------------------------
q33_EW_capconst(t,regi)..
    sum((rlf_cz33, rlf), v33_EW_onfield(t,regi,rlf_cz33,rlf))
    =e=
    sum(teNoTransform2rlf33("weathering",rlf),
        vm_capFac(t,regi,"weathering") * vm_cap(t,regi,"weathering",rlf)
    )
    ;

***---------------------------------------------------------------------------
*'  Calculation of the total amount of ground rock on the fields in timestep t.
*'  The first part of the equation describes the decay of the rocks added until that time,
*'  the rest describes the newly added rocks.
*'  The amounts already on or newly spread on the fields are multiplied with the total fraction 
*'  remaining for the next time step, i.e. the fraction not weathering in the time step years. 
*'  This fraction is generally calculated as (1-p33_rock_weath_rate)**(time_step_years).
*'  For better solver solution, it is rewritten according to a**b = exp(log(a)*b) as
*'  exp(log(1-p33_rock_weath_rate) * time_step_years).

***---------------------------------------------------------------------------
q33_EW_onfield_tot(ttot,regi,rlf_cz33,rlf)$(ttot.val ge max(2025, cm_startyear))..
    v33_EW_onfield_tot(ttot,regi,rlf_cz33,rlf)
    =e=
    v33_EW_onfield_tot(ttot-1,regi,rlf_cz33,rlf) * exp(log(1-p33_rock_weath_rate(rlf_cz33)) * pm_ts(ttot))
    + v33_EW_onfield(ttot-1,regi,rlf_cz33,rlf) * (
        sum(tall$(tall.val le (ttot.val - pm_ts(ttot)/2) and tall.val gt (ttot.val - pm_ts(ttot))),
            exp(log(1-p33_rock_weath_rate(rlf_cz33)) * (ttot.val - tall.val)))
        )
    + v33_EW_onfield(ttot,regi,rlf_cz33,rlf) * (
        sum(tall$(tall.val le ttot.val and tall.val gt (ttot.val - pm_ts(ttot)/2)),
            exp(log(1-p33_rock_weath_rate(rlf_cz33)) * (ttot.val-tall.val)))
    )
;

***---------------------------------------------------------------------------
*'  Calculation of (negative) CO2 emissions from enhanced weathering.
***---------------------------------------------------------------------------
q33_EW_emi(t,regi)..
    vm_emiCdrTeDetail(t,regi, "weathering")
    =e=
    sum((rlf_cz33, rlf),
        - v33_EW_onfield_tot(t,regi,rlf_cz33,rlf) * s33_co2_rem_pot * p33_rock_weath_rate(rlf_cz33)
        )
    ;

***---------------------------------------------------------------------------
*'  Calculation of FE demand for enhanced weathering, i.e., electricity demand for grinding,
*'  and the diesel demand for transportation and spreading on crop fields.
***---------------------------------------------------------------------------
q33_EW_FEdemand(t,regi,entyFe2)$sum(entyFe, fe2cdr(entyFe,entyFe2,"weathering"))..
    sum(fe2cdr(entyFe,entyFe2,"weathering"), v33_FEdemand(t,regi,entyFe,entyFe2,"weathering"))
    =e=
    p33_fedem("weathering",entyFe2) * sm_EJ_2_TWa * sum((rlf_cz33, rlf), v33_EW_onfield(t,regi,rlf_cz33,rlf))
    ;

***---------------------------------------------------------------------------
*'  O&M costs of EW, consisting of fix costs for mining, grinding and spreading, and transportation costs.
***---------------------------------------------------------------------------
q33_EW_omcosts(t,regi)..
    vm_omcosts_cdr(t,regi)
    =e=
    sum((rlf_cz33, rlf),
        (s33_costs_fix + p33_EW_transport_costs(regi,rlf_cz33,rlf)) * v33_EW_onfield(t,regi,rlf_cz33,rlf)
    )
    ;

***---------------------------------------------------------------------------
*'  Limit total amount of ground rock on the fields to regional maximum potentials.
***---------------------------------------------------------------------------
q33_EW_potential(t,regi,rlf_cz33)..
    sum(rlf, v33_EW_onfield_tot(t,regi,rlf_cz33,rlf))
    =l=
    p33_EW_maxShareOfCropland(regi) * f33_maxProdGradeRegiWeathering(regi,rlf_cz33)
    ;


***---------------------------------------------------------------------------
*'  An annual limit for the maximum global amount of rocks spread [Gt] can be set via cm_LimRock,
*'  e.g. due to sustainability concerns.
***---------------------------------------------------------------------------
q33_EW_LimEmi(t,regi)..
    sum((rlf_cz33, rlf), v33_EW_onfield(t,regi,rlf_cz33,rlf))
    =l=
    cm_LimRock * p33_LimRock(regi)
    ;

***---------------------------------------------------------------------------
*' Short term bound on spreading of rock
***---------------------------------------------------------------------------

q33_EW_ShortTermBound(t, regi)$(t.val eq 2030)..
    sum((rlf_cz33, rlf), v33_EW_onfield(t,regi,rlf_cz33,rlf))
    =l=
    p33_EW_shortTermEW_Limit(regi) 
    ;

***---------------------------------------------------------------------------
*' Limits on the upscaling rate of mining and spreading of rocks. 
*' Current cost parameters do not include cost of additional mining being developed, 
*' thus adjustment cost are not effective.
***---------------------------------------------------------------------------	
q33_EW_upscaling_rate(ttot,regi)$(ord(ttot) lt card(ttot) AND pm_ttot_val(ttot) gt 2030)..
   sum((rlf_cz33, rlf), v33_EW_onfield(ttot,regi,rlf_cz33,rlf))
    =l=
   (1+p33_EW_upScalingLimit(ttot))**pm_dt(ttot) * sum((rlf_cz33, rlf), v33_EW_onfield(ttot-1,regi,rlf_cz33,rlf)) + p33_EW_shortTermEW_Limit(regi)
;

***---------------------------------------------------------------------------
*' #### OAE equations

***---------------------------------------------------------------------------
*'  Calculation of FE demand for OAE, i.e., electricity for rock preprocessing,
*'  and heat for calcination.
***---------------------------------------------------------------------------
q33_OAE_FEdemand(t,regi,entyFe2,te_oae33)$sum(entyFe, fe2cdr(entyFe,entyFe2,te_oae33))..
    sum(fe2cdr(entyFe, entyFe2, te_oae33), v33_FEdemand(t, regi, entyFe, entyFe2, te_oae33))
    =e=
    p33_fedem(te_oae33, entyFe2) * sm_EJ_2_TWa * (- vm_emiCdrTeDetail(t, regi, te_oae33))
    ;

***---------------------------------------------------------------------------
*'  The CO2 captured from limestone decomposition (OAE technologies only).
***---------------------------------------------------------------------------
q33_OAE_co2emi_non_atm_calcination(t, regi, te_oae33)..
    v33_co2emi_non_atm_calcination(t, regi, te_oae33)
    =e=
    - s33_OAE_chem_decomposition * vm_emiCdrTeDetail(t, regi, te_oae33)
    ;

***---------------------------------------------------------------------------
*'  Limit OAE by region based on the regions' share of the exclusive economic zone.
*'  There are still many uncertainties about whether OAE would more likely be done
*'  outside or inside EEZ. The equation is thus deactivated by default. 
*'  Arguments in favor of OAE being done in EEZ, which can justify the distribution by EEZ
*'  in case the cost-efficient allocation via cm_implicitQttyTrgt is not feasible: 
*'  1. Tides lead to better mixing of the waters, thus more contact of the more alkaline 
*'       surface waters with the atmosphere, leading to an expected higher CO2 uptake efficiency.
*'  2. The generally lower water depth compared to the high seas helps OAE efficiency as the more alkaline 
*'       surface waters don't sink to the deep oceans as quickly/ easily.
*'  3. Legal situation: likely easier to create a legal framework for EEZs than high seas, 
*'       where a significantly larger number of countries would need to agree
*'  Potential issues to consider:
*'  1. available EEZ-area is limited through other uses (fishing, offshore wind, marine protection etc.). 
*'       Esp. marine protected areas are uncertain, as they are supposed to cover 30% of lgobal oceans by 2030 and are
*'       currently mainly in EEZ areas. Some could, however, also be primary target for OAE, e.g. with ecosystems 
*'       susceptible to ocean acidification like coral reefs.
*'  2. Sufficiency of available area: depending on deployment depth and time-scales until the new equilibrium is reached,
*'      the total EEZ area may not suffice for chosen uptake targets. At the default uptake efficiency of
*'      1.2 tCO2/tCaO, 5 GtCO2 ocean uptake/yr corresponds ~ to distribution of CaO once a year
*'      on the entire EEZ area at 2m depth.
*'  3. Uptake efficiency differs by local conditions, and high-efficiency areas may lie outside EEZ areas.
***---------------------------------------------------------------------------
q33_OAE_EEZ_limit(t,regi)..
    -p33_oae_eez_limit(regi) 
    =l= 
    sum(te_oae33,
        vm_emiCdrTeDetail(t,regi, te_oae33))
;

*' @stop
*** EOF ./modules/33_CDR/portfolio/equations.gms
