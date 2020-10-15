class DataExporter
  include Sidekiq::Worker

  def perform(importer_class, data_export_id)
    data_export = DataExport.find(data_export_id)

    csv_data = generate_csv(
      importer_class.constantize.new.data_for_export,
    )

    data_export.update!(
      data: csv_data,
      completed_at: Time.zone.now,
    )
  end

private

  def generate_csv(objects, header_row = nil)
    header_row ||= objects.to_a.first&.keys
    SafeCSV.generate(objects.map(&:values), header_row)
  end
end
