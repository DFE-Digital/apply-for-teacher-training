module DataAPI
  class TADSubjectsExport
    def self.run_daily
      data_export = DataExport.create!(
        name: 'Weekly export of subjects, candidate nationality, domicile and application status for TAD',
        export_type: :tad_subjects,
      )
      DataExporter.perform_async(DataAPI::TADSubjectsExport, data_export.id)
    end

    def self.all
      DataSubjectsExport
        .where(export_type: :tad_subjects)
        .where.not(completed_at: nil)
    end

    def self.latest
      all.last
    end

    def data_for_export(*)
      {}
    end

  private

  end
end
