module CandidateInterface
  module EnglishForeignLanguage
    class MissingApplicationFormError < StandardError; end

    class ToeflForm
      include ActiveModel::Model
      include ValidationUtils

      attr_accessor :registration_number, :total_score, :award_year, :application_form

      validates :registration_number, presence: true
      validates :total_score, presence: true
      validates :award_year, presence: true
      validate :award_year_is_a_valid_year

      def save
        return false unless valid?

        raise_error_unless_application_form

        toefl = ToeflQualification.new(
          registration_number: registration_number,
          total_score: total_score,
          award_year: award_year,
        )
        UpdateEnglishProficiency.new(
          application_form,
          qualification_status: :has_qualification,
          efl_qualification: toefl,
        ).call
      end

      def fill(toefl:)
        self.registration_number = toefl.registration_number
        self.total_score = toefl.total_score
        self.award_year = toefl.award_year
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
