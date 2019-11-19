module ProviderInterface
  class QualificationRowComponent < ActionView::Component::Base
    validates :qualification, presence: true
    attr_reader :qualification

    def initialize(qualification:)
      @qualification = qualification
    end

    def grade
      qualification.predicted_grade ? "#{friendly_grade} (predicted)" : friendly_grade
    end

  private

    def friendly_grade
      if qualification.degree?
        t("application_form.degree.grade.#{qualification.grade}.label", default: qualification.grade)
      else
        qualification.grade
      end
    end
  end
end
