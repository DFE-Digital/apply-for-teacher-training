require 'rails_helper'

RSpec.describe SubmitApplication do
  describe 'Submit an application' do
    it 'updates the application to Submitted and sets application_form.submitted_at' do
      application_form = create(:application_form)
      create(:application_choice, application_form: application_form, status: 'unsubmitted')
      create(:application_choice, application_form: application_form, status: 'unsubmitted')
      application_dates = instance_double(
        ApplicationDates,
        edit_by: Time.zone.local(2019, 11, 11, 11, 59, 0),
      )
      allow(ApplicationDates).to receive(:new).and_return(application_dates)

      Timecop.freeze do
        SubmitApplication.new(application_form).call

        expect(application_form.submitted_at).to eq Time.zone.now
        expect(application_form.application_choices[0]).to be_awaiting_references
        expect(application_form.application_choices[1]).to be_awaiting_references
        expect(application_form.support_reference).not_to be_empty
        expect(application_form.application_choices[0].edit_by).to eq application_dates.edit_by
        expect(application_form.application_choices[1].edit_by).to eq application_dates.edit_by
      end
    end
  end
end
