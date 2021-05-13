require 'rails_helper'

RSpec.describe DataMigrations::SpecifyExportTypeForTADExports do
  it 'backfills export_type for tad application exports' do
    notifications_export = create(
      :data_export,
      name: 'Daily export of applications for TAD',
      export_type: nil,
    )

    described_class.new.change
    expect(notifications_export.reload.export_type).to eq('tad_applications')
  end
end
