require 'rails_helper'

RSpec.describe '#update' do
  it 'updates the application_choices when the form is updated' do
    original_time = Time.zone.now - 1.day
    application_form = create(:application_form)
    application_choices = create_list(
      :application_choice,
      2,
      application_form: application_form,
      updated_at: original_time,
    )

    application_form.update!(first_name: 'Something else')
    application_choices.each(&:reload)

    expect(application_choices.map(&:updated_at)).not_to include(original_time)
  end

  %w[reference application_volunteering_experience application_work_experience application_qualification application_work_history_break].each do |form_attribute|
    it "updates the application_choices when a #{form_attribute} is added" do
      application_form = create(:completed_application_form, application_choices_count: 1)

      expect { create(form_attribute, application_form: application_form) }
        .to(change { application_form.application_choices.first.updated_at })
    end

    it "updates the application_choices when a #{form_attribute} is updated" do
      application_form = create(:completed_application_form, application_choices_count: 1)
      model = create(form_attribute, application_form: application_form)

      expect { model.update(updated_at: Time.zone.now) }
        .to(change { application_form.application_choices.first.updated_at })
    end

    it "updates the application_choices when a #{form_attribute} is deleted" do
      application_form = create(:completed_application_form, application_choices_count: 1)
      model = create(form_attribute, application_form: application_form)

      expect { model.destroy! }
        .to(change { application_form.application_choices.first.updated_at })
    end
  end

  it 'does not update application_choices when unrelated models that touch the form are updated' do
    application_form = create(:completed_application_form, application_choices_count: 1)
    feedback = create(:application_feedback, application_form: application_form)

    expect { feedback.update(feedback: 'It was easy to do really') }
      .not_to(change { application_form.application_choices.first.updated_at })
  end

  %w[application_choice reference application_volunteering_experience application_work_experience application_qualification].each do |form_attribute|
    it "updates the form when a #{form_attribute} is added" do
      original_time = Time.zone.now - 1.day
      application_form = create(:application_form, updated_at: original_time)

      create(form_attribute, application_form: application_form)

      expect(application_form.updated_at).not_to eql(original_time)
    end
  end
end
