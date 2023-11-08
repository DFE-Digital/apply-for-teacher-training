Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    # should be VendorAPIUser, maintained for backwards compat with the audit log
    'vendor_api_user' => 'VendorApiUser',
    'itt_monthly_report' => 'ITTMonthlyReport',
    'itt_monthly_report_generator' => 'ITTMonthlyReportGenerator',
  )
  autoloader.collapse('app/components/shared')
  autoloader.collapse('app/components/utility')
end
