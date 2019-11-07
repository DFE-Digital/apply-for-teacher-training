module CandidateInterface
  class GcseQualificationTypeForm
    include ActiveModel::Model

    attr_accessor :subject, :level, :qualification_type, :qualification_id
    validates :subject, :level, :qualification_type, presence: true

    def save_base(application_form)
      return false unless valid?

      if new_record?
        application_form.application_qualifications.create!(
          level: level,
          subject: subject,
          qualification_type: qualification_type,
          )
      else
        qualification = ApplicationQualification.find(qualification_id)

        qualification.update(
          level: level,
          subject: subject,
          qualification_type: qualification_type,
        )
      end

      true
    end

    def self.build_from_qualification(qualification)
      new(
        level: qualification.level,
        subject: qualification.subject,
        qualification_type: qualification.qualification_type,
        qualification_id: qualification.id,
      )
    end

    def new_record?
      qualification_id.nil?
    end
  end
end
