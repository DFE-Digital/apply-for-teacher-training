module Publications
  class RecruitmentCycleTimetablesPresenter
    def initialize(timetables)
      @timetables = Array.wrap(timetables)
    end

    def call
      @timetables.map do |timetable|
        attributes = timetable.attributes
        attributes.delete('id')
        attributes.delete('created_at')

        attributes.each do |key, value|
          attributes[key] = value.iso8601 if value.respond_to?(:iso8601)
        end

        if timetable.christmas_holiday_range.present?
          attributes['christmas_holiday_range'] = [
            timetable.christmas_holiday_range.first.iso8601,
            timetable.christmas_holiday_range.last.iso8601,
          ].compact

        end

        if timetable.easter_holiday_range.present?
          attributes['easter_holiday_range'] = [
            timetable.easter_holiday_range.first.iso8601,
            timetable.easter_holiday_range.last.iso8601,
          ].compact
        end

        attributes
      end
    end
  end
end
