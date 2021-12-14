class ValidRecruitmentCycleYear
  def self.matches?(request)
    [RecruitmentCycle.current_year, RecruitmentCycle.previous_year].include?(request.params['year'].to_i)
  end
end

class ValidVendorApiRoute
  extend VersioningHelpers

  def self.matches?(request)
    api_version = request.params[:api_version]
    controller_name = request.controller_class.to_s
    action = request.params[:action]

    version = api_version.match(/^v(?<number>.*)/)[:number]

    true if VendorAPI::VERSIONS[version_number(version)][controller_name].include?(action.to_sym)
  rescue ArgumentError, NoMethodError
    false
  end
end
