module CandidateInterface
  class DegreeSubjectForm
    include ActiveModel::Model

    attr_accessor :subject_raw, :degree
    attr_writer :subject

    delegate :international?, to: :degree

    validates :subject, presence: true
    validates :subject, length: { maximum: 255 }

    def subject
      @subject_raw || @subject
    end

    def save
      return false unless valid?

      degree.update!(subject:, subject_hesa_code: hesa_code, degree_subject_uuid:)
    end

    def assign_form_values
      self.subject = degree.subject
      self
    end

  private

    def hesa_code
      degree_subject&.hesa_code
    end

    def degree_subject_uuid
      degree_subject&.id
    end

    def degree_subject
      Hesa::Subject.find_by_name(subject)
    end
  end
end
