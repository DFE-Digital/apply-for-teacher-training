module ProviderInterface
  class OfferWizard
    include ActiveModel::Model

    STEPS = { make_offer: %i[select_option conditions check],
              change_offer: %i[select_option study_modes locations conditions check] }.freeze

    attr_accessor :provider_id, :course_id, :course_option_id, :study_mode, :location_id,
                  :standard_conditions, :further_condition_1, :further_condition_2,
                  :further_condition_3, :further_condition_4, :current_step, :decision

    validates :decision, presence: true
    validates :course_option_id, presence: true, on: :locations
    validates :study_mode, presence: true, on: :study_modes
    validates :further_condition_1, :further_condition_2, :further_condition_3, :further_condition_4, length: { maximum: 255 }

    def initialize(state_store, attrs = {})
      @state_store = state_store

      super(last_saved_state.deep_merge(attrs))
    end

    def conditions
      @conditions = (standard_conditions + [further_condition_1, further_condition_2,
                                            further_condition_3, further_condition_4]).reject!(&:blank?)
    end

    def course_option
      @course_option = CourseOption.find(course_option_id)
    end

    def save_state!
      @state_store.write(state)
    end

    def clear_state!
      @state_store.delete
    end

    def valid_for_current_step?
      valid?(current_step.to_sym)
    end

    def next_step
      index = STEPS[decision.to_sym].index(current_step.to_sym)

      STEPS[decision.to_sym][index + 1] if index
    end

  private

    def last_saved_state
      saved_state = @state_store.read
      saved_state ? JSON.parse(saved_state) : {}
    end

    def state
      as_json(except: %w[state_store errors validation_context course_option]).to_json
    end
  end
end
