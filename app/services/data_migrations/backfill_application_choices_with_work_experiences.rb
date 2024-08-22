module DataMigrations
  class BackfillApplicationChoicesWithWorkExperiences
    TIMESTAMP = 20240822105049
    MANUAL_RUN = true

    def change
      time_now = Time.zone.now

      choices_without_work_histories.each_slice(5000).with_index do |ids, index|
        next_batch_time = time_now + index.minutes
        MigrateApplicationChoicesWorker.perform_at(next_batch_time, ids)
      end
    end

    def choices_without_work_histories
      sql = <<-SQL
       SELECT "application_choices".id FROM "application_choices" LEFT OUTER JOIN "application_experiences" "work_experiences" ON
       "work_experiences"."experienceable_type" = 'ApplicationChoice' AND "work_experiences"."experienceable_id" = "application_choices"."id" AND
       "work_experiences"."type" = 'ApplicationWorkExperience' WHERE "application_choices"."status" != 'unsubmitted' AND "work_experiences"."id" IS NULL
       union
       SELECT "application_choices".id FROM "application_choices" LEFT OUTER JOIN "application_experiences" "volunteering_experiences" ON
       "volunteering_experiences"."experienceable_type" = 'ApplicationChoice' AND "volunteering_experiences"."experienceable_id" = "application_choices"."id" AND
       "volunteering_experiences"."type" = 'ApplicationVolunteeringExperience' WHERE "application_choices"."status" != 'unsubmitted' AND
       "volunteering_experiences"."id" IS NULL
       union
       SELECT "application_choices".id FROM "application_choices" LEFT OUTER JOIN "application_work_history_breaks" "work_history_breaks" ON
       "work_history_breaks"."breakable_type" = 'ApplicationChoice' AND "work_history_breaks"."breakable_id" = "application_choices"."id" WHERE
       "application_choices"."status" != 'unsubmitted' AND "work_history_breaks"."id" IS NULL
      SQL

      ApplicationChoice.find_by_sql(sql).map(&:id)
    end
  end
end
