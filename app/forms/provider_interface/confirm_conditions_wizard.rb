module ProviderInterface
  class ConfirmConditionsWizard
    include ActiveModel::Model

    attr_accessor :statuses, :offer

    def initialize(state_store, attrs = {})
      @state_store = state_store

      super(last_saved_state.merge(attrs))
    end

    def conditions
      conditions = offer.conditions
      return conditions if statuses.blank?

      conditions.each do |condition|
        new_status = statuses.dig(condition.id.to_s, 'status')
        condition.status = new_status
      end
    end

    def save_state!
      @state_store.write(state)
    end

    def clear_state!
      @state_store.delete
    end

  private

    def last_saved_state
      saved_state = @state_store.read
      saved_state ? JSON.parse(saved_state) : {}
    end

    def state
      as_json(
        except: %w[state_store errors validation_context],
      ).to_json
    end
  end
end
