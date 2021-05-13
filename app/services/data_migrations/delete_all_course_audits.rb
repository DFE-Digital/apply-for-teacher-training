module DataMigrations
  class DeleteAllCourseAudits
    TIMESTAMP = 20210512155055
    MANUAL_RUN = true

    def change
      Course.in_batches(of: 100).each_with_index do |relation, batch_index|
        course_audits_query =
          Audited::Audit
            .with(courses: relation)
            .joins('INNER JOIN courses ON auditable_type = \'Course\' AND auditable_id = courses.id')
            .select(:id)

        delete_course_audits!(
          audits_sql: course_audits_query.to_sql,
          batch_index: batch_index,
        )
      end
    end

    def delete_course_audits!(audits_sql:, batch_index:)
      delete_sql = <<~DELETE_COURSE_AUDITS.squish
        DELETE FROM audits
        WHERE id IN (#{audits_sql})
      DELETE_COURSE_AUDITS

      result = ActiveRecord::Base.connection.execute(delete_sql)
      Rails.logger.info("Deleting course audits - batch no. #{batch_index + 1}: #{result.cmd_status}")
    end
  end
end
