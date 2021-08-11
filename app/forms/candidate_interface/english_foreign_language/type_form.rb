module CandidateInterface
  module EnglishForeignLanguage
    class TypeForm
      include ActiveModel::Model
      include Rails.application.routes.url_helpers

      attr_accessor :type, :return_to

      validates :type, presence: true

      def save
        return false unless valid?

        true
      end

      def next_form_path
        case type
        when 'ielts'
          candidate_interface_ielts_path(return_to_params)
        when 'toefl'
          candidate_interface_toefl_path(return_to_params)
        when 'other'
          candidate_interface_other_efl_qualification_path(return_to_params)
        end
      end

      private

      def return_to_params
        return_to == 'application-review' ? { 'return-to' => 'application-review' } : {}
      end
    end
  end
end
