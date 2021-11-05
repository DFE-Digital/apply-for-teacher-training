cf_space = "bat-prod"
app_name = "apply-vendor-jmeter"
app_env_variables = {
  JMETER_TARGET_PLAN      = "vendor"
  JMETER_THREAD_COUNT     = 200
  JMETER_RAMPUP           = 120
  JMETER_WAIT_FACTOR      = 1
  JMETER_TARGET_BASEURL   = "https://apply-load-test.london.cloudapps.digital"
  JMETER_TARGET_APP       = "apply-load-test"
  JMETER_TARGET_APP_SPACE = "bat-prod"
}
