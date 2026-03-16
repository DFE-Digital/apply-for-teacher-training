module CandidateInterface
  module EnglishProficiencies
    class IeltsForm
      include ActiveModel::Model

      BandScore = Struct.new(:value, :option)

      attr_accessor :trf_number, :band_score, :award_year, :application_form, :english_proficiency

      validates :trf_number, presence: true, length: { maximum: 255 }
      validates :band_score, presence: true
      validates :award_year, presence: true,
                             numericality: { greater_than_or_equal_to: 1980, only_integer: true },
                             year: { future: true }
      validate :band_score_is_a_valid_score

      def save
        return false unless valid?

        raise_error_unless_application_form
        raise_error_unless_english_proficiency

        ielts = IeltsQualification.new(
          trf_number:,
          band_score: sanitize(band_score),
          award_year:,
        )
        UpdateEnglishProficiencies.new(
          application_form:,
          qualification_statuses: persisting_qualification_statuses,
          efl_qualification: ielts,
          publish: true,
        ).call
      end

      def fill
        return self unless english_proficiency.efl_qualification_type == 'IeltsQualification'

        ielts = english_proficiency.efl_qualification
        self.trf_number = ielts.trf_number
        self.band_score = ielts.band_score
        self.award_year = ielts.award_year
        self
      end

    private

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
