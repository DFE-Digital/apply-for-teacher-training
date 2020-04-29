class DuplicateApplication
  attr_reader :original_application_form

  def initialize(original_application_form)
    @original_application_form = original_application_form
  end

  IGNORED_ATTRIBUTES = %w[id created_at updated_at submitted_at course_choices_completed phase].freeze
  IGNORED_CHILD_ATTRIBUTES = %w[id created_at updated_at application_form_id].freeze

  def duplicate
    attrs = original_application_form.attributes.except(
      *IGNORED_ATTRIBUTES,
    ).merge(
      phase: 'apply_2',
    )

    new_application_form = ApplicationForm.create!(attrs)

    original_application_form.application_work_experiences.each do |w|
      new_application_form.application_work_experiences.create!(
        w.attributes.except(*IGNORED_CHILD_ATTRIBUTES),
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

    original_application_form.application_references.feedback_provided.each do |w|
      new_application_form.application_references.create!(
        w.attributes.except(*IGNORED_CHILD_ATTRIBUTES),
      )
    end

    original_application_form.application_work_history_breaks.each do |w|
      new_application_form.application_work_history_breaks.create!(
        w.attributes.except(*IGNORED_CHILD_ATTRIBUTES),
      )
    end

    new_application_form
  end
end
