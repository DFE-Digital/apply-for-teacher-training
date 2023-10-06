module CandidateInterface
  class SortApplicationChoices
    def self.call(application_choices:)
      scope = application_choices.from <<~WITH_GROUP.squish
        (
          SELECT application.*,
          CASE
            WHEN (status IN ('offer')) THEN 1
            WHEN (status IN ('unsubmitted', 'application_not_sent', 'cancelled')) THEN 2
            WHEN (status IN ('rejected', 'conditions_not_met')) THEN 3
            WHEN (status IN ('interviewing', 'inactive', 'awaiting_provider_decision')) THEN 4
            WHEN (status IN ('declined')) THEN 5
            WHEN (status IN ('offer_withdrawn', 'withdrawn')) THEN 6
            ELSE 10
          END AS application_choices_group
          FROM application_choices application
        ) AS application_choices
      WITH_GROUP
      scope.order('application_choices_group ASC, application_choices.sent_to_provider_at DESC')
    end
  end
end
