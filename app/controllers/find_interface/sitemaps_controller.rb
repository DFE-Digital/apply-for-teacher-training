class SitemapsController < ApplicationController
  def show
    @courses = Course
      .where(recruitment_cycle_year: Settings.current_cycle)
      .select("course_code", "provider_code", "changed_at")
      .page(1)
      .per(20_000)
      .all
  end
end
