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
        attributes
      end
    end
  end
end
