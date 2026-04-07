module CandidateInterface
  module EnglishProficiencies
    class OtherEflQualificationForm
      include ActiveModel::Model

      attr_accessor :name, :grade, :award_year, :application_form, :english_proficiency

      validates :name, presence: true, length: { maximum: 255 }
      validates :grade, presence: true, length: { maximum: 255 }
      validates :award_year, presence: true,
                             numericality: { only_integer: true },
                             year: { past: true }

      def save
        return false unless valid?

        raise_error_unless_application_form
        raise_error_unless_english_proficiency

        other_qualification = OtherEflQualification.new(
          name:,
          grade:,
          award_year:,
        )

        UpdateEnglishProficiencies.new(
          application_form:,
          qualification_statuses: persisting_qualification_statuses,
          efl_qualification: other_qualification,
          publish: true,
        ).call
      end

      def fill
        return self unless english_proficiency.efl_qualification_type == 'OtherEflQualification'

        qualification = english_proficiency.efl_qualification
        self.name = qualification.name
        self.grade = qualification.grade
        self.award_year = qualification.award_year
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
