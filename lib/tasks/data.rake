DATA_MIGRATION_SERVICES = [
  # do not delete or edit this line - services added below by generator
  'DataMigrations::BackfillInvalidProviderRelationshipPermissions',
  'DataMigrations::RemoveDuplicateProvider',
  'DataMigrations::BackfillReferencesCompleted',
  'DataMigrations::CleanseEocChasersSentData',
  'DataMigrations::BackfillSetupInterviewsPermission',
  'DataMigrations::FixEmptyOfferConditions',
  'DataMigrations::RemoveSurplusReferenceSelections',
  'DataMigrations::BackfillCandidateAPIUpdatedAt',
  'DataMigrations::BackfillNoneHesaDisabilitiesCodes',
  'DataMigrations::RemoveApplicationChoicesInTheIncorrectCycle',
  'DataMigrations::DeleteUuidlessCourses',
  'DataMigrations::RemovePreviousCyclesCoursesFromApplicationsInTheCurrentCycle',
  'DataMigrations::BackfillRestucturedWorkHistoryBoolean',
  'DataMigrations::BackfillValidationErrorsServiceColumn',
  'DataMigrations::BackfillSelectedBoolean',
  'DataMigrations::DeleteAllSiteAudits',
  'DataMigrations::RemoveIncorrectHesaCodes',
  'DataMigrations::SpecifyExportTypeForTADExports',
  'DataMigrations::SpecifyExportTypeForNotificationExports',
  'DataMigrations::FixMisspellingOfCaribbeanEthnicGroupAndSetHesaCodes',
  'DataMigrations::TrimQualificationDegreeTypes',
  'DataMigrations::BackfillExportType',
  'DataMigrations::FixLatLongFlipFlops',
].freeze

def data_migrations
  puts 'Running data migrations configured in lib/tasks/data.rake...'

  DATA_MIGRATION_SERVICES.each do |data_migration_service_name|
    DataMigrationRunner.new(data_migration_service_name).execute
  rescue StandardError => e
    STDOUT.puts "#{data_migration_service_name} skipped with error: #{e.message}"
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

      data_migration_runner = DataMigrationRunner.new(args[:service_name], manual: true)
      STDOUT.puts 'Hello! Who are you? This name will be used in the audit log for any changes you make.'
      user = STDIN.gets
      STDOUT.puts 'Type your audit comment or hit return to continue'
      comment = STDIN.gets

      data_migration_runner.execute(audit_user: user, audit_comment: comment)

    rescue StandardError => e
      STDOUT.puts "#{args[:service_name]} skipped with error: #{e.message}"
    end
  end
end

Rake::Task['db:migrate'].enhance do
  Rake::Task['data:migrate'].invoke
end
