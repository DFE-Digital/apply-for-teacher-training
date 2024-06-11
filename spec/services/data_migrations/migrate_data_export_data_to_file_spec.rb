require 'rails_helper'

RSpec.describe DataMigrations::MigrateDataExportDataToFile do
  let(:csv_string) { "email_template,send_count\nsign_in_email,1" }

  it "updates all existing DataExport records 'data' fields and puts them into 'file' attachments" do
    data_export = create(:data_export, data: csv_string, file: nil)

    described_class.new.change

    data_export.reload

    expect(data_export.file).to be_attached
    expect(data_export.file.download).to eq(csv_string)
  end
end
