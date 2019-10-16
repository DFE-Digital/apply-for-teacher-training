require 'rails_helper'

RSpec.describe ApplicationStateChange do
  describe '#valid_states' do
    it 'has human readable translations' do
      expect(ApplicationStateChange.valid_states)
        .to eql(I18n.t('application_choice.status_name').keys)
    end

    it 'corresponding enum entries' do
      expect(ApplicationStateChange.valid_states)
        .to eql(ApplicationChoice.statuses.keys.map(&:to_sym))
    end
  end
end
