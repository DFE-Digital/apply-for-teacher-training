desc 'Reset the database to a state with some standard providers and test applications. Preserves existing support users'
task reset_qa: :environment do
  raise 'Not permitted on this environment' unless HostingEnvironment.generate_test_data?

  Rake::Task['_reset_qa'].invoke
end

task _reset_qa: %i[
  environment
  truncate_qa_database_retaining_support_users
  sync_timetables
  sync_dev_providers
  generate_test_applications
  run_end_of_cycle_jobs
]

task truncate_qa_database_retaining_support_users: :environment do
  raise 'Not permitted on this environment' unless HostingEnvironment.generate_test_data?

  support_user_data = SupportUser.pluck(:email_address, :dfe_sign_in_uid)

  ActiveRecord::Tasks::DatabaseTasks.truncate_all
  puts 'Truncated database'

  support_user_data.each do |(email, uid)|
    SupportUser.find_or_create_by(email_address: email, dfe_sign_in_uid: uid)
  end
  puts 'Support users restored'
end

task sync_timetables: :environment do
  SeedTimetablesService.seed_from_csv
  puts 'Timetables synced with production'
end

task :run_end_of_cycle_jobs, :environment do
  raise 'Not permitted on this environment' unless HostingEnvironment.generate_test_data?

  EndOfCycle::RunEndOfCycleJobsWorker.perform_async
  puts 'Running all relevant end of cycle jobs based on the current point in the cycle'
end
