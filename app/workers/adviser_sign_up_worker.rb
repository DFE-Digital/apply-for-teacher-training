class AdviserSignUpWorker
  include Sidekiq::Worker

  attr_reader :application_form, :preferred_teaching_subject_id

  CHANNELS = {
    apply: 222_750_049,
  }.freeze
  DEGREE_STATUS = {
    graduated: 222_750_000,
    studying: 222_750_001,
  }.freeze
  UK_DEGREE_GRADES = {
    'First-class honours' => 222_750_001,
    'Upper second-class honours (2:1)' => 222_750_002,
    'Lower second-class honours (2:2)' => 222_750_003,
  }.freeze
  DEGREE_TYPES = {
    domestic: 222_750_000,
    international: 222_750_005,
  }.freeze
  TYPES = {
    interested_in_teacher_training: 222_750_000,
  }.freeze
  GCSE = {
    yes: 222_750_000,
    no: 222_750_001,
  }.freeze
  SUBJECTS = {
    primary: 'b02655a1-2afa-e811-a981-000d3a276620',
  }.freeze
  EDUCATION_PHASES = {
    primary: 222_750_000,
    secondary: 222_750_001,
  }.freeze
  COUNTRIES = {
    unknown: '76f5c2e6-74f9-e811-a97a-000d3a2760f2',
  }.freeze

  def perform(application_form_id, preferred_teaching_subject_id)
    @application_form = Adviser::ApplicationFormValidations.new(
      ApplicationForm.find(application_form_id),
    )
    @preferred_teaching_subject_id = preferred_teaching_subject_id

    request = GetIntoTeachingApiClient::TeacherTrainingAdviserSignUp.new(attributes)
    api.sign_up_teacher_training_adviser_candidate(request)
  end

private

  def attributes
    {
      email: application_form.email_address,
      first_name: application_form.first_name,
      last_name: application_form.last_name,
      date_of_birth: application_form.date_of_birth,
      address_telephone: application_form.phone_number,
      address_postcode: application_form.postcode,
      country_id:,
      degree_subject: degree.subject,
      uk_degree_grade_id: UK_DEGREE_GRADES[degree.grade],
      degree_status_id: degree.completed? ? DEGREE_STATUS[:graduated] : DEGREE_STATUS[:studying],
      degree_type_id: degree.international? ? DEGREE_TYPES[:international] : DEGREE_TYPES[:domestic],
      has_gcse_maths_and_english_id: pass_gcse_maths_and_english? ? GCSE[:yes] : GCSE[:no],
      planning_to_retake_gcse_maths_and_english_id: retaking_gcse_maths_and_english? ? GCSE[:yes] : GCSE[:no],
      has_gcse_science_id: pass_gcse_science? ? GCSE[:yes] : GCSE[:no],
      planning_to_retake_gcse_science_id: retaking_gcse_science? ? GCSE[:yes] : GCSE[:no],
      preferred_teaching_subject_id:,
      preferred_education_phase_id:,
      initial_teacher_training_year_id: current_itt_year.id,
      accepted_policy_id: latest_privacy_policy.id,
      type_id: TYPES[:interested_in_teacher_training],
      channel_id: CHANNELS[:apply],
    }
  end

  def degree
    application_form.applicable_degree
  end

  def pass_gcse_maths_and_english?
    application_form.maths_gcse&.pass_gcse? && application_form.english_gcse&.pass_gcse?
  end

  def retaking_gcse_maths_and_english?
    application_form.maths_gcse&.currently_completing_qualification? &&
      application_form.english_gcse&.currently_completing_qualification?
  end

  def pass_gcse_science?
    application_form.science_gcse&.pass_gcse?
  end

  def retaking_gcse_science?
    application_form.science_gcse&.currently_completing_qualification?
  end

  def preferred_education_phase_id
    preferred_teaching_subject_id == SUBJECTS[:primary] ? EDUCATION_PHASES[:primary] : EDUCATION_PHASES[:secondary]
  end

  def current_itt_year
    today = Time.zone.today
    cutoff_date = Date.new(today.year, 9, 7)
    current_year = today < cutoff_date ? today.year : today.year + 1

    itt_years.find { |itt_year| itt_year.value == current_year.to_s }
  end

  def itt_years
    @itt_years ||= GetIntoTeachingApiClient::PickListItemsApi.new.get_candidate_initial_teacher_training_years
  end

  def countries
    @countries ||= GetIntoTeachingApiClient::LookupItemsApi.new.get_countries
  end

  def latest_privacy_policy
    @latest_privacy_policy ||= GetIntoTeachingApiClient::PrivacyPoliciesApi.new.get_latest_privacy_policy
  end

  def api
    @api ||= GetIntoTeachingApiClient::TeacherTrainingAdviserApi.new
  end

  def country_id
    matching_country = countries.find { |country| country.iso_code == application_form.country }

    matching_country&.id || COUNTRIES[:unknown]
  end
end
