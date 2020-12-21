module AffectsApplicationAPIResponse
  extend ActiveSupport::Concern

  included do
    after_commit :refresh_application_api_response_cache

    def refresh_application_api_response_cache
      application_choices.each(&:refresh_api_response_cache)
    end
  end
end
