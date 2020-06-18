module CandidateInterface
  class DegreeSubjectForm
    include ActiveModel::Model

    attr_accessor :subject, :degree

    validates :subject, presence: true
    validates :subject, length: { maximum: 255 }

    def save
      return false unless valid?

      degree.update!(subject: subject)
    end

    def fill_form_values
      self.subject = degree.subject
      self
    end
  end
end
