require 'rails_helper'

RSpec.describe '#update' do
  before do
    TestSuiteTimeMachine.unfreeze!
  end

  it 'updates the application_choices when the form is updated' do
    original_time = 1.day.ago
    application_form = create(:application_form)
    application_choices = create_list(
      :application_choice,
      2,
      application_form:,
      updated_at: original_time,
    )

    application_form.update!(first_name: 'Something else')
    application_choices.each(&:reload)

    expect(application_choices.map(&:updated_at)).not_to include(original_time)
  end

  describe 'ApplicationQualification' do
    it 'updates the application_choices when an ApplicationQualification is added' do
      application_form = create(:completed_application_form, application_choices_count: 1)

      expect { create(:application_qualification, application_form:) }
        .to(change { application_form.application_choices.first.updated_at })
    end

    it 'updates the application_choices when an ApplicationQualification is updated' do
      application_form = create(:completed_application_form, application_choices_count: 1)
      model = create(:application_qualification, application_form:)

      expect { model.update(updated_at: Time.zone.now) }
        .to(change { application_form.application_choices.first.updated_at })
    end

    it 'updates the application_choices when an ApplicationQualification is deleted' do
      application_form = create(:completed_application_form, application_choices_count: 1)
      model = create(:application_qualification, application_form:)

      expect { model.destroy! }
        .to(change { application_form.application_choices.first.updated_at })
    end
  end

  describe 'ApplicationReference' do
    let(:application_form) { create(:completed_application_form) }

    context 'when the application choice is in a status where references are not visible to providers' do
      [:unsubmitted, :cancelled, :awaiting_provider_decision, :inactive, :interviewing, :offer, :rejected,
       :application_not_sent, :offer_withdrawn, :declined, :withdrawn].each do |status|
        it "updates the application_choices (status: #{status}) when a reference is added" do
          create(:application_choice, application_form: application_form, status:)
          expect { create(:reference, application_form:) }
            .not_to(change { application_form.application_choices.first.updated_at })
        end

        it "updates the application_choices (status: #{status}) when a reference is updated" do
          create(:application_choice, application_form: application_form, status:)
          model = create(:reference, application_form:)

          expect { model.update(updated_at: Time.zone.now) }
            .not_to(change { application_form.application_choices.first.updated_at })
        end

        it "updates the application_choices (status: #{status}) when a reference is deleted" do
          create(:application_choice, application_form: application_form, status:)
          model = create(:reference, application_form:)

          expect { model.destroy! }
            .not_to(change { application_form.application_choices.first.updated_at })
        end
      end
    end

    context 'when the application choice is in a status where references are visible to providers' do
      %i[pending_conditions conditions_not_met recruited offer_deferred].each do |status|
        it "updates the application_choices (status: #{status}) when a reference is added" do
          create(:application_choice, application_form: application_form, status:)
          expect { create(:reference, application_form:) }
            .to(change { application_form.application_choices.first.updated_at })
        end

        it "updates the application_choices (status: #{status}) when a reference is updated" do
          create(:application_choice, application_form: application_form, status:)
          model = create(:reference, application_form:)

          expect { model.update(updated_at: Time.zone.now) }
            .to(change { application_form.application_choices.first.updated_at })
        end

        it "updates the application_choices (status: #{status}) when a reference is deleted" do
          create(:application_choice, application_form: application_form, status:)
          model = create(:reference, application_form:)

          expect { model.destroy! }
            .to(change { application_form.application_choices.first.updated_at })
        end
      end
    end
  end

  it 'does not update application_choices when unrelated models that touch the form are updated' do
    application_form = create(:completed_application_form, application_choices_count: 1)
    feedback = create(:application_feedback, application_form:)

    expect { feedback.update(feedback: 'It was easy to do really') }
      .not_to(change { application_form.application_choices.first.updated_at })
  end

  describe 'EFL qualifications' do
    %i[ielts_qualification toefl_qualification other_efl_qualification].each do |qualification_type|
      it "updates the application_choices when a #{qualification_type} is added" do
        application_form = create(:completed_application_form, application_choices_count: 1)

        qualification_type_trait = :"with_#{qualification_type}"

        expect { create(:english_proficiency, qualification_type_trait, application_form:) }
          .to(change { application_form.application_choices.first.updated_at })
      end

      it "updates the application_choices when a #{qualification_type} is updated" do
        application_form = create(:completed_application_form, application_choices_count: 1)

        qualification_type_trait = :"with_#{qualification_type}"

        english_proficiency = create(:english_proficiency, qualification_type_trait, application_form:)

        expect { english_proficiency.efl_qualification.update(updated_at: Time.zone.now) }
            .to(change { english_proficiency.updated_at })
      end

      it "updates the application_choices when a #{qualification_type} is deleted" do
        application_form = create(:completed_application_form, application_choices_count: 1)

        qualification_type_trait = :"with_#{qualification_type}"

        english_proficiency = create(:english_proficiency, qualification_type_trait, application_form:)

        expect { english_proficiency.efl_qualification.destroy! }
          .to(change { application_form.application_choices.first.updated_at })
      end
    end
  end
end
