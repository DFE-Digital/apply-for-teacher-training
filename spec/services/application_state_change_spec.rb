require 'rails_helper'

RSpec.describe ApplicationStateChange do
  describe '#valid_states' do
    it 'has human readable translations' do
      expect(
        ApplicationStateChange.valid_states
      ).to eql(
        I18n.t('application_choice.status_name').keys
      )
    end
  end
end
