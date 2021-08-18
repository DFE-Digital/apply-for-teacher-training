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
          Name: courses.first.name,
          Code: courses.first.code,
          'Partner organisation': provider_name(courses.first),
          Received: status_count(courses, :awaiting_provider_decision),
          Interviewing: status_count(courses, :interviewing),
          Offered: status_count(courses, :offer),
          'Awaiting conditions': status_count(courses, :pending_conditions),
          'Pending conditions': status_count(courses, :recruited),
        }
      end
      data << totals_row(data)

      SafeCSV.generate(data.map(&:values), data.first.keys)
    end

  private

    def totals_row(rows)
      {
        Name: 'All courses',
        Code: 'TOTAL',
        'Partner organisation': '',
        Received: totals_count(rows)[0],
        Interviewing: totals_count(rows)[1],
        Offered: totals_count(rows)[2],
        'Awaiting conditions': totals_count(rows)[3],
        'Pending conditions': totals_count(rows)[4],
      }
    end

    def totals_count(rows)
      return @totals_count if @totals_count

      @totals_count = Array.new(5) { 0 }
      rows.each do |row|
        @totals_count[0] += row[:Received]
        @totals_count[1] += row[:Interviewing]
        @totals_count[2] += row[:Offered]
        @totals_count[3] += row[:'Awaiting conditions']
        @totals_count[4] += row[:'Pending conditions']
      end
      @totals_count
    end
  end
end
