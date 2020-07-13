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

        ActiveRecord::Base.transaction do
          application_form.english_language_proficiency&.destroy!
          application_form.build_english_language_proficiency(qualification_status: :yes)
          toefl = ToeflQualification.create!(
            registration_number: registration_number,
            total_score: total_score,
            award_year: award_year,
          )
          application_form.english_language_proficiency.update!(efl_qualification: toefl)
        end
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
