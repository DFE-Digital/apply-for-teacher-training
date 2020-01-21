class GenerateTestApplications
  include Sidekiq::Worker

  def perform
    raise 'You can\'t generate test data in production' if HostingEnvironment.production?

    without_slack_message_sending do
      TestApplications.create_application [:unsubmitted]
      TestApplications.create_application [:awaiting_references]
      TestApplications.create_application [:application_complete]
      TestApplications.create_application [:awaiting_provider_decision]
      TestApplications.create_application %i[offer offer]
      TestApplications.create_application %i[offer rejected]
      TestApplications.create_application %i[rejected rejected]
      TestApplications.create_application [:declined]
      TestApplications.create_application [:accepted]
      TestApplications.create_application [:recruited]
      TestApplications.create_application [:enrolled]
      TestApplications.create_application [:withdrawn]
    end
  end

private

  def without_slack_message_sending
    RequestStore.store[:disable_slack_messages] = true
    yield
    RequestStore.store[:disable_slack_messages] = false
  end
end
