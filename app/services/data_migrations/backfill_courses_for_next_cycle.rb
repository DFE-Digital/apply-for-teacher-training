module DataMigrations
  class BackfillCoursesForNextCycle
    TIMESTAMP = 20210917140806
    MANUAL_RUN = false

    def change
      Course.where(recruitment_cycle_year: RecruitmentCycle.next_year, open_on_apply: false).update_all(open_on_apply: true, opened_on_apply_at: Time.zone.now)
    end
  end
end
