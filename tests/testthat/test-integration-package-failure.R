test_that("integration test: package failure", {
  cli::cat_boxx("integration test: package failure")

  package_path <- tempfile("ticpkg", fileext = "pkg")

  cat("\n")
  git2r::clone("https://github.com/pat-s/oddsratio.git", package_path)
  withr::with_envvar(c("R_USER_CACHE_DIR" = tempfile()), {
    withr::with_dir(
      package_path,
      { # nolint
        writeLines("do_package_checks()", "tic.R")
        writeLines("^tic\\.R$", ".Rbuildignore")
        dir.create("tests")
        writeLines('stop("Check failure!")', "tests/test.R")
        expect_error(
          callr::r(
            function() {
              tic::run_all_stages()
            },
            show = TRUE,
            env = c(callr::rcmd_safe_env(), TIC_LOCAL = "true")
          ),
          'A step failed in stage "script"'
        )
      }
    )
  })
})
