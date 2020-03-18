class GenerateTestApplications
  include Sidekiq::Worker

  def perform
    raise 'You can\'t generate test data in production' if HostingEnvironment.production?

    TestApplications.new.create_application states: [:unsubmitted]
    TestApplications.new.create_application states: [:awaiting_references]
    TestApplications.new.create_application states: [:application_complete]
    TestApplications.new.create_application states: [:awaiting_provider_decision] * 3
    TestApplications.new.create_application states: [:offer] * 2
    TestApplications.new.create_application states: %i[offer rejected]
    TestApplications.new.create_application states: [:rejected] * 2
    TestApplications.new.create_application states: [:offer_withdrawn]
    TestApplications.new.create_application states: [:declined]
    TestApplications.new.create_application states: [:accepted]
    TestApplications.new.create_application states: [:accepted_no_conditions]
    TestApplications.new.create_application states: [:recruited]
    TestApplications.new.create_application states: [:conditions_not_met]
    TestApplications.new.create_application states: [:enrolled]
    TestApplications.new.create_application states: [:withdrawn]
  end
end
