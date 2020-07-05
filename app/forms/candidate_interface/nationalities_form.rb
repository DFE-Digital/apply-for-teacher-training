module CandidateInterface
  class NationalitiesForm
    include ActiveModel::Model
    include ValidationUtils

    attr_accessor :first_nationality, :second_nationality, :other_nationality, :multiple_nationalities

    validates :first_nationality, presence: true

    validates :other_nationality, presence: true, if: :first_nationality_is_other?

    validates :multiple_nationalities, presence: true, if: :multiple_nationalities_selected?

    validates :first_nationality, :second_nationality,
              inclusion: { in: NATIONALITY_DEMONYMS, allow_blank: true },
              unless: :international_flag_is_on?

    validates :other_nationality,
              inclusion: { in: NATIONALITY_DEMONYMS, allow_blank: true },
              if: :international_flag_is_on?

    def self.build_from_application(application_form)
      new(
        first_nationality: application_form.first_nationality,
        second_nationality: application_form.second_nationality,
      )
    end

    def save(application_form)
      return false unless valid?

      if FeatureFlag.active?('international_personal_details')
        application_form.update(
          first_nationality: nationality,
          multiple_nationalities_details: multiple_nationalities,
        )
      else
        application_form.update(
          first_nationality: first_nationality,
          second_nationality: second_nationality,
        )
      end
    end

  private

    def first_nationality_is_other?
      first_nationality == 'other'
    end

    def multiple_nationalities_selected?
      first_nationality == 'multiple'
    end

    def nationality
      case first_nationality
      when 'other'
        other_nationality
      when 'multiple'
        first_nationality
      else
        first_nationality.capitalize
      end
    end

    def international_flag_is_on?
      FeatureFlag.active?('international_personal_details')
    end
  end
end
