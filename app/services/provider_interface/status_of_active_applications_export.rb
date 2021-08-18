module ProviderInterface
  class StatusOfActiveApplicationsExport
    include DataForActiveApplicationsStatuses

    attr_reader :provider

    def initialize(provider:)
      @provider = provider
    end

    def call
      data = grouped_course_data.inject([]) do |rows, course_data|
        courses = course_data.last
        rows << {
          name: courses.first.name,
          code: courses.first.code,
          partner_organisation: provider_name(courses.first),
          received: status_count(courses, :awaiting_provider_decision),
          interviewing: status_count(courses, :interviewing),
          offered: status_count(courses, :offer),
          awaiting_conditions: status_count(courses, :pending_conditions),
          pending_conditions: status_count(courses, :recruited),
        }
      end
      data << totals_row(data)

      SafeCSV.generate(data.map(&:values), data.first.keys)
    end

  private

    def totals_row(rows)
      {
        name: 'All courses',
        code: 'TOTAL',
        partner_organisation: '',
        received: totals_count(rows)[0],
        interviewing: totals_count(rows)[1],
        offered: totals_count(rows)[2],
        awaiting_conditions: totals_count(rows)[3],
        pending_conditions: totals_count(rows)[4],
      }
    end

    def totals_count(rows)
      return @totals_count if @totals_count

      @totals_count = Array.new(5) { 0 }
      rows.each do |row|
        @totals_count[0] += row[:received]
        @totals_count[1] += row[:interviewing]
        @totals_count[2] += row[:offered]
        @totals_count[3] += row[:awaiting_conditions]
        @totals_count[4] += row[:pending_conditions]
      end
      @totals_count
    end
  end
end
