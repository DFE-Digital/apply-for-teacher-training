module VendorAPI
  class Base
    include Rails.application.routes.url_helpers

    VERSIONS = {}.freeze

    attr_reader :active_version

    def initialize(active_version)
      @active_version = active_version

      self.class::VERSIONS.each do |version, modules|
        modules.each do |mod|
          singleton_class.send(:prepend, mod) if @active_version >= version
        end
      end
    end
  end
end
