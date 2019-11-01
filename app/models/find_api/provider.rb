module FindAPI
  class Provider < FindAPI::Resource
    belongs_to :recruitment_cycle, param: :recruitment_cycle_year
    has_many :courses
  end
end
