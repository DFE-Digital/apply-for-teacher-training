desc 'Set up your local development environment with data from Find'
task setup_local_dev_data: :environment do
  puts 'Syncing data from Find...'
  ENV['DEV_PROVIDERS_TO_SYNC'].split(',').each do |code|
    SyncProviderFromFind.call(provider_code: code, sync_courses: true)
  end

  puts 'Making all the courses open on Apply...'
  Provider.all.each do |provider|
    OpenProviderCourses.new(provider: provider).call
  end

  FeatureFlag.activate('pilot_open')

  puts 'Generating some test applications...'
  GenerateTestApplications.new.perform

  puts 'Creating a provider-only user with DfE Sign-in UID `dev-provider` and email `provider@example.com`...'
  ProviderUser.find_or_create_by!(dfe_sign_in_uid: 'dev-provider', email_address: 'provider@example.com') do |u|
    u.providers = [ApplicationChoice.first.provider]
  end

  puts 'Creating a support & provider user with DfE Sign-in UID `dev-support` and email `support@example.com`...'
  ProviderUser.find_or_create_by!(dfe_sign_in_uid: 'dev-support', email_address: 'support@example.com') do |u|
    u.providers = [ApplicationChoice.first.provider]
  end
  SupportUser.find_or_create_by!(dfe_sign_in_uid: 'dev-support', email_address: 'support@example.com')
end
