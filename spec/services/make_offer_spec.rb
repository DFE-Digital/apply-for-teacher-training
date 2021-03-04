require 'rails_helper'

RSpec.describe MakeOffer do
  include CourseOptionHelpers

  let(:make_offer) do
    MakeOffer.new(actor: provider_user,
                  application_choice: application_choice,
                  course_option: course_option,
                  conditions: conditions)
  end

  describe '#save!' do
    let(:application_choice) { create(:application_choice) }
    let(:course_option) { course_option_for_provider(provider: application_choice.course_option.provider) }
    let(:provider_user) { create(:provider_user, providers: [build(:provider)]) }
    let(:conditions) { [Faker::Lorem.sentence] }

    describe 'if the actor is not authorised to perform this action' do
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
      let(:provider_user) do
        create(:provider_user,
               :with_make_decisions,
               providers: [application_choice.course_option.provider])
      end

      it 'throws an exception' do
        expect {
          make_offer.save!
        }.to raise_error(Workflow::NoTransitionAllowed, 'There is no event make_offer defined for the pending_conditions state')
      end
    end

    describe 'if the provided details are correct' do
      let(:application_choice) { create(:application_choice, status: :awaiting_provider_decision) }
      let(:provider_user) do
        create(:provider_user,
               :with_make_decisions,
               providers: [application_choice.course_option.provider])
      end

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

        expect(SetDeclineByDefault).to have_received(:new).with(application_form: application_choice.application_form)
        expect(SendNewOfferEmailToCandidate).to have_received(:new).with(application_choice: application_choice)
      end
    end
  end
end
