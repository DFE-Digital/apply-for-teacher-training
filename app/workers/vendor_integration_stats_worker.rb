require 'http'

class VendorIntegrationStatsWorker
  SLACK_MESSAGE_LIMIT = 4000

  include Sidekiq::Worker

  SLACK_CHANNELS = {
    'tribal' => 'tribal_dfe_collaboration_',
    'ellucian' => 'ellucian_dfe_collaboration',
    'unit4' => 'unit4_dfe_collaboration',
    'oracle' => 'oracle_dfe_collaboration',
  }.freeze

  def perform(vendor_name)
    raise 'Unknown vendor' if SLACK_CHANNELS[vendor_name].blank?

    @vendor_name = vendor_name
    @webhook_url = fetch_webhook_url

    if @webhook_url.present?
      message_array = SlackReport.new(vendor_name).generate

      check_and_post(message_array)
    end
  end

private

  def check_and_post(messages)
    if messages.join("\n").length < SLACK_MESSAGE_LIMIT
      post_to_slack messages.join("\n")
    else
      messages.each do |message|
        post_to_slack message
      end
    end
  end

  def fetch_webhook_url
    ENV.fetch("#{@vendor_name.upcase}_INTEGRATION_STATS_SLACK_URL", nil)
  end

  def post_to_slack(slack_message)
    slack_channel = SLACK_CHANNELS[@vendor_name]

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
    include ActionView::Helpers::NumberHelper

    def initialize(vendor_name)
      @vendor = Vendor.find_by(name: vendor_name)
      @monitor = SupportInterface::VendorAPIMonitor.new(vendor: @vendor)
    end

    def generate
      [
        "*API integration report for #{@vendor.name.titleize}* (#{Time.zone.now.to_s(:govuk_date)}, #{HostingEnvironment.environment_name})",
        ":negative_squared_cross_mark:\n```#{never_connected_text}```",
        ":satellite_antenna:\n```#{no_sync_in_7d_text}```",
        ":checkered_flag:\n```#{no_decisions_in_7d_text}```",
        ":thinking_face:\n```#{providers_with_errors_text}```",
      ]
    end

    def never_connected_text
      <<~NEVER_CONNECTED_TEXT
        Never connected via API (#{@monitor.never_connected.size} found)
        -----------------------------------------------------------------------------
        #{@monitor.never_connected.map(&:name).join("\n")}
      NEVER_CONNECTED_TEXT
    end

    def no_sync_in_7d_text
      <<~NO_SYNC_IN_7D_TEXT
        #{justify("No API sync in the last 7 days (#{@monitor.no_sync_in_7d.size} found)", 'Last sync')}
        -----------------------------------------------------------------------------
        #{
          @monitor.no_sync_in_7d.map { |p| justify(p.name, p.try(:last_sync)) }
            .join("\n")
        }
      NO_SYNC_IN_7D_TEXT
    end

    def no_decisions_in_7d_text
      <<~NO_DECISIONS_IN_7D_TEXT
        #{justify("No API decisions in the last 7 days (#{@monitor.no_decisions_in_7d.size} found)", 'Last decision')}
        -----------------------------------------------------------------------------
        #{
          @monitor.no_decisions_in_7d.map { |p| justify(p.name, p.try(:last_decision)) }
            .join("\n")
        }
      NO_DECISIONS_IN_7D_TEXT
    end

    def providers_with_errors_text
      <<~PROVIDERS_WITH_ERRORS_TEXT
        #{justify("Providers with API errors (#{@monitor.providers_with_errors.size} found)", 'Error rate')}
        -----------------------------------------------------------------------------
        #{
          @monitor.providers_with_errors.map { |provider| justify(provider.name, error_rate(provider)) }
            .join("\n")
        }
      PROVIDERS_WITH_ERRORS_TEXT
    end

    def justify(left, right)
      [left.to_s.ljust(50), right.to_s.rjust(23)].join("\t")
    end

    def error_rate(provider)
      "#{number_with_precision(provider.error_rate, precision: 2)}%" if provider.respond_to?(:error_rate)
    end
  end
end
