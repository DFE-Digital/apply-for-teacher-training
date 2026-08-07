module CandidateInterface
  module EnglishForeignLanguage
    module EflRoutingConcern
      extend ActiveSupport::Concern

      included do
        before_action :redirect_to_english_proficiencies
      end

    private

      def redirect_to_english_proficiencies
        case controller_name
        when 'start'
          redirect_to candidate_interface_english_proficiencies_start_path
        when 'review'
          redirect_to candidate_interface_english_proficiencies_review_path
        end
      end

      def redirect_to_efl_root
        redirect_to candidate_interface_english_foreign_language_start_path
      end
    end
  end
end
