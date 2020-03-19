class GenerateTestApplications
  include Sidekiq::Worker

  def perform
    raise 'You can\'t generate test data in production' if HostingEnvironment.production?

    test_applications = TestApplications.new
    test_applications.create_application states: [:unsubmitted]
    test_applications.create_application states: [:awaiting_references]
    test_applications.create_application states: [:application_complete]
    test_applications.create_application states: [:awaiting_provider_decision] * 3
    test_applications.create_application states: [:offer] * 2
    test_applications.create_application states: %i[offer rejected]
    test_applications.create_application states: [:rejected] * 2
    test_applications.create_application states: [:offer_withdrawn]
    test_applications.create_application states: [:declined]
    test_applications.create_application states: [:accepted]
    test_applications.create_application states: [:accepted_no_conditions]
    test_applications.create_application states: [:recruited]
    test_applications.create_application states: [:conditions_not_met]
    test_applications.create_application states: [:enrolled]
    test_applications.create_application states: [:withdrawn]
  end
end
