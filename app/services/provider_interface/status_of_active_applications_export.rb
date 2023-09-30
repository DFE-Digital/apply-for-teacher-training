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
          "#{I18n.t('provider_application_states.awaiting_provider_decision')}": status_count(courses, :awaiting_provider_decision) + status_count(courses, :inactive),
          "#{I18n.t('provider_application_states.interviewing')}": status_count(courses, :interviewing),
          "#{I18n.t('provider_application_states.offer')}": status_count(courses, :offer),
          "#{I18n.t('provider_application_states.pending_conditions')}": status_count(courses, :pending_conditions),
          "#{I18n.t('provider_application_states.recruited')}": status_count(courses, :recruited),
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
        "#{I18n.t('provider_application_states.awaiting_provider_decision')}": totals_count(rows)[0],
        "#{I18n.t('provider_application_states.interviewing')}": totals_count(rows)[1],
        "#{I18n.t('provider_application_states.offer')}": totals_count(rows)[2],
        "#{I18n.t('provider_application_states.pending_conditions')}": totals_count(rows)[3],
        "#{I18n.t('provider_application_states.recruited')}": totals_count(rows)[4],
      }
    end

    def totals_count(rows)
      return @totals_count if @totals_count

      @totals_count = Array.new(5) { 0 }
      rows.each do |row|
        @totals_count[0] += row[:"#{I18n.t('provider_application_states.awaiting_provider_decision')}"]
        @totals_count[1] += row[:"#{I18n.t('provider_application_states.interviewing')}"]
        @totals_count[2] += row[:"#{I18n.t('provider_application_states.offer')}"]
        @totals_count[3] += row[:"#{I18n.t('provider_application_states.pending_conditions')}"]
        @totals_count[4] += row[:"#{I18n.t('provider_application_states.recruited')}"]
      end
      @totals_count
    end
  end
end
