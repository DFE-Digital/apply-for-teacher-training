desc 'Set up your local development environment with data from the Teacher training public API'
task setup_local_dev_data: %i[environment copy_feature_flags_from_production sync_dev_providers_and_open_courses update_vendors] do
  puts 'Creating a support & provider user with DfE Sign-in UID `dev-support` and email `support@example.com`...'
  SupportUser.create!(
    dfe_sign_in_uid: 'dev-support',
    email_address: 'support@example.com',
    first_name: 'Susan',
    last_name: 'Upport',
  )

  puts 'Creating various provider users...'
  CreateExampleProviderUsersWithPermissions.call

  Rake::Task['create_persona_users'].invoke

  puts 'Generating a Vendor API token...'
  VendorAPIToken.create_with_random_token!(provider: Provider.find_by(code: '1JA'))

  puts 'Generating fake API requests for the Vendor API Monitor...'
  CreateVendorAPIMonitorDummyData.call

  Rake::Task['generate_test_applications'].invoke
end

desc 'Sync some pilot-enabled providers and open all their courses'
task sync_dev_providers_and_open_courses: :environment do
  puts 'Syncing data from TTAPI...'

  provider_codes = %w[1JA 24J 24P D39 S72 1JB 4T7 1N1 Y50 L34 D86 K60 H72]
  provider_codes.each do |code|
    provider_from_api = TeacherTrainingPublicAPI::Provider
        .where(year: RecruitmentCycle.current_year)
        .find(code).first

    TeacherTrainingPublicAPI::SyncSubjects.new.perform

    TeacherTrainingPublicAPI::SyncProvider.new(
      provider_from_api: provider_from_api, recruitment_cycle_year: RecruitmentCycle.previous_year,
    ).call(run_in_background: false)

    Provider.find_by_code(code).courses.previous_cycle.exposed_in_find.update_all(open_on_apply: true, opened_on_apply_at: Time.zone.now)

    TeacherTrainingPublicAPI::SyncProvider.new(
      provider_from_api: provider_from_api, recruitment_cycle_year: RecruitmentCycle.current_year,
    ).call(run_in_background: false)
  end
end

desc 'Copy feature flags from production to your local dev env'
task copy_feature_flags_from_production: :environment do
  flags = JSON.parse(HTTP.get('https://www.apply-for-teacher-training.service.gov.uk/integrations/feature-flags')).fetch('feature_flags')

  puts 'Synchronising feature flags with production...'

  FeatureFlag::FEATURES.each_key do |f|
    if flags.dig(f, 'active') && flags.dig(f, 'type') != 'variant'
      puts "+ #{f}"
      FeatureFlag.activate(f)
    else
      puts "- #{f}"
      FeatureFlag.deactivate(f)
    end
  end
end

desc 'Set up all ProviderPermissionRelationships to be open'
task setup_all_provider_relationships: :environment do
  possible_permissions = ProviderRelationshipPermissions.possible_permissions
  permissions_config = possible_permissions.index_with { true }
  ProviderRelationshipPermissions.all.each do |p|
    p.update(permissions_config.merge(setup_at: Time.zone.now))
  end
end
