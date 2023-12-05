require 'rails_helper'

RSpec.describe Chasers::Candidate::OfferWorker do
  let!(:application_choices) do
    OffersToChaseQuery::VALID_INTERVALS.map do |interval|
      create(:application_choice, :offer).tap do |choice|
        choice.offer.update(created_at: (interval + 1).days.ago)
      end
    end
  end
  let(:chaser_types) do
    %i[
      offer_10_day
      offer_20_day
      offer_30_day
      offer_40_day
      offer_50_day
    ]
  end
  let(:mailers) { chaser_types }
  let(:groups) { application_choices.zip(chaser_types, mailers) }

  it 'calls the service for each chaser interval' do
    allow(Chasers::Candidate::OfferEmailService).to receive(:call).and_call_original

    described_class.new.perform

    groups do |application_choice, chaser_type, mailer|
      expect(Chasers::Candidate::OfferEmailService).to have_received(:call).with(chaser_type:, mailer:, application_choice:)
    end
  end
end
