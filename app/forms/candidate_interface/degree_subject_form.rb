module CandidateInterface
  class DegreeSubjectForm
    include ActiveModel::Model

    attr_accessor :subject, :degree

    validates :subject, presence: true
    validates :subject, length: { maximum: 255 }

    def save
      return false unless valid?

      degree.update!(subject: subject, subject_hesa_code: hesa_code)
    end

    def fill_form_values
      self.subject = degree.subject
      self
    end

  private

    def hesa_code
      Hesa::Subject.find_by_name(subject)&.hesa_code
    end
  end
end
