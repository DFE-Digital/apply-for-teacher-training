module CandidateInterface
  module EnglishProficiencies
    class ToeflForm
      include ActiveModel::Model

      attr_accessor :registration_number, :total_score, :award_year, :application_form, :english_proficiency

      validates :registration_number, presence: true, length: { maximum: 255 }
      validates :total_score, numericality: true, presence: true, length: { maximum: 255 }
      validates :award_year, presence: true,
                             numericality: { greater_than_or_equal_to: 1964, only_integer: true },
                             year: { future: true }

      def save
        return false unless valid?

        raise_error_unless_application_form
        raise_error_unless_english_proficiency

        toefl = ToeflQualification.new(
          registration_number:,
          total_score:,
          award_year:,
        )
        UpdateEnglishProficiencies.new(
          application_form:,
          qualification_statuses: persisting_qualification_statuses,
          efl_qualification: toefl,
          publish: true,
        ).call
      end

      def fill
        return self unless english_proficiency.efl_qualification_type == 'ToeflQualification'

        toefl = english_proficiency.efl_qualification
        self.registration_number = toefl.registration_number
        self.total_score = toefl.total_score
        self.award_year = toefl.award_year
        self
      end

    private

      def raise_error_unless_application_form
        if application_form.blank?
          raise MissingApplicationFormError
        end
      end

      def raise_error_unless_english_proficiency
        if english_proficiency.blank?
          raise MissingEnglishProficiencyFormError
        end
      end

      def persisting_qualification_statuses
        @persisting_qualification_statuses ||= english_proficiency.qualification_statuses
      end
    end
  end
end
