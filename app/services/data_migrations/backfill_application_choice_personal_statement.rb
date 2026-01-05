module DataMigrations
  class BackfillApplicationChoicePersonalStatement
    TIMESTAMP = 20230612121150
    MANUAL_RUN = true

    def change
      ApplicationForm
        .select(:id)
        .joins(:application_choices)
        .where('becoming_a_teacher != personal_statement')
        .or(ApplicationForm.where.not(becoming_a_teacher: nil))
        .in_batches(of: 100) do |relation|
          ids = ActiveRecord::Base.sanitize_sql(relation.ids.join(','))

          ActiveRecord::Base.connection.execute(<<~SQL)
            WITH forms AS (
              SELECT id, becoming_a_teacher
              FROM "application_forms"
              WHERE id IN (#{ids})
            )

            UPDATE "application_choices" c
            SET personal_statement = f.becoming_a_teacher
            from forms f
            where c.application_form_id = f.id
          SQL
      end
    end
  end
end
