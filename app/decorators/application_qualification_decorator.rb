class ApplicationQualificationDecorator < SimpleDelegator
  attr_reader :qualification

  ENGLISH_AWARDS = { english_single_award: 'English single award',
                     english_double_award: 'English double award',
                     english_studies_single_award: 'English Studies single award',
                     english_studies_double_award: 'English Studies double award' }.freeze

  def initialize(qualification)
    @qualification = qualification
    super(qualification)
  end

  def grade_details
    return [] if qualification.missing_qualification?

    case qualification.subject
    when ApplicationQualification::SCIENCE_TRIPLE_AWARD
      [
        "#{constituent_grade_for('biology')} (biology)",
        "#{constituent_grade_for('chemistry')} (chemistry)",
        "#{constituent_grade_for('physics')} (physics)",
      ]
    when ApplicationQualification::SCIENCE_DOUBLE_AWARD
      ["#{qualification.grade} (double award)"]
    when ApplicationQualification::SCIENCE_SINGLE_AWARD
      ["#{qualification.grade} (single award)"]
    when ->(_n) { constituent_grades.present? }
      present_constituent_grades
    else
      [qualification.grade]
    end
  end

private

  def present_constituent_grades
    constituent_grades.map do |award, details|
      return "#{details['grade']} (#{ENGLISH_AWARDS[award]})" if ENGLISH_AWARDS.include?(award)

      "#{details['grade']} (#{award.humanize(capitalize: false).sub('english', 'English')})"
    end
  end

  def constituent_grades
    @constituent_grades ||= qualification.constituent_grades || {}
  end

  def constituent_grade_for(subject)
    constituent_grades.dig(subject, 'grade') || 'Grade information not available'
  end
end
