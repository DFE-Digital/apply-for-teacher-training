require 'rails_helper'

RSpec.shared_examples 'a data export' do
  let(:exported_data) { described_class.new.data_for_export.first }
  let(:documentation) { DataSetDocumentation.for(described_class) }

  describe 'the documentation' do
    it 'describes all columns' do
      create(:submitted_application_choice)

      exported_column_headings = exported_data.keys
      documented_column_headings = documentation.keys.map(&:to_sym)

      expect(exported_column_headings).to match_array(documented_column_headings)
    end

    it 'has the correct type for each column' do
      exported_data_value_types = exported_data.values.map { |value| value.class.to_s.downcase }
      documented_value_types = documentation.values.map { |value| value['type'] }

      expect(exported_data_value_types).to match_array(documented_value_types)
    end
  end
end
