module SupportInterface
  class ProviderCoursesFilter
    include FilterParamsHelper

    attr_reader :applied_filters

    def initialize(params:)
      @applied_filters = compact_params(params)
    end

    def filters
      [
        {
          type: :checkboxes,
          heading: 'Recruitment cycle',
          name: 'recruitment_cycle',
          options: recruitment_cycles.map do |year|
            {
              value: year,
              label: year,
              checked: applied_filters[:recruitment_cycle]&.include?(year.to_s) || false,
            }
          end,
        },
        {
          type: :search,
          heading: 'Course code',
          value: applied_filters[:course_code],
          name: 'course_code',
        },
        {
          type: :checkboxes,
          heading: 'Course name',
          name: 'course_name',
          options: course_names.map do |course_name|
            {
              value: course_name,
              label: course_name,
              checked: applied_filters[:course_name]&.include?(course_name) || false,
            }
          end,
        },
        {
          type: :checkboxes,
          heading: 'Status',
          name: 'status',
          options: statuses.map do |status|
            {
              value: status,
              label: status,
              checked: applied_filters[:status]&.include?(status) || false,
            }
          end,
        },
      ]
    end

    def filter_records(courses)
      courses = courses.where(recruitment_cycle_year: applied_filters[:recruitment_cycle]) if applied_filters[:recruitment_cycle].present?
      courses = courses.where('courses.code ILIKE ?', "%#{applied_filters[:course_code]}%") if applied_filters[:course_code].present?
      courses = courses.where(name: applied_filters[:course_name]) if applied_filters[:course_name].present?

      return courses if applied_filters[:status].blank?

      status_course_ids = []

      if applied_filters[:status].include?('Open')
        status_course_ids += courses.where(course_status: 'open')
                                    .where.not(recruitment_cycle_year: RecruitmentCycleTimetable.next_year)
                                    .ids
      end
      if applied_filters[:status].include?('Unpublished')
        status_course_ids += courses.where(recruitment_cycle_year: RecruitmentCycleTimetable.next_year).ids
      end
      if applied_filters[:status].include?('Closed by provider')
        status_course_ids += courses.where(course_status: 'closed', exposed_in_find: true).ids
      end
      if applied_filters[:status].include?('Hidden in Find')
        status_course_ids += courses.where(exposed_in_find: false).ids
      end

      courses.where(id: status_course_ids)
    end

  private

    def recruitment_cycles
      courses.pluck(:recruitment_cycle_year).uniq.sort.reverse
    end

    def statuses
      [
        'Open',
        'Unpublished',
        'Closed by provider',
        'Hidden in Find',
      ]
    end

    def course_names
      @course_names ||= courses.pluck(:name).uniq.sort
    end

    def courses
      @courses ||= provider.courses.order(:name)
    end

    def provider
      @provider ||= Provider.find(applied_filters[:provider_id])
    end
  end
end
