require 'rails_helper'

RSpec.describe ReinstateConditionsMet do
  subject(:service) do
    described_class.new(actor: provider_user,
                        application_choice: application_choice,
                        course_option: new_course_option)
  end

  let(:provider_user) { create(:provider_user, :with_provider, :with_make_decisions) }
  let(:provider) { provider_user.providers.first }
  let(:original_course) { create(:course, :open_on_apply, :previous_year_but_still_available, provider: provider) }
  let(:previous_course_option) { create(:course_option, course: original_course) }
  let(:new_course_option) { create(:course_option, course: original_course.in_next_cycle) }
  let(:application_choice) { create(:application_choice, :with_deferred_offer, course_option: previous_course_option) }

  it 'changes application status to \'recruited\'' do
    expect { service.save }.to change(application_choice, :status).to('recruited')
  end

  it 'changes current_course_option_id for the application choice' do
    expect { service.save }.to change(application_choice, :current_course_option_id)
  end

  it 'sets the application\'s recruited_at date if conditions had not been met before' do
    Timecop.freeze do
      expect { service.save }.to change(application_choice, :recruited_at).to(Time.zone.now)
    end
  end

  it 'does not modify recruited_at if conditions had already been met before' do
    application_choice.update(status_before_deferral: 'recruited',
                              recruited_at: application_choice.accepted_at + 7.days)

    Timecop.freeze do
      expect { service.save }.not_to change(application_choice, :recruited_at)
    end
  end

  it 'updates the status of all conditions to met' do
    offer = Offer.find_by(application_choice: application_choice)

    expect { service.save }.to change { offer.reload.conditions.first.status }.from('pending').to('met')
  end

  context 'when the application does not have an offer object associated' do
    let(:conditions) { [build(:offer_condition, text: 'Be cool')] }
    let(:application_choice) do
      create(:application_choice,
             :with_offer,
             :offer_deferred,
             offer: build(:offer, conditions: conditions),
             status_before_deferral: :pending_conditions,
             course_option: previous_course_option)
    end

    it 'creates an offer object' do
      service.save

      offer = Offer.find_by(application_choice: application_choice)
      expect(offer).not_to be_nil
      expect(offer.conditions.first.status).to eq('met')
    end
  end

  describe 'validations' do
    context 'checks the course option is present' do
      let(:new_course_option) { nil }

      it 'save! raises a ValidationException' do
        expect { service.save! }
          .to raise_error(ValidationException, 'Please provide a course_option or course_option_id')
      end

      it 'save returns false' do
        expect(service.save).to be false
      end
    end

    context 'checks the course is open on apply' do
      let(:new_course_option) do
        create(:course_option,
               course: create(:course, provider: provider, open_on_apply: false))
      end

      it 'save! raises a ValidationException' do
        expect { service.save! }
          .to raise_error(ValidationException, 'The requested course is not open for applications via the Apply service')
      end

      it 'save returns false' do
        expect(service.save).to be false
      end
    end

    context 'checks course option matches the current RecruitmentCycle' do
      let(:new_course_option) { previous_course_option }

      it 'save! raises a ValidationException' do
        expect { service.save! }
          .to raise_error(ValidationException, 'The requested course does not exist in the current cycle')
      end

      it 'save returns false' do
        expect(service.save).to be false
      end
    end

    context 'when the application is not in a state allowing to reinstate conditions met' do
      let(:application_choice) do
        create(:application_choice, :awaiting_provider_decision,
               course_option: previous_course_option)
      end

      it 'save! raises a Workflow::NoTransitionAllowed error' do
        expect { service.save!  }
          .to raise_error(Workflow::NoTransitionAllowed,
                          'There is no event reinstate_conditions_met defined for the awaiting_provider_decision state')
      end

      it 'save returns false' do
        expect(service.save).to be false
      end
    end
  end

  describe 'other dependencies' do
    it 'calls update_course_option_and_associated_fields!' do
      allow(application_choice).to receive(:update_course_option_and_associated_fields!)
      service.save
      expect(application_choice).to have_received(:update_course_option_and_associated_fields!)
    end
  end
end
