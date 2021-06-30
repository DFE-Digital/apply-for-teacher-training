require 'rails_helper'

RSpec.describe ProviderInterface::SaveConditionStatuses do
  let(:application_choice) { create(:application_choice, :with_accepted_offer, offer: offer) }
  let(:offer) { create(:offer, conditions: conditions) }
  let(:conditions) { create_list(:offer_condition, 3, status: :pending) }
  let(:new_conditions) { conditions }

  let(:statuses_form_object) do
    all_conditions_met = new_conditions.all?(&:met?)
    any_condition_not_met = new_conditions.any?(&:unmet?)
    instance_double(
      ProviderInterface::ConfirmConditionsWizard,
      conditions: new_conditions,
      all_conditions_met?: all_conditions_met,
      any_condition_not_met?: any_condition_not_met,
    )
  end

  let(:provider_user) { create(:provider_user, :with_make_decisions, providers: [application_choice.current_course.provider]) }

  let(:service) { described_class.new(actor: provider_user, application_choice: application_choice, statuses_form_object: statuses_form_object) }

  describe 'save!' do
    context 'provider user does not have make_decisions' do
      let(:provider_user) { create(:provider_user, providers: [application_choice.current_course.provider]) }

      it 'raises an error' do
        expect { service.save! }.to raise_error(ProviderAuthorisation::NotAuthorisedError)
      end
    end

    context 'when a condition status is changed' do
      let(:new_conditions) { conditions.each { |condition| condition.status = 'met' } }

      it 'attributes audits to the actor', with_audited: true do
        expect { service.save! }.to change(offer.conditions.last.audits, :count).by(1)
        expect(offer.conditions.last.audits.last.user).to eq(provider_user)
      end
    end

    context 'when none of the conditions are marked as unmet' do
      context 'when all conditions are met' do
        let(:new_conditions) { conditions.each { |condition| condition.status = 'met' } }

        it 'transitions the application to the recruited state' do
          Timecop.freeze do
            expect { service.save! }.to change(application_choice, :status).from('pending_conditions').to('recruited')
                                    .and change(application_choice, :recruited_at).to(Time.zone.now)
          end
        end

        it 'sends an email to the candidate', sidekiq: true do
          service.save!
          expect(ActionMailer::Base.deliveries.first['rails-mail-template'].value).to eq('conditions_met')
        end

        # rubocop:disable RSpec/NestedGroups
        context 'when the application is not in the pending_conditions state' do
          let(:application_choice) { create(:application_choice, :with_recruited, offer: offer) }

          it 'raises a Workflow::NoTransitionAllowed error' do
            expect { service.save! }.to raise_error(Workflow::NoTransitionAllowed)
          end
        end
        # rubocop:enable RSpec/NestedGroups
      end

      context 'when one conditions is still pending' do
        let(:new_conditions) do
          conditions.each_with_index do |condition, index|
            condition.status = index.zero? ? 'pending' : 'met'
          end
        end

        it 'keeps the application in the pending_conditions state' do
          expect { service.save! }.not_to change(application_choice, :status)
        end

        it 'does not send an email to the candidate', sidekiq: true do
          service.save!
          expect(ActionMailer::Base.deliveries).to be_empty
        end
      end
    end

    context 'when one of the conditions is marked as unmet' do
      let(:new_conditions) do
        conditions.each_with_index do |condition, index|
          condition.status = index.zero? ? 'unmet' : 'pending'
        end
      end

      it 'transitions the application to the conditions_not_met state' do
        Timecop.freeze do
          expect { service.save! }.to change(application_choice, :status).from('pending_conditions').to('conditions_not_met')
                                  .and change(application_choice, :conditions_not_met_at).to(Time.zone.now)
        end
      end

      it 'sends an email to the candidate', sidekiq: true do
        service.save!
        expect(ActionMailer::Base.deliveries.first['rails-mail-template'].value).to eq('conditions_not_met')
      end

      context 'when the application is not in the pending_conditions state' do
        let(:application_choice) { create(:application_choice, :with_conditions_not_met, offer: offer) }

        it 'raises a Workflow::NoTransitionAllowed error' do
          expect { service.save! }.to raise_error(Workflow::NoTransitionAllowed)
        end
      end
    end
  end
end
