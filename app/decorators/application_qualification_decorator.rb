class ApplicationQualificationDecorator < SimpleDelegator
  attr_reader :qualification

  ENGLISH_AWARDS = { english_single_award: 'English Single award',
                     english_double_award: 'English Double award',
                     english_studies_single_award: 'English Studies Single award',
                     english_studies_double_award: 'English Studies Double award' }.freeze

  def initialize(qualification)
    @qualification = qualification
    super(qualification)
  end

  def grade_details
    case qualification.subject
    when ApplicationQualification::SCIENCE_TRIPLE_AWARD
      grades = qualification.constituent_grades
      [
        "#{grades['biology']['grade']} (Biology)",
        "#{grades['chemistry']['grade']} (Chemistry)",
        "#{grades['physics']['grade']} (Physics)",
      ]
    when ApplicationQualification::SCIENCE_DOUBLE_AWARD
      ["#{qualification.grade} (Double award)"]
    when ApplicationQualification::SCIENCE_SINGLE_AWARD
      ["#{qualification.grade} (Single award)"]
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

      "#{details['grade']} (#{award.humanize.titleize})"
    end
  end
end
