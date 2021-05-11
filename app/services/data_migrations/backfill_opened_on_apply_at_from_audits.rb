module DataMigrations
  class BackfillOpenedOnApplyAtFromAudits
    TIMESTAMP = 20210511084457
    MANUAL_RUN = false

    def change
      sql = <<~SET_OPENED_ON_APPLY_AT_FROM_AUDITS.squish
        UPDATE courses c
        SET opened_on_apply_at = courses_with_open_events.last_opened_at
        FROM (
          SELECT auditable_id AS course_id, max(created_at) AS last_opened_at
          FROM audits
          WHERE
            auditable_type = 'Course'
            AND audited_changes->>'open_on_apply' IN ('true', '[false, true]')
          GROUP BY auditable_id
        ) AS courses_with_open_events
        WHERE c.id = courses_with_open_events.course_id
      SET_OPENED_ON_APPLY_AT_FROM_AUDITS

      ActiveRecord::Base.connection.execute(sql)
    end
  end
end
