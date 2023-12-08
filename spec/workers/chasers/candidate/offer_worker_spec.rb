require 'rails_helper'

RSpec.describe Chasers::Candidate::OfferWorker do
  let!(:application_choices) do
    Chasers::Candidate.chaser_to_date_range.each_value do |date_range|
      create(:application_choice, :offer).tap do |choice|
        choice.offer.update(created_at: date_range.min)
      end
    end
  end
  let(:chaser_types) do
    Chasers::Candidate.chaser_types
  end
  let(:mailers) { chaser_types }
  let(:groups) { application_choices.zip(chaser_types, mailers) }

  it 'calls the service for each chaser interval' do
    allow(Chasers::Candidate::OfferEmailService).to receive(:call).and_call_original
    allow(OffersToChaseQuery).to receive(:call).and_call_original

    described_class.new.perform

    expect(OffersToChaseQuery).to have_received(:call).with(chaser_type: Symbol, date_range: Range).exactly(5).times
    groups do |application_choice, chaser_type, mailer|
      expect(Chasers::Candidate::OfferEmailService).to have_received(:call).with(chaser_type:, mailer:, application_choice:)
    end
  end
end
