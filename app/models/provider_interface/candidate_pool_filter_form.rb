module ProviderInterface
  class CandidatePoolFilterForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :location
    attribute :course_ids
    attribute :study_types
    attribute :course_types
    attribute :visa_sponsorships

    ## Should this form have a save method?
    ## Which saves the form to the current provider user?
    ## This way we can make the form remember the field values?

    # fix the filters

    validate :location_validity

    def applied_filters
      @applied_filters ||=
        {
          subject: course_ids, # course_ids should be subjects
          study_mode: study_types,
          course_type: course_types,
          visa_sponsorship: visa_sponsorships, # should we make these match?
        }.merge!(filter_params_with_location)
    end

    def applied_location_search?
      applied_filters[:origin].present?
    end

    def subject_options
      subjects = Subject.select("name, string_agg(id::text, ',') as ids").group(:name).order(:name)
      # Should we scope to all subjects of the provider?
    end

    def visa_sponsorship_options
      visa = Struct.new(:value, :name)

      [['required', 'Needs a visa'], ['not required', 'Does not need a visa']].map do |value, name|
        visa.new(
          value:,
          name:,
        )
      end
    end

    def study_type_options
      study_mode = Struct.new(:value, :name)

      CourseOption.study_modes.map do |_, value|
        study_mode.new(
          value: value,
          name: value.split('_').join(' ').capitalize,
        )
      end
    end

    def course_type_options
      course_type = Struct.new(:value, :name)

      %w[undergraduate postgraduate].map do |value|
        filter_value = if value == 'postgraduate'
                         Course.program_types.except('teacher_degree_apprenticeship').values.join(',')
                       else
                         Course.program_types['teacher_degree_apprenticeship']
                       end

        course_type.new(
          value: filter_value,
          name: value.capitalize,
        )
      end
    end

  private

    def filter_params_with_location
      filter_params = {}

      if location && location_coordinates.present?
        filter_params.merge!(
          {
            origin: [
              location_coordinates&.latitude,
              location_coordinates&.longitude,
            ],
          },
        )
      end

      filter_params
    end

    def location_coordinates
      return unless suggested_location

      Geocoder.search(suggested_location[:place_id], google_place_id: true).first
    end

    def suggested_location
      @suggested_location ||= LocationSuggestions.new(location).call.first
    end

    def location_validity
      return if location.blank?

      if location_coordinates.nil?
        errors.add(:location, 'Invalid')
      end
    end
  end
end
