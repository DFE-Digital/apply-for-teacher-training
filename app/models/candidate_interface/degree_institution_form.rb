module CandidateInterface
  class DegreeInstitutionForm
    include ActiveModel::Model

    attr_accessor :institution_name, :degree

    validates :institution_name, presence: true
    validates :institution_name, length: { maximum: 255 }

    def save
      return false unless valid?

      degree.update!(institution_name: institution_name)
    end

    def fill_form_values
      self.institution_name = degree.institution_name
      self
    end
  end
end
