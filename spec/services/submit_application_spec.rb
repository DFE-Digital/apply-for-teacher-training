require 'rails_helper'

RSpec.describe SubmitApplication do
  describe 'Submit an application' do
    it 'updates the application to Submitted and sets application_form.submitted_at' do
      application_form = create(:application_form)
      create(:application_choice, application_form: application_form, status: 'unsubmitted')
      create(:application_choice, application_form: application_form, status: 'unsubmitted')

      Timecop.freeze do
        SubmitApplication.new(application_form).call

        expect(application_form.submitted_at.utc).to eq Time.now.utc
        expect(application_form.application_choices[0]).to be_awaiting_references
        expect(application_form.application_choices[1]).to be_awaiting_references
        expect(application_form.support_reference).not_to be_empty
      end
    end
  end
end
