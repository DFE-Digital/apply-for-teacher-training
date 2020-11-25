module CandidateInterface
  class IntermediateDataService
    def initialize(state_store)
      @state_store = state_store
    end

    def clear_state!
      @state_store.delete
    end

    def read
      last_saved_state
    end

    def write(attrs)
      @state_store.write(
        last_saved_state.merge(attrs).to_json,
      )
    end

  private

    def last_saved_state
      state = @state_store&.read

      if state
        JSON.parse(state)
      else
        {}
      end
    end
  end
end
