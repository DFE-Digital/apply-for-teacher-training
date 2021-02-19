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

  %i[reference application_volunteering_experience application_work_experience application_qualification application_work_history_break].each do |form_attribute|
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

  describe 'EFL qualifications' do
    %i[ielts_qualification toefl_qualification other_efl_qualification].each do |qualification_type|
      it "updates the application_choices when a #{qualification_type} is added" do
        application_form = create(:completed_application_form, application_choices_count: 1)

        qualification_type_trait = :"with_#{qualification_type}"

        expect { create(:english_proficiency, qualification_type_trait, application_form: application_form) }
          .to(change { application_form.application_choices.first.updated_at })
      end

      it "updates the application_choices when a #{qualification_type} is updated" do
        application_form = create(:completed_application_form, application_choices_count: 1)

        qualification_type_trait = :"with_#{qualification_type}"

        english_proficiency = create(:english_proficiency, qualification_type_trait, application_form: application_form)

        expect { english_proficiency.efl_qualification.update(updated_at: Time.zone.now) }
            .to(change { english_proficiency.updated_at })
      end

      it "updates the application_choices when a #{qualification_type} is deleted" do
        application_form = create(:completed_application_form, application_choices_count: 1)

        qualification_type_trait = :"with_#{qualification_type}"

        english_proficiency = create(:english_proficiency, qualification_type_trait, application_form: application_form)

        expect { english_proficiency.efl_qualification.destroy! }
          .to(change { application_form.application_choices.first.updated_at })
      end
    end
  end
end
