module MinisterialReport
  SUBJECTS = %i[
    art_and_design
    biology
    business_studies
    chemistry
    classics
    computing
    design_and_technology
    drama
    english
    further_education
    geography
    history
    mathematics
    modern_foreign_languages
    music
    other
    physical_education
    physics
    religious_education
    stem
    ebacc
    primary
    secondary
  ].freeze

  NON_TOTAL_SUBJECTS = %i[
    art_and_design
    biology
    business_studies
    chemistry
    classics
    computing
    design_and_technology
    drama
    english
    geography
    history
    mathematics
    modern_foreign_languages
    music
    other
    physical_education
    physics
    religious_education
    primary
  ].freeze

  STEM_SUBJECTS = %i[
    mathematics
    biology
    chemistry
    physics
    computing
  ].freeze

  EBACC_SUBJECTS = %i[
    english
    mathematics
    biology
    chemistry
    physics
    computing
    geography
    history
    modern_foreign_languages
    classics
  ].freeze

  SECONDARY_SUBJECTS = %i[
    art_and_design
    biology
    business_studies
    chemistry
    classics
    computing
    design_and_technology
    drama
    english
    geography
    history
    mathematics
    modern_foreign_languages
    music
    other
    physical_education
    physics
    religious_education
  ].freeze

  SUBJECT_CODE_MAPPINGS = {
    '00' => :primary,
    '01' => :primary,
    '02' => :primary,
    '03' => :primary,
    '04' => :primary,
    '06' => :primary,
    '07' => :primary,
    'W1' => :art_and_design,
    'F0' => :physics,
    'F3' => :physics,
    'C1' => :biology,
    '08' => :business_studies,
    'L1' => :business_studies,
    'F1' => :chemistry,
    '09' => :other,
    'P3' => :other,
    'L5' => :other,
    'P1' => :other,
    'C8' => :other,
    '14' => :other,
    '41' => :other,
    'Q8' => :classics,
    'A0' => :classics,
    'A1' => :classics,
    'A2' => :classics,
    '11' => :computing,
    '12' => :physical_education,
    'C6' => :physical_education,
    'C7' => :physical_education,
    'DT' => :design_and_technology,
    '13' => :drama,
    'Q3' => :english,
    'F8' => :geography,
    'V1' => :history,
    'G1' => :mathematics,
    'W3' => :music,
    'V6' => :religious_education,
    '15' => :modern_foreign_languages,
    '16' => :modern_foreign_languages,
    '17' => :modern_foreign_languages,
    '18' => :modern_foreign_languages,
    '19' => :modern_foreign_languages,
    '20' => :modern_foreign_languages,
    '21' => :modern_foreign_languages,
    '22' => :modern_foreign_languages,
    '24' => :modern_foreign_languages,
  }.freeze

  INTERNATIONAL_RELOCATION_PAYMENT_SUBJECTS = {
    'F0' => :physics,
    'F3' => :physics,
    '15' => :french,
    '17' => :german,
    '22' => :spanish,
  }.freeze

  APPLICATIONS_REPORT_STATUS_MAPPING = {
    unsubmitted: %i[applications],
    application_not_sent: %i[applications],
    awaiting_provider_decision: %i[applications],
    offer: %i[applications offer_received],
    pending_conditions: %i[applications offer_received accepted],
    rejected: %i[applications application_rejected],
    cancelled: %i[applications application_declined],
    offer_deferred: %i[applications offer_received accepted],
    interviewing: %i[applications],
    offer_withdrawn: %i[applications], # TAD do not count these as rejections or offer_received
    conditions_not_met: %i[applications application_rejected],
    declined: %i[applications offer_received application_declined],
    recruited: %i[applications offer_received accepted],
    withdrawn: %i[applications application_withdrawn],
  }.freeze

  TAD_STATUS_PRECEDENCE = {
    recruited: %i[offer_received accepted],
    pending_conditions: %i[offer_received accepted],
    offer_deferred: %i[offer_received accepted],
    offer: %i[offer_received],
    interviewing: nil,
    awaiting_provider_decision: nil,
    declined: %i[offer_received application_declined],
    conditions_not_met: %i[application_rejected],
    rejected: %i[application_rejected],
    withdrawn: %i[application_withdrawn],
    offer_withdrawn: nil,
  }.freeze

  APPLICATIONS_BY_SUBJECT_ROUTE_AND_DEGREE_GRADE_REPORT_STATUS_MAPPING = {
    unsubmitted: %i[applications],
    application_not_sent: %i[applications],
    awaiting_provider_decision: %i[applications],
    offer: %i[applications offers_received],
    pending_conditions: %i[applications offers_received number_of_acceptances],
    rejected: %i[applications number_of_rejected_applications],
    cancelled: %i[applications number_of_declined_applications],
    offer_deferred: %i[applications offers_received number_of_acceptances],
    interviewing: %i[applications],
    offer_withdrawn: %i[applications number_of_withdrawn_applications],
    conditions_not_met: %i[applications offers_received],
    declined: %i[applications number_of_declined_applications],
    recruited: %i[applications offers_received number_of_acceptances],
    withdrawn: %i[applications],
  }.freeze

  FURTHER_EDUCATION_COURSE_LEVELS = [
    'Further education',
    'further_education',
  ].freeze

  def self.determine_dominant_course_subject_for_report(course)
    course_name = course.name
    course_level = course.level
    subjects = course.subjects.sort_by(&:id)
    subject_names_and_codes = subjects.to_h { |subject| [subject.name, subject.code] }

    determine_dominant_subject_for_report(course_name, course_level, subject_names_and_codes)
  end

  def self.determine_dominant_subject_for_report(course_name, course_level, subject_names_and_codes)
    subject_names = subject_names_and_codes.keys

    return :further_education if FURTHER_EDUCATION_COURSE_LEVELS.include?(course_level)

    # is there only one subject?
    subject = subject_names.first if subject_names.size == 1

    # is subject first in the course name?
    if !subject
      subject = subject_names.find do |subject_name|
        course_name.split.first.downcase.in?(subject_name.to_s.downcase)
      end
    end

    # is it a PE course
    if !subject
      subject = subject_names.find do |subject_name|
        subject_name.to_s.downcase == 'physical education' && (course_name.downcase.include?('pe') || course_name.downcase.include?('p.e'))
      end
    end

    # is subject in the course name at all?
    if !subject
      subject = subject_names.find do |subject_name|
        subject_name.to_s.downcase.in?(course_name.downcase)
      end
    end

    # take the first subject value if unable to match above
    if !subject
      subject = subject_names.first
    end

    subject_code_for_report = subject_names_and_codes[subject]

    SUBJECT_CODE_MAPPINGS[subject_code_for_report].presence || course_level.downcase.to_sym
  end
end
