module DataMigrations
  class PruneQualificationFlipFlopsFromCourseAudits
    TIMESTAMP = 20210505154302
    MANUAL_RUN = false

    def change
      sql = <<~REMOVE_DUPLICATE_QUALIFICATION_CHANGES_FROM_COURSE_AUDITS.squish
        DELETE FROM audits
        WHERE id IN (
          SELECT id FROM (
            SELECT
              id,
              ROW_NUMBER() OVER(
                PARTITION BY auditable_id, audited_changes ORDER BY created_at DESC
              ) AS row_num
            FROM audits
            WHERE
              auditable_type = 'Course'
              AND username = '(Automated process)'
              AND audited_changes IN (
                '{"qualifications": [null, ["qts"]]}'::jsonb,
                '{"qualifications": [["qts"], null]}'::jsonb,
                '{"qualifications": [null, ["qts", "pgce"]]}'::jsonb,
                '{"qualifications": [["qts", "pgce"], null]}'::jsonb
              )
          ) t WHERE t.row_num > 1
        )
      REMOVE_DUPLICATE_QUALIFICATION_CHANGES_FROM_COURSE_AUDITS

      ActiveRecord::Base.connection.execute(sql)
    end
  end
end
