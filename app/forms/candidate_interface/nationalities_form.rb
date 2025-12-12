module CandidateInterface
  class NationalitiesForm
    include ActiveModel::Model

    attr_accessor :first_nationality, :second_nationality, :british, :irish, :other,
                  :other_nationality1, :other_nationality2, :other_nationality3,
                  :other_nationality1_raw, :other_nationality2_raw, :other_nationality3_raw,
                  :nationalities

    validates :first_nationality, :second_nationality, :other_nationality1, :other_nationality2, :other_nationality3,
              inclusion: { in: NATIONALITY_DEMONYMS, allow_blank: true }

    validate :candidate_provided_nationality

    def self.build_from_application(application_form)
      new(
        application_form.build_nationalities_hash,
      )
    end

    def save(application_form)
      return false unless valid?

      nationalities = candidates_nationalities

      if british.present? || irish.present?
        application_form.update!(
          first_nationality: nationalities[0],
          second_nationality: nationalities[1],
          third_nationality: nationalities[2],
          fourth_nationality: nationalities[3],
          fifth_nationality: nationalities[4],
          right_to_work_or_study: nil,
          right_to_work_or_study_details: nil,
        )
      else
        application_form.update!(
          first_nationality: nationalities[0],
          second_nationality: nationalities[1],
          third_nationality: nationalities[2],
          fourth_nationality: nationalities[3],
          fifth_nationality: nationalities[4],
        )
      end
    end

    def candidates_nationalities
      other.present? ? [british, irish, other_nationality1, other_nationality2, other_nationality3].compact_blank.uniq : [british, irish].compact_blank
    end

  private

    def candidate_provided_nationality
      errors.add(:nationalities, :blank) if [british, irish, other].all?(&:blank?)

      if other.present? && (other_nationality1.blank? || other_nationality1_raw.blank?)
        # 'nationalities' needs to be set in order for govuk form builder to be able to display this error
        self.nationalities = ['other', british, irish].compact
        errors.add(:other_nationality1, :blank)
      end

      if other.present? && other_nationality1_raw.present? && NATIONALITY_DEMONYMS.exclude?(other_nationality1_raw)
        errors.add(:other_nationality1, :blank)
      end
    end
  end
end
