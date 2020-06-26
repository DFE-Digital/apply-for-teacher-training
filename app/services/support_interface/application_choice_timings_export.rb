module SupportInterface
  class ApplicationChoiceTimingsExport
    def application_choices
      all_application_choices.map do |choice|
        {
          id: choice.id,
          status: choice.status,
          candidate_id: choice.application_form.candidate_id,
          support_reference: choice.application_form.support_reference,
          phase: choice.application_form.phase,
        }
      end
    end

  private

    def all_application_choices
      ApplicationChoice
        .includes(
          application_form: %i[candidate],
        )
        .joins(:application_form)
        .order('application_forms.submitted_at asc, application_forms.id asc, id asc')
    end
  end
end
