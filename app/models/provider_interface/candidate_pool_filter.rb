module ProviderInterface
  class CandidatePoolFilter
    include FilterParamsHelper

    RADIUS_VALUES = [1, 5, 10, 15, 20, 25, 50, 100, 200].freeze
    FILTERS = %w[within original_location subject study_mode course_type visa_sponsorship].freeze

    attr_reader :filter_params

    def initialize(filter_params:, current_provider_user:)
      @filter_params = set_filters(
        compact_params(filter_params),
        current_provider_user,
      )
    end

    def filters
      [
        {
          type: :location_search,
          heading: 'Search radius',
          name: 'location_search',
          hint: "Candidate's last course location",
          radius_values: RADIUS_VALUES,
          within: filter_params[:within],
          original_location: filter_params[:original_location],
        },
        {
          type: :checkbox_filter,
          heading: 'Subject',
          name: 'subject',
          options: subject_options,
          hide_tags: true,
          title: "Candidate's selections",
        },
        {
          type: :checkboxes,
          heading: 'Study type',
          name: 'study_mode',
          options: study_mode_options,
        },
        {
          type: :checkboxes,
          heading: 'Course type',
          name: 'course_type',
          options: course_type_options,
        },
        {
          type: :checkboxes,
          heading: 'Visa sponsorship',
          name: 'visa_sponsorship',
          options: visa_sponsorship_options,
        },
      ]
    end

    def applied_filters
      if applied_location_search?
        geocoder_location = Geocoder.search(filter_params[:original_location], components: 'country:UK').first

        return filter_params unless geocoder_location

        filter_params.merge!(
          {
            origin: [
              geocoder_location.latitude,
              geocoder_location.longitude,
            ],
          },
        )
      end

      filter_params
    end

    def applied_location_search?
      filter_params[:within].present? && filter_params[:original_location].present?
    end

  private

    def set_filters(filters, current_provider_user)
      any_filters = filters.keys.intersect?(FILTERS)

      if filters[:remove] == 'true' && !any_filters
        current_provider_user.update!(find_a_candidate_filters: {})
      elsif any_filters
        current_provider_user.update!(find_a_candidate_filters: filters)
      end

      current_provider_user.find_a_candidate_filters.with_indifferent_access
    end

    def visa_sponsorship_options
      ['required', 'not required'].map do |value|
        {
          value: value,
          label: value.capitalize,
          checked: applied_filters[:visa_sponsorship]&.include?(value),
        }
      end
    end

    def subject_options
      subjects = Subject.select("name, string_agg(id::text, ',') as ids").group(:name).order(:name)

      subjects.map do |subject|
        {
          value: subject.ids,
          label: subject.name.capitalize,
          checked: applied_filters[:subject]&.include?(subject.ids),
        }
      end
    end

    def study_mode_options
      CourseOption.study_modes.map do |_, value|
        {
          value: value,
          label: value.split('_').join(' ').capitalize,
          checked: applied_filters[:study_mode]&.include?(value),
        }
      end
    end

    def course_type_options
      %w[undergraduate postgraduate].map do |value|
        filter_value = if value == 'postgraduate'
                         Course.program_types.except('teacher_degree_apprenticeship').values.join(',')
                       else
                         Course.program_types['teacher_degree_apprenticeship']
                       end

        {
          value: filter_value,
          label: value.capitalize,
          checked: applied_filters[:course_type]&.include?(filter_value),
        }
      end
    end
  end
end
