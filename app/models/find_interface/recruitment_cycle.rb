class FindInterface::RecruitmentCycle < FindInterface::Base
  has_many :providers
  has_many :courses, through: :providers
  has_many :sites, through: :providers

  self.primary_key = :year

  def self.current
    RecruitmentCycle.includes(:providers).find(Settings.current_cycle).first
  end
end
