module DataMigrations
  class BackfillOpenedOnApplyAtFromAudits
    TIMESTAMP = 20210511084457
    MANUAL_RUN = true

    def change
      Course
        .where(open_on_apply: true)
        .where('created_at < \'2020-04-01\'')
        .update_all('opened_on_apply_at = \'2020-03-26\'')

      Course.where(open_on_apply: true).in_batches(of: 50).each_with_index do |relation, batch_index|
        most_recent_open_events_per_course =
          Audited::Audit
            .with(open_courses: relation)
            .joins('INNER JOIN open_courses ON auditable_type = \'Course\' AND auditable_id = open_courses.id')
            .where('audited_changes->>\'open_on_apply\' IN (\'true\', \'[false, true]\')')
            .group('auditable_id')
            .select('auditable_id AS course_id, MAX(audits.created_at) AS opened_at')

        update_courses_from_audits!(
          open_events_sql: most_recent_open_events_per_course.to_sql,
          batch_index: batch_index,
        )
      end
    end

    def update_courses_from_audits!(open_events_sql:, batch_index:)
      update_sql = <<~SET_OPENED_ON_APPLY_AT_FROM_AUDITS.squish
        UPDATE courses c
        SET opened_on_apply_at = open_events.opened_at
        FROM (#{open_events_sql}) open_events
        WHERE c.id = open_events.course_id
      SET_OPENED_ON_APPLY_AT_FROM_AUDITS

      result = ActiveRecord::Base.connection.execute(update_sql)
      Rails.logger.info("Updating opened_on_apply_at - batch no. #{batch_index + 1}: #{result.cmd_status}")
    end
  end
end
