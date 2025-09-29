module HasApplicableDegreeForAdviser
  extend ActiveSupport::Concern

  APPLICABLE_DOMESTIC_DEGREE_GRADES = [
    'First-class honours',
    'Upper second-class honours (2:1)',
    'Lower second-class honours (2:2)',
  ].freeze

  APPLICABLE_INTERNATIONAL_DEGREE_LEVELS = %w[
    bachelor_honours_degree
    postgraduate_certificate_or_diploma
    masters_degree
    doctor_of_philosophy
    post_doctoral_award
  ].freeze

  APPLICABLE_DOMESTIC_DEGREE_LEVELS = %w[bachelor master doctor].freeze

  included do
    def applicable_degree_for_adviser
      @applicable_degree_for_adviser ||= application_qualifications
                                           .degrees
                                           .reject(&:incomplete_degree_information?)
                                           .reject(&method(:international_without_equivalency?))
                                           .select(&method(:applicable_degree_grade?))
                                           .select(&method(:applicable_degree_level?))
                                           .min_by(&method(:highest_grade_first))
    end

    def applicable_degree_for_quickfire_sign_up
      @applicable_degree_for_quickfire_sign_up ||= application_qualifications
          .degrees
          .reject(&:incomplete_degree_information?)
          .reject(&method(:international_degree?))
          .select(&method(:applicable_quickfire_degree_grade?))
          .select(&method(:applicable_quickfire_degree_level?))
          .select(&method(:applicable_quickfire_degree_subject?))
          .min_by(&method(:highest_grade_first))
    end
  end

private

  def international_without_equivalency?(degree)
    degree.international? && !degree.enic_reference
  end

  def international_degree?(degree)
    degree.international?
  end

  def applicable_degree_grade?(degree)
    degree.international? || degree.grade.in?(APPLICABLE_DOMESTIC_DEGREE_GRADES)
  end

  def applicable_quickfire_degree_grade?(degree)
    degree.grade.in?(APPLICABLE_DOMESTIC_DEGREE_GRADES)
  end

  def applicable_degree_level?(degree)
    if degree.international?
      degree.comparable_uk_degree.in?(APPLICABLE_INTERNATIONAL_DEGREE_LEVELS)
    else
      degree.qualification_level.in?(APPLICABLE_DOMESTIC_DEGREE_LEVELS)
    end
  end

  def applicable_quickfire_degree_level?(degree)
    degree.qualification_level == 'bachelor'
  end

  def applicable_quickfire_degree_subject?(degree)
    Adviser::SubjectMatchCheck.quickfire_subject_match?(degree)
  end

  def highest_grade_first(degree)
    APPLICABLE_DOMESTIC_DEGREE_GRADES.index(degree.grade) || (APPLICABLE_DOMESTIC_DEGREE_GRADES.count + 1)
  end
end
