cf_space = "bat-prod"
app_name = "apply-manage-jmeter"
app_env_variables = {
  JMETER_TARGET_PLAN      = "manage"
  JMETER_THREAD_CONFIG    = "30,30,30,30,30,30"
  JMETER_RAMPUP           = 120
  JMETER_WAIT_FACTOR      = 1
  JMETER_TARGET_BASEURL   = "https://apply-loadtest.test.teacherservices.cloud"
  JMETER_TARGET_APP       = "apply-loadtest"
  JMETER_TARGET_APP_SPACE = "bat-prod"
}
