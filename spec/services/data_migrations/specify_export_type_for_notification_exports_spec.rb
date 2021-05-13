require 'rails_helper'

RSpec.describe DataMigrations::SpecifyExportTypeForNotificationExports do
  it 'backfills export_type for notification exports' do
    notifications_export = create(
      :data_export,
      name: 'Daily export of notifications breakdown',
      export_type: nil,
    )

    described_class.new.change
    expect(notifications_export.reload.export_type).to eq('notifications_export')
  end
end
