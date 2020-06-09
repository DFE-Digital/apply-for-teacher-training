require 'rails_helper'

RSpec.describe ChangeOffer do
  include CourseOptionHelpers
  let(:provider_user) { create(:provider_user, :with_provider) }
  let(:provider) { provider_user.providers.first }
  let(:original_course_option) { course_option_for_provider(provider: provider) }
  let(:new_course_option) { course_option_for_provider(provider: provider) }
  let(:application_choice) { create(:application_choice, :with_modified_offer, course_option: original_course_option) }

  def service
    ChangeOffer.new(actor: provider_user, application_choice: application_choice, course_option: new_course_option)
  end

  it 'changes offered_course_option_id for the application choice' do
    expect { service.save }.to change(application_choice, :offered_course_option_id)
  end

  it 'replaces conditions if offer_conditions is supplied' do
    application_choice.update(offer: { 'conditions' => ['DBS check'] })

    with_conditions = ChangeOffer.new(
      actor: provider_user,
      application_choice: application_choice,
      course_option: new_course_option,
      offer_conditions: ['First condition', 'Second condition'],
    )

    expect { with_conditions.save }.to change(application_choice, :offer)
    expect(application_choice.offer['conditions']).to eq(['First condition', 'Second condition'])
  end

  it 'sets the offered_at date for the application_choice' do
    Timecop.freeze do
      expect { service.save }.to change(application_choice, :offered_at).to(Time.zone.now)
    end
  end

  it 'resets declined_by_default_at for the application choice' do
    expect { service.save && application_choice.reload }.to change(application_choice, :decline_by_default_at)
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
      change = ChangeOffer.new(actor: provider_user, application_choice: application_choice, course_option: nil)

      expect(change).not_to be_valid

      expect(change.errors[:course_option]).to include('could not be found')
    end

    it 'checks the course option is different from the current option' do
      change = ChangeOffer.new(actor: provider_user, application_choice: application_choice, course_option: application_choice.offered_option)

      expect(change).not_to be_valid

      expect(change.errors[:course_option]).to include('is the same as the course currently offered')
    end

    it 'checks the course is open on apply' do
      new_course_option = create(:course_option, course: create(:course, provider: provider, open_on_apply: false))
      change = ChangeOffer.new(actor: provider_user, application_choice: application_choice, course_option: new_course_option)

      expect(change).not_to be_valid

      expect(change.errors[:course_option]).to include('is not open for applications via the Apply service')
    end
  end
end
