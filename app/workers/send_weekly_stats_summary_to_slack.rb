class SendWeeklyStatsSummaryToSlack
  include Sidekiq::Worker

  def perform
    SlackNotificationWorker.perform_async(WeeklyStatsSummary.new.as_slack_message, nil, '#twd_apply')
  end
end
