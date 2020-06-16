module CandidateInterface
  class DegreeSubjectForm
    include ActiveModel::Model

    attr_accessor :subject, :degree

    validates :subject, presence: true

    def save
      return false unless valid?

      degree.update!(subject: subject)
    end
  end
end
