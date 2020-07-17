module CandidateInterface
  module EnglishForeignLanguage
    class OtherEflQualificationForm
      include ActiveModel::Model
      include ValidationUtils

      attr_accessor :name, :grade, :award_year, :application_form

      validates :name, presence: true
      validates :grade, presence: true
      validates :award_year, presence: true
      validate :award_year_is_a_valid_year

      def save
        return false unless valid?

        raise_error_unless_application_form

        other_qualification = OtherEflQualification.new(
          name: name,
          grade: grade,
          award_year: award_year,
        )

        UpdateEnglishProficiency.new(
          application_form,
          qualification_status: :has_qualification,
          efl_qualification: other_qualification,
        ).call
      end

      def fill(qualification:)
        self.name = qualification.name
        self.grade = qualification.grade
        self.award_year = qualification.award_year
        self
      end

    private

      def award_year_is_a_valid_year
        if !valid_year?(award_year)
          errors.add(:award_year, :invalid)
        end
      end

      def raise_error_unless_application_form
        if application_form.blank?
          raise MissingApplicationFormError
        end
      end
    end
  end
end
