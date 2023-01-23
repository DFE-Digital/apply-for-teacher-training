cf_space = "bat-prod"
app_name = "apply-jmeter"
app_env_variables = {
  JMETER_TARGET_PLAN      = "apply"
  JMETER_THREAD_COUNT     = 200
  JMETER_RAMPUP           = 120
  JMETER_WAIT_FACTOR      = 1
  JMETER_TARGET_BASEURL   = "https://apply-loadtest.test.teacherservices.cloud"
  JMETER_TARGET_APP       = "apply-loadtest"
  JMETER_TARGET_APP_SPACE = "bat-prod"
}
