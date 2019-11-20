require 'http'

class SlackNotificationWorker
  include Sidekiq::Worker
  INCOMING_WEBHOOK_URL = ENV['STATE_CHANGE_SLACK_URL']

  def perform(text, url)
    Rails.logger.debug "State change notification: #{text}"
    if !INCOMING_WEBHOOK_URL.blank?
      message = hyperlink text, url
      post_to_slack message
    end
  end

private

  def hyperlink(text, url)
    "<#{url}|#{text}>"
  end

  def post_to_slack(text)
    payload = {
      username: 'ApplyBot',
      icon_emoji: ':parrot:',
      text: text,
      mrkdwn: true,
    }
    response = HTTP.post INCOMING_WEBHOOK_URL, body: payload.to_json
    Rails.logger.warn "Notification to slack failed: #{response.status}" if !response.status.success?
  rescue StandardError => e
    Rails.logger.warn "Notification to slack failed: #{e.message}"
  end
end
