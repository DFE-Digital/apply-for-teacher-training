DATA_MIGRATION_SERVICES = [
  # do not delete or edit this line - services added below by generator
  'DataMigrations::DeleteAllOldAudits',
  'DataMigrations::CorrectHesaEthnicity',
  'DataMigrations::BackfillWithdrawalReasons',
  'DataMigrations::RemoveTeacherDegreeApprenticeshipFeatureFlag',
  'DataMigrations::BackfillApplicationChoicesWithWorkExperiences',
  'DataMigrations::MarkUnsubmittedApplicationsWithoutEnglishProficiencyAsElfIncomplete',
  'DataMigrations::BackfillEnglishProficiencyRecordsForCarriedOverApplications',
  'DataMigrations::BackfillWeek42PerformanceReportData',
  'DataMigrations::RemoveRecruitmentPerformanceReportFeatureFlag',
  'DataMigrations::MigrateDataExportDataToFile',
  'DataMigrations::RemoveCoursesNotOnPublish',
  'DataMigrations::RemoveIncidentEvictionFeatureFlag',
  'DataMigrations::RemoveCourseHasVacanciesFeatureFlag',
  'DataMigrations::IncorrectEqualityAndDiversityMigration',
  'DataMigrations::SetInstitutionCountryToGbOnUkDegrees',
  'DataMigrations::RemoveSupportUserReinstateOfferFeatureFlag',
  'DataMigrations::RemoveSupportUserRevertWithdrawnOfferFeatureFlag',
  'DataMigrations::RemoveWithdrawAtCandidatesRequestFeatureFlag',
  'DataMigrations::RemoveProviderActivityLogFeatureFlag',
  'DataMigrations::RemoveUnconditionalOffersViaAPIFeatureFlag',
  'DataMigrations::RemoveFeedbackHelpfulFeatureFlag',
  'DataMigrations::RemoveOnePersonalStatementFeatureFlag',
  'DataMigrations::SetMissingWorkHistoryStatusValues',
  'DataMigrations::RemoveRecruitWithPendingConditionsFeatureFlag',
  'DataMigrations::BackfillFeedbackFormComplete',
  'DataMigrations::RemoveMidCycleReportFeatureFlag',
  'DataMigrations::BackfillEqualityAndDiversityCompletedAttributes',
  'DataMigrations::RemoveMidCycleReportsFeatureFlag',
  'DataMigrations::RemoveProviderReportsFeatureFlag',
  'DataMigrations::RemoveSkeFeatureFlag',
  'DataMigrations::StoreEnumForSkeReason',
  'DataMigrations::SetMissingSectionCompletedAtTimestamps',
  'DataMigrations::PopulateSectionCompletedAts',
  'DataMigrations::BackfillSandboxCourseUuids',
  'DataMigrations::RemoveReferencesProviderFeatureFlag',
  'DataMigrations::RemoveCandidateReferenceFlowFeatureFlag',
  'DataMigrations::RemoveNewDegreeFlowFeatureFlag',
  'DataMigrations::RemoveLockExternalReportFeatureFlag',
  'DataMigrations::ProviderInterviewDataFix',
  'DataMigrations::RemoveDataExportsFeatureFlag',
  'DataMigrations::BackfillSitesFromTempSites',
  'DataMigrations::DestroyOrphanedSites',
  'DataMigrations::RemoveExportApplicationDataFeatureFlag',
  'DataMigrations::RemoveSummerRecruitmentBannerFeatureFlag',
  'DataMigrations::ChangeEnglishNationalityData',
  'DataMigrations::BackfillQualificationLevel',
  'DataMigrations::BackfillInternationalDegreesSubjectsUuid',
  'DataMigrations::DeleteRetiredNudgeFeatureFlags',
  'DataMigrations::RemoveStructuredReasonsForRejectionRedesignFeatureFlag',
  'DataMigrations::RemoveApplicationNumberReplacementFeatureFlag',
  'DataMigrations::BackfillOriginalCourseOption',
  'DataMigrations::BackfillRejectionReasonsTypeField',
  'DataMigrations::DropExpandedQualsExportFeatureFlag',
  'DataMigrations::DropImmigrationEntryDateFeatureFlag',
  'DataMigrations::DropRestructuredImmigrationStatusFeatureFlag',
  'DataMigrations::MakeDecisionReminderNotificationSettingFeatureFlag',
  'DataMigrations::BackfillDegreesNewData',
  'DataMigrations::BackfillWithdrawnOrDeclinedForCandidateByProvider',
  'DataMigrations::BackfillUserColumnsOnNotes',
  'DataMigrations::RemoveDuplicateProvider',
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
