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

  class VersionMatcher
    include VersioningHelpers

    attr_reader :request

    def initialize(request)
      @request = request
    end

    def match?
      versions_up_to_current.each do |version|
        VendorAPI::VERSIONS[version].each do |change_class|
          return true if change_class.new.actions[controller_class]&.include?(action.to_sym)
        end
      end
      false
    end

  private

    delegate :controller_class, to: :request

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
