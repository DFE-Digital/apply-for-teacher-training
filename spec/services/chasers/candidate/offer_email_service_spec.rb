require 'rails_helper'

RSpec.describe Chasers::Candidate::OfferEmailService do
  let(:application_choice) { create(:application_choice) }
  let(:mailer) { :offer_10_day }
  let(:chaser_type) { mailer }

  it 'sends an email and creates a ChaserSent' do
    expect do
      described_class.call(chaser_type:, mailer:, application_choice:)
    end
      .to change { CandidateMailer.deliveries.count }.by(1)
      .and change { ChaserSent.count }.by(1)
  end
end
