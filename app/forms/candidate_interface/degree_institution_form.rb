module CandidateInterface
  class DegreeInstitutionForm
    include ActiveModel::Model

    attr_accessor :institution_name, :degree

    validates :institution_name, presence: true
    validates :institution_name, length: { maximum: 255 }

    def save
      return false unless valid?

      degree.update!(institution_name: institution_name, institution_hesa_code: hesa_code)
    end

    def fill_form_values
      self.institution_name = degree.institution_name
      self
    end

  private

    def hesa_code
      Hesa::Institution.find_by_name(institution_name)&.hesa_code
    end
  end
end
