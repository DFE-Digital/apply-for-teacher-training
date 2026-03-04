module CandidateInterface
  module EnglishProficiencies
    class TypeForm
      include ActiveModel::Model
      include Rails.application.routes.url_helpers

      attr_accessor :type, :return_to

      validates :type, presence: true, inclusion: { in: %w[ielts toefl other] }

      def save
        return false unless valid?

        true
      end

      def next_path
        case type
        when 'ielts'
          candidate_interface_english_proficiencies_ielts_path(return_to_params)
        when 'toefl'
          candidate_interface_english_proficiencies_toefl_path(return_to_params)
        when 'other'
          english_proficiencies_other_efl_qualification_path(return_to_params)
        end
      end

    private

      def return_to_params
        return_to == 'application-review' ? { 'return-to' => 'application-review' } : {}
      end
    end
  end
end
