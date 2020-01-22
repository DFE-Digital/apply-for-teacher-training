class GenerateTestApplications
  include Sidekiq::Worker

  def perform
    raise 'You can\'t generate test data in production' if HostingEnvironment.production?

    without_slack_message_sending do
      TestApplications.create_application states: [:unsubmitted]
      TestApplications.create_application states: [:awaiting_references]
      TestApplications.create_application states: [:application_complete]
      TestApplications.create_application states: [:awaiting_provider_decision]
      TestApplications.create_application states: %i[offer offer]
      TestApplications.create_application states: %i[offer rejected]
      TestApplications.create_application states: %i[rejected rejected]
      TestApplications.create_application states: [:declined]
      TestApplications.create_application states: [:accepted]
      TestApplications.create_application states: [:recruited]
      TestApplications.create_application states: [:enrolled]
      TestApplications.create_application states: [:withdrawn]
    end
  end

private

  def without_slack_message_sending
    RequestStore.store[:disable_slack_messages] = true
    yield
    RequestStore.store[:disable_slack_messages] = false
  end
end
