desc 'Set up your local development environment with data from Find'
task setup_local_dev_data: %i[environment copy_feature_flags_from_production sync_dev_providers_and_open_courses] do
  puts 'Creating a provider-only user with DfE Sign-in UID `dev-provider` and email `provider@example.com`...'
  ProviderUser.create!(
    dfe_sign_in_uid: 'dev-provider',
    email_address: 'provider@example.com',
    first_name: 'Peter',
    last_name: 'Rovider',
  ) do |u|
    u.providers = Provider.where(code: '1JA').all
  end

  puts 'Creating a support & provider user with DfE Sign-in UID `dev-support` and email `support@example.com`...'

  SupportUser.create!(
    dfe_sign_in_uid: 'dev-support',
    email_address: 'support@example.com',
    first_name: 'Susan',
    last_name: 'Upport',
  )

  admin_provider_user = ProviderUser.create!(
    dfe_sign_in_uid: 'dev-support',
    email_address: 'support@example.com',
    first_name: 'Susan',
    last_name: 'Upport',
  ) do |u|
    u.providers = Provider.where(code: %w[1JA 24J]).all
  end

  admin_provider_user.provider_permissions.update_all(
    manage_users: true,
    manage_organisations: true,
    view_safeguarding_information: true,
    make_decisions: true,
  )

  Rake::Task['generate_test_applications'].invoke
end

desc 'Sync some pilot-enabled providers and open all their courses'
task sync_dev_providers_and_open_courses: :environment do
  puts 'Syncing data from Find...'

  provider_codes = HostingEnvironment.review? ? %w[1JA 24J] : %w[1JA 24J 1N1]
  provider_codes.each do |code|
    SyncProviderFromFind.call(provider_code: code, sync_courses: true, provider_recruitment_cycle_year: RecruitmentCycle.current_year)
  end

  puts 'Making all the courses open on Apply...'
  Provider.all.each do |provider|
    OpenProviderCourses.new(provider: provider).call
  end
end

desc 'Copy feature flags from production to your local dev env'
task copy_feature_flags_from_production: :environment do
  flags = JSON.parse(HTTP.get('https://www.apply-for-teacher-training.service.gov.uk/integrations/feature-flags')).fetch('feature_flags')

  puts 'Synchronising feature flags with production...'

  FeatureFlag::FEATURES.each_key do |f|
    if flags.dig(f, 'active')
      puts "+ #{f}"
      FeatureFlag.activate(f)
    else
      puts "- #{f}"
      FeatureFlag.deactivate(f)
    end
  end
end
