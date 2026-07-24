class DuplicateApplication
  attr_reader :original_application_form

  def initialize(original_application_form, recruitment_cycle_year: RecruitmentCycleTimetable.current_year)
    @original_application_form = original_application_form
    @recruitment_cycle_year = recruitment_cycle_year
  end

  IGNORED_ATTRIBUTES = %w[id created_at updated_at submitted_at contact_details_completed course_choices_completed phase support_reference english_main_language english_language_details other_language_details efl_completed efl_completed_at feedback_form_complete equality_and_diversity_completed equality_and_diversity_completed_at adviser_interruption_response].freeze
  IGNORED_CHILD_ATTRIBUTES = %w[id created_at updated_at application_form_id public_id enic_reason].freeze

  def duplicate
    attrs = original_application_form.attributes.except(
      *IGNORED_ATTRIBUTES,
    ).merge(
      previous_application_form_id: original_application_form.id,
      recruitment_cycle_year: @recruitment_cycle_year,
      work_history_status: original_application_form.work_history_status || 'can_complete',
    ).merge(*nationalities)

    ApplicationForm.create!(attrs).tap do |new_application_form|
      original_application_form.application_work_experiences.each do |w|
        new_application_form.application_work_experiences.create!(
          w.attributes.except(*IGNORED_CHILD_ATTRIBUTES).merge('currently_working' => infer_currently_working(w)),
        )
      end

      if !new_application_form.british_or_irish?
        new_application_form.update(
          personal_details_completed: false,
        )

        if visa_carry_over_condition_not_met_for_2027(new_application_form, original_application_form)
          || subsequent_years_visa_carry_over_condition_not_met(new_application_form, original_application_form)
          new_application_form.update(
            immigration_status: nil,
            visa_expired_at: nil,
            right_to_work_or_study: nil,
            right_to_work_or_study_details: nil,
          )
        end
      end

      original_application_form.application_volunteering_experiences.each do |w|
        new_application_form.application_volunteering_experiences.create!(
          w.attributes.except(*IGNORED_CHILD_ATTRIBUTES),
        )
      end

      original_application_form.application_qualifications.each do |w|
        new_application_form.application_qualifications.create!(
          w.attributes.except(*IGNORED_CHILD_ATTRIBUTES),
        )

        next unless w.non_uk_qualification_type.present? && unstructured_qualification_from_a_structured_qualification_country?(w)
                      && %w[english maths science].include?(w.subject)

        new_application_form.update(
          "#{w.subject}_gcse_completed": false,
        )
      end

      if new_application_form.incomplete_degree_information?
        new_application_form.update!(degrees_completed: false)
      end

      if original_application_form.degrees?
        new_application_form.update!(university_degree: true)
      end

      original_references = original_application_form.application_references
        .includes([:reference_tokens])
        .creation_order
        .where(feedback_status: %w[feedback_provided not_requested_yet cancelled_at_end_of_cycle feedback_requested])

      original_references.each do |original_reference|
        new_application_form.application_references.create!(
          original_reference.attributes.except(*IGNORED_CHILD_ATTRIBUTES).merge!(duplicate: true),
        )

        awaiting_response_references = new_application_form.application_references.creation_order.feedback_requested
        change_references_to_not_requested_yet(awaiting_response_references)

        references_cancelled_at_eoc = new_application_form.application_references.creation_order.cancelled_at_end_of_cycle

        change_references_to_not_requested_yet(references_cancelled_at_eoc)
      end

      new_application_form.update!(references_completed: false)

      if original_application_form.english_proficiency.present?
        efl_qualification = if original_application_form.english_proficiency.efl_qualification.present?
                              original_application_form.english_proficiency.efl_qualification_type.constantize.new(
                                **original_application_form.english_proficiency.efl_qualification.attributes.except(*IGNORED_CHILD_ATTRIBUTES),
                              )
                            end
        dup_english_proficiency = EnglishProficiency.create!(
          **original_application_form.english_proficiency.attributes.except(*IGNORED_CHILD_ATTRIBUTES),
          efl_qualification:,
          application_form: new_application_form,
        )
        # TODO: Remove after 1 Nov
        if dup_english_proficiency.qualification_statuses.blank?
          if dup_english_proficiency.qualification_status == 'has_qualification'
            dup_english_proficiency.update!(has_qualification: true)
          elsif dup_english_proficiency.qualification_status == 'no_qualification'
            dup_english_proficiency.update!(no_qualification: true)
          elsif dup_english_proficiency.qualification_status == 'qualification_not_needed'
            dup_english_proficiency.update!(qualification_not_needed: true)
          end
        end
      end

      original_application_form.application_work_history_breaks.each do |w|
        new_application_form.application_work_history_breaks.create!(
          w.attributes.except(*IGNORED_CHILD_ATTRIBUTES),
        )
      end

      original_candidate_preference = original_application_form.published_preferences.last
      if original_candidate_preference.present? && original_candidate_preference.opt_in?
        new_candidate_preference = new_application_form.preferences.create!(
          **original_candidate_preference.attributes.except(*IGNORED_ATTRIBUTES),
          status: 'duplicated',
        )
        if original_candidate_preference.training_locations_specific?
          original_candidate_preference.location_preferences.each do |location_preference|
            new_candidate_preference.location_preferences.create!(
              location_preference.attributes.except(*IGNORED_ATTRIBUTES),
            )
          end
        end
      end

      original_previous_teacher_trainings = original_application_form.published_previous_teacher_trainings

      if original_previous_teacher_trainings.blank?
        new_application_form.update!(previous_teacher_training_completed: false)
      else
        new_application_form.published_previous_teacher_trainings.create!(
          original_previous_teacher_trainings.map do |original_previous_teacher_training|
            original_previous_teacher_training.attributes.except(*IGNORED_ATTRIBUTES)
          end,
        )
        new_application_form.update!(previous_teacher_training_completed: true)
      end

      if new_application_form.recruitment_cycle_year <= 2024
        new_application_form.update!(equality_and_diversity: nil)
      end

      if original_application_form.never_asked?
        new_application_form.update!(
          safeguarding_issues_completed: nil,
          safeguarding_issues_status: 'not_answered_yet',
          safeguarding_issues_completed_at: nil,
        )
      end
    end
  end

private

  def multiple_previous_teacher_trainings_2025?
    original_application_form.recruitment_cycle_year == 2025 && original_application_form.published_previous_teacher_trainings.many?
  end

  def single_previous_teacher_training_2025?
    original_application_form.recruitment_cycle_year == 2025 && original_application_form.published_previous_teacher_trainings.one?
  end

  def visa_carry_over_condition_not_met_for_2027(new_application_form, original_application_form)
    new_application_form.recruitment_cycle_year == 2027
        && original_application_form.temporary_immigration_status?
  end

  def subsequent_years_visa_carry_over_condition_not_met(new_application_form, original_application_form)
    new_application_form.recruitment_cycle_year > 2027 &&
      original_application_form.visa_expired_at.present? && original_application_form.visa_expired_at <= Time.zone.today
  end

  def unstructured_qualification_from_a_structured_qualification_country?(qualification)
    InternationalQualifications::StructuredGcseOptionFinder
      .new(qualification.institution_country, qualification.subject)
      .international_qualifications
      .none? { |qual| qual.name == qualification.non_uk_qualification_type }
  end

  def infer_currently_working(application_experience)
    return application_experience.currently_working unless application_experience.currently_working.nil?

    application_experience.start_date <= Time.zone.today &&
      (application_experience.end_date.nil? || application_experience.end_date >= Time.zone.today)
  end

  def change_references_to_not_requested_yet(references)
    references.update_all(feedback_status: 'not_requested_yet')
  end

  def nationalities
    # Remove any nationalities that do not map to existing nationalities
    invalid_nationalities = %i[
      first_nationality
      second_nationality
      third_nationality
      fourth_nationality
      fifth_nationality
    ].filter do |nat|
      nationality = original_application_form.public_send(nat)
      nationality.present? &&
        UK_NATIONALITIES.exclude?(nationality) &&
        NATIONALITIES_BY_NAME[original_application_form.public_send(nat)].blank?
    end

    if invalid_nationalities.empty?
      {}
    else
      invalid_nationalities.map do |n|
        { n => nil }
      end << { personal_details_completed: false }
    end
  end
end
