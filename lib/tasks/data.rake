def data_migrations
  puts 'Running data migrations configured in lib/tasks/data.rake...'
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
