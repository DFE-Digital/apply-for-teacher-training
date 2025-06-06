module DataMigrations
  class BackfillRecruitmentCycleYearOnPoolInvites
    TIMESTAMP = 20250605151610
    MANUAL_RUN = false

    def change
      Pool::Invite
        .where(recruitment_cycle_year: nil)
        .update_all(recruitment_cycle_year:)
    end

  private

    def recruitment_cycle_year
      @recruitment_cycle_year ||= RecruitmentCycleTimetable.current_year
    end
  end
end
