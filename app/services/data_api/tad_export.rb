module DataAPI
  class TADExport
    def self.run_daily
      data_export = DataExport.create!(
        name: 'Daily export of applications for TAD',
        export_type: :tad_applications,
      )
      DataExporter.perform_async(DataAPI::TADExport, data_export.id)
    end

    def self.all
      DataExport
        .where(export_type: :tad_applications)
        .where.not(completed_at: nil)
    end

    def self.latest
      all.last
    end

    def data_for_export(*)
      relevant_applications.flat_map do |application_form|
        application_form.application_choices.map do |application_choice|
          TADApplicationExport.new(application_choice).as_json
        end
      end
    end

  private

    def relevant_applications
      ApplicationForm
        .current_cycle
        .includes(
          :candidate,
        ).preload(
          :application_qualifications,
          application_choices: [{ course: :subjects }, :provider, :accredited_provider, :audits],
        )
        .where('candidates.hide_in_reporting' => false)
        .where.not(submitted_at: nil)
        .order('submitted_at asc')
    end
  end
end
