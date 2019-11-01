module FindAPI
  class Provider < FindAPI::Resource
    RECRUITMENT_CYCLE_YEAR = ENV.fetch('RECRUITMENT_CYCLE_YEAR') { 2020 }

    belongs_to :recruitment_cycle, param: :recruitment_cycle_year
    has_many :courses
    has_many :sites

    def self.current_cycle
      where(recruitment_cycle_year: RECRUITMENT_CYCLE_YEAR)
    end
  end
end
