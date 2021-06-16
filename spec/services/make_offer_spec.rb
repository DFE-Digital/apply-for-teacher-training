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
  let(:update_conditions_service) { instance_double(SaveOfferConditionsFromText, save: true, conditions: conditions) }
  let(:make_offer) do
    described_class.new(
      actor: provider_user,
      application_choice: application_choice,
      course_option: course_option,
      update_conditions_service: update_conditions_service,
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
      it 'then it executes the service without errors ' do
        set_declined_by_default = instance_double(SetDeclineByDefault, call: true)
        send_new_offer_email_to_candidate = instance_double(SendNewOfferEmailToCandidate, call: true)
        allow(SetDeclineByDefault)
            .to receive(:new).with(application_form: application_choice.application_form)
                    .and_return(set_declined_by_default)
        allow(SendNewOfferEmailToCandidate)
            .to receive(:new).with(application_choice: application_choice)
                    .and_return(send_new_offer_email_to_candidate)

        make_offer.save!

        expect(set_declined_by_default).to have_received(:call)
        expect(send_new_offer_email_to_candidate).to have_received(:call)
        expect(update_conditions_service).to have_received(:save)
      end
    end

    describe 'audits', with_audited: true do
      it 'generates an audit event combining status change with current_course_option_id' do
        make_offer.save!

        audit_with_status_change = application_choice.reload.audits.find_by('jsonb_exists(audited_changes, ?)', 'status')
        expect(audit_with_status_change.audited_changes).to have_key('current_course_option_id')
      end
    end
  end
end
