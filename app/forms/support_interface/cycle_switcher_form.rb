module SupportInterface
  class CycleSwitcherForm
    include ActiveModel::Model

    attr_reader :timetable
    attr_accessor :find_opens_at,
                  :apply_opens_at,
                  :apply_deadline_at,
                  :reject_by_default_at,
                  :decline_by_default_at,
                  :find_closes_at

    validates :find_opens_at,
              :apply_opens_at,
              :apply_deadline_at,
              :reject_by_default_at,
              :decline_by_default_at,
              :find_closes_at,
              presence: true

    validates_with RecruitmentCycleTimetableDateSequenceValidator

    delegate :recruitment_cycle_year, to: :timetable
    delegate :cycle_state, to: :presenter

    def self.build_from_timetable(timetable)
      attrs =
        {
          find_opens_at: timetable.find_opens_at.to_date,
          apply_opens_at: timetable.apply_opens_at.to_date,
          apply_deadline_at: timetable.apply_deadline_at.to_date,
          reject_by_default_at: timetable.reject_by_default_at.to_date,
          decline_by_default_at: timetable.decline_by_default_at.to_date,
          find_closes_at: timetable.find_closes_at.to_date,
        }

      new(attrs, timetable:)
    end

    def self.build_from_form(attrs, timetable:)
      form_attributes = {}
      %i[find_opens_at
         apply_opens_at
         apply_deadline_at
         reject_by_default_at
         decline_by_default_at
         find_closes_at].each do |date_time_attribute|
        year = attrs["#{date_time_attribute}(1i)"]
        month = attrs["#{date_time_attribute}(2i)"]
        day = attrs["#{date_time_attribute}(3i)"]

        form_attributes[date_time_attribute] = Time.zone.local(
          year,
          month,
          day,
          timetable.send(date_time_attribute).hour,
          timetable.send(date_time_attribute).min,
        )
      rescue ArgumentError, RangeError
        form_attributes[date_time_attribute] = Struct.new(:year, :month, :day).new(year, month, day)
      end

      new(form_attributes, timetable:)
    end

    def initialize(attributes = {}, timetable: RecruitmentCycleTimetable.current_timetable)
      @timetable = timetable
      super(attributes)
    end

    def persist
      if valid?
        timetable.update(
          find_opens_at:,
          apply_opens_at:,
          apply_deadline_at:,
          reject_by_default_at:,
          decline_by_default_at:,
          find_closes_at:,
        )
      end
    end

  private

    def presenter
      @presenter ||= SupportInterface::RecruitmentCycleTimetablePresenter.new(timetable)
    end
  end
end
