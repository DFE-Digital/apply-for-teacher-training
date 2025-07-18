require 'rails_helper'

RSpec.describe DeclineOffer do
  include CourseOptionHelpers

  before do
    allow(ProviderMailer).to receive(:declined).and_return(
      instance_double(ActionMailer::MessageDelivery, deliver_later: true),
    )
    allow(CandidateMailer).to receive(:decline_last_application_choice).and_return(
      instance_double(ActionMailer::MessageDelivery, deliver_later: true),
    )
    allow(CandidateCoursesRecommender).to receive(:recommended_courses_url)
                                            .and_return(recommended_courses_url)
  end

  let(:recommended_courses_url) { nil }

  it 'sets the declined_at date' do
    application_choice = create(:application_choice, status: :offer)

    expect {
      described_class.new(application_choice:).save!
    }.to change { application_choice.declined_at }.to(Time.zone.now)
    .and change { application_choice.withdrawn_or_declined_for_candidate_by_provider }.to false
  end

  it 'sends a notification email to the training provider and ratifying provider' do
    training_provider = create(:provider)
    training_provider_user = create(:provider_user, :with_notifications_enabled, providers: [training_provider])

    ratifying_provider = create(:provider)
    ratifying_provider_user = create(:provider_user, :with_notifications_enabled, providers: [ratifying_provider])

    course_option = course_option_for_accredited_provider(provider: training_provider, accredited_provider: ratifying_provider)
    application_choice = create(:application_choice, status: :offer, course_option:)

    described_class.new(application_choice:).save!

    expect(CandidateMailer).to have_received(:decline_last_application_choice)
                                 .with(application_choice, nil)
    expect(ProviderMailer).to have_received(:declined)
                                .with(training_provider_user, application_choice)
    expect(ProviderMailer).to have_received(:declined)
                                .with(ratifying_provider_user, application_choice)
  end

  context 'with a course recommendation url' do
    let(:recommended_courses_url) { 'https://www.find-postgraduate-teacher-training.service.gov.uk/results' }

    it 'sends an email to the candidate with a recommendation url' do
      application_choice = create(:application_choice, status: :offer)

      described_class.new(application_choice:).save!

      expect(CandidateMailer).to have_received(:decline_last_application_choice)
                                   .with(application_choice, 'https://www.find-postgraduate-teacher-training.service.gov.uk/results')
    end
  end

  context 'when the candidate has other applications' do
    it 'does not send the decline_last_application_choice email' do
      training_provider = create(:provider)
      training_provider_user = create(:provider_user, :with_notifications_enabled, providers: [training_provider])

      ratifying_provider = create(:provider)
      ratifying_provider_user = create(:provider_user, :with_notifications_enabled, providers: [ratifying_provider])

      course_option = course_option_for_accredited_provider(provider: training_provider, accredited_provider: ratifying_provider)
      application_form = create(:application_form)
      application_choice = create(:application_choice, application_form:, status: :offer, course_option:)
      _other_application_choice = create(:application_choice, application_form:, status: :offer)

      described_class.new(application_choice:).save!

      expect(CandidateMailer).not_to have_received(:decline_last_application_choice)
      expect(ProviderMailer).to have_received(:declined)
                                  .with(training_provider_user, application_choice)
      expect(ProviderMailer).to have_received(:declined)
                                  .with(ratifying_provider_user, application_choice)
    end
  end
end
