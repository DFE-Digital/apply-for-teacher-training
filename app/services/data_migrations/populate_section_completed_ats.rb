module DataMigrations
  class PopulateSectionCompletedAts
    TIMESTAMP = 20230127151055
    MANUAL_RUN = false

    def change
      ApplicationForm::SECTION_COMPLETED_FIELDS.each do |field|
        ActiveRecord::Base.connection.execute(
          <<~SQL,
            WITH boolean_updates AS (
              SELECT DISTINCT ON (auditable_id) auditable_id, created_at
              FROM audits
              WHERE auditable_type = 'ApplicationForm'
              AND (
                audited_changes->'#{field}_completed' = '[false,true]'
                OR audited_changes->'#{field}_completed' = '[null,true]'
              )
              ORDER BY auditable_id, created_at DESC
            )
            UPDATE application_forms
            SET #{field}_completed_at = boolean_updates.created_at
            FROM boolean_updates
            WHERE application_forms.id = boolean_updates.auditable_id
          SQL
        )
      end
    end
  end
end
