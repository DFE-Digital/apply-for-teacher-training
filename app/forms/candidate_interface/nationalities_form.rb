module CandidateInterface
  class NationalitiesForm
    include ActiveModel::Model
    include ValidationUtils

    attr_accessor :nationality, :second_nationality

    validates :nationality, presence: true

    validates :nationality, :second_nationality,
              inclusion: { in: NATIONALITY_DEMONYMS, allow_blank: true }

    def self.build_from_application(application_form)
      new(
        nationality: application_form.nationality,
        second_nationality: application_form.second_nationality,
      )
    end

    def save(application_form)
      return false unless valid?

      application_form.update(
        nationality: nationality,
        second_nationality: second_nationality,
      )
    end
  end
end
