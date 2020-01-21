class GenerateTestApplications
  include Sidekiq::Worker

  def perform
    raise 'You can\'t generate test data in production' if HostingEnvironment.production?

    without_slack_message_sending do
      (1..11).each do |i|
        TestApplications.create_an_application(i)
      end
    end
  end

private

  def without_slack_message_sending
    RequestStore.store[:disable_slack_messages] = true
    yield
    RequestStore.store[:disable_slack_messages] = false
  end
end
