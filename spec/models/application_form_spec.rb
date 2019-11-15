require 'rails_helper'

RSpec.describe ApplicationForm do
  describe 'auditing' do
    it 'records an audit entry when creating a new ApplicationForm' do
      application_form = create :application_form
      expect(application_form.audits.count).to eq 1
    end

    it 'can view audit records for ApplicationForm and its associated ApplicationChoices' do
      application_form = create :completed_application_form
      expect(application_form.own_and_associated_audits.count).to eq 6
      application_form.application_choices.first.update!(personal_statement: 'hello again')
      expect(application_form.own_and_associated_audits.count).to eq 7
    end
  end

  describe '#update' do
    it 'updates the application_choices updated_at as well' do
      original_time = Time.now - 1.day
      application_form = create(:application_form)
      application_choices = create_list(
        :application_choice,
        2,
        application_form: application_form,
        updated_at: original_time,
      )

      application_form.update!(first_name: 'Something else')
      application_choices.each(&:reload)

      expect(application_choices.map(&:updated_at)).not_to include(original_time)
    end
  end
end
