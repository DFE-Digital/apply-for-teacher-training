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
        # if a form belongs to previous year, we only want to consider the choice that was deferred
        # for non-deferred apps this set will be equivalent to all choices
        application_form.application_choices.select { |ac| ac.current_recruitment_cycle_year == RecruitmentCycle.current_year }.map do |application_choice|
          TADApplicationExport.new(application_choice).as_json
        end
      end
    end

  private

    def relevant_applications
      ApplicationForm
        .joins(:application_choices)
        .current_cycle
        .or(
          ApplicationForm
            .joins(:application_choices)
            .where('application_forms.recruitment_cycle_year < ?', RecruitmentCycle.current_year)
            .where('application_choices.current_recruitment_cycle_year' => RecruitmentCycle.current_year),
        ).includes(
          :candidate,
        ).preload(
          :application_qualifications,
          application_choices: [{ current_course: :subjects }, :provider, :accredited_provider, :audits],
        )
        .where('candidates.hide_in_reporting' => false)
        .where.not(submitted_at: nil)
        .order('submitted_at asc')
    end
  end
end
