module HasApplicableDegreeForAdviser
  extend ActiveSupport::Concern

  APPLICABLE_DOMESTIC_DEGREE_GRADES = [
    'First-class honours',
    'Upper second-class honours (2:1)',
    'Lower second-class honours (2:2)',
  ].freeze

  APPLICABLE_DOMESTIC_DEGREE_LEVELS = %w[bachelor].freeze

  included do
    def applicable_degree_for_adviser
      @applicable_degree_for_adviser ||= application_qualifications
                                           .degrees
                                           .reject(&:incomplete_degree_information?)
                                           .reject(&method(:international_degree?))
                                           .select(&method(:applicable_degree_grade?))
                                           .select(&method(:applicable_degree_level?))
                                           .min_by(&method(:highest_grade_first))
    end
  end

private

  def international_degree?(degree)
    degree.international?
  end

  def applicable_degree_grade?(degree)
    degree.grade.in?(APPLICABLE_DOMESTIC_DEGREE_GRADES)
  end

  def applicable_degree_level?(degree)
    degree.qualification_level.in?(APPLICABLE_DOMESTIC_DEGREE_LEVELS)
  end

  def highest_grade_first(degree)
    APPLICABLE_DOMESTIC_DEGREE_GRADES.index(degree.grade) || (APPLICABLE_DOMESTIC_DEGREE_GRADES.count + 1)
  end
end
