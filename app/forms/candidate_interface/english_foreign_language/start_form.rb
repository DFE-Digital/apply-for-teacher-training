module CandidateInterface
  module EnglishForeignLanguage
    class StartForm
      include ActiveModel::Model
      include Rails.application.routes.url_helpers

      attr_accessor :has_efl_qualification

      validates :has_efl_qualification, presence: true

      def save
        return false unless valid?

        true
      end

      def next_path
        case has_efl_qualification
        when 'yes'
          candidate_interface_english_foreign_language_type_path
        end
      end
    end
  end
end
