DATA_MIGRATION_SERVICES = [
  # do not delete or edit this line - services added below by generator
].freeze

def data_migrations
  puts 'Running data migrations configured in lib/tasks/data.rake...'

  DATA_MIGRATION_SERVICES.each do |data_migration_service_name|
    service = Object.const_get(data_migration_service_name)

    next if service::MANUAL_RUN || migration_ran?(service)

    puts "Executing #{service}..."
    ActiveRecord::Base.transaction do
      log_migration(service)
      service.new.change
    end
    puts "#{service}##{service::TIMESTAMP} data migration completed successfully"
  end
end

def migration_ran?(service)
  DataMigration.exists?(service_name: service.to_s, timestamp: service::TIMESTAMP)
end

def log_migration(service, audit_user: 'system', audit_comment: nil)
  data = { service_name: service.to_s,
           timestamp: service::TIMESTAMP }
  data.merge!(audit_comment: audit_comment) if audit_comment

  Audited.audit_class.as_user(audit_user) do
    DataMigration.create(data)
  end
end

namespace :data do
  desc 'Executes all pending data migrations'
  task migrate: :environment do
    at_exit { data_migrations }
  end

  namespace :migrate do
    desc "Executes specified migration if it's pending"
    task :manual, [:service_name] => :environment do |_, args|
      abort('You must specify a migration service e.g. rake data:migrate:manual[DataMigrations::UpdateApplicationChoiceData]') if args[:service_name].blank?
      service = Object.const_get(args[:service_name])
      abort('Migration already executed') if migration_ran?(service)

      STDOUT.puts 'Hello! Who are you? This name will be used in the audit log for any changes you make.'
      user = STDIN.gets.strip
      STDOUT.puts 'Type your audit comment or hit return to continue'
      audit_comment = STDIN.gets.strip

      puts "Executing #{service}..."
      ActiveRecord::Base.transaction do
        log_migration(service, audit_user: user, audit_comment: audit_comment)
        service.new.change
      end
      puts "#{service}##{service::TIMESTAMP} data migration completed successfully"

    rescue StandardError => e
      abort("Something went wrong and the migration was not executed: #{e}")
    end
  end
end

Rake::Task['db:migrate'].enhance do
  Rake::Task['data:migrate'].invoke
end
