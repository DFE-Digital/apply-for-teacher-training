class ValidRecruitmentCycleYear
  def self.matches?(request)
    [RecruitmentCycle.current_year, RecruitmentCycle.previous_year].include?(request.params['year'].to_i)
  end
end

class ValidVendorApiRoute
  def self.matches?(request)
    request.params[:api_version].match(/v1(\z|.\d+)/).present?
  end
end
