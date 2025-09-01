module EndOfCycle
  class SyncNextYearsCoursesAndProviders
    include Sidekiq::Worker

    def first_full_sync_after
      start_syncing_after = 8.weeks.before(current_timetable.apply_deadline_at).change(hour: 0o0, min: 4)
      start_syncing_after = start_syncing_after.next_occurring(:friday) unless start_syncing_after.friday?
      start_syncing_after
    end

    def sync_next_year?
      # After find closes, the main sync is for the 'next year', so we no longer need these jobs to run.
      Time.zone.now.after?(first_full_sync_after) && Time.zone.now.before?(current_timetable.find_closes_at)
    end

    def current_timetable
      @current_timetable ||= RecruitmentCycleTimetable.current_timetable
    end

    def next_year
      @next_year ||= current_timetable.relative_next_year
    end
  end
end
