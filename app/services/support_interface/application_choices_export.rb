module SupportInterface
  class ApplicationChoicesExport
    def application_choices
      relevant_applications.flat_map do |application_form|
        application_form.application_choices.map do |choice|
          {
            support_reference: application_form.support_reference,
            submitted_at: application_form.submitted_at,
            choice_id: choice.id,
            provider_code: choice.provider.code,
            course_code: choice.course.code,
          }
        end
      end
    end

  private

    def relevant_applications
      ApplicationForm
        .includes(
          :candidate,
          :application_choices,
        )
        .where('candidates.hide_in_reporting' => false)
        .where.not(submitted_at: nil)
    end
  end
end
