cf_space = "bat-prod"
app_name = "find-jmeter"
app_env_variables = {
  JMETER_TARGET_PLAN      = "find"
  JMETER_THREAD_COUNT     = 100
  JMETER_RAMPUP           = 180
  JMETER_WAIT_FACTOR      = 1
  JMETER_TARGET_BASEURL   = "https://find-loadtest.london.cloudapps.digital"
  JMETER_TARGET_APP       = "find-loadtest"
  JMETER_TARGET_APP_SPACE = "bat-prod"
}
