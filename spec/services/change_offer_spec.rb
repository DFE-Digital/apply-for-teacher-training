require 'rails_helper'

RSpec.describe ChangeOffer do
  include CourseOptionHelpers
  let(:provider_user) { create(:provider_user, :with_provider) }
  let(:provider) { provider_user.providers.first }
  let(:course) { create(:course, :full_time, provider: provider) }
  let(:original_course_option) { course_option_for_provider(provider: provider, course: course) }
  let(:new_course_option) { course_option_for_provider(provider: provider, course: course) }
  let(:application_choice) { create(:application_choice, :with_modified_offer, course_option: original_course_option) }

  def service
    ChangeOffer.new(actor: provider_user, application_choice: application_choice, course_option_id: new_course_option.id)
  end

  it 'changes offered_course_option_id for the application choice if it is already set' do
    expect { service.save! }.to change(application_choice, :offered_course_option_id)
  end

  it 'sets offered_course_option_id for the application choice if it is not already set' do
    application_choice.update(offered_course_option_id: nil)

    expect { service.save! }.to change(application_choice, :offered_course_option_id)
  end

  it 'sets the offered_at date for the application_choice' do
    Timecop.freeze do
      expect { service.save! }.to change(application_choice, :offered_at).to(Time.zone.now)
    end
  end

  it 'resets declined_by_default_at for the application choice' do
    expect { service.save! && application_choice.reload }.to change(application_choice, :decline_by_default_at)
  end

  it 'does not change declined_by_default_at if the offered course option has not changed' do
    noop = ChangeOffer.new(actor: provider_user, application_choice: application_choice, course_option_id: original_course_option.id)
    expect { noop.save! }.not_to change(application_choice, :decline_by_default_at)
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
