module ProviderInterface
  class CandidatePoolFilter
    include ActiveModel::Model
    include ActiveModel::Attributes

    # filter attributes
    attribute :location
    attribute :subject
    attribute :study_mode
    attribute :course_type
    attribute :visa_sponsorship

    attr_reader :filters, :current_provider_user, :remove_filter, :suggested_location

    validate :location_validity

    def initialize(filter_params:, current_provider_user:, remove_filter:)
      @current_provider_user = current_provider_user
      @remove_filter = remove_filter
      @suggested_location ||= LocationSuggestions.new(
        filter_params[:location] || current_provider_user.find_a_candidate_filters['location'],
      ).call.first

      super(filter_attributes(filter_params))

      @filters = attributes.compact
    end

    def applied_filters
      return {} if invalid?

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

  private

    def filter_attributes(filter_params)
      filter_params.compact_blank!

      if filter_params.blank? && remove_filter.blank?
        current_provider_user.find_a_candidate_filters.with_indifferent_access
      else
        if filter_params[:location].present? && suggested_location
          filter_params[:location] = suggested_location&.fetch(:name, nil)
        end

        filter_params
      end
    end

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

    def location_validity
      if location.present? && location_coordinates.nil?
        errors.add(:location, :invalid_location)
      end
    end
  end
end
