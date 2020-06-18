module CandidateInterface
  class DegreeTypeForm
    include ActiveModel::Model

    attr_accessor :type_description
    attr_accessor :application_form, :degree

    validates :type_description, presence: true
    validates :type_description, length: { maximum: 255 }

    def save
      return false unless valid?

      self.degree = application_form.application_qualifications.degree.create!(
        qualification_type: type_description,
      )
    end

    def update
      return false unless valid?

      degree.update!(qualification_type: type_description)
    end

    def fill_form_values
      self.type_description = degree.qualification_type
      self
    end
  end
end
