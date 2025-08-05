class Adviser::Constants
  CONSTANTS_PATH = 'config/adviser/constants.yml'.freeze

  class << self
    extend Forwardable

    def_delegator :constants, :dig, :fetch

  private

    def constants
      @constants ||= YAML.load_file(CONSTANTS_PATH).with_indifferent_access
    end
  end
end
