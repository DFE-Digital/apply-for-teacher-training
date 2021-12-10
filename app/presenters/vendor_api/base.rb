module VendorAPI
  class Base
    include Rails.application.routes.url_helpers
    include VersioningHelpers

    VERSIONS = {}.freeze

    attr_reader :active_version

    def initialize(active_version)
      @active_version = active_version

      self.class::VERSIONS.each do |version, modules|
        modules.each do |mod|
          singleton_class.send(:prepend, mod) if minor_version(@active_version) >= minor_version(version)
        end
      end
    end
  end
end
