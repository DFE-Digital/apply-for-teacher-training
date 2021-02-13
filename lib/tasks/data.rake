DATA_MIGRATION_SERVICES = [
  # do not delete or edit this line - services added below by generator
].freeze

def data_migrations
  puts 'Running data migrations configured in lib/tasks/data.rake...'

  DATA_MIGRATION_SERVICES.each do |data_migration|
  end
end

namespace :data do
  desc 'Migrates data'
  task migrate: :environment do
    at_exit { data_migrations }
  end
end

Rake::Task['db:migrate'].enhance do
  Rake::Task['data:migrate'].invoke
end
