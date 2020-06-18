module CandidateInterface
  class OtherQualificationTypeForm
    include ActiveModel::Model

    attr_accessor :qualification_type

    validates :qualification_type, presence: true

    validates :qualification_type, inclusion: { in: ['A level', 'AS level', 'GCSE', 'Other'], allow_blank: false }

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
