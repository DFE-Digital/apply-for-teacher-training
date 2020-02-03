require 'rails_helper'

RSpec.describe SendChaseEmailToRefereesWorker do
  let(:application_form) { create(:completed_application_form) }
  let(:reference1) { create(:reference, feedback_status: 'feedback_requested', application_form: application_form) }
  let(:reference2) { create(:reference, feedback_status: 'feedback_requested', application_form: application_form) }
  let(:references) { [reference1, reference2] }
  let(:query_service) { GetRefereesToChase.new }
  let(:chase_email_service) { SendChaseEmail.new }

  before { allow(query_service).to receive(:perform).and_return(references) }

  describe 'processes all references' do
    it 'sends a chase email to all of the references' do
      references.each do |reference|
        chase_email_service.perform(reference: reference)
        expect(reference.chasers_sent.referee_mailer_reference_request_chaser_email.count).to eq(1)
      end
    end
  end
end
