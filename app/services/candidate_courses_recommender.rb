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
    candidate_suitable_for_recommendation? && create_recommended_courses_url
  end

private

  attr_reader :candidate, :locatable

  def candidate_suitable_for_recommendation?
    conditions = [
      # Candidate does not have any safeguarding concerns on their applications
      # Candidate does not have any safeguarding concerns on their references
      # Candidate does not have any safeguarding concerns on their rejection reasons
      !candidate.safeguarding_concerns?,

      # Candidate does not have any active applications
      candidate.current_application.application_choices.in_progress.none?,

      # Candidate does not already have QTS
      !candidate.application_choices_rejected_with_already_qualified?,
    ]

    conditions.all?
  end

  def create_recommended_courses_url
    find_url_with_query_params_and_utm if recommended?
  end

  def current_year
    @current_year ||= RecruitmentCycleTimetable.current_year
  end

  def recommended?
    query_parameters.values.any?(&:present?) && courses_available_at_url?
  end

  def courses_available_at_url?
    @courses_available_at_url ||= begin
      # Make get request to find_url_with_query_params using Faraday
      response = Faraday.get(find_url_with_query_params)
      raise "Unexpected response code: #{response.status}" unless response.success?

      # Use Nokogiri to look for the H1 tag with the text "7,536 courses found"
      doc = Nokogiri::HTML(response.body)
      header_text = doc.at_css('h1')&.text
      raise 'Header text not found' unless header_text

      # Parse the count out of the H1 tag
      count, *_parts = header_text.split

      count.to_i.positive?
    rescue StandardError
      false
    end
  end

  def find_url_with_query_params_and_utm
    utm_params = {
      utm_source: :apply,
      utm_medium: :courses_recommender,
    }

    find_url_with_query_params(utm_params)
  end

  def find_url_with_query_params(additional_params = {})
    uri = URI.join(find_url, 'results')
    uri.query = query_parameters
                  .with_defaults(additional_params)
                  .to_query
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
    return unless candidate.current_application.application_choices.visible_to_provider.any?

    # What Courses has the Candidate applied for?
    # course codes & provider codes
    candidate.current_application
             .application_choices
             .visible_to_provider
             .joins(course_option: { course: :provider })
             .pluck('course.code', 'provider.code')
             .compact_blank
             .uniq
             .sort
             .map.with_index { |(course_code, provider_code), index| [index, { course_code: course_code, provider_code: provider_code }] }
             .to_h
  end
end
