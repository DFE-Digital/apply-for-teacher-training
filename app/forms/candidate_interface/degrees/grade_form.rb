module CandidateInterface
  class Degrees::GradeForm < Degrees::BaseForm
    validate do |wizard|
      if wizard.grade.blank?
        message =
          if wizard.specified_grades?
            I18n.t('activemodel.errors.models.candidate_interface/degrees/degree_wizard.attributes.grade.blank')
          else
            I18n.t('activemodel.errors.models.candidate_interface/degrees/degree_wizard.attributes.do_you_have_a_grade.blank')
          end
        wizard.errors.add(:grade, message)
      end
    end
    validates :other_grade, presence: true, length: { maximum: 255 }, if: :use_other_grade?

    def use_other_grade?
      [OTHER, YES].include?(grade)
    end

    def other_grade
      @other_grade_raw || @other_grade
    end

    def sanitize_attrs(attrs)
      return attrs if attrs[:grade].blank?

      if [YES, OTHER].exclude?(attrs[:grade])
        attrs[:other_grade] = nil
      end
      attrs
    end

    def other_grades
      @other_grades ||= Hesa::Grade.other_grouping
    end

    def back_link
      if reviewing_and_unchanged_country?
        paths.candidate_interface_degree_review_path
      else
        paths.candidate_interface_degree_completed_path
      end
    end

    def next_step
      if reviewing_and_unchanged_country?
        :review
      else
        :start_year
      end
    end

    def specified_grades?
      masters? || bachelors?
    end
  end
end
