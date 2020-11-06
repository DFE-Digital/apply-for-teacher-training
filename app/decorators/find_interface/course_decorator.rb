class FindInterface::CourseDecorator < Draper::Decorator
  delegate_all

  def name_and_code
    "#{object.name} (#{object.course_code})"
  end

  def outcome
    I18n.t("qualifications.#{object.qualification}")
  end

  def subject_name
    if object.subjects.count == 1
      object.subjects.first.subject_name
    else
      object.name
    end
  end

  def has_scholarship_and_bursary?
    has_bursary? && has_scholarship?
  end

  def bursary_first_line_ending
    if bursary_requirements.count > 1
      ":"
    else
      "#{bursary_requirements.first}."
    end
  end

  def bursary_requirements
    requirements = ["a degree of 2:2 or above in any subject"]

    if object.subjects.any? { |subject| subject.subject_name.downcase == "primary with mathematics" }
      mathematics_requirement = "at least grade B in maths A-level (or an equivalent)"
      requirements.push(mathematics_requirement)
    end

    requirements
  end

  def bursary_only?
    has_bursary? && !has_scholarship?
  end

  def has_bursary?
    object.subjects.present? &&
      object.subjects.any? { |subject| subject.attributes["bursary_amount"].present? }
  end

  def excluded_from_bursary?
    object.subjects.present? &&
      # incorrect bursary eligibility only shows up on courses with 2 subjects
      object.subjects.count == 2 &&
      has_excluded_course_name?
  end

  def has_scholarship?
    object.subjects.present? &&
      object.subjects.any? { |subject| subject.attributes["scholarship"].present? }
  end

  def has_early_career_payments?
    object.subjects.present? &&
      object.subjects.any? { |subject| subject.attributes["early_career_payments"].present? }
  end

  def bursary_amount
    find_max("bursary_amount")
  end

  def scholarship_amount
    find_max("scholarship")
  end

  def salaried?
    object.funding_type == "salary" || object.funding_type == "apprenticeship"
  end

  def apprenticeship?
    object.funding_type == "apprenticeship" ? "Yes" : "No"
  end

  def length
    case object.course_length
    when "OneYear"
      "1 year"
    when "TwoYears"
      "Up to 2 years"
    else
      object.course_length
    end
  end

  def preview_site_statuses
    site_statuses.select(&:new_or_running?).sort_by { |status| status.site.location_name }
  end

  def funding_option
    if salaried?
      "Salary"
    elsif excluded_from_bursary?
      "Student finance if you’re eligible"
    elsif has_scholarship_and_bursary?
      "Scholarships or bursaries, as well as student finance, are available if you’re eligible"
    elsif has_bursary?
      "Bursaries and student finance are available if you’re eligible"
    else
      "Student finance if you’re eligible"
    end
  end

  def display_title
    "#{name} (#{course_code})"
  end

  def has_vacancies?
    object.has_vacancies? ? "Yes" : "No"
  end

  def year_range
    "#{object.recruitment_cycle_year} to #{object.recruitment_cycle_year.to_i + 1}"
  end

  def placements_heading
    if further_education?
      "How teaching placements work"
    else
      "How school placements work"
    end
  end

private

  def find_max(attribute)
    subject_attributes = object.subjects.map do |s|
      if s.attributes[attribute].present?
        s.__send__(attribute).to_i
      end
    end

    subject_attributes.compact.max.to_s
  end

  def has_excluded_course_name?
    exclusions = [
      /^Drama/,
      /^Media Studies/,
      /^PE/,
      /^Physical/,
    ]
    # We only care about course with a name matching the pattern 'Foo with bar'
    # We don't care about courses matching the pattern 'Foo and bar'
    return false unless /with/.match?(object.name)

    exclusions.any? { |e| e.match?(object.name) }
  end
end
