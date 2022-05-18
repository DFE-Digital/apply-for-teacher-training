class ApplicationQualificationDecorator < SimpleDelegator
  attr_reader :qualification

  ENGLISH_AWARDS = { english_single_award: 'English single award',
                     english_double_award: 'English souble award',
                     english_studies_single_award: 'English Studies single award',
                     english_studies_double_award: 'English Studies double award' }.freeze

  def initialize(qualification)
    @qualification = qualification
    super(qualification)
  end

  def grade_details
    case qualification.subject
    when ApplicationQualification::SCIENCE_TRIPLE_AWARD
      grades = qualification.constituent_grades
      [
        "#{grades['biology']['grade']} (biology)",
        "#{grades['chemistry']['grade']} (chemistry)",
        "#{grades['physics']['grade']} (physics)",
      ]
    when ApplicationQualification::SCIENCE_DOUBLE_AWARD
      ["#{qualification.grade} (double award)"]
    when ApplicationQualification::SCIENCE_SINGLE_AWARD
      ["#{qualification.grade} (single award)"]
    when ->(_n) { qualification.constituent_grades }
      present_constituent_grades
    else
      [qualification.grade]
    end
  end

private

  def present_constituent_grades
    grades = qualification.constituent_grades
    grades.map do |award, details|
      return "#{details['grade']} (#{ENGLISH_AWARDS[award]})" if ENGLISH_AWARDS.include?(award)

      "#{details['grade']} (#{award.humanize(capitalize: false).sub('english', 'English')})"
    end
  end
end
