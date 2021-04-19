module SupportInterface
  class CandidateJourneyTrackingExport
    def application_choices
      all_application_choices.find_each(batch_size: 100).map do |choice|
        {
          application_choice_id: choice.id,
          choice_status: choice.status,
          recruitment_cycle_year: choice.application_form.recruitment_cycle_year,
          candidate_id: choice.application_form.candidate_id,
          support_reference: choice.application_form.support_reference,
          phase: choice.application_form.phase,
        }.merge(journey_items(choice))
      end
    end

    alias_method :data_for_export, :application_choices

  private

    def journey_items(application_choice)
      tracker = CandidateJourneyTracker.new(application_choice)

      CandidateJourneyTracker::DATA_POINTS.index_with { |item| tracker.send(item)&.iso8601 }
    end

    def all_application_choices
      ApplicationChoice
        .includes(
          :audits,
          :chasers_sent,
          application_form: [
            :candidate,
            :audits,
            :chasers_sent,
            { application_references: %i[audits chasers_sent] },
          ],
        )
        .joins(:application_form)
        .order('application_forms.submitted_at asc, application_forms.id asc, id asc')
    end
  end
end
