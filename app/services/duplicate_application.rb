class DuplicateApplication
  attr_reader :original_application_form

  def initialize(original_application_form, recruitment_cycle_year: RecruitmentCycleTimetable.current_year)
    @original_application_form = original_application_form
    @recruitment_cycle_year = recruitment_cycle_year
  end

  IGNORED_ATTRIBUTES = %w[id created_at updated_at submitted_at course_choices_completed phase support_reference english_main_language english_language_details other_language_details feedback_form_complete equality_and_diversity equality_and_diversity_completed adviser_interruption_response].freeze
  IGNORED_CHILD_ATTRIBUTES = %w[id created_at updated_at application_form_id public_id enic_reason].freeze

  def duplicate
    attrs = original_application_form.attributes.except(
      *IGNORED_ATTRIBUTES,
    ).merge(
      previous_application_form_id: original_application_form.id,
      recruitment_cycle_year: @recruitment_cycle_year,
      work_history_status: original_application_form.work_history_status || 'can_complete',
    )

    ApplicationForm.create!(attrs).tap do |new_application_form|
      original_application_form.application_work_experiences.each do |w|
        new_application_form.application_work_experiences.create!(
          w.attributes.except(*IGNORED_CHILD_ATTRIBUTES).merge('currently_working' => infer_currently_working(w)),
        )
      end

      if !original_application_form.restructured_immigration_status? &&
         new_application_form.restructured_immigration_status? &&
         !new_application_form.british_or_irish?
        new_application_form.update(
          personal_details_completed: false,
        )
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
        .reject(&:feedback_overdue?)

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
        EnglishProficiency.create!(
          **original_application_form.english_proficiency.attributes.except(*IGNORED_CHILD_ATTRIBUTES),
          efl_qualification:,
          application_form: new_application_form,
        )
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
    end
  end

private

  def infer_currently_working(application_experience)
    return application_experience.currently_working unless application_experience.currently_working.nil?

    application_experience.start_date <= Time.zone.today &&
      (application_experience.end_date.nil? || application_experience.end_date >= Time.zone.today)
  end

  def change_references_to_not_requested_yet(references)
    references.update_all(feedback_status: 'not_requested_yet')
  end
end
