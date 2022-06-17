namespace :api do
  task :check_applications, [:provider_id] => :environment do |_, args|
    Bullet.enable = true
    Bullet.bullet_logger = true

    provider = args[:provider_id].present? ? Provider.find(args[:provider_id]) : Provider.first

    puts Benchmark.measure {
      Bullet.profile {
        ActiveRecord::Base.logger = Logger.new(STDOUT)
        since = Time.zone.iso8601('0001-01-01T01:00:00')
        VendorAPI::MultipleApplicationsPresenter.new(
          '1.1',
          GetApplicationChoicesForProviders.call(providers: [provider]).where('application_choices.updated_at > ?', since),
          ActionDispatch::Request.new({}),
          { since: since, page: 1, per_page: 50 }
        ).serialized_applications_data
      }
    }
  end
end
