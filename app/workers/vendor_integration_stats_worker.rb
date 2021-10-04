require 'http'

class VendorIntegrationStatsWorker
  include Sidekiq::Worker

  SLACK_CHANNELS = {
    'tribal' => 'tribal_dfe_collaboration_',
    'ellucian' => 'ellucian_dfe_collaboration',
  }.freeze

  def perform(vendor_name)
    @vendor_name = vendor_name
    @webhook_url = fetch_webhook_url

    if @webhook_url.present?
      message = SlackReport.new(vendor_name).generate
      post_to_slack message
    end
  end

private

  def fetch_webhook_url
    ENV.fetch "#{@vendor_name.upcase}_INTEGRATION_STATS_SLACK_URL"
  end

  def post_to_slack(slack_message)
    slack_channel = '#twd_apply_test' # TODO: hardcoded for now

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

  class SlackReport
    def initialize(vendor_name)
      @vendor = Vendor.find_by(name: vendor_name)
      @monitor = SupportInterface::VendorAPIMonitor.new(vendor: @vendor)
    end

    def generate
      <<~VENDOR_INTEGRATION_STATS_SLACK_REPORT
        ```
        Integration report for #{@vendor.name.titleize} (#{Time.zone.now.to_s(:govuk_date)})

        #{never_connected_text}
        #{no_sync_in_24h_text}
        #{no_decisions_in_7d_text}
        #{providers_with_errors_text}
        ```
      VENDOR_INTEGRATION_STATS_SLACK_REPORT
    end

    def never_connected_text
      <<~NEVER_CONNECTED_TEXT
        Never connected:
        -----------------------------------------------------------------------------
        #{@monitor.never_connected.map(&:name).join("\n")}
      NEVER_CONNECTED_TEXT
    end

    def no_sync_in_24h_text
      <<~NO_SYNC_IN_24H_TEXT
        #{justify('No sync in the last 24h', 'Last sync'.rjust(23))}
        -----------------------------------------------------------------------------
        #{
          @monitor.no_sync_in_24h.map { |p| justify(p.name, p.try(:last_sync)) }
            .join("\n")
        }
      NO_SYNC_IN_24H_TEXT
    end

    def no_decisions_in_7d_text
      <<~NO_DECISIONS_IN_7D_TEXT
        #{justify('No decisions in the last 7 days', 'Last decision'.rjust(23))}
        -----------------------------------------------------------------------------
        #{
          @monitor.no_decisions_in_7d.map { |p| justify(p.name, p.try(:last_decision)) }
            .join("\n")
        }
      NO_DECISIONS_IN_7D_TEXT
    end

    def providers_with_errors_text
      <<~PROVIDERS_WITH_ERRORS_TEXT
        #{justify('Providers with errors', 'Error rate'.rjust(23))}
        -----------------------------------------------------------------------------
        #{
          @monitor.providers_with_errors.map { |p| justify(p.name, p.try(:error_rate)) }
            .join("\n")
        }
      PROVIDERS_WITH_ERRORS_TEXT
    end

    def justify(left, right)
      [left.ljust(50), right].join("\t")
    end
  end
end
