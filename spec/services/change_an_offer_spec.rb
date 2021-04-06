require 'rails_helper'

RSpec.describe ChangeAnOffer do
  include CourseOptionHelpers
  let(:provider_user) { create(:provider_user, :with_provider, :with_make_decisions) }
  let(:provider) { provider_user.providers.first }
  let(:original_course_option) { course_option_for_provider(provider: provider) }
  let(:new_course_option) { course_option_for_provider(provider: provider) }
  let(:application_choice) do
    choice = create(:application_choice, :with_modified_offer, course_option: original_course_option)
    SetDeclineByDefault.new(application_form: choice.application_form).call # fix DBD
    choice.reload
  end

  def service
    ChangeAnOffer.new(actor: provider_user, application_choice: application_choice, course_option: new_course_option)
  end

  it 'changes current_course_option_id' do
    expect { service.save }.to change(application_choice, :current_course_option_id)
  end

  it 'does not change offered_at' do
    expect { service.save }.not_to change(application_choice, :offered_at)
  end

  it 'populates offer_changed_at for the application choice' do
    Timecop.freeze do
      expect { service.save }.to change(application_choice, :offer_changed_at).to(Time.zone.now)
    end
  end

  it 'groups offer(ed)_ changes in a single audit', with_audited: true do
    service.save

    audit_with_option_id =
      application_choice.audits
      .where('jsonb_exists(audited_changes, :key)', key: 'current_course_option_id')
      .last

    expect(audit_with_option_id.audited_changes).to have_key('offer_changed_at')
  end

  it 'replaces conditions if offer_conditions is supplied' do
    application_choice.update(offer: { 'conditions' => ['DBS check'] })

    with_conditions = ChangeAnOffer.new(
      actor: provider_user,
      application_choice: application_choice,
      course_option: new_course_option,
      offer_conditions: ['First condition', 'Second condition'],
    )

    expect { with_conditions.save }.to change(application_choice, :offer)
    expect(application_choice.offer['conditions']).to eq(['First condition', 'Second condition'])
  end

  it 'resets decline_by_default_at for the application choice' do
    Timecop.travel(1.business_day.from_now) do
      expect { service.save && application_choice.reload }.to change(application_choice, :decline_by_default_at)
    end
  end

  it 'sends an email to the candidate to notify them about the change' do
    mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
    allow(CandidateMailer).to receive(:changed_offer).and_return(mail)

    service.save

    expect(CandidateMailer).to have_received(:changed_offer).with(application_choice)
    expect(mail).to have_received(:deliver_later)
  end

  it 'calls `StateChangeNotifier` to send a Slack notification' do
    allow(StateChangeNotifier).to receive(:call).and_return(nil)
    service.save
    expect(StateChangeNotifier).to have_received(:call).with(:change_an_offer, application_choice: application_choice)
  end

  describe 'course option validation' do
    it 'checks the course option is present' do
      change = ChangeAnOffer.new(actor: provider_user, application_choice: application_choice, course_option: nil)

      expect(change).not_to be_valid

      expect(change.errors[:course_option]).to include('could not be found')
    end

    it 'checks the course option and conditions are different from the current option' do
      application_choice.update(offer: { 'conditions' => ['DBS check'] })
      change = ChangeAnOffer.new(actor: provider_user, application_choice: application_choice, course_option: application_choice.current_course_option, offer_conditions: ['DBS check'])

      expect(change).not_to be_valid

      expect(change.errors[:base]).to include('The new offer is identical to the current offer')
    end

    it 'checks the course is open on apply' do
      new_course_option = create(:course_option, course: create(:course, provider: provider, open_on_apply: false))
      change = ChangeAnOffer.new(actor: provider_user, application_choice: application_choice, course_option: new_course_option)

      expect(change).not_to be_valid

      expect(change.errors[:course_option]).to include('is not open for applications via the Apply service')
    end
  end

  describe '#is_identical_to_existing_offer?' do
    it 'returns true when offer and conditions match' do
      application_choice.update(offer: { 'conditions' => ['DBS check'] })
      change = ChangeAnOffer.new(actor: provider_user, application_choice: application_choice, course_option: application_choice.current_course_option, offer_conditions: ['DBS check'])

      expect(change).to be_identical_to_existing_offer
    end

    it 'returns false when offer matches, but not conditions' do
      application_choice.update(offer: { 'conditions' => ['Different things'] })
      change = ChangeAnOffer.new(actor: provider_user, application_choice: application_choice, course_option: application_choice.current_course_option, offer_conditions: ['DBS check'])

      expect(change).not_to be_identical_to_existing_offer
    end

    it 'returns false when conditions match, but not offer' do
      application_choice.update(offer: { 'conditions' => ['DBS check'] })
      change = ChangeAnOffer.new(actor: provider_user, application_choice: application_choice, course_option: new_course_option, offer_conditions: ['DBS check'])

      expect(change).not_to be_identical_to_existing_offer
    end
  end
end
