require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe 'Offer X day' do
    let(:offer) do
      build_stubbed(:application_choice, :offered,
                    sent_to_provider_at: Time.zone.today,
                    application_form: build_stubbed(:application_form, first_name: 'Fred'),
                    course_option:)
    end
    let(:course_option) do
      build_stubbed(:course_option, course: build_stubbed(:course,
                                                          name: 'Applied Science (Psychology)',
                                                          code: '3TT5', provider:))
    end
    let(:provider) { build_stubbed(:provider, name: 'Brighthurst Technical College') }
    let(:application_choices) { [offer] }

    describe 'Offer 10 day' do
      let(:email) { described_class.offer_10_day(offer) }

      it_behaves_like(
        'a mail with subject and content',
        'Respond to your teacher training offer from Brighthurst Technical College',
        'heading' => 'Hello Fred',
        'provider name' => 'Brighthurst Technical College',
      )

      it_behaves_like 'an email with unsubscribe option'
    end

    describe 'Offer 20 day described_class' do
      let(:email) { described_class.offer_20_day(offer) }

      it_behaves_like(
        'a mail with subject and content',
        'Respond to your teacher training offer from Brighthurst Technical College',
        'heading' => 'Hello Fred',
        'provider name' => 'Brighthurst Technical College',
      )

      it_behaves_like 'an email with unsubscribe option'
    end

    describe 'Offer 30 day' do
      let(:email) { described_class.offer_30_day(offer) }

      it_behaves_like(
        'a mail with subject and content',
        'Respond to your teacher training offer from Brighthurst Technical College',
        'heading' => 'Hello Fred',
        'provider name' => 'Brighthurst Technical College',
      )

      it_behaves_like 'an email with unsubscribe option'
    end

    describe 'Offer 40 day' do
      let(:email) { described_class.offer_40_day(offer) }

      it_behaves_like(
        'a mail with subject and content',
        'Respond to your teacher training offer from Brighthurst Technical College',
        'heading' => 'Hello Fred',
        'provider name' => 'Brighthurst Technical College',
      )

      it_behaves_like 'an email with unsubscribe option'
    end

    describe 'Offer 50 day' do
      let(:email) { described_class.offer_50_day(offer) }

      it_behaves_like(
        'a mail with subject and content',
        'You must respond to your teacher training offer from Brighthurst Technical College',
        'heading' => 'Hello Fred',
        'provider name' => 'Brighthurst Technical College',
      )

      it_behaves_like 'an email with unsubscribe option'
    end
  end
end
