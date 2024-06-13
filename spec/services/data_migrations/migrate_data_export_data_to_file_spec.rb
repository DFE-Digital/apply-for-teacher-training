require 'rails_helper'

RSpec.describe DataMigrations::MigrateDataExportDataToFile do
  let(:csv_string) { "email_template,send_count\nsign_in_email,1" }

  it "updates all existing DataExport records 'data' fields and puts them into 'file' attachments" do
    create(:data_export, data: csv_string, file: nil)

    expect { described_class.new.change }.to change(DataExportFileMigrationWorker.jobs, :size).by(1)
  end
end
