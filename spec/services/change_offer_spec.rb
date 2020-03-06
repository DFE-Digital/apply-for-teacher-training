require 'rails_helper'

RSpec.describe ChangeOffer do
  include CourseOptionHelpers
  let(:provider_user) { create(:provider_user, :with_provider) }
  let(:provider) { provider_user.providers.first }
  let(:course) { create(:course, :full_time, provider: provider) }
  let(:course_option) { course_option_for_provider(provider: provider, course: course) }
  let(:application_choice) { create(:application_choice, :with_modified_offer, course_option: course_option) }

  def service
    ChangeOffer.new(actor: provider_user, application_choice: application_choice, course_option_id: course_option.id)
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
end
