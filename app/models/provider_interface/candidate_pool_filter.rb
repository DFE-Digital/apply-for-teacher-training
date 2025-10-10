module ProviderInterface
  class CandidatePoolFilter
    include ActiveModel::Model
    include ActiveModel::Attributes

    ## Filter attributes
    ## If you change an attribute add alias to persist the old db saved filters
    ## Removing or adding one doesn't require aliases
    ATTRIBUTES = %i[
      location
      candidate_search
      candidate_id
      subject_ids
      study_mode
      course_type
      visa_sponsorship
      funding_type
    ].freeze
    ATTRIBUTES.each do |attribute|
      attribute attribute.to_sym
    end
    alias subject= subject_ids=

    attr_reader :filters, :current_provider_user, :suggested_location,
                :provider_user_filter, :apply_filters

    validate :location_validity
    validates :candidate_id, numericality: { only_integer: true, allow_nil: true }
    validate :candidate_presence_on_search

    def initialize(filter_params:, current_provider_user:, apply_filters:)
      @current_provider_user = current_provider_user
      @provider_user_filter = build_provider_user_filter
      @apply_filters = apply_filters
      @suggested_location ||= LocationSuggestions.new(
        filter_params[:location] || @provider_user_filter.filters['location'],
      ).call.first

      super(filter_attributes(filter_params))

      @filters = attributes.compact
    end

    def applied_filters
      return {} if invalid?

      @applied_filters ||= provider_user_filter.filters.merge(
        filter_params_with_location,
      ).with_indifferent_access
    end

    def applied_location_search?
      applied_filters[:origin].present?
    end

    def save
      return false unless valid?

      if apply_filters
        ActiveRecord::Base.transaction do
          provider_user_filter.update(filters:, updated_at: Time.zone.now)
          sister_filter.update(filters:, updated_at: 2.seconds.ago)
        end
      else
        ActiveRecord::Base.transaction do
          provider_user_filter.update(updated_at: Time.zone.now)
          sister_filter.update(updated_at: 2.seconds.ago)
        end
      end
    end

    def save_pagination(pagination_page)
      provider_user_filter.update(pagination_page:)
    end

    def no_results_message
      if applied_filters.keys.include?('candidate_id') && candidate_exists_but_not_in_pool?
        I18n.t('provider_interface.candidate_pool.exists_but_not_in_pool')
      elsif applied_filters.keys == %w[candidate_search candidate_id]
        I18n.t('provider_interface.candidate_pool.no_candidate_with_id')
      elsif applied_filters.keys.include?('candidate_id')
        I18n.t('provider_interface.candidate_pool.no_candidates_with_id_and_other_filters')
      else
        I18n.t('provider_interface.candidate_pool.no_candidates')
      end
    end

  private

    def filter_attributes(filter_params)
      filter_params.compact_blank!

      if apply_filters
        if filter_params[:location].present? && suggested_location
          filter_params[:location] = suggested_location&.fetch(:name, nil)
        end

        filter_params
      else
        sanitised_db_filters
      end
    end

    def sanitised_db_filters
      filters = @provider_user_filter.filters.with_indifferent_access

      old_filters = filters.keys.map(&:to_sym) - ATTRIBUTES

      if old_filters.present?
        filters.reject! do |filter_key|
          !self.class.method_defined?("#{filter_key}=") && old_filters.include?(filter_key.to_sym)
        end
        @apply_filters = true
      end

      filters
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

    def candidate_presence_on_search
      if candidate_search.present? && candidate_id.nil?
        errors.add(:candidate_id, :blank)
      end
    end

    def build_provider_user_filter
      current_provider_user.find_a_candidate_all_filter ||
        current_provider_user.build_find_a_candidate_all_filter
    end

    def sister_filter
      current_provider_user.find_a_candidate_not_seen_filter ||
        current_provider_user.build_find_a_candidate_not_seen_filter
    end

    def candidate_exists_but_not_in_pool?
      candidate && candidate.application_forms.last.candidate_pool_application.blank?
    end

    def candidate
      return if candidate_id.blank?

      Candidate.find_by(id: candidate_id)
    end
  end
end
