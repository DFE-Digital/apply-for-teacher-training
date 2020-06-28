module SupportInterface
  class CandidateJourneyTrackingExport
    def application_choices
      all_application_choices.find_each.map do |choice|
        {
          id: choice.id,
          status: choice.status,
          candidate_id: choice.application_form.candidate_id,
          support_reference: choice.application_form.support_reference,
          phase: choice.application_form.phase,
        }.merge(journey_items(choice))
      end
    end

  private

    def journey_items(application_choice)
      tracker = CandidateJourneyTracker.new(application_choice)

      tracker.public_methods(false).index_with { |item| [item, tracker.send(item)] }
    end

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
