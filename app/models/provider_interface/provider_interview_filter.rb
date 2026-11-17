module ProviderInterface
  class ProviderInterviewFilter
    include FilterParamsHelper

    attr_reader :params, :interviews

    def initialize(params:, interviews:)
      @params = compact_params(params)
      @interviews = interviews
    end

    def filters
      [subject_options, courses_filter]
    end

    def applied_filters
      filtered_interviews = filter_by_subject(interviews)
      filter_by_course(filtered_interviews)
    end

  private

    def subject_options
      {
        type: :checkbox_filter,
        heading: 'Subject',
        name: 'subject',
        options: Subject.joins(:courses).where(courses: { id: course_ids }).order(:name).distinct.map do |subject|
          {
            value: subject.id,
            label: subject.name,
            checked: subject_ids_filter.include?(subject.id.to_s),
          }
        end,
      }
    end

    def course_ids
      @course_ids ||= CourseOption
        .where(id: ApplicationChoice.where(id: interviews.select(:application_choice_id)).select(:current_course_option_id))
        .distinct
        .pluck(:course_id)
    end

    def courses_filter
      {
        type: :checkboxes,
        heading: 'Course',
        name: 'course_ids',
        options: Course.where(id: course_ids).order(:name).map do |course|
          {
            value: course.id,
            label: course.name_and_code,
            checked: course_id_filter.include?(course.id.to_s),
          }
        end,
      }
    end

    def filter_by_subject(interviews)
      return interviews if subject_ids_filter.blank?

      id_course = Course
        .joins(:subjects)
        .where(id: course_ids, subjects: { id: subject_ids_filter })
        .select(:id)

      interviews.where(
        application_choice_id: ApplicationChoice
          .joins(:current_course)
          .where(current_course: { id: id_course }).select(:id),
      )
    end

    def subject_ids_filter
      @subject_filter ||= params.fetch(:subject, [])
    end

    def filter_by_course(interviews)
      return interviews if course_id_filter.blank?

      interviews.where(
        application_choice_id: ApplicationChoice
          .joins(:current_course)
          .where(current_course: { id: course_id_filter }).select(:id),
      )
    end

    def course_id_filter
      @course_id_filter ||= params.fetch(:course_ids, [])
    end
  end
end
