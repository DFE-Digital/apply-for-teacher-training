module SupportInterface
  class TADExport
    def data_for_export(run_once_flag = false)
      relevant_applications.flat_map do |application_form|
        application_form.application_choices.map do |application_choice|
          TADApplicationExport.new(application_choice).as_json
        end
      end
      break if run_once_flag
    end

  private

    def relevant_applications
      # Should be the same as UCAS.
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
