require 'rails_helper'

RSpec.describe SendChaseEmailToRefereesWorker do
  let(:choices) { 3.times.map { create(:application_choice, status: 'awaiting_references') } }
  let(:query_service)   { GetRefereesToChase }
  let(:chase_email_service) { SendChaseEmail }

  before { allow(query_service).to receive(:call).and_return(choices) }

  def invoke_worker
    chase_email_service.new.perform
  end

  describe 'processes all application_choices' do
    it 'updates the state of all the application choices returned by the query service' do
      invoke_worker
      choices.each do |choice|
        expect(choice.status).to eq('awaiting_references_and_chased')
      end
    end
  end
end
