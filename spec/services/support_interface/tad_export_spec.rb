require 'rails_helper'

RSpec.describe SupportInterface::TADExport do
  describe '#data_for_export' do
    it 'incorporates RDB and DBD into the status' do
      create(:submitted_application_choice, status: 'rejected', rejected_by_default: true)
      create(:submitted_application_choice, status: 'declined', declined_by_default: true)
      create(:submitted_application_choice, status: 'rejected')
      create(:submitted_application_choice, status: 'declined')

      result = described_class.new.data_for_export

      expect(result.map { |r| r[:status] }).to match_array(%w[rejected_by_default declined_by_default rejected declined])
    end
  end
end
