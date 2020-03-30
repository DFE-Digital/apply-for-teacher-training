module CandidateInterface
  class OtherQualificationTypeForm
    include ActiveModel::Model

    attr_accessor :qualification_type

    validates :qualification_type, presence: true

    def save(application_form)
      return false unless valid?

      application_form.application_qualifications.create!(
        level: ApplicationQualification.levels[:other],
        qualification_type: qualification_type,
      )
      true
    end
  end
end
