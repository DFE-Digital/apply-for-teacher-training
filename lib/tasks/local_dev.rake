desc 'Set up your local development environment with data from the Teacher training public API'
task setup_review_app_data: :environment do
  if ProviderUser.none?
    Rake::Task['setup_local_dev_data'].invoke
    Rake::Task['setup_all_provider_relationships'].invoke
  end
end

task setup_local_dev_data: %i[environment copy_feature_flags_from_production sync_dev_providers] do
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
  VendorAPIToken.create_with_random_token!(provider: Provider.find_by(code: 'U80'))

  puts 'Generating fake API requests for the Vendor API Monitor...'
  CreateVendorAPIMonitorDummyData.call

  Rake::Task['generate_test_applications'].invoke

  puts 'Finding duplicate applications'
  UpdateDuplicateMatchesWorker.new.perform

  Rake::Task['create_undergraduate_courses'].invoke
end

desc 'Create undergraduate courses'
task create_undergraduate_courses: :environment do
  Provider.find_each do |provider|
    FactoryBot.create(
      :course,
      :open,
      :secondary,
      :teacher_degree_apprenticeship,
      :available_in_current_and_next_year,
      :with_course_options,
      provider:,
      name: 'Mathematics',
    )
  end
end

desc 'Sync some pilot-enabled providers'
task sync_dev_providers: :environment do
  puts 'Syncing data from TTAPI...'

  provider_codes = %w[U80 24J 24P D39 S72 1ZW 1N1 Y50 L34 D86 K60 H72 W53 1TZ]
  provider_codes.each do |code|
    provider_from_api = TeacherTrainingPublicAPI::Provider
        .where(year: RecruitmentCycle.current_year)
        .find(code).first

    TeacherTrainingPublicAPI::SyncSubjects.new.perform

    TeacherTrainingPublicAPI::SyncProvider.new(
      provider_from_api:, recruitment_cycle_year: RecruitmentCycle.previous_year,
    ).call(run_in_background: false)

    TeacherTrainingPublicAPI::SyncProvider.new(
      provider_from_api:, recruitment_cycle_year: RecruitmentCycle.current_year,
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
