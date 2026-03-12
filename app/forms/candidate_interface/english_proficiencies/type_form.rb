module CandidateInterface
  module EnglishProficiencies
    class TypeForm
      include ActiveModel::Model
      include Rails.application.routes.url_helpers

      attr_accessor :type, :return_to, :english_proficiency

      validates :type, presence: true, inclusion: { in: %w[ielts toefl other] }

      def save
        return false unless valid?

        true
      end

      def fill
        efl_qualification_types = {
          'IeltsQualification' => 'ielts',
          'ToeflQualification' => 'toefl',
          'OtherEflQualification' => 'other',
        }
        self.type = efl_qualification_types[english_proficiency.efl_qualification_type]
        self
      end

      def next_path
        case type
        when 'ielts'
          candidate_interface_english_proficiencies_ielts_path(english_proficiency)
        when 'toefl'
          candidate_interface_english_proficiencies_toefl_path(english_proficiency)
        when 'other'
          candidate_interface_english_proficiencies_other_efl_qualification_path(english_proficiency)
        end
      end

    private

      def return_to_params
        return_to == 'application-review' ? { 'return-to' => 'application-review' } : {}
      end
    end
  end
end
