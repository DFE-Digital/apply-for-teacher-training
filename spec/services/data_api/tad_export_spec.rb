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

  describe '#status' do
    it 'only includes states that are documented' do
      documented_columns = DataSetDocumentation.for(described_class)['status']['enum'].map(&:to_sym)

      unless FeatureFlag.active?(:interviews)
        documented_columns -= %i[interviewing]
      end

      possible_states_in_export = ApplicationStateChange.states_visible_to_tad

      expect(documented_columns).to match_array(possible_states_in_export)
    end
  end
end
