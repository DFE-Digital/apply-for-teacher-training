module SupportInterface
  class CycleSwitcherForm
    include ActiveModel::Model

    attr_reader :timetable, :next_timetable
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

    delegate :recruitment_cycle_year, to: :timetable

    validates_with RecruitmentCycleTimetableDateSequenceValidator

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
      attributes = {}
      %i[find_opens_at
         apply_opens_at
         apply_deadline_at
         reject_by_default_at
         decline_by_default_at
         find_closes_at].each do |attribute|
        year = attrs["#{attribute}(1i)"]
        month = attrs["#{attribute}(2i)"]
        day = attrs["#{attribute}(3i)"]

        attributes[attribute] = Time.zone.local(
          year,
          month,
          day,
          timetable.send(attribute).hour,
          timetable.send(attribute).min,
        )
      rescue ArgumentError, RangeError
        attributes[attribute] = Struct.new(:year, :month, :day).new(year, month, day)
      end

      new(attributes, timetable:)
    end

    def initialize(attributes = {}, timetable: RecruitmentCycleTimetable.current_timetable)
      @timetable = timetable
      @next_timetable = timetable.relative_next_timetable
      super(attributes)
    end

    def cycle_state
      if next_timetable.present? && next_timetable.after_find_opens?
        :find_has_reopened
      elsif timetable.after_find_closes?
        :after_find_has_closed
      elsif timetable.after_decline_by_default?
        :after_decline_by_default
      elsif timetable.after_reject_by_default?
        :after_reject_by_default
      elsif timetable.after_apply_deadline?
        :after_apply_deadline
      elsif approaching_apply_deadline?
        :apply_deadline_approaching
      elsif timetable.after_apply_opens?
        :apply_has_opened
      elsif timetable.after_find_opens?
        :find_has_opened
      end
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

    def approaching_apply_deadline?
      Time.zone.now.after? show_banners_at
    end

    def show_banners_at
      12.weeks.before timetable.apply_deadline_at
    end
  end
end
