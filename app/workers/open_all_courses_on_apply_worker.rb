class OpenAllCoursesOnApplyWorker
  include Sidekiq::Worker

  def perform
    return unless RecruitmentCycle.current_year == 2022

    closed_courses.find_each { |course| course.update!(open_on_apply: true, opened_on_apply_at: Time.zone.now) }
  end

private

  def closed_courses
    Course
      .current_cycle
      .where(open_on_apply: false)
  end
end
