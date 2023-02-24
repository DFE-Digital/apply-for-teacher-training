module DataMigrations
  class SetMissingSectionCompletedAtTimestamps
    TIMESTAMP = 20230223145758
    MANUAL_RUN = false

    def change
      ApplicationForm::SECTION_COMPLETED_FIELDS.each do |field|
        ApplicationForm
          .where("#{field}_completed": true, "#{field}_completed_at": nil)
          .where.not(previous_application_form_id: nil)
          .update_all("#{field}_completed_at = created_at")
      end
    end
  end
end
