module ProviderInterface
  class OfferWizard
    include ActiveModel::Model

    STEPS = {
      default: [:select_option ],
      new_offer: [:select_option,
                  :conditions,
                  :check],
      make_changed_offer: [:select_option,
                           :select_provider,
                           :select_course,
                           :select_study_mode,
                           :select_location,
                           :conditions,
                           :check]
    }.freeze

    attr_accessor :provider_id, :provider, :course_id, :course_option_id, :study_mode, :location_id, :conditions, :current_step, :current_context

    validates :provider_id, :course_id, presence: true

    def initialize(state_store, attrs = {})
      @state_store = state_store

      super(last_saved_state.deep_merge(attrs))
    end

    def course_option
      @course_option ||= CourseOption.find(course_option_id)
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

    def next_step(current_step = current_setp)
      index = STEPS[current_context.to_sym].index(current_step.to_sym)

      #if index
        #STEPS[current_context.to_sym][index + 1]
      #end

      # if logic about next step is on wizard
      if current_step == :select_provider
        next_step = :select_courses

        #index = index + 1
        courses = Course.where(
          open_on_apply: true,
          provider_id: provider_id,
          recruitment_cycle_year: course_option.course.recruitment_cycle_year,
        ).count

        if courses.count == 1
          course_id = courses.first.id
          next_step(:select_location)
        end
      elsif current_step == :select_location
        locations = courses.locations

        if locations.count == 1
          location_id = locations.first.id
          if courses.sites.count == 1
            site = courses.sites.first # call some service that returns available sites?
          end
        end
      end

    end

    private

    def last_saved_state
      saved_state = @state_store.read
      saved_state ? JSON.parse(saved_state) : {}
    end

    def state
      as_json(except: %w[state_store errors validation_context]).to_json
    end
  end
end
