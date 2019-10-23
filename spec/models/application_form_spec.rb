require 'rails_helper'

RSpec.describe ApplicationForm do
  describe 'auditing' do
    it 'records an audit entry when creating a new ApplicationForm' do
      application_form = create :application_form
      expect(application_form.audits.count).to eq 1
    end

    it 'can view audit records for ApplicationForm and it\'s associated ApplicationChoices' do
      application_form = create :completed_application_form
      expect(application_form.own_and_associated_audits.count).to eq 4
      application_form.application_choices.first.update!(personal_statement: 'hello again')
      expect(application_form.own_and_associated_audits.count).to eq 5
    end
  end
end
