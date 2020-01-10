class CleanUpCourseOptionsWithNoStudyMode
  include Sidekiq::Worker

  def perform
    CourseOption.where('study_mode = \'0\'').each do |nil_co|
      if nil_co.application_choices.any?
        equivalent_course_option = CourseOption.where(
          course: nil_co.course,
          site: nil_co.site,
          study_mode: :full_time,
        ).first
        if equivalent_course_option
          nil_co.application_choices.each do |application_choice|
            application_choice.update!(course_option_id: equivalent_course_option.id)
          end
          nil_co.destroy!
        end
      else
        nil_co.destroy!
      end
    end
  end
end
