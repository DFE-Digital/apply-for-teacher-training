module CandidateInterface
  class NationalitiesForm
    include ActiveModel::Model

    attr_accessor :first_nationality, :second_nationality, :other_nationality, :multiple_nationalities

    validates :first_nationality, presence: true

    validates :other_nationality, presence: true, if: :first_nationality_is_other?

    validates :multiple_nationalities, presence: true, if: :multiple_nationalities_selected?

    validates :multiple_nationalities, length: { maximum: 200 }

    validates :first_nationality, :second_nationality,
              inclusion: { in: NATIONALITY_DEMONYMS, allow_blank: true },
              unless: :international_flag_is_on?

    validates :other_nationality,
              inclusion: { in: NATIONALITY_DEMONYMS, allow_blank: true },
              if: :international_flag_is_on?

    UK_AND_IRISH_NATIONALITIES = ['British', 'Welsh', 'Scottish', 'Northern Irish', 'Irish', 'English'].freeze

    def self.build_from_application(application_form)
      new(
        first_nationality: application_form.first_nationality,
        second_nationality: application_form.second_nationality,
        multiple_nationalities: application_form.multiple_nationalities_details,
        other_nationality: application_form.return_other_nationality,
      )
    end

    def save(application_form)
      return false unless valid?

      if FeatureFlag.active?('international_personal_details')
        application_form.update(
          first_nationality: nationality,
          multiple_nationalities_details: populate_multiple_nationalties,
        )
      else
        application_form.update(
          first_nationality: first_nationality,
          second_nationality: second_nationality,
          multiple_nationalities_details: populate_multiple_nationalties,
        )
      end
    end

  private

    def first_nationality_is_other?
      first_nationality == 'Other'
    end

    def multiple_nationalities_selected?
      first_nationality == 'Multiple'
    end

    def nationality
      first_nationality_is_other? ? other_nationality : first_nationality
    end

    def populate_multiple_nationalties
      if FeatureFlag.active?('international_personal_details') && multiple_nationalities_selected?
        multiple_nationalities
      elsif second_nationality.present?
        "#{first_nationality} and #{second_nationality}"
      end
    end

    def international_flag_is_on?
      FeatureFlag.active?('international_personal_details')
    end
  end
end
