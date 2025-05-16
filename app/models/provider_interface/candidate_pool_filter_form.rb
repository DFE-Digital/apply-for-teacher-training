module ProviderInterface
  class CandidatePoolFilterForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    FILTERS = %w[location subject study_mode course_type visa_sponsorship].freeze

    # filter attributes
    attribute :location
    attribute :subject
    attribute :study_mode
    attribute :course_type
    attribute :visa_sponsorship

    attr_reader :filters, :current_provider_user, :remove_filter

    validate :location_validity

    def initialize(filter_params:, current_provider_user:, remove_filter:)
      filter_params.compact_blank!
      @current_provider_user = current_provider_user
      @remove_filter = remove_filter

      if filter_params.blank? && remove_filter.blank?
        super(current_provider_user.find_a_candidate_filters)
      else
        super(filter_params)
      end

      @filters = attributes.compact
    end

    def applied_filters
      @applied_filters ||= current_provider_user.find_a_candidate_filters.merge(
        filter_params_with_location,
      ).with_indifferent_access
    end

    def applied_location_search?
      applied_filters[:origin].present?
    end

    def save
      if valid? && filters.any?
        current_provider_user.update!(find_a_candidate_filters: filters)
      elsif remove_filter && filters.blank?
        current_provider_user.update!(find_a_candidate_filters: {})
      end
    end

    def subject_options
      # Need to check why we need to do this subject thing, where we group
      Subject.select(:id, :name) # .group(:name, :id).order(:name)
      struct = Struct.new(:id, :name)

      Subject.all.map do |subject|
        struct.new(
          id: subject.id.to_s,
          name: subject.name,
        )
      end

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

    def study_mode_options
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
