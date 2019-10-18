require 'rails_helper'

RSpec.describe SubmitApplication do
  describe 'Submit an application' do
    it 'updates the application to Submitted' do
      application_choices = [create(:application_choice, status: 'unsubmitted'),
                             create(:application_choice, status: 'unsubmitted')]

      SubmitApplication.new(application_choices).call

      expect(application_choices[0].status).to eq 'application_complete'
      expect(application_choices[1].status).to eq 'application_complete'
    end
  end
end
