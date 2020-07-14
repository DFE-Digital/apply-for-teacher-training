module CandidateInterface
  module EnglishForeignLanguage
    class MissingApplicationFormError < StandardError; end

    class IeltsForm
      include ActiveModel::Model
      include ValidationUtils

      attr_accessor :trf_number, :band_score, :award_year, :application_form

      validates :trf_number, presence: true
      validates :band_score, presence: true
      validates :award_year, presence: true
      validate :award_year_is_a_valid_year

      def save
        return false unless valid?

        raise_error_unless_application_form

        ActiveRecord::Base.transaction do
          application_form.english_proficiency&.destroy!
          application_form.build_english_proficiency(qualification_status: :yes)
          ielts = IeltsQualification.create!(
            trf_number: trf_number,
            band_score: band_score,
            award_year: award_year,
          )
          application_form.english_proficiency.update!(efl_qualification: ielts)
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
