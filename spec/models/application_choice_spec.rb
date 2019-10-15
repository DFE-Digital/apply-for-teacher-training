require 'rails_helper'

RSpec.describe ApplicationChoice, type: :model do
  describe '#update' do
    it 'updates the form as well' do
      original_time = Time.now - 1.day
      application_form = create(:application_form, updated_at: original_time)
      application_choice = create(:application_choice, application_form: application_form)

      application_choice.update!(personal_statement: 'Something else')

      expect(application_form.updated_at).not_to eql(original_time)
    end
  end
end
