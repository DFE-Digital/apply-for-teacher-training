module CandidateInterface
  class PoolOptInsForm
    include ActiveModel::Model

    attr_accessor :pool_status, :opt_out_reason
    attr_reader :current_application, :preference

    validates :pool_status, presence: true
    validates :opt_out_reason, word_count: { maximum: 200 }, if: -> { pool_status == 'opt_out' }

    def initialize(current_application:, preference: nil, params: {})
      @current_application = current_application
      @preference = preference
      super(params)
    end

    def self.build_from_preference(current_application:, preference:)
      new(
        current_application:,
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
        application_form: current_application,
        pool_status:,
        opt_out_reason: pool_status == 'opt_in' ? nil : opt_out_reason,
        training_locations: pool_status == 'opt_out' ? nil : preference&.training_locations,
        funding_type: pool_status == 'opt_out' ? nil : preference&.funding_type,
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
          @preference = current_application.preferences.create!(**kwargs)

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
        current_application.published_preferences.where.not(id: preference.id).destroy_all
      end
    end
  end
end
