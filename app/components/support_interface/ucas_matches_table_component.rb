module SupportInterface
  class UCASMatchesTableComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :matches

    def initialize(matches:)
      @matches = matches
    end

    def table_rows
      matches.map do |match|
        {
          status: govuk_tag(text: match.action_taken&.humanize || 'No action taken', colour: match.resolved? ? 'green' : 'purple'),
          action_needed: action_needed(match),
          match_link: govuk_link_to(match.candidate.email_address, support_interface_ucas_match_path(match)),
          last_update: match.updated_at.to_s(:govuk_date),
        }
      end
    end

  private

    def action_needed(match)
      if match.invalid_matching_data?
        govuk_tag(text: 'Invalid data', colour: 'red')
      elsif match.action_needed?
        govuk_tag(text: 'Action needed', colour: 'yellow')
      end
    end
  end
end
