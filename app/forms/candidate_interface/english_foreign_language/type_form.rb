module CandidateInterface
  module EnglishForeignLanguage
    class TypeForm
      include ActiveModel::Model
      include Rails.application.routes.url_helpers

      attr_accessor :type

      validates :type, presence: true

      def save
        return false unless valid?

        true
      end

      def next_form_path
        case type
        when 'ielts'
          candidate_interface_ielts_path
        end
      end
    end
  end
end
