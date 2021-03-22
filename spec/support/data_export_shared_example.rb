require 'rails_helper'

RSpec.shared_examples 'a data export' do
  it 'has documentation that describes all columns' do
    create(:submitted_application_choice)

    exported_columns = described_class.new.data_for_export.first.keys
    documented_columns = DataSetDocumentation.for(described_class).keys.map(&:to_sym)

    expect(exported_columns).to match_array(documented_columns)
  end

  it 'doesn’t shadow any common columns' do
    shadowed_columns = DataSetDocumentation.shadowed_common_columns(described_class)

    expect(shadowed_columns.count).to eq(0)
  end
end
