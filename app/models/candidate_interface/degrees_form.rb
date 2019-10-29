module CandidateInterface
  class DegreesForm
    include ActiveModel::Model

    attr_accessor :qualification_type, :subject, :institution_name

    validates :qualification_type, :subject, :institution_name, presence: true

    validates :qualification_type, :subject, :institution_name, length: { maximum: 255 }

    def save_base(application_form)
      return false unless valid?

      application_form.application_qualifications.create!(
        level: ApplicationQualification.levels['degree'],
        qualification_type: qualification_type,
        subject: subject,
        institution_name: institution_name,
      )

      true
    end
  end
end
