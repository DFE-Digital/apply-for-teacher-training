require 'rails_helper'

RSpec.describe SendChaseEmailToRefereesWorker do
  let(:application_form1) { create(:application_form) }
  let(:application_form2) { create(:application_form) }
  let(:application_choice1) { create(:application_choice, status: 'awaiting_references', application_form: application_form1) }
  let(:application_choice2) { create(:application_choice, status: 'awaiting_references', application_form: application_form2) }
  let(:choices) { [application_choice1, application_choice2] }
  let(:query_service) { GetRefereesToChase.new }
  let(:chase_email_service) { SendChaseEmail.new }

  before { allow(query_service).to receive(:perform).and_return(choices) }

  describe 'processes all application_choices' do
    it 'updates the state of all the application choices returned by the query service' do
      create(:reference, feedback_status: 'feedback_requested', application_form: application_form1)
      create(:reference, feedback_status: 'feedback_requested', application_form: application_form2)

      choices.each do |choice|
        chase_email_service.perform(reference: choice.reload.application_form.application_references.first)
        expect(choice.reload.status).to eq('awaiting_references_and_chased')
      end
    end
  end
end
