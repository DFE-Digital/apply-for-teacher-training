class UCASMatchedApplication
  def initialize(matching_data, recruitment_cycle_year)
    @matching_data = matching_data
    @recruitment_cycle_year = recruitment_cycle_year
  end

  def course
    course = Course.find_by(
      code: @matching_data['Course code'],
      provider: Provider.find_by(code: @matching_data['Provider code']),
      recruitment_cycle_year: @recruitment_cycle_year,
    )

    if course.nil?
      OpenStruct.new(
        code: @matching_data['Course code'].presence || 'Missing course code',
        name: @matching_data['Course name'].presence || 'Missing course name',
        provider: Provider.find_by(code: @matching_data['Provider code']),
      )
    else
      course
    end
  end

  def valid_matching_data?
    # UCAS matches can't be invalid
    return true if ucas_scheme?

    application_choice.present?
  end

  def trackable_applicant_key
    @matching_data['Trackable applicant key']
  end

  def scheme
    @matching_data['Scheme']
  end

  def ucas_scheme?
    scheme == 'U'
  end

  def dfe_scheme?
    scheme == 'D'
  end

  def both_scheme?
    scheme == 'B'
  end

  def status
    if !valid_matching_data?
      'invalid_data'
    elsif ucas_scheme?
      mapped_ucas_status
    else
      application_choice.status
    end
  end

  def mapped_ucas_status
    if @matching_data['Rejects'] == '1'
      'rejected'
    elsif @matching_data['Withdrawns'] == '1'
      'withdrawn'
    elsif @matching_data['Declined offers'] == '1'
      'declined'
    elsif @matching_data['Conditional firm'] == '1'
      'pending_conditions'
    elsif @matching_data['Unconditional firm'] == '1'
      'recruited'
    elsif @matching_data['Offers'] == '1'
      'offer'
    else
      'awaiting_provider_decision'
    end
  end

  def application_in_progress_on_ucas?
    return false if dfe_scheme? || provider_not_on_apply?

    !ApplicationStateChange::UNSUCCESSFUL_END_STATES.include?(mapped_ucas_status.to_sym)
  end

  def application_in_progress_on_apply?
    return false if ucas_scheme?

    !ApplicationStateChange::UNSUCCESSFUL_END_STATES.include?(status.to_sym)
  end

  def application_accepted_on_ucas?
    return false if dfe_scheme? || provider_not_on_apply?

    ApplicationStateChange::ACCEPTED_STATES.include?(mapped_ucas_status.to_sym)
  end

  def application_accepted_on_apply?
    return false if ucas_scheme?

    ApplicationStateChange::ACCEPTED_STATES.include?(status.to_sym)
  end

  def application_withdrawn_on_apply?
    application_choice.status.eql?('withdrawn')
  end

  def application_withdrawn_on_ucas?
    mapped_ucas_status.eql?('withdrawn')
  end

  def application_choice
    @application_choice ||=
      ApplicationChoice.includes(:application_form)
      .where('application_forms.candidate_id = ?', @matching_data['Apply candidate ID'])
      .references(:application_forms)
      .find_by(course_option: course.course_options)
  end

private

  def provider_not_on_apply?
    !Provider.exists?(code: @matching_data['Provider code'])
  end
end
