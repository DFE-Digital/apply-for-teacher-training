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
          status: render(TagComponent.new(text: match.matching_data_updated? ? 'Updated' : match.matching_state.humanize, type: match.processed? ? :green : :purple)),
          action_needed: action_needed(match),
          match_link: govuk_link_to(match.candidate.email_address, support_interface_ucas_match_path(match)),
          last_update: match.updated_at.to_s(:govuk_date),
        }
      end
    end

  private

    def action_needed(match)
      if match.invalid_matching_data?
        render(TagComponent.new(text: 'Invalid data', type: :red))
      elsif match.action_needed?
        render(TagComponent.new(text: 'Action needed', type: :yellow))
      end
    end
  end
end
