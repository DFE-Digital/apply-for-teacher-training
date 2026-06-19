require 'rails_helper'

RSpec.describe DataExport do
  context 'validations' do
    it { is_expected.to validate_presence_of(:export_type) }

    it 'validates export type active' do
      deprecated_export_type = build(
        :data_export,
        export_type: described_class.deprecated_export_types.keys.sample,
      )
      active_export_type = build(
        :data_export,
        export_type: described_class.active_export_types.keys.sample,
      )

      active_export_type.validate
      expect(active_export_type.errors[:export_type]).to be_empty

      deprecated_export_type.validate
      expect(deprecated_export_type.errors[:export_type]).to eq(['This export is no longer available'])
    end
  end
end
