module SupportInterface
  class MathGcseForm
    include ActiveModel::Model
    attr_accessor :application_form, :grade, :other_grade, :qualification_type, :qualification

    def self.build_from_qualification(qualification)
      if qualification.qualification_type == 'non_uk'
        new(
          qualification:,
          application_form: qualification.application_form,
          grade: qualification.set_grade,
          other_grade: qualification.set_other_grade,
          qualification_type: qualification.qualification_type,
        )
      else
        new(
          qualification:,
          application_form: qualification.application_form,
          grade: qualification.grade,
          qualification_type: qualification.qualification_type,
        )
      end
    end
  end
end
