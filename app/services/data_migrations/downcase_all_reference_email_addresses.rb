module DataMigrations
  class DowncaseAllReferenceEmailAddresses
    TIMESTAMP = 20260106170245
    MANUAL_RUN = false

    def change
      sql = <<~SQL
        UPDATE "references"
        SET email_address = TRIM(LOWER(email_address))
      SQL

      ActiveRecord::Base.connection.execute(sql)
    end
  end
end
