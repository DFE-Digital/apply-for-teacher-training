require 'http'

class SlackNotificationWorker
  include Sidekiq::Worker

  def perform(text, url)
    @webhook_url = ENV['STATE_CHANGE_SLACK_URL']

    if @webhook_url.present?
      message = hyperlink text, url
      post_to_slack message
    end
  end

private

  def hyperlink(text, url)
    "<#{url}|#{text}>"
  end

  def post_to_slack(text)
    if HostingEnvironment.production?
      slack_message = text
      slack_channel = '#twd_apply_support'
    else
      slack_message = "[#{HostingEnvironment.environment_name.upcase}] #{text}"
      slack_channel = '#twd_apply_test'
    end

    payload = {
      username: 'Apply for teacher training',
      channel: slack_channel,
      text: slack_message,
      mrkdwn: true,
    }

    response = HTTP.post(@webhook_url, body: payload.to_json)

    unless response.status.success?
      raise SlackMessageError, "Slack error: #{response.body}"
    end
  end

  class SlackMessageError < StandardError; end
end
