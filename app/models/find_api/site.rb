module FindAPI
  class Site < FindAPI::Resource
    belongs_to :recruitment_cycle, through: :provider, param: :recruitment_cycle_year
  end
end
