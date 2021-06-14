desc 'Reset the database to a state with some standard providers and test applications. Preserves existing support users'
task reset_qa: :environment do
  raise 'Not permitted on this environment' unless HostingEnvironment.generate_test_data?

  Rake::Task['_reset_qa'].invoke
end

task _reset_qa: %i[
  environment
  backup_support_users
  truncate_qa_database
  restore_support_users
  sync_dev_providers_and_open_courses
  generate_test_applications
]

task truncate_qa_database: :environment do
  raise 'Not permitted on this environment' unless HostingEnvironment.generate_test_data?

  ActiveRecord::Tasks::DatabaseTasks.truncate_all
  puts 'Truncated database'
end

task backup_support_users: :environment do
  backed_up_count = BackupAndRestoreSupportUsers.backup!
  puts "Backed up #{backed_up_count} support users"
end

task restore_support_users: :environment do
  restored_count = BackupAndRestoreSupportUsers.restore!
  puts "Restored #{restored_count} support users"
end
