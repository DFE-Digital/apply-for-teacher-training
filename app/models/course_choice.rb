class CourseChoice < ActiveRecord::Base
  belongs_to :training_location
  belongs_to :course

  def self.find_matching(provider_code, course_code, training_location_code)
    provider = Provider.find_by!(code: provider_code)
    find_by!(
      course: provider.courses.find_by!(course_code: course_code),
      training_location: provider.training_locations.find_by!(code: training_location_code)
    )
  end

  def same_choice_as?(other)
    self.course == other.course
  end
end
