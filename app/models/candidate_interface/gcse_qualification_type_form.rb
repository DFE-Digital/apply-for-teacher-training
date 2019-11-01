module CandidateInterface
  class GcseQualificationTypeForm
    include ActiveModel::Model

    attr_accessor :subject, :level, :qualification_type
    validates :subject, :level, :qualification_type, presence: true

    def save_base(application_form)
      return false unless valid?

      application_form.application_qualifications.create!(
        level: level,
        subject: subject
        )

      true
    end
  end
end
