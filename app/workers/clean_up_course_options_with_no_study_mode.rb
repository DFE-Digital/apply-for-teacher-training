class CleanUpCourseOptionsWithNoStudyMode
  include Sidekiq::Worker

  def perform
    CourseOption.where('study_mode IN (\'0\',\'1\')').find_each do |nil_co|
      intended_study_mode = case nil_co.study_mode_before_type_cast
                            when '0'; :full_time
                            when '1'; :part_time
                            end
      equivalent_course_option = find_equivalent_course_option nil_co, intended_study_mode
      if equivalent_course_option
        nil_co.application_choices.each do |application_choice|
          application_choice.update!(course_option_id: equivalent_course_option.id)
        end
        nil_co.destroy!
      else
        nil_co.update!(study_mode: intended_study_mode)
      end
    end
  end

  def find_equivalent_course_option(nil_co, intended_study_mode)
    CourseOption.where(
      course: nil_co.course,
      site: nil_co.site,
      study_mode: intended_study_mode,
    ).first
  end
end
