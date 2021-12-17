module VendorAPI
  class Base
    include Rails.application.routes.url_helpers
    include VersioningHelpers

    VERSIONS = {}.freeze

    attr_reader :active_version

    def initialize(active_version)
      @active_version = active_version

      VendorAPI::VERSIONS.each_pair do |version, changes|
        next if minor_version_number(version) > minor_version_number(@active_version)

        changes.each do |change_module|
          resources_for_class(change_module).each do |resource|
            singleton_class.send(:prepend, resource) if minor_version(@active_version) >= minor_version(version)
          end
        end
      end
    end

    def resources_for_class(change_class)
      change_class.new.resources[self.class] || []
    end
  end
end
