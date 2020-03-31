class DailyReport
  include Sidekiq::Worker

  def perform
    HTTP.post(ENV.fetch('STATE_CHANGE_SLACK_URL'), body: payload.to_json)
  end

private

  def payload
    blocks = []

    blocks << {
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: headlines_message,
      },
    }

    blocks << {
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: ":#{%w[male female].sample}-student: *<https://www.apply-for-teacher-training.education.gov.uk/integrations/performance-dashboard|Candidate stats>*",
      },
    }

    # Slack only allows 10 fields per section, so we have to split them up
    # https://api.slack.com/reference/block-kit/blocks#section
    candidate_stats_blocks.each_slice(10).map do |fields|
      blocks << {
        type: 'section',
        fields: fields,
      }
    end

    blocks << {
      type: 'divider',
    }

    blocks << {
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: ':school: *<https://www.apply-for-teacher-training.education.gov.uk/support/providers|Provider stats>*',
      },
      fields: [
        {
          type: 'mrkdwn',
          text: '*Providers with courses on Apply*',
        },
        {
          type: 'mrkdwn',
          text: "#{Course.open_on_apply.uniq(&:provider_id).count} providers",
        },
        {
          type: 'mrkdwn',
          text: '*Courses available on Apply*',
        },
        {
          type: 'mrkdwn',
          text: "#{Course.open_on_apply.count} courses",
        },
      ],
    }

    {
      username: 'Apply for teacher training',
      icon_emoji: ':shipitbeaver:',
      channel: HostingEnvironment.production? ? '#twd_apply' : '#twd_apply_test',
      text: headlines_message,
      blocks: blocks,
    }
  end

  def headlines_message
    [
      ':wave: Good morning!',
      "This is your daily stats update. Headlines: we've now got #{statistics.total_candidate_count} sign-ups,",
      "#{statistics.total_submitted_count} candidates who submitted their application, and #{statistics.accepted_offer_count} candidates who received and accepted an offer :tada:",
    ].join(' ')
  end

  def candidate_stats_blocks
    statistics.candidate_status_counts.flat_map do |row|
      [
        {
          type: 'mrkdwn',
          text: "*#{I18n.t!("candidate_flow_application_states.#{row['status']}.name")}*",
        },
        {
          type: 'mrkdwn',
          text: "#{row['count']} #{'candidate'.pluralize(row['count'])}",
        },
      ]
    end
  end

  def statistics
    @statistics ||= PerformanceStatistics.new
  end
end
