module CandidateInterface
  module EnglishForeignLanguage
    class OtherEflQualificationForm
      include ActiveModel::Model

      attr_accessor :name, :grade, :award_year, :application_form

      validates :name, presence: true, length: { maximum: 255 }
      validates :grade, presence: true, length: { maximum: 255 }
      validates :award_year, presence: true, year: { future: true }

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

      def raise_error_unless_application_form
        if application_form.blank?
          raise MissingApplicationFormError
        end
      end
    end
  end
end
