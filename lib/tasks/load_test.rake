namespace :load_test do
  desc 'Set up the Apply load test application with data from the Teacher training public API'
  task setup_app_data: :environment do
    Rails.logger.info 'Setting up load test application data...'

    Rake::Task['load_test:setup_provider_and_course_data'].invoke
    Rake::Task['load_test:setup_provider_users'].invoke
    Rake::Task['load_test:setup_dsas'].invoke
    Rake::Task['load_test:setup_support_user'].invoke

    Rake::Task['generate_test_applications'].invoke

    # Do this last as the user running the rake task needs to save the generated API keys
    Rake::Task['load_test:setup_vendor_api_tokens'].invoke

    Rails.logger.info 'Finished'
  end

  desc 'Generate more load test applications'
  task generate_test_applications: :environment do
    10.times { GenerateTestApplications.new.perform }
  end

  desc 'Set up provider and course data from the Teacher training public API'
  task setup_provider_and_course_data: :environment do
    check_environment!

    Rails.logger.info 'Syncing provider and course data from TTAPI...'

    ProductionRecruitmentCycleTimetablesAPI::SyncTimetablesWithProduction.new.call if RecruitmentCycleTimetable.none?

    provider_codes.each do |code|
      provider_from_api = TeacherTrainingPublicAPI::Provider
          .where(year: RecruitmentCycleTimetable.current_year)
          .find(code).first

      TeacherTrainingPublicAPI::SyncSubjects.new.perform

      TeacherTrainingPublicAPI::SyncProvider.new(
        provider_from_api:, recruitment_cycle_year: RecruitmentCycleTimetable.previous_year,
      ).call(run_in_background: false)

      TeacherTrainingPublicAPI::SyncProvider.new(
        provider_from_api:, recruitment_cycle_year: RecruitmentCycleTimetable.current_year,
      ).call(run_in_background: false)

      ProviderRelationshipPermissions.update_all(training_provider_can_make_decisions: true)
    rescue JsonApiClient::Errors::NotFound
      Rails.logger.warn "Could not find Provider for code #{code}. Skipping."
    end
  end

  desc 'Set up provider users for load test seed organisations'
  task setup_provider_users: :environment do
    check_environment!

    provider_codes.each do |code|
      Rails.logger.info "Setting up ProviderUser uid: #{code}, email: provider-user-#{code}@example.com"

      create_provider_user({
        dfe_sign_in_uid: code,
        email_address: "provider-user-#{code}@example.com",
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
      }, [code])
    end

    ProviderPermissions.update_all(make_decisions: true)
  end

  desc 'Set up signed provider agreements'
  task setup_dsas: :environment do
    check_environment!

    provider_codes.each do |code|
      Rails.logger.info "Setting up DSA for Provider: #{code}"
      provider_user = ProviderUser.find_by(dfe_sign_in_uid: code)
      provider = Provider.find_by(code:)

      ProviderAgreement.create!(
        provider:,
        provider_user:,
        agreement_type: :data_sharing_agreement,
        accept_agreement: true,
      )
    end
  end

  desc 'Set up support user'
  task setup_support_user: :environment do
    check_environment!

    Rails.logger.info 'Setting up default SupportUser'

    SupportUser.create!(
      dfe_sign_in_uid: 'dev-support',
      email_address: 'support@example.com',
      first_name: 'Susan',
      last_name: 'Upport',
    )
  end

  desc 'Set up Vendor API tokens for load test seed organisations'
  task setup_vendor_api_tokens: :environment do
    check_environment!

    unhashed_tokens = provider_codes.map do |code|
      VendorAPIToken.create_with_random_token!(provider: Provider.find_by(code:))
    end

    Rails.root.join('jmeter/plans/vendor_api_keys.txt').binwrite(unhashed_tokens.join(' '))

    Rails.logger.info 'Generated random tokens. API keys written to jmeter/plans/vendor_api_keys.txt'
    Rails.logger.info unhashed_tokens.join(' ')
  end
end

def provider_codes
  Rails.root.join('jmeter/plans/provider_codes.txt').read.split
end

def check_environment!
  raise 'Not permitted on this environment' unless HostingEnvironment.loadtest? || HostingEnvironment.development?
end

def create_provider_user(attrs, provider_codes)
  user = ProviderUser.create!(attrs)
  user.providers = Provider.where(code: provider_codes).all
  user.save!
end
