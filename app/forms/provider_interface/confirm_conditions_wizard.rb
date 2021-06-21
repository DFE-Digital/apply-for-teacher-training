module ProviderInterface
  class ConfirmConditionsWizard
    include ActiveModel::Model

    attr_accessor :statuses, :offer

    validate :all_conditions_have_a_status_selected

    def initialize(state_store, attrs = {})
      @state_store = state_store

      super(last_saved_state.merge(attrs))
    end

    def conditions
      conditions = offer.conditions
      return conditions if statuses.blank?

      conditions.each do |condition|
        new_status = statuses&.dig(condition.id.to_s, 'status')
        condition.status = new_status
      end
    end

    def all_conditions_met?
      conditions.all?(&:met?)
    end

    def any_condition_not_met?
      conditions.any?(&:unmet?)
    end

    def save_state!
      @state_store.write(state)
    end

    def clear_state!
      @state_store.delete
    end

  private

    def all_conditions_have_a_status_selected
      conditions.each do |condition|
        next if condition.valid?

        condition.errors.each do |error|
          field_name = "statuses[#{condition.id}][#{error.attribute}]"
          create_method(field_name) { error.message }

          errors.add(field_name, error.message)
        end
      end
    end

    def last_saved_state
      saved_state = @state_store.read
      saved_state ? JSON.parse(saved_state) : {}
    end

    def state
      as_json(
        except: %w[state_store errors validation_context],
      ).to_json
    end

    def create_method(name, &block)
      self.class.send(:define_method, name, &block)
    end
  end
end
