module WizardStateStores
  class SessionStore
    def initialize(session:, key:)
      @session = session
      @key = key
    end

    def write(value)
      @session[@key] = value
    end

    def read
      @session[@key]
    end

    def delete
      @session.delete(@key)
    end
  end
end
