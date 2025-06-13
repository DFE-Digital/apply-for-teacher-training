module ProductionRecruitmentCycleTimetablesAPI
  class Client
    BASE_URL = 'https://www.apply-for-teacher-training.service.gov.uk/publications/recruitment-cycle-timetables'.freeze
    def initialize
      @connection = Faraday.new(BASE_URL) do |f|
        f.response :json
      end
    end

    def fetch_recruitment_cycle(recruitment_cycle_year)
      fetch(recruitment_cycle_year)
    end

    def fetch_all_recruitment_cycles
      fetch
    end

  private

    def fetch(recruitment_cycle_year = '')
      return {} if HostingEnvironment.production?

      response = @connection.get(recruitment_cycle_year.to_s)

      response.body || {}
    rescue Faraday::Error => e
      Sentry.capture_message("Error fetching recruitment cycle timetables - '#{response.status}', '#{response.body}'. Exception: '#{e}'")
      {}
    end
  end
end
