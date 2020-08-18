module ProviderInterface
  class SortApplicationChoices
    def self.call(application_choices:)
      for_task_view(application_choices).order(sort_order)
    end

    def self.for_task_view(application_choices)
      application_choices.from <<~WITH_TASK_VIEW_GROUP.squish
        (
          SELECT *,
            CASE
              WHEN #{awaiting_provider_decision} THEN 1
              WHEN #{offered} THEN 2
              ELSE 999
            END AS task_view_group,
            #{pg_days_left_to_respond} AS pg_days_left_to_respond

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

    def self.pg_days_left_to_respond
      <<~PG_DAYS_LEFT_TO_RESPOND.squish
        CASE
          WHEN (DATE(reject_by_default_at) > DATE('#{Time.zone.now.iso8601}'))
          THEN (DATE(reject_by_default_at) - DATE('#{Time.zone.now.iso8601}'))
          ELSE NULL END
      PG_DAYS_LEFT_TO_RESPOND
    end

    def self.sort_order
      <<~ORDER_BY.squish
        task_view_group,
        status,
        pg_days_left_to_respond,
        application_choices.updated_at
      ORDER_BY
    end
  end
end
