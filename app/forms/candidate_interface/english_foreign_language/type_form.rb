module CandidateInterface
  module EnglishForeignLanguage
    class TypeForm
      include ActiveModel::Model

      attr_accessor :type

      validates :type, presence: true

      def save
        return false unless valid?

        true
      end

      def path_for_next_form
        Rails.application.routes.url_helpers.candidate_interface_ielts_path
      end
    end
  end
end
