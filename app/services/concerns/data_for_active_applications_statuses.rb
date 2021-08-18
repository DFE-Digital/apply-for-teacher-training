module DataForActiveApplicationsStatuses
private

  def grouped_course_data
    @course_data ||= GetApplicationProgressDataByCourse.new(provider: provider).call.group_by(&:id)
  end

  def status_count(courses, status)
    courses.find { |course| course.status == status.to_s }&.count || 0
  end

  def provider_name(course)
    accredited_by_different_provider?(course) ? course.accredited_provider_name : course.provider_name
  end

  def accredited_by_different_provider?(course)
    course.accredited_provider_id && provider.id == course.provider_id && course.provider_id != course.accredited_provider_id
  end
end
