module VendorAPI
  class Base
    include Rails.application.routes.url_helpers
    include VersioningHelpers

    VERSIONS = {}.freeze

    attr_reader :active_version, :available_in_active_version

    def initialize(active_version)
      @active_version = active_version

      raise ActiveVersionNotAvailableInEnvironment if active_version_not_available

      VendorAPI::VERSIONS.each_pair do |version, changes|
        next unless active_version_in_retrieved_version?(version) && version_available_in_environment?(version)

        changes.each do |change_module|
          resources_for_class(change_module).each do |resource|
            singleton_class.send(:prepend, resource)
          end
        end
      end

      raise PresenterNotVersioned unless available_in_active_version
    end

  private

    def resources_for_class(change_class)
      return [] unless change_class.new.resources.include?(self.class)

      available_in_active_version!
      change_class.new.resources[self.class]
    end

    def available_in_active_version!
      @available_in_active_version = true
    end

    def active_version_not_available
      (Gem::Version.new(full_version_number_from(released_version)) <=> Gem::Version.new(active_version)).negative?
    end

    def active_version_in_retrieved_version?(version)
      minor_version_number(active_version) >= minor_version_number(version)
    end

    def version_available_in_environment?(version)
      return true unless HostingEnvironment.production?

      !prerelease_suffix?(version)
    end

    def cache_key(model, api_version, suffixes = {})
      CacheKey.generate("#{api_version}_#{model.cache_key_with_version}#{suffixes.hash}")
    end
  end
end

class PresenterNotVersioned < StandardError; end
class ActiveVersionNotAvailableInEnvironment < StandardError; end
