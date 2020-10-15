require 'rails_helper'

RSpec.describe SupportInterface::TADExport do
  describe '#data_for_export' do
    it 'does not raise errors' do
      create(:submitted_application_choice)
      create(:submitted_application_choice)

      result = described_class.new.data_for_export

      expect(result).not_to be_nil
    end
  end
end
