module SupportInterface
  class CandidatePoolFilter
    include FilterParamsHelper
    include ActionView::Helpers::TagHelper
    include Rails.application.routes.url_helpers

    attr_reader :filter_params

    def initialize(filter_params:)
      @filter_params = compact_params(filter_params)
    end

    def filters
      [
        {
          type: :location_search,
          heading: 'Town, city or postcode:',
          name: 'location_search',
          original_location: filter_params[:original_location],
          title: 'Candidate location preferences',
          path_to_location_suggestions: support_interface_location_suggestions_path,
        },
        {
          type: :checkbox_filter,
          heading: 'Subjects previously applied to',
          name: 'subject_ids',
          options: subject_options,
          hide_tags: true,
          title: 'Candidate course preferences',
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
          heading: tag.h3('Candidate visa requirements', class: 'govuk-heading-m govuk-!-margin-bottom-0'),
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
      filter_params[:original_location].present?
    end

  private

    def visa_sponsorship_options
      [['required', 'Needs a visa'], ['not required', 'Does not need a visa']].map do |value, label|
        {
          value:,
          label:,
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
          checked: applied_filters[:subject_ids]&.include?(subject.ids),
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
        {
          value: value,
          label: value.capitalize,
          checked: applied_filters[:course_type]&.include?(value),
        }
      end
    end
  end
end
