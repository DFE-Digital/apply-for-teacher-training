class CreateVendorAPIMonitorDummyData
  def self.call
    integrated_providers = Provider.where(provider_type: 'university').shuffle

    # decision older than 7 days
    FactoryBot.create(:vendor_api_request, :decision, provider: integrated_providers.pop, created_at: Faker::Date.between(from: 3.weeks.ago, to: 8.days.ago))

    # sync older than one day
    FactoryBot.create(:vendor_api_request, :sync, provider: integrated_providers.pop, created_at: Faker::Date.between(from: 7.days.ago, to: 2.days.ago))

    # mix of errors and legitimate requests
    error_provider = integrated_providers.pop
    FactoryBot.create_list(:vendor_api_request, rand(3..9), :with_validation_error, provider: error_provider, created_at: Faker::Date.between(from: 1.week.ago, to: 2.days.ago))
    FactoryBot.create_list(:vendor_api_request, rand(10..19), :sync, provider: error_provider, created_at: Faker::Date.between(from: 7.days.ago, to: 2.days.ago))

    # token but never connected
    token_but_no_connection = integrated_providers.pop
    FactoryBot.create(:vendor_api_token, provider: token_but_no_connection)

    # no token, never connected
    integrated_providers.pop

    # make some random traffic for the rest
    integrated_providers.each do |provider|
      FactoryBot.create(:vendor_api_request, :decision, provider: provider, created_at: Faker::Date.between(from: 6.weeks.ago, to: 6.days.ago))
      FactoryBot.create(:vendor_api_request, :with_validation_error, provider: provider, created_at: Faker::Date.between(from: 2.weeks.ago, to: 2.days.ago))
      FactoryBot.create_list(:vendor_api_request, rand(28), :sync, provider: provider, created_at: Faker::Date.between(from: 2.weeks.ago, to: 12.hours.ago))
    end
  end
end
