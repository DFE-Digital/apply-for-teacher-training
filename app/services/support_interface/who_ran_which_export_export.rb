module SupportInterface
  class WhoRanWhichExportExport
    def data_for_export
      DataExport
      .where
      .not(export_type: nil)
      .order(%i[export_type created_at])
      .find_each(batch_size: 100)
      .map do |export|
        {
          export_type: export.export_type,
          created_at: export.created_at,
          initiated_by: export.initiator.email_address,
        }
      end
    end
  end
end
