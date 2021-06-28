class DuplicateApplication
  attr_reader :original_application_form, :target_phase

  def initialize(original_application_form, target_phase:, recruitment_cycle_year: RecruitmentCycle.current_year)
    @original_application_form = original_application_form
    @target_phase = target_phase
    @recruitment_cycle_year = recruitment_cycle_year
  end

  IGNORED_ATTRIBUTES = %w[id created_at updated_at submitted_at course_choices_completed phase support_reference].freeze
  IGNORED_CHILD_ATTRIBUTES = %w[id created_at updated_at application_form_id public_id].freeze
  IGNORED_LEGACY_WORK_HISTORY_ATTRIBUTES = %w[working_with_children working_pattern].freeze

  def duplicate
    attrs = original_application_form.attributes.except(
      *IGNORED_ATTRIBUTES,
    ).merge(
      phase: target_phase,
      previous_application_form_id: original_application_form.id,
      recruitment_cycle_year: @recruitment_cycle_year,
    )

    new_application_form = ApplicationForm.create!(attrs)

    original_application_form.application_work_experiences.each do |w|
      new_application_form.application_work_experiences.create!(
        w.attributes.except(*ignored_work_experience_attributes).merge('currently_working' => infer_currently_working(w)),
      )
    end
    if original_application_form.feature_restructured_work_history == false &&
        FeatureFlag.active?(:restructured_work_history)
      new_application_form.update(
        feature_restructured_work_history: true,
        work_history_completed: false,
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

    original_application_form.application_references.where(feedback_status: %w[feedback_provided not_requested_yet cancelled_at_end_of_cycle]).reject(&:feedback_overdue?).each do |w|
      new_application_form.application_references.create!(
        w.attributes.except(*IGNORED_CHILD_ATTRIBUTES).merge!(duplicate: true),
      )

      references_cancelled_at_eoc = new_application_form.application_references.select(&:cancelled_at_end_of_cycle?)

      if references_cancelled_at_eoc.present?
        references_cancelled_at_eoc.each(&:not_requested_yet!)
      end
    end

    original_application_form.application_work_history_breaks.each do |w|
      new_application_form.application_work_history_breaks.create!(
        w.attributes.except(*IGNORED_CHILD_ATTRIBUTES),
      )
    end

    new_application_form
  end

private

  def ignored_work_experience_attributes
    if original_application_form.feature_restructured_work_history == false &&
        FeatureFlag.active?(:restructured_work_history)
      IGNORED_CHILD_ATTRIBUTES + IGNORED_LEGACY_WORK_HISTORY_ATTRIBUTES
    else
      IGNORED_CHILD_ATTRIBUTES
    end
  end

  def infer_currently_working(application_experience)
    return application_experience.currently_working unless application_experience.currently_working.nil?

    application_experience.start_date < Time.zone.today &&
      (application_experience.end_date.nil? || application_experience.end_date > Time.zone.today)
  end
end
