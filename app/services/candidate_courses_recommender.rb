class CandidateCoursesRecommender
  include Rails.application.routes.url_helpers

  def self.recommended_courses_url(candidate:, locatable: nil)
    new(candidate:, locatable:).recommended_courses_url
  end

  # @param [Provider, Site, ApplicationForm] locatable
  def initialize(candidate:, locatable: nil)
    @candidate = candidate
    @locatable = locatable
  end

  def recommended_courses_url
    find_url_with_query_params if recommended?
  end

private

  attr_reader :candidate, :locatable

  def current_year
    @current_year ||= RecruitmentCycleTimetable.current_year
  end

  def recommended?
    query_parameters.values.any?(&:present?)
  end

  def find_url_with_query_params
    uri = URI("#{find_url}results")
    uri.query = query_parameters.to_query
    uri.to_s
  end

  def query_parameters
    @query_parameters ||= build_query_parameters
  end

  def build_query_parameters
    params = {}

    params[:can_sponsor_visa] = can_sponsor_visa
    params[:minimum_degree_required] = minimum_degree_required
    params[:funding] = funding_type
    params[:study_types] = study_type
    params[:subjects] = subjects
    params[:location] = locatable&.postcode
    params[:excluded_courses] = excluded_courses

    params.compact_blank
  end

  def can_sponsor_visa
    return unless candidate.application_forms
                           .where(recruitment_cycle_year: current_year)
                           .exists?(personal_details_completed: true)

    # Does the Candidate require Courses to sponsor their visa?
    # Returns true if the Candidate does not have the right to work or study in the UK
    requires_visa = candidate.application_forms
                             .where(recruitment_cycle_year: current_year)
                             .exists?(right_to_work_or_study: 'no')
    requires_visa.to_s # 'true' or 'false'
  end

  def minimum_degree_required
    return unless candidate.application_forms
                           .where(recruitment_cycle_year: current_year)
                           .exists?(degrees_completed: true)

    candidate_degree_grades = candidate.degree_qualifications
                                       .joins(:application_form)
                                       .where(application_form: { recruitment_cycle_year: current_year })
                                       .pluck(:grade)

    return 'no_degree_required' if candidate_degree_grades.empty?

    # What Course degree entry requirements can the Candidate meet?
    return 'show_all_courses' if candidate_degree_grades.include?('First-class honours')
    return 'two_two' if candidate_degree_grades.include?('Lower second-class honours (2:2)')
    return 'third_class' if candidate_degree_grades.include?('Third-class honours')

    # The Grades don't match any of the above,
    # so we assume the Candidate can meet any degree entry requirement
    'show_all_courses'
  end

  def funding_type
    # Does the Candidate have any submitted Applications?
    return unless candidate.application_choices
                           .joins(:application_form)
                           .where(application_form: { recruitment_cycle_year: current_year })
                           .exists?(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)

    # What Course funding types has the Candidate applied for?
    candidate.application_choices
                      .joins(:application_form)
                      .where(application_form: { recruitment_cycle_year: current_year })
                             .where(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)
                             .joins(course_option: :course)
                             .pluck('courses.funding_type')
                             .compact_blank
                             .uniq
                             .sort
  end

  def study_type
    # Does the Candidate have any submitted Applications?
    return unless candidate.application_choices
                           .joins(:application_form)
                           .where(application_form: { recruitment_cycle_year: current_year })
                           .exists?(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)

    # What Course study types has the Candidate applied for?
    candidate.application_choices
                           .joins(:application_form)
                           .where(application_form: { recruitment_cycle_year: current_year })
                           .where(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)
                           .joins(course_option: :course)
                           .pluck('course_options.study_mode')
                           .compact_blank
                           .uniq
                           .sort
  end

  def subjects
    # Does the Candidate have any submitted Applications?
    return unless candidate.application_choices
                           .joins(:application_form)
                           .where(application_form: { recruitment_cycle_year: current_year })
                           .exists?(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)

    # What Course subjects has the Candidate applied for?
    # subject codes
    candidate.application_choices
      .joins(:application_form)
      .where(application_form: { recruitment_cycle_year: current_year })
      .where(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)
      .joins(course_option: { course: :subjects })
      .pluck('subjects.code')
      .compact_blank
      .uniq
      .sort
  end

  def excluded_courses
    # Does the Candidate have any submitted Applications?
    return unless candidate.application_choices
                           .joins(:application_form)
                           .where(application_form: { recruitment_cycle_year: current_year })
                           .exists?(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)

    # What Courses has the Candidate applied for?
    # course codes & provider codes
    candidate.application_choices
                       .joins(:application_form)
                       .where(application_form: { recruitment_cycle_year: current_year })
                       .where(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)
                       .joins(course_option: { course: :provider })
                       .pluck('course.code', 'provider.code')
                       .compact_blank
                       .uniq
                       .sort
                       .map.with_index { |(course_code, provider_code), index| [index, { course_code: course_code, provider_code: provider_code }] }
             .to_h
  end
end
