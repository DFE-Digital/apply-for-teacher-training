class CandidateInterface::DegreeRequiredComponent < ViewComponent::Base
  CANDIDATE_GRADES = {
    'Upper second-class honours (2:1)' => 4,
    'Lower second-class honours (2:2)' => 3,
    'Third-class honours' => 2,
    'Pass' => 1,
  }.freeze

  COURSE_REQUIRED_GRADES = {
    'two_one' => 4,
    'two_two' => 3,
    'third_class' => 2,
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

  def initialize(application_choice)
    @application_choice = application_choice
    @course_degree_requirements = application_choice.current_course.degree_grade
    @candidate_degrees = candidate_non_other_uk_degrees(application_choice)
    @highest_candidate_degree_grade = ''
  end

  def candidate_degree_grade_below_required_grade?
    return false if @candidate_degrees.empty? || degrees_with_other_grades_only(@candidate_degrees)

    find_highest_degree_grade(@candidate_degrees)

    COURSE_REQUIRED_GRADES[@course_degree_requirements] > CANDIDATE_GRADES[@highest_candidate_degree_grade]
  end

private

  def find_highest_degree_grade(candidate_degrees)
    counter = 0
    candidate_degrees.each do |degree|
      if !CANDIDATE_GRADES[degree.grade].nil? && CANDIDATE_GRADES[degree.grade] > counter
        counter = CANDIDATE_GRADES[degree.grade]
        @highest_candidate_degree_grade = degree.grade
      end
    end
  end

  def degrees_with_other_grades_only(candidate_degrees)
    grades = []
    candidate_degrees.each do |degree|
      if CANDIDATE_GRADES.keys.include?(degree.grade)
        grades << degree.grade
      end
    end
    grades.empty?
  end

  def candidate_non_other_uk_degrees(application_choice)
    application_choice.application_form.application_qualifications
    .where(level: 'degree', other_uk_qualification_type: nil)
    .where(institution_country: nil).or(
      application_choice.application_form.application_qualifications.where(institution_country: 'GB'),
    )
    .where(qualification_type: HESA_DEGREE_TYPES.map(&:second)).or(
      application_choice.application_form.application_qualifications.where(qualification_type: HESA_DEGREE_TYPES.map(&:third)),
    )
  end
end
