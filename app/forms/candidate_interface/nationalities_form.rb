module CandidateInterface
  class NationalitiesForm
    include ActiveModel::Model
    include ValidationUtils

    attr_accessor :first_nationality, :second_nationality

    validates :first_nationality, presence: true

    validates :first_nationality, :second_nationality,
              inclusion: { in: NATIONALITY_DEMONYMS, allow_blank: true }

    def self.build_from_application(application_form)
      new(
        first_nationality: application_form.first_nationality,
        second_nationality: application_form.second_nationality,
      )
    end

    def save(application_form)
      return false unless valid?

      application_form.update(
        first_nationality: first_nationality,
        second_nationality: second_nationality,
      )
    end
  end
end
