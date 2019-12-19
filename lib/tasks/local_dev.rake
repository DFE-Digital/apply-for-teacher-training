desc 'Set up your local development environment with data from Find'
task setup_local_dev_data: :environment do
  puts 'Syncing data from Find...'
  Rails.configuration.providers_to_sync[:codes].each do |code|
    SyncProviderFromFind.call(provider_code: code)
  end

  puts 'Making all the courses open on Apply...'
  Course.update_all(open_on_apply: true)

  FeatureFlag.activate('pilot_open')

  puts 'Generating some test applications...'
  GenerateTestApplications.new.perform

  puts 'Creating a provider user with DfE Sign-in UID `ABC` and email `support@example.com`...'
  ProviderUser.find_or_create_by!(dfe_sign_in_uid: 'dev-support', email_address: 'support@example.com') do |u|
    u.providers = [ApplicationChoice.first.provider]
  end

  puts 'Creating a support user with DfE Sign-in UID `dev-support` and email `support@example.com`...'
  SupportUser.find_or_create_by!(dfe_sign_in_uid: 'dev-support', email_address: 'support@example.com')
end
