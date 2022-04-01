module CandidateInterface
  class DegreeTypeForm
    include ActiveModel::Model

    attr_accessor :type_description, :international_type_description, :uk_degree, :application_form, :degree

    validates :uk_degree, presence: true
    validates :type_description, presence: true, if: -> { uk? }
    validates :type_description, length: { maximum: 255 }
    validates :international_type_description, presence: true, if: -> { international? }
    validates :international_type_description, length: { maximum: 255 }

    def save
      return false unless valid?
      return false unless application_form_present?

      self.degree = application_form.application_qualifications.degree.create!(
        international: international?,
        qualification_type: international? ? international_type_description : type_description,
        qualification_type_hesa_code: international? ? nil : hesa_code,
        degree_type_uuid: degree_type_uuid,
      )
    end

    def update
      return false unless valid?
      return false unless degree_present?

      if type_description_is_for_bachelor_degree? && current_grade_is_invalid_for_bachelor_degree?
        degree.update!(
          international: international?,
          qualification_type: international? ? international_type_description : type_description,
          qualification_type_hesa_code: international? ? nil : hesa_code,
          grade: nil,
        )
      else
        degree.update!(
          international: international?,
          qualification_type: international? ? international_type_description : type_description,
          qualification_type_hesa_code: international? ? nil : hesa_code,
          degree_type_uuid: degree_type_uuid,
        )
      end
    end

    def assign_form_values
      self.uk_degree = degree.international? ? 'no' : 'yes'
      self.type_description = degree.international? ? nil : degree.qualification_type
      self.international_type_description = degree.international? ? degree.qualification_type : nil
      self
    end

  private

    def type_description_is_for_bachelor_degree?
      return false if international?

      Hesa::DegreeType.all.select(&:bachelor?).map(&:name).include?(type_description)
    end

    def current_grade_is_invalid_for_bachelor_degree?
      Hesa::Grade.undergrad_grouping_only.map(&:description).exclude?(degree.grade)
    end

    def hesa_code
      Hesa::DegreeType.find_by_name(type_description)&.hesa_code
    end

    def application_form_present?
      if application_form.present?
        true
      else
        errors.add(:application_form, 'is missing')
        false
      end
    end

    def degree_present?
      if degree.present?
        true
      else
        errors.add(:degree, 'is missing')
        false
      end
    end

    def international?
      uk_degree == 'no'
    end

    def uk?
      uk_degree == 'yes'
    end

    def degree_type_uuid
      Hesa::DegreeType.find_by_name(type_description)&.id
    end
  end
end
