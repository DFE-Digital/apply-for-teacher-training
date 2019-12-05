require 'rails_helper'

RSpec.describe DeclineOffersByDefaultWorker do
  let(:choices) { 3.times.map { create(:application_choice, status: 'offer') } }
  let(:query_service)   { GetApplicationChoicesReadyToDeclineByDefault }
  let(:decline_service) { DeclineOfferByDefault }

  before { allow(query_service).to receive(:call).and_return(choices) }

  def invoke_worker
    DeclineOffersByDefaultWorker.new.perform
  end

  describe 'processes all application_choices' do
    it 'declines all application choices returned by the query service' do
      invoke_worker
      choices.each do |choice|
        expect(choice.status).to eq('declined')
        expect(choice.declined_at).not_to be_nil
        expect(choice.declined_by_default).to eq(true)
      end
    end
  end

  describe 'ignores applications that cannot be transitioned' do
    let(:choices) {
      [
        create(:application_choice, status: 'offer'),
        create(:application_choice, status: 'awaiting_provider_decision'),
        create(:application_choice, status: 'offer'),
      ]
    }

    it 'processes all application choices it can' do
      expect { invoke_worker }.not_to raise_error
      expect(choices[0].status).to eq('declined')
      expect(choices[1].status).to eq('awaiting_provider_decision')
      expect(choices[2].status).to eq('declined')
    end
  end
end
