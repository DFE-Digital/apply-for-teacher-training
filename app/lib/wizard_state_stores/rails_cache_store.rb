module WizardStateStores
  class RailsCacheStore < StateStores::RailsCacheStore
    def write(value)
      super(value, 4.hours.to_i)
    end
  end
end
