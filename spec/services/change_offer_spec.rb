require 'rails_helper'

RSpec.describe ChangeOffer do
  include CourseOptionHelpers
  let(:provider_user) { create(:provider_user, :with_provider, :with_make_decisions) }
  let(:provider) { provider_user.providers.first }
  let(:original_course_option) { course_option_for_provider(provider: provider) }
  let(:new_course_option) { course_option_for_provider(provider: provider) }
  let(:application_choice) do
    choice = create(:application_choice, :with_modified_offer, course_option: original_course_option)
    SetDeclineByDefault.new(application_form: choice.application_form).call
    choice.reload
  end

  def service
    described_class.new(actor: provider_user, application_choice: application_choice, course_option: new_course_option)
  end

  describe 'database changes and side-effects' do
    it 'changes offered_course_option_id for the application choice' do
      expect { service.save! }.to change(application_choice, :offered_course_option_id)
    end

    it 'does not change offered_at' do
      expect { service.save! }.not_to change(application_choice, :offered_at)
    end

    it 'populates offer_changed_at for the application choice' do
      Timecop.freeze do
        expect { service.save! }.to change(application_choice, :offer_changed_at).to(Time.zone.now)
      end
    end

    it 'groups offer(ed)_ changes in a single audit', with_audited: true do
      service.save!

      audit_with_option_id =
        application_choice.audits
        .where('jsonb_exists(audited_changes, :key)', key: 'offered_course_option_id')
        .last

      expect(audit_with_option_id.audited_changes).to have_key('offer_changed_at')
    end

    it 'replaces conditions if conditions is supplied' do
      application_choice.update(offer: { 'conditions' => ['DBS check'] })

      with_conditions = described_class.new(
        actor: provider_user,
        application_choice: application_choice,
        course_option: new_course_option,
        conditions: ['First condition', 'Second condition'],
      )

      expect { with_conditions.save! }.to change(application_choice, :offer)
      expect(application_choice.offer['conditions']).to eq(['First condition', 'Second condition'])
    end

    it 'resets decline_by_default_at for the application choice' do
      expect { service.save! && application_choice.reload }.to change(application_choice, :decline_by_default_at)
    end

    it 'sends an email to the candidate to notify them about the change' do
      mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(CandidateMailer).to receive(:changed_offer).and_return(mail)

      service.save!

      expect(CandidateMailer).to have_received(:changed_offer).with(application_choice)
      expect(mail).to have_received(:deliver_later)
    end

    it 'calls `StateChangeNotifier` to send a Slack notification' do
      allow(StateChangeNotifier).to receive(:call).and_return(nil)
      service.save!
      expect(StateChangeNotifier).to have_received(:call).with(:change_an_offer, application_choice: application_choice)
    end
  end

  describe 'user authorisation' do
    let(:provider_user) { create(:provider_user, :with_provider) }

    it 'throws an exception if actor is not authorised to perform this action' do
      expect {
        service.save!
      }.to raise_error(
        ProviderAuthorisation::NotAuthorisedError,
        'You are not permitted to view this application. The specified course is not associated with any of your organisations. You do not have the required user level permissions to make decisions on applications for this provider.',
      )
    end
  end

  describe 'repeat offers' do
    it 'throw an exception if neither offer nor conditions have changed' do
      application_choice.update(offer: { 'conditions' => ['DBS check'] })
      change = described_class.new(actor: provider_user, application_choice: application_choice, course_option: application_choice.offered_option, conditions: ['DBS check'])

      # already covered by ChangeAnOffer as an error
      skip
    end

    it 'do not error if the change offer conditions' do
      application_choice.update(offer: { 'conditions' => ['Different things'] })
      change = described_class.new(actor: provider_user, application_choice: application_choice, course_option: application_choice.offered_option, conditions: ['DBS check'])

      skip
    end

    it 'do not error when if they change offered course details' do
      application_choice.update(offer: { 'conditions' => ['DBS check'] })
      change = described_class.new(actor: provider_user, application_choice: application_choice, course_option: new_course_option, conditions: ['DBS check'])

      skip
    end
  end

  describe 'course option validation' do
    it 'throws exception if course option is absent' do
      change = described_class.new(actor: provider_user, application_choice: application_choice, course_option: nil)

      # covered by controller

      # TODO service call with invalid course_option_id
      expect {
        service.save!
      }.to raise_error(
        Offer::CourseValidationError,
        'Course option id does not match a valid course option',
      )
    end

    it 'throws exception unless course is open on apply' do
      # covered by ChangeAnOffer as an error

      new_course_option = create(:course_option, course: create(:course, provider: provider, open_on_apply: false))
      change = described_class.new(actor: provider_user, application_choice: application_choice, course_option: new_course_option)

      skip
    end

    it 'throws exception if new course option changes the ratifying provider' do
      # this check needs to be added to wrapper service
      skip
    end
  end

  # .save!
  #   ProviderAuthorisation::NotAuthorisedError,
  #   Offer::CourseValidationError,
  #   Offer::ConditionsValidationError,

  describe 'conditions validation' do
    it 'throws exception if number of conditions exceeds 20' do
      # this check needs to be added to wrapper service

      expect {
        service.save!
      }.to raise_error(
        Offer::ConditionsValidationError,
        'Too many conditions specified (20 or fewer required)',
      )
    end

    it 'throws exception if any conditions are longer than 255 characters' do
      # this check needs to be added to wrapper service

      skip
    end
  end
end
