class ValidRecruitmentCycleYear
  def self.matches?(request)
    [RecruitmentCycle.current_year, RecruitmentCycle.previous_year].include?(request.params['year'].to_i)
  end
end

class ValidVendorApiRoute
  def self.matches?(request)
    VersionMatcher.new(request).match?
  rescue ArgumentError, NoMethodError
    false
  end

  Rails.application.config.to_prepare do
    VersionMatcher.include VersioningHelpers
  end

  class VersionMatcher
    attr_reader :request

    def initialize(request)
      @request = request
    end

    def match?
      return false if locked_version_lower_than_current_version? && (HostingEnvironment.production? || HostingEnvironment.sandbox_mode?)
      return false if prerelease?(version) && HostingEnvironment.production?
      return false if requested_version_unavailable?

      versions_up_to_current.each do |inner_version|
        return false if HostingEnvironment.production? && prerelease?(inner_version)

        VendorAPI::VERSIONS[inner_version].each do |change_class|
          return false if HostingEnvironment.production? && prerelease?(inner_version)
          return true if change_class.new.actions[controller_class]&.include?(action.to_sym)
        end
      end
      false
    end

  private

    delegate :controller_class, to: :request

    def requested_version_unavailable?
      major_version_number(released_version) == major_version_number(version) &&
        minor_version_number(released_version) < minor_version_number(version)
    end

    def locked_version_lower_than_current_version?
      major_version_number(VendorAPI::VERSION) == major_version_number(version) &&
        minor_version_number(VendorAPI::VERSION) < minor_version_number(version)
    end

    def versions_up_to_current
      VendorAPI::VERSIONS.keys.filter do |version_number|
        major_version_number(version_number) == major_version_number(version) &&
          minor_version_number(version_number) <= minor_version_number(version)
      end
    end

    def api_version
      request.params[:api_version]
    end

    def action
      request.params[:action]
    end

    def version
      extract_version(api_version)
    end
  end
end
