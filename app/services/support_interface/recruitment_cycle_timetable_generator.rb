module SupportInterface
  class RecruitmentCycleTimetableGeneratorError < StandardError; end

  class RecruitmentCycleTimetableGenerator
    FIRST_RECRUITMENT_CYCLE_YEAR = 2019

    def self.call(recruitment_cycle_year)
      new(recruitment_cycle_year).call
    end

    def self.generate_next_year
      new(RecruitmentCycleTimetable.last_timetable.recruitment_cycle_year + 1).call
    end

    def initialize(recruitment_cycle_year)
      @recruitment_cycle_year = recruitment_cycle_year
    end

    def call
      seed_timetables if RecruitmentCycleTimetable.none?
      raise RecruitmentCycleTimetableGeneratorError unless within_generating_range?

      timetable = RecruitmentCycleTimetable.find_by(recruitment_cycle_year: @recruitment_cycle_year)
      return timetable if timetable.present?

      generate_timetable
    end

  private

    def within_generating_range?
      last_recruitment_cycle_year = RecruitmentCycleTimetable.last_timetable.recruitment_cycle_year
      # This generates timetables recursively, so we want to limit how many we generate at once.
      # Obviously, we could do a lot more than ten without a stack overflow issue,
      # but really, any more than 10 would just be silly.
      @recruitment_cycle_year.between?(
        FIRST_RECRUITMENT_CYCLE_YEAR, last_recruitment_cycle_year + 10
      )
    end

    def generate_timetable
      last_timetable = RecruitmentCycleTimetable.last_timetable
      return last_timetable if last_timetable.recruitment_cycle_year == @recruitment_cycle_year

      next_year = last_timetable.recruitment_cycle_year + 1

      # Find opens and Apply opens depend on when Find closes in the previous year
      find_opens_at = generate_find_opens_at(last_timetable.find_closes_at)
      apply_opens_at = generate_apply_opens_at(find_opens_at)

      # Then we work backward from when Find should close to generate the rest of the dates
      find_closes_at = generate_find_closes_at(next_year)
      decline_by_default_at = generate_decline_by_default_at(find_closes_at)
      reject_by_default_at = generate_reject_by_default_at(decline_by_default_at)
      apply_deadline_at = generate_apply_deadline_at(reject_by_default_at)

      RecruitmentCycleTimetable.create!(
        recruitment_cycle_year: next_year,
        find_opens_at:,
        apply_opens_at:,
        find_closes_at:,
        decline_by_default_at:,
        reject_by_default_at:,
        apply_deadline_at:,
      )
      generate_timetable
    end

    def generate_find_opens_at(prev_find_closes_at)
      (prev_find_closes_at + 1.day).change(hour: 9)
    end

    def generate_apply_opens_at(find_opens_at)
      find_opens_at + 1.week
    end

    def generate_apply_deadline_at(reject_by_default_at)
      (reject_by_default_at - 1.week - 1.day).change(hour: 18)
    end

    def generate_reject_by_default_at(decline_by_default_at)
      decline_by_default_at.prev_occurring(:wednesday)
    end

    def generate_decline_by_default_at(find_closes_at)
      find_closes_at - 1.day
    end

    def generate_find_closes_at(recruitment_cycle_year)
      oct_first = Time.zone.local(recruitment_cycle_year, 10, 1, 23, 59, 59)

      if oct_first.monday?
        oct_first
      elsif oct_first.tuesday? || oct_first.wednesday?
        oct_first - 1.day
      else
        oct_first.next_occurring(:monday)
      end
    end

    def seed_timetables
      CYCLE_DATES.each do |recruitment_cycle_year, dates|
        RecruitmentCycleTimetable.find_or_create_by(recruitment_cycle_year:).tap do |timetable|
          timetable.update(
            find_opens_at: dates[:find_opens],
            apply_opens_at: dates[:apply_opens],
            apply_deadline_at: dates[:apply_deadline],
            reject_by_default_at: dates[:reject_by_default],
            decline_by_default_at: dates[:find_closes] - 1.day,
            find_closes_at: dates[:find_closes],
          )
        end
      end
    end
  end
end
