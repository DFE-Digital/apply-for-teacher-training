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
        expect(application_form.application_choices[0].status).to eq 'application_complete'
        expect(application_form.application_choices[1].status).to eq 'application_complete'
      end
    end
  end
end
