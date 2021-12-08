module VendorAPI
  class Base
    include Rails.application.routes.url_helpers

    VERSIONS = {}.freeze

    attr_reader :active_version

    def initialize(active_version)
      @active_version = active_version

      self.class::VERSIONS.each do |_, modules|
        modules.each do |mod|
          self.class.send(:prepend, mod)
        end
      end
    end
  end
end
