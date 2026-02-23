# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

test_that("ensureLocalCalibrationSetup calls setup script when calibration_results/ is absent", {
  withr::with_tempdir({
    remind_folder <- getwd()
    called <- FALSE
    # Mock callSetLocalCalibration so no shell script is run
    local_mocked_bindings(
      callSetLocalCalibration = function(folder) { called <<- TRUE; 0L },
      .env = globalenv()
    )
    ensureLocalCalibrationSetup(remind_folder)
    expect_true(called, label = "callSetLocalCalibration should be invoked when calibration_results/ is absent")
  })
})

test_that("ensureLocalCalibrationSetup skips setup script when calibration_results/ already exists", {
  withr::with_tempdir({
    remind_folder <- getwd()
    dir.create(file.path(remind_folder, "calibration_results"))
    called <- FALSE
    local_mocked_bindings(
      callSetLocalCalibration = function(folder) { called <<- TRUE; 0L },
      .env = globalenv()
    )
    ensureLocalCalibrationSetup(remind_folder)
    expect_false(called, label = "callSetLocalCalibration should NOT be invoked when calibration_results/ exists")
  })
})

test_that("ensureLocalCalibrationSetup stops on non-zero exit code from setup script", {
  withr::with_tempdir({
    remind_folder <- getwd()
    local_mocked_bindings(
      callSetLocalCalibration = function(folder) 1L,
      .env = globalenv()
    )
    expect_error(
      ensureLocalCalibrationSetup(remind_folder),
      regexp = "make set-local-calibration"
    )
  })
})
