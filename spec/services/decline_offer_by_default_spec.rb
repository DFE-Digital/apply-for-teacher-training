require 'rails_helper'

RSpec.describe DeclineOfferByDefault do
  include CourseOptionHelpers

  let(:application_choice) { create(:application_choice, status: :offer) }

  it 'updates the application_choice' do
    described_class.new(application_form: application_choice.application_form).call

    application_choice.reload

    expect(application_choice.declined_by_default).to be(true)
    expect(application_choice.declined_at).not_to be_nil
    expect(application_choice.withdrawn_or_declined_for_candidate_by_provider).to be false
  end

  it 'sends a notification email to the training provider and ratifying provider', :sidekiq do
    training_provider = create(:provider)
    training_provider_user = create(:provider_user, :with_notifications_enabled, providers: [training_provider])

    ratifying_provider = create(:provider)
    ratifying_provider_user = create(:provider_user, :with_notifications_enabled, providers: [ratifying_provider])

    course_option = course_option_for_accredited_provider(provider: training_provider, accredited_provider: ratifying_provider)
    application_choice = create(:application_choice, status: :offer, course_option:)

    described_class.new(application_form: application_choice.application_form).call

    training_provider_email = ActionMailer::Base.deliveries.find { |e| e.header['to'].value == training_provider_user.email_address }
    ratifying_provider_email = ActionMailer::Base.deliveries.find { |e| e.header['to'].value == ratifying_provider_user.email_address }

    expect(training_provider_email['rails-mail-template'].value).to eq('declined_by_default')
    expect(ratifying_provider_email['rails-mail-template'].value).to eq('declined_by_default')
  end
end
