require 'load_test'

desc 'Set up the Apply load test application with data from the Teacher training public API'
task setup_load_test_app_data: :environment do
  Rails.logger.info 'Syncing data from TTAPI...'

  LoadTest::PROVIDER_CODES.each do |code|
    provider_from_api = TeacherTrainingPublicAPI::Provider
        .where(year: RecruitmentCycle.current_year)
        .find(code).first

    TeacherTrainingPublicAPI::SyncSubjects.new.perform

    TeacherTrainingPublicAPI::SyncProvider.new(
      provider_from_api: provider_from_api, recruitment_cycle_year: RecruitmentCycle.previous_year,
    ).call(run_in_background: false)

    Provider.find_by(code: code).courses.previous_cycle.exposed_in_find.update_all(open_on_apply: true, opened_on_apply_at: Time.zone.now)

    TeacherTrainingPublicAPI::SyncProvider.new(
      provider_from_api: provider_from_api, recruitment_cycle_year: RecruitmentCycle.current_year,
    ).call(run_in_background: false)

  rescue JsonApiClient::Errors::NotFound
    Rails.logger.warn "Could not find Provider for code #{code}. Skipping."
  end
end
