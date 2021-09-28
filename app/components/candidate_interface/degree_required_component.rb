class CandidateInterface::DegreeRequiredComponent < ViewComponent::Base
  CANDIDATE_GRADES = {
    'First class honours' => 4,
    'Upper second-class honours (2:1)' => 4,
    'Lower second-class honours (2:2)' => 3,
    'Third-class honours' => 2,
    'Pass' => 1,
  }.freeze

  COURSE_REQUIRED_GRADES = {
    'two_one' => 4,
    'two_two' => 3,
    'third_class' => 2,
    'not_required' => 1,
  }.freeze

  COURSE_REQUIRED_GRADE_TEXT = {
    'two_one' => '2:1 degree or higher (or equivalent)',
    'two_two' => '2:2 degree or higher (or equivalent)',
    'third_class' => 'Third-class degree or higher (or equivalent)',
    'not_required' => 'Any degree grade',
  }.freeze

  DEGREE_GRADE_INSUFFICIENT_TEXT = {
    'Lower second-class honours (2:2)' => 'a 2:2 degree.',
    'Third-class honours' => 'a Third class degree.',
    'Pass' => 'an Ordinary degree (pass).',
  }.freeze

  attr_accessor :application_choice, :course_degree_requirements, :uk_bachelor_degrees

  def initialize(application_choice)
    @application_choice = application_choice
    @course_degree_requirements = application_choice.current_course.degree_grade
    @uk_bachelor_degrees = find_uk_bachelor_degrees(application_choice)
  end

  def candidate_degree_grade_below_required_grade?
    return false if @uk_bachelor_degrees.empty? || degrees_with_other_grades_only? || bachelors_and_masters_degree?

    COURSE_REQUIRED_GRADES[@course_degree_requirements] > CANDIDATE_GRADES[highest_degree_grade]
  end

private

  def highest_degree_grade
    @highest_degree_grade ||= return_highest_degree_grade
  end

  def return_highest_degree_grade
    grades = uk_bachelor_degrees.map(&:grade)
    grades.max_by { |grade| CANDIDATE_GRADES[grade] }
  end

  def degrees_with_other_grades_only?
    grades = uk_bachelor_degrees.map(&:grade)
    grades.none? { |grade| CANDIDATE_GRADES.keys.include?(grade) }
  end

  def bachelors_and_masters_degree?
    uk_bachelor_degrees.any? && candidate_has_masters_degree?
  end

  def candidate_has_masters_degree?
    application_choice.application_form.application_qualifications
      .where(level: 'degree', other_uk_qualification_type: nil, institution_country: [nil, 'GB'])
      .where(qualification_type_hesa_code: HESA_DEGREE_TYPES.select { |dt| dt[3] == :master }.collect(&:first)).any?
  end

  def find_uk_bachelor_degrees(application_choice)
    application_choice.application_form.application_qualifications
      .where(level: 'degree', other_uk_qualification_type: nil, institution_country: [nil, 'GB'])
      .where(qualification_type_hesa_code: HESA_DEGREE_TYPES.select { |dt| dt[3] == :bachelor }.collect(&:first))
  end
end
