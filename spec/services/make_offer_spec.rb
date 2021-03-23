require 'rails_helper'

RSpec.describe MakeOffer do
  include CourseOptionHelpers
  let(:provider_user) { create(:provider_user, :with_provider, :with_make_decisions) }
  let(:provider) { provider_user.providers.first }
  let(:original_course_option) { course_option_for_provider(provider: provider) }
  let(:new_course_option) { course_option_for_provider(provider: provider) }
  let(:application_choice) do
    create(:application_choice, :awaiting_provider_decision, course_option: original_course_option)
  end

  let(:service) do
    described_class.new(actor: provider_user, application_choice: application_choice, course_option: new_course_option)
  end

  describe 'database changes and side-effects' do
    it 'sets offered_course_option_id' do
      expect { service.save! }.to change(application_choice, :offered_course_option_id)
    end

    it 'sets offered_at' do
      expect { service.save! }.to change(application_choice, :offered_at)
    end

    it 'generates an audit event combining status change with offered_course_option_id', with_audited: true do
      service.save!

      audit_with_status_change = application_choice.reload.audits.find_by('jsonb_exists(audited_changes, ?)', 'status')
      expect(audit_with_status_change.audited_changes).to have_key('offered_course_option_id')
    end

    it 'sets conditions' do
      with_conditions = described_class.new(
        actor: provider_user,
        application_choice: application_choice,
        course_option: new_course_option,
        conditions: ['First condition', 'Second condition'],
      )

      expect { with_conditions.save! }.to change(application_choice, :offer)
      expect(application_choice.offer['conditions']).to eq(['First condition', 'Second condition'])
    end

    it 'triggers SetDeclineByDefault on the application form' do
      double = instance_double(SetDeclineByDefault)
      allow(double).to receive(:call)
      allow(SetDeclineByDefault).to receive(:new).and_return(double)

      service.save!

      expect(SetDeclineByDefault).to have_received(:new)
        .with(application_form: application_choice.application_form)
      expect(double).to have_received(:call)
    end

    it 'sends an email to the candidate to notify them about the offer' do
      double = instance_double(SendNewOfferEmailToCandidate)
      allow(double).to receive(:call)
      allow(SendNewOfferEmailToCandidate).to receive(:new).and_return(double)

      service.save!

      expect(SendNewOfferEmailToCandidate).to have_received(:new)
        .with(application_choice: application_choice)
      expect(double).to have_received(:call)
    end
  end

  describe 'user authorisation' do
    let(:provider_user) { create(:provider_user, :with_provider) }

    it 'throws an exception if actor is not authorised to perform this action' do
      expect {
        service.save!
      }.to raise_error(
        ProviderAuthorisation::NotAuthorisedError,
        'You do not have the required user level permissions to make decisions on applications for this provider.',
      )
    end
  end

  describe 'repeat offers' do
    it 'throw an exception if an offer is already in place' do
      application_choice.update(status: :offer)
      offer = described_class.new(actor: provider_user, application_choice: application_choice, course_option: application_choice.offered_option, conditions: ['DBS check'])

      expect {
        offer.save!
      }.to raise_error(
        MakeOffer::AlreadyOfferedError,
        'An offer already exists, use ChangeOffer service to modify',
      )
    end
  end

  describe 'unable to transition to an offer state' do
    it 'throw an exception if the state is withdrawn' do
      application_choice.update(status: :withdrawn)
      offer = described_class.new(actor: provider_user, application_choice: application_choice, course_option: application_choice.offered_option, conditions: ['DBS check'])

      expect {
        offer.save!
      }.to raise_error(
               MakeOffer::NoTransitionAllowedError,
               MakeAnOffer::STATE_TRANSITION_ERROR,
               )
    end
  end

  describe 'course option validation' do
    it 'throws exception unless course is open on apply' do
      new_course_option = create(:course_option, course: create(:course, provider: provider, open_on_apply: false))
      offer = described_class.new(actor: provider_user, application_choice: application_choice, course_option: new_course_option)

      expect {
        offer.save!
      }.to raise_error(
        MakeOffer::CourseValidationError,
        'is not open for applications via the Apply service',
      )
    end

    it 'throws exception if new course option changes the ratifying provider' do
      new_course_option = create(:course_option, course: create(:course, :with_accredited_provider, provider: provider))
      offer = described_class.new(actor: provider_user, application_choice: application_choice, course_option: new_course_option)

      expect {
        offer.save!
      }.to raise_error(
        MakeOffer::RatifyingProviderChangeError,
        'The offer has a different ratifying provider to the application choice',
      )
    end
  end

  describe 'conditions validation' do
    it 'throws exception if number of conditions exceeds 20' do
      too_many = described_class.new(
        actor: provider_user,
        application_choice: application_choice,
        course_option: original_course_option,
        conditions: Array.new(21) { 'a condition' },
      )

      expect { too_many.save! }.to raise_error(
        MakeOffer::ConditionsValidationError,
        'Too many conditions specified (20 or fewer required)',
      )
    end

    it 'throws exception if any conditions are longer than 255 characters' do
      too_long = described_class.new(
        actor: provider_user,
        application_choice: application_choice,
        course_option: original_course_option,
        conditions: ['a' * 256],
      )

      expect { too_long.save! }.to raise_error(
        MakeOffer::ConditionsValidationError,
        'Condition exceeds length limit (255 characters or fewer required)',
      )
    end
  end
end
