class ExistingCandidateAuthentication
  attr_accessor :candidate

  def initialize(candidate:)
    @candidate = candidate
  end

  def execute
    if has_course_from_find? && course_has_one_site?
      add_application_choice
      set_course_from_find_id_to_nil
      :candidate_has_new_course_added
    elsif has_course_from_find?
      set_course_from_find_id_to_nil
      :candidate_should_choose_site
    else
      :candidate_does_not_have_a_course_from_find_id
    end
  end

private

  def add_application_choice
    course_option = CourseOption.find_by!(course_id: @candidate.course_from_find_id)
    new_application_choice = ApplicationChoice.new(course_option_id: course_option.id)
    @candidate.current_application.application_choices << new_application_choice
  end

  def set_course_from_find_id_to_nil
    @candidate.update(course_from_find_id: nil)
  end

  def has_course_from_find?
    @candidate.course_from_find_id.present?
  end

  def course_has_one_site?
    CourseOption.where(course_id: @candidate.course_from_find_id).one?
  end
end
