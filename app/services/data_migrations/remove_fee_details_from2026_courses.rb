module DataMigrations
  class RemoveFeeDetailsFrom2026Courses
    TIMESTAMP = 20251211154445
    MANUAL_RUN = false

    def change
      courses.update_all(fee_details: nil)
    end

  private

    def courses
      Course.where(recruitment_cycle_year: 2026).where.not(fee_details: nil)
    end
  end
end
