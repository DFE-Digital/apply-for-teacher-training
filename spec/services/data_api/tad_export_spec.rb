require 'rails_helper'

RSpec.describe DataAPI::TADExport do
  before do
    create(:submitted_application_choice, status: 'rejected', rejected_by_default: true)
    create(:submitted_application_choice, status: 'declined', declined_by_default: true)
    create(:submitted_application_choice, status: 'rejected')
    create(:submitted_application_choice, status: 'declined')
  end

  it_behaves_like 'a data export'

  describe '#data_for_export' do
    it 'incorporates RDB and DBD into the status' do
      result = described_class.new.data_for_export

      expect(result.map { |r| r[:status] }).to match_array(%w[rejected_by_default declined_by_default rejected declined])
    end
  end
end
