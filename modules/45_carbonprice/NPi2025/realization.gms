*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NPi2025/realization.gms

*' @description: This realization takes the carbon prices until 2025 from the input data (for EUR until 2030) and implements a linear growth up to 20US until 2100 afterwards

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "datainput" $include "./modules/45_carbonprice/NPi2025/datainput.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/45_carbonprice/NPi2025/realization.gms
