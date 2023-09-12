require 'rails_helper'

RSpec.describe MakeOffer do
  include CourseOptionHelpers

  let(:application_choice) { create(:application_choice, :awaiting_provider_decision) }
  let(:provider_user) do
    create(
      :provider_user,
      :with_make_decisions,
      providers: [application_choice.course_option.provider],
    )
  end
  let(:course_option) { course_option_for_provider(provider: application_choice.course_option.provider) }
  let(:conditions) { [Faker::Lorem.sentence] }
  let(:update_conditions_service) { instance_double(SaveOfferConditionsFromText, save: true, conditions:) }
  let(:make_offer) do
    described_class.new(
      actor: provider_user,
      application_choice:,
      course_option:,
      update_conditions_service:,
    )
  end

  describe '#save!' do
    describe 'if the actor is not authorised to perform this action' do
      let(:provider_user) { create(:provider_user, providers: [build(:provider)]) }

      it 'throws an exception' do
        expect {
          make_offer.save!
        }.to raise_error(
          ProviderAuthorisation::NotAuthorisedError,
          'You are not permitted to view this application. The specified course is not associated with any of your organisations. You do not have the required user level permissions to make decisions on applications for this provider.',
        )
      end
    end

    describe 'if the application choice cannot transition to the offer state' do
      let(:application_choice) { create(:application_choice, status: :pending_conditions) }

      it 'throws an exception' do
        expect {
          make_offer.save!
        }.to raise_error(Workflow::NoTransitionAllowed, 'There is no event make_offer defined for the pending_conditions state')
      end
    end

    describe 'if the offer is invalid' do
      let(:conditions) { [Faker::Lorem.paragraph_by_chars(number: 2001)] }

      it 'throws an exception' do
        expect {
          make_offer.save!
        }.to raise_error(ValidationException, 'Condition 1 must be 2000 characters or fewer')
      end
    end

    describe 'if the provided details are correct' do
      it 'then calls various services' do
        set_declined_by_default = instance_double(SetDeclineByDefault, call: true)
        send_new_offer_email_to_candidate = instance_double(SendNewOfferEmailToCandidate, call: true)

        allow(SetDeclineByDefault)
            .to receive(:new).with(application_form: application_choice.application_form)
                    .and_return(set_declined_by_default)
        allow(SendNewOfferEmailToCandidate)
            .to receive(:new).with(application_choice:)
                    .and_return(send_new_offer_email_to_candidate)
        allow(application_choice).to receive(:update_course_option_and_associated_fields!)

        make_offer.save!

        expect(SetDeclineByDefault).to have_received(:new)
        expect(set_declined_by_default).to have_received(:call)
        expect(send_new_offer_email_to_candidate).to have_received(:call)
        expect(update_conditions_service).to have_received(:save)
        expect(application_choice).to have_received(:update_course_option_and_associated_fields!)
      end

      it 'then calls the cancel upcoming interview services' do
        cancel_upcoming_interviews = instance_double(CancelUpcomingInterviews, call!: true)

        allow(CancelUpcomingInterviews)
          .to receive(:new).with(actor: provider_user, application_choice:, cancellation_reason: 'We made you an offer.')
             .and_return(cancel_upcoming_interviews)
        make_offer.save!
        expect(cancel_upcoming_interviews).to have_received(:call!)
      end

      context 'when the application form is in continuous application cycle', :continuous_applications do
        let(:application_choice) { create(:application_choice, :awaiting_provider_decision, :continuous_applications) }

        it 'calls DeclineByDefaultToEndOfCycle' do
          allow(SetDeclineByDefaultToEndOfCycle)
            .to receive(:new).and_return(instance_double(SetDeclineByDefaultToEndOfCycle, call: true))
          make_offer.save!

          expect(SetDeclineByDefaultToEndOfCycle).to have_received(:new)
        end
      end
    end

    describe 'audits', :with_audited do
      it 'generates an audit event combining status change with current_course_option_id' do
        make_offer.save!

        audit_with_status_change = application_choice.reload.audits.find_by('jsonb_exists(audited_changes, ?)', 'status')
        expect(audit_with_status_change.audited_changes).to have_key('current_course_option_id')
      end
    end
  end
end
