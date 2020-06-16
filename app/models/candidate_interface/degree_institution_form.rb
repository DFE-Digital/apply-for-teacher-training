module CandidateInterface
  class DegreeInstitutionForm
    include ActiveModel::Model

    attr_accessor :institution_name, :degree

    validates :institution_name, presence: true

    def save
      return false unless valid?

      degree.update!(institution_name: institution_name)
    end
  end
end
