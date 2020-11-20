module CandidateInterface
  module EnglishForeignLanguage
    class IeltsForm
      include ActiveModel::Model
      include ValidationUtils

      BandScore = Struct.new(:value, :option)

      attr_accessor :trf_number, :band_score, :award_year, :application_form

      validates :trf_number, presence: true, length: { maximum: 255 }
      validates :band_score, presence: true
      validates :award_year, presence: true
      validate :award_year_is_a_valid_year
      validate :band_score_is_a_valid_score

      def save
        return false unless valid?

        raise_error_unless_application_form

        ielts = IeltsQualification.new(
          trf_number: trf_number,
          band_score: sanitize(band_score),
          award_year: award_year,
        )
        UpdateEnglishProficiency.new(
          application_form,
          qualification_status: :has_qualification,
          efl_qualification: ielts,
        ).call
      end

      def fill(ielts:)
        self.trf_number = ielts.trf_number
        self.band_score = ielts.band_score
        self.award_year = ielts.award_year
        self
      end

    private

      def award_year_is_a_valid_year
        year_limit = Time.zone.today.year.to_i + 1

        if !valid_year?(award_year)
          errors.add(:award_year, :invalid)
        elsif award_year.to_i >= year_limit
          errors.add(:award_year, :in_the_future, date: year_limit)
        end
      end

      def band_score_is_a_valid_score
        unless sanitize(band_score).in? IeltsQualification::VALID_SCORES
          errors.add(:band_score, :invalid)
        end
      end

      def sanitize(band_score)
        if band_score.nil?
          nil
        elsif band_score.length == 1
          "#{band_score}.0"
        else
          band_score
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
