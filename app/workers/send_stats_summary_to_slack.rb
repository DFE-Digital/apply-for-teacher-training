class SendStatsSummaryToSlack
  include Sidekiq::Worker

  def perform
    SlackNotificationWorker.perform_async(StatsSummary.new.as_slack_message, nil, '#twd_find_and_apply')
  end
end
