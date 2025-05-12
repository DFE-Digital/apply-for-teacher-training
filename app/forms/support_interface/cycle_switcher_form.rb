module SupportInterface
  class CycleSwitcherForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :find_opens_at, :datetime
    attribute :apply_opens_at, :datetime
    attribute :apply_deadline_at, :datetime
    attribute :reject_by_default_at, :datetime
    attribute :decline_by_default_at, :datetime
    attribute :find_closes_at, :datetime

    attr_reader :timetable

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

    def initialize(attributes = {}, timetable: RecruitmentCycleTimetable.current_timetable)
      @timetable = timetable
      super(attributes)
    end

    def persist
      if valid?
        # We preserve the original times, it's only the dates that change. So that jobs run as expected.
        timetable.update(
          find_opens_at: find_opens_at.change(hour: timetable.find_opens_at.hour, min: timetable.find_opens_at.min),
          apply_opens_at: apply_opens_at.change(hour: timetable.apply_opens_at.hour, min: timetable.apply_opens_at.min),
          apply_deadline_at: apply_deadline_at.change(hour: timetable.apply_deadline_at.hour, min: timetable.apply_deadline_at.min),
          reject_by_default_at: reject_by_default_at.change(hour: timetable.reject_by_default_at.hour, min: timetable.reject_by_default_at.min),
          decline_by_default_at: decline_by_default_at.change(hour: timetable.decline_by_default_at.hour, min: timetable.decline_by_default_at.min),
          find_closes_at: find_closes_at.change(hour: timetable.find_closes_at.hour, min: timetable.find_closes_at.min),
        )
      end
    end

  private

    def presenter
      @presenter ||= SupportInterface::RecruitmentCycleTimetablePresenter.new(timetable)
    end
  end
end
