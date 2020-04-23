module FindAPI
  class Provider < FindAPI::Resource
    belongs_to :recruitment_cycle, param: :recruitment_cycle_year
    has_many :courses
    has_many :sites

    # There's a quirk in the JsonAPIClient that means we have to do some
    # counter-intuitive things with our resource models to get it to work.
    # In this case, to get included course subjects to work, we have to define
    # this as an inner class of Provider, despite it actually being a has-has_many
    # of Course. Don't know why - if anyone can figure out a more
    # elegant way, feel free.
    class Subject < FindAPI::Resource; end

    def self.current_cycle
      where(recruitment_cycle_year: RECRUITMENT_CYCLE_YEAR)
    end
  end
end
