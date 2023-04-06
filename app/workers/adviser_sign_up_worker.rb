class AdviserSignUpWorker
  include Sidekiq::Worker

  attr_reader :application_form, :candidate_matchback, :preferred_teaching_subject_id

  MATCHBACK_ATTRIBUTES = %i[
    candidate_id
    adviser_status_id
    qualification_id
  ].freeze

  def perform(application_form_id, preferred_teaching_subject_id)
    @application_form = Adviser::ApplicationFormValidations.new(
      ApplicationForm.find(application_form_id),
    )
    @candidate_matchback = Adviser::CandidateMatchback.new(application_form)
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
      uk_degree_grade_id: constants.fetch(:uk_degree_grades, degree.grade),
      degree_status_id: constants.fetch(:degree_status, degree.completed? ? :graduated : :studying),
      degree_type_id: constants.fetch(:degree_types, degree.international? ? :international : :domestic),
      has_gcse_maths_and_english_id: constants.fetch(:gcse, pass_gcse_maths_and_english?),
      planning_to_retake_gcse_maths_and_english_id: constants.fetch(:gcse, retaking_gcse_maths_and_english?),
      has_gcse_science_id: constants.fetch(:gcse, pass_gcse_science?),
      planning_to_retake_gcse_science_id: constants.fetch(:gcse, retaking_gcse_science?),
      preferred_teaching_subject_id:,
      preferred_education_phase_id:,
      initial_teacher_training_year_id: current_itt_year.id,
      accepted_policy_id: latest_privacy_policy.id,
      type_id: constants.fetch(:types, :interested_in_teacher_training),
      channel_id: constants.fetch(:channels, :apply),
    }.merge(matchback_attributes)
  end

  def matchback_attributes
    matchback_candidate = candidate_matchback.matchback

    return {} unless matchback_candidate

    matchback_candidate
      .attributes_as_snake_case
      .slice(*MATCHBACK_ATTRIBUTES)
  end

  def degree
    application_form.applicable_degree
  end

  def pass_gcse_maths_and_english?
    pass_gcse_maths? && pass_gcse_english?
  end

  def pass_gcse_maths?
    !!application_form.maths_gcse&.pass_gcse?
  end

  def pass_gcse_english?
    !!application_form.english_gcse&.pass_gcse?
  end

  def retaking_gcse_maths_and_english?
    return false if pass_gcse_maths_and_english?

    retaking_maths = application_form.maths_gcse&.currently_completing_qualification?
    retaking_english = application_form.english_gcse&.currently_completing_qualification?

    !!((pass_gcse_maths? || retaking_maths) && (pass_gcse_english? || retaking_english))
  end

  def pass_gcse_science?
    !!application_form.science_gcse&.pass_gcse?
  end

  def retaking_gcse_science?
    !!application_form.science_gcse&.currently_completing_qualification?
  end

  def preferred_education_phase_id
    phase = preferred_teaching_subject_id == constants.fetch(:teaching_subjects, :primary) ? :primary : :secondary
    constants.fetch(:education_phases, phase)
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

    matching_country&.id || constants.fetch(:countries, :unknown)
  end

  def constants
    Adviser::Constants
  end
end
