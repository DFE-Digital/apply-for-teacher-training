module CandidateInterface
  class DegreeInstitutionForm
    include ActiveModel::Model

    attr_accessor :degree, :institution_name_raw, :institution_country
    attr_writer :institution_name

    delegate :international?, to: :degree, allow_nil: true

    validates :institution_name, presence: true
    validates :institution_name, length: { maximum: 255 }
    validates :institution_country, presence: true, if: -> { international? }
    validates :institution_country, length: { maximum: 255 }

    def institution_name
      @institution_name_raw || @institution_name
    end

    def save
      return false unless valid?

      degree.update!(
        institution_name: institution_name,
        institution_country: institution_country,
        institution_hesa_code: hesa_code,
        degree_institution_uuid: degree_institution_uuid,
      )
    end

    def assign_form_values
      self.institution_name = degree.institution_name
      self.institution_country = degree.institution_country
      self
    end

  private

    def hesa_code
      institution&.hesa_code
    end

    def degree_institution_uuid
      institution&.id
    end

    def institution
      Hesa::Institution.find_by_name(institution_name)
    end
  end
end
