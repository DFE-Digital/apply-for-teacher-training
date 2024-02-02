class SendWeeklyStatsSummaryToSlack
  include Sidekiq::Worker

  def perform
    SlackNotificationWorker.perform_async(WeeklyStatsSummary.new.as_slack_message, nil, '#twd_find_and_apply', ENV['FIND_AND_APPLY_SLACK_URL'])
  end
end
