module DataMigrations
  class BackfillApplicationChoicePersonalStatement
    TIMESTAMP = 20230612121150
    MANUAL_RUN = true

    def change
      ApplicationForm.select(:id).in_batches(of: 100) do |relation|
        ids = relation.ids.join(',')

        ActiveRecord::Base.connection.execute(<<~SQL)
          UPDATE "application_choices" c
          SET personal_statement = (
            SELECT becoming_a_teacher
            FROM application_forms
            WHERE c.application_form_id = id
            AND id in (#{ids})
            AND becoming_a_teacher IS NOT NULL
          )
          where c.application_form_id in (#{ids})
        SQL
      end
    end
  end
end
