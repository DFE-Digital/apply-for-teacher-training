module CandidateInterface
  class PoolOptInsForm
    include ActiveModel::Model
    DEFAULT_RADIUS = 10

    attr_accessor :pool_status
    attr_reader :current_candidate, :preference

    validates :pool_status, presence: true

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
        },
      )
    end

    def save
      return if invalid?

      if preference.present?
        ActiveRecord::Base.transaction do
          preference.update!(pool_status: pool_status)

          if preference.opt_out?
            preference_opt_out!(preference)
          end

          true
        end
      else
        ActiveRecord::Base.transaction do
          @preference = current_candidate.preferences.create(pool_status:)

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

      # This will have no effect if the candidate has not been sent the email
      exp = FieldTest::Experiment.find('find_a_candidate/candidate_feature_launch_email')
      participants = FieldTest::Participant.standardize(current_candidate)
      exp.convert(participants, goal: :opt_out)
    end
  end
end
