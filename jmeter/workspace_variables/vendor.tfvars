cf_space = "bat-prod"
app_name = "apply-vendor-jmeter"
app_env_variables = {
  JMETER_TARGET_PLAN      = "vendor"
  JMETER_THREAD_COUNT     = 2
  JMETER_RAMPUP           = 120
  JMETER_WAIT_FACTOR      = 1
  JMETER_TARGET_BASEURL   = "https://apply-loadtest.test.teacherservices.cloud"
  JMETER_TARGET_APP       = "apply-loadtest"
  JMETER_TARGET_APP_SPACE = "bat-prod"
  API_VERSION             = "v1.1"
}
