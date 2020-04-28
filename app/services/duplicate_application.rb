class DuplicateApplication
  attr_reader :original_application_form

  def initialize(original_application_form)
    @original_application_form = original_application_form
  end

  def duplicate
    attrs = original_application_form.attributes.except(
      *%w[id created_at updated_at submitted_at course_choices_completed phase],
    ).merge(
      phase: 'apply_2',
    )

    new_application_form = ApplicationForm.create!(attrs)

    original_application_form.application_work_experiences.each do |w|
      new_application_form.application_work_experiences.create!(w.attributes.except(*%w[
        id created_at updated_at application_form_id
      ]))
    end

    original_application_form.application_volunteering_experiences.each do |w|
      new_application_form.application_volunteering_experiences.create!(w.attributes.except(*%w[
        id created_at updated_at application_form_id
      ]))
    end

    original_application_form.application_qualifications.each do |w|
      new_application_form.application_qualifications.create!(w.attributes.except(*%w[
        id created_at updated_at application_form_id
      ]))
    end

    original_application_form.application_references.each do |w|
      new_application_form.application_references.create!(w.attributes.except(*%w[
        id created_at updated_at application_form_id
      ]))
    end

    true
  end
end
