module SupportInterface
  class DuplicateMatchesResolveComponent < ApplicationComponent
    include ViewHelper

    attr_reader :match

    def initialize(match)
      @match = match
    end

    def resolve_button
      if @match.resolved?
        govuk_button_to 'Mark as unresolved', support_interface_update_duplicate_match_path(@match), method: :patch, params: { resolved: false }
      else
        govuk_button_to 'Mark as resolved', support_interface_update_duplicate_match_path(@match), method: :patch, params: { resolved: true }
      end
    end
  end
end
