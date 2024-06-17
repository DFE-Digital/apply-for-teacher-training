class DataExportFileMigrationWorker
  include Sidekiq::Worker

  def perform(data_export_id)
    data_export = DataExport.find(data_export_id)

    data_export.file.attach(io: CSV.new(data_export.data).to_io, filename: data_export.filename)
  end
end
