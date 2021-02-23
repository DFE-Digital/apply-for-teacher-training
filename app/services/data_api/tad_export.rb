module DataAPI
  class TADExport
    EXPORT_NAME = 'Daily export of applications for TAD'.freeze

    def self.run_daily
      data_export = DataExport.create!(name: EXPORT_NAME)
      DataExporter.perform_async(TADExport::TADExport, data_export.id)
    end

    def self.latest
      DataExport
        .where(name: EXPORT_NAME)
        .where('completed_at IS NOT NULL')
        .last
    end

    def data_for_export
      relevant_applications.flat_map do |application_form|
        application_form.application_choices.map do |application_choice|
          TADApplicationExport.new(application_choice).as_json
        end
      end
    end

  private

    def relevant_applications
      # Should be the same as the UCAS sync export (app/services/ucas_matching/matching_data_export.rb).
      ApplicationForm
        .current_cycle
        .includes(
          :candidate,
        ).preload(
          :application_qualifications,
          application_choices: %i[course provider accredited_provider audits],
        )
        .where('candidates.hide_in_reporting' => false)
        .where.not(submitted_at: nil)
        .order('submitted_at asc')
    end
  end
end
