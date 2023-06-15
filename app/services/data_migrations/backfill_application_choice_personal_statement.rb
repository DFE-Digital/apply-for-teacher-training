module DataMigrations
  class BackfillApplicationChoicePersonalStatement
    TIMESTAMP = 20230612121150
    MANUAL_RUN = true

    def change
      ActiveRecord::Base.connection.execute(<<~SQL)
        UPDATE "application_choices" c
        SET personal_statement = (
          SELECT becoming_a_teacher
          FROM application_forms
          WHERE c.application_form_id = id
          AND becoming_a_teacher IS NOT NULL
        )
      SQL
    end
  end
end
