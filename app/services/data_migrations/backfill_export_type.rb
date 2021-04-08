module DataMigrations
  class BackfillExportType
    TIMESTAMP = 20210326113829
    MANUAL_RUN = false

    def change
      data_exports = DataExport.all.where(export_type: nil)

      data_exports.each { |export| export.update!(export_type: export_type(export)) }
    end

  private

    def export_type(export)
      case export.name
      when 'Unexplained breaks in work history'
        'work_history_break'
      when 'Locations', 'Locations export'
        'persona_export'
      when 'Applications for TAD'
        'tad_applications'
      when 'Provider performance for TAD'
        'tad_provider_performance'
      when 'Candidate survey', 'Daily export of applications for TAD', 'Daily export of notifications breakdown', 'RejectedCandidatesExport'
        nil
      else
        export.name.parameterize.underscore
      end
    end
  end
end
