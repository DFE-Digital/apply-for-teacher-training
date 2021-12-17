class ValidRecruitmentCycleYear
  def self.matches?(request)
    [RecruitmentCycle.current_year, RecruitmentCycle.previous_year].include?(request.params['year'].to_i)
  end
end

class ValidVendorApiRoute
  extend VersioningHelpers

  def self.matches?(request)
    api_version = request.params[:api_version]
    controller_class = request.controller_class
    action = request.params[:action]

    version = extract_version(api_version)

    VendorAPI::VERSIONS[version_number(version)].each do |change_module|
      return true if change_module.new.actions[controller_class].include?(action.to_sym)
    end
    false
  rescue ArgumentError, NoMethodError
    false
  end
end
