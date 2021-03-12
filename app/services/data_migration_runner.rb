# This service is used by the data migration rake task found in `lib/tasks/data.rake`
# Read more in `docs/data-migrations.md`

class DataMigrationRunner
  class MigrationAlreadyRanError < StandardError
    def message
      'The migration has already been executed'
    end
  end

  class ManualRanOnlyError < StandardError
    def message
      'The migration only allows for manual execution. Run rake -T to find out how to run it manually.'
    end
  end

  class AutomatedRanOnlyError < StandardError
    def message
      'The migration only allows for automated execution.'
    end
  end

  attr_reader :service, :manual

  def initialize(service_name, manual: false)
    @service = Object.const_get(service_name)
    @manual = manual

    raise ManualRanOnlyError if service::MANUAL_RUN && !manual
    raise AutomatedRanOnlyError if !service::MANUAL_RUN && manual
    raise MigrationAlreadyRanError if migration_ran?
  end

  def execute(audit_user: 'system', audit_comment: nil)
    Rails.logger.info("Executing #{service}...")
    ActiveRecord::Base.transaction do
      log_migration(audit_user: audit_user, audit_comment: audit_comment)
      service.new.change
    end
    Rails.logger.info("#{service}##{service::TIMESTAMP} data migration completed successfully")
  end

private

  def migration_ran?
    DataMigration.exists?(service_name: service.to_s, timestamp: service::TIMESTAMP)
  end

  def log_migration(audit_user: 'system', audit_comment: nil)
    data = { service_name: service.to_s, timestamp: service::TIMESTAMP }
    data.merge!(audit_comment: audit_comment) if audit_comment

    Audited.audit_class.as_user(audit_user) do
      DataMigration.create(data)
    end
  end
end
