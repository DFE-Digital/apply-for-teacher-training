module ProviderInterface
  class SortApplicationChoices
    def self.call(application_choices:)
      with_task_view_group(application_choices).order(sort_order)
    end

    def self.with_task_view_group(application_choices)
      application_choices.from <<~WITH_TASK_VIEW_GROUP.squish
        (
          SELECT *,
            CASE
              WHEN #{awaiting_provider_decision} THEN 1
              WHEN #{offered} THEN 2
              ELSE 999
            END AS task_view_group
            FROM application_choices
        ) AS application_choices
      WITH_TASK_VIEW_GROUP
    end

    def self.awaiting_provider_decision
      <<~AWAITING_PROVIDER_DECISION.squish
        (
          status='awaiting_provider_decision'
          AND (DATE(reject_by_default_at) > '#{Time.zone.now.iso8601}')
        )
      AWAITING_PROVIDER_DECISION
    end

    def self.offered
      <<~OFFERED.squish
        (
          status='offer'
        )
      OFFERED
    end

    def self.sort_order
      # FIXME: do we need some sort of rank within each task_view_group?
      <<~ORDER_BY.squish
        task_view_group, status, application_choices.updated_at
      ORDER_BY
    end
  end
end
