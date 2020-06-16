module CandidateInterface
  class DegreeTypeForm
    include ActiveModel::Model

    attr_accessor :type_description
    attr_accessor :application_form, :degree

    validates :type_description, presence: true

    def save
      return false unless valid?

      self.degree = application_form.application_qualifications.degree.create!(
        qualification_type: type_description,
      )
    end
  end
end
