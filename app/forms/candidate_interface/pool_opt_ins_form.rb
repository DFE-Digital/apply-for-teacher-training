module CandidateInterface
  class PoolOptInsForm
    include ActiveModel::Model
    DEFAULT_RADIUS = 10

    attr_accessor :pool_status, :opt_out_reason
    attr_reader :current_candidate, :preference

    validates :pool_status, presence: true
    validates :opt_out_reason, word_count: { maximum: 200 }, if: -> { pool_status == 'opt_out' }

    def initialize(current_candidate:, preference: nil, params: {})
      @current_candidate = current_candidate
      @preference = preference
      super(params)
    end

    def self.build_from_preference(current_candidate:, preference:)
      new(
        current_candidate:,
        preference:,
        params: {
          pool_status: preference.pool_status,
          opt_out_reason: preference.opt_out_reason,
        },
      )
    end

    def save
      return if invalid?

      kwargs = {
        pool_status:,
        opt_out_reason: pool_status == 'opt_in' ? nil : opt_out_reason,
        training_locations: pool_status == 'opt_out' ? nil : preference&.training_locations,
      }

      if preference.present?
        ActiveRecord::Base.transaction do
          preference.update!(**kwargs)

          if preference.opt_out?
            preference_opt_out!(preference)
          end

          true
        end
      else
        ActiveRecord::Base.transaction do
          @preference = current_candidate.preferences.create(**kwargs)

          if @preference.opt_out?
            preference_opt_out!(@preference)
          else
            LocationPreferences.add_default_location_preferences(preference: @preference)
          end

          true
        end
      end
    end

  private

    def preference_opt_out!(preference)
      ActiveRecord::Base.transaction do
        preference.published!
        current_candidate.published_preferences.where.not(id: preference.id).destroy_all
      end
    end
  end
end
