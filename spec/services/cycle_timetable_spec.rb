require 'rails_helper'

RSpec.describe CycleTimetable do
  let(:this_year) { Time.zone.now.year }
  let(:next_year) { this_year + 1 }
  let(:next_next_year) { this_year + 2 }
  let(:one_hour_before_apply1_deadline) { described_class.apply_1_deadline(this_year) - 1.hour }
  let(:one_hour_after_apply1_deadline) { described_class.apply_1_deadline(this_year) + 1.hour  }
  let(:one_hour_before_apply2_deadline) { described_class.apply_2_deadline(this_year) - 1.hour }
  let(:one_hour_after_apply2_deadline) { described_class.apply_2_deadline(this_year) + 1.hour  }
  let(:one_hour_after_this_year_cycle_opens) { described_class.apply_opens(this_year) + 1.hour }
  let(:one_hour_after_next_year_cycle_opens) { described_class.apply_opens(next_year) + 1.hour }
  let(:one_hour_before_find_closes) { described_class.find_closes(this_year) - 1.hour }
  let(:one_hour_after_find_closes) { described_class.find_closes(this_year) + 1.hour }
  let(:one_hour_after_find_opens) { described_class.find_opens(this_year) + 1.hour }
  let(:one_hour_after_find_reopens) { described_class.find_reopens(this_year) + 1.hour }
  let(:three_days_before_find_reopens) { described_class.find_reopens(this_year) - 3.days }
  let(:twenty_days_after_next_year_cycle_opens) { 20.business_days.after(described_class.apply_opens(next_year)).end_of_day }

  describe '.current_year' do
    it 'is this_year if we are in the middle of the this_year cycle' do
      travel_temporarily_to(one_hour_after_this_year_cycle_opens) do
        expect(described_class.current_year).to eq(this_year)
      end
    end

    it 'is next_year if we are in the middle of the next_year cycle' do
      travel_temporarily_to(one_hour_after_next_year_cycle_opens) do
        expect(described_class.current_year).to eq(next_year)
      end
    end
  end

  describe '.next_year' do
    it 'is next_year if we are in the middle of the this_year cycle' do
      travel_temporarily_to(one_hour_after_this_year_cycle_opens) do
        expect(described_class.next_year).to eq(next_year)
      end
    end

    it 'is next_next_year if we are in the middle of the next_year cycle' do
      travel_temporarily_to(one_hour_after_next_year_cycle_opens) do
        expect(described_class.next_year).to eq(next_next_year)
      end
    end
  end

  describe '.show_apply_1_deadline_banner?' do
    it 'returns true before the configured date and it is an unsuccessful apply_1 application' do
      application_form = build(:application_form, phase: 'apply_1')

      travel_temporarily_to(one_hour_before_apply1_deadline) do
        expect(described_class.show_apply_1_deadline_banner?(application_form)).to be true
      end
    end

    it 'returns false if it is a apply_2 application' do
      application_form = build(:application_form, phase: 'apply_2')

      travel_temporarily_to(one_hour_before_apply1_deadline) do
        expect(described_class.show_apply_1_deadline_banner?(application_form)).to be false
      end
    end

    it 'returns false if it is a successful application' do
      application_choice = build(:application_choice, :offered)
      application_form = build(:application_form, phase: 'apply_1', application_choices: [application_choice])

      travel_temporarily_to(one_hour_before_apply1_deadline) do
        expect(described_class.show_apply_1_deadline_banner?(application_form)).to be false
      end
    end

    it 'returns false after the configured date' do
      application_form = build(:application_form, phase: 'apply_1')

      travel_temporarily_to(one_hour_after_apply1_deadline) do
        expect(described_class.show_apply_1_deadline_banner?(application_form)).to be false
      end
    end
  end

  describe '.show_summer_recruitment_banner?' do
    let(:one_hour_before_show_summer_recruitment_banner) do
      CycleTimetable.date(:show_summer_recruitment_banner) - 1.hour
    end
    let(:one_hour_after_show_summer_recruitment_banner) do
      CycleTimetable.date(:show_summer_recruitment_banner) + 1.hour
    end

    it 'returns false before the configured date' do
      travel_temporarily_to(one_hour_before_show_summer_recruitment_banner) do
        expect(described_class.show_summer_recruitment_banner?).to be false
      end
    end

    it 'returns true between configure date and apply 1 closes' do
      travel_temporarily_to(one_hour_after_show_summer_recruitment_banner) do
        expect(described_class.show_summer_recruitment_banner?).to be true
      end
    end

    it 'returns false after apply 1 closes' do
      travel_temporarily_to(described_class.apply_1_deadline(2022) + 1.hour) do
        expect(described_class.show_summer_recruitment_banner?).to be false
      end
    end
  end

  describe '.show_apply_2_deadline_banner?' do
    it 'returns true before the configured date and it is a phase 2 application' do
      application_form = build(:application_form, phase: 'apply_2')

      travel_temporarily_to(one_hour_before_apply2_deadline) do
        expect(described_class.show_apply_2_deadline_banner?(application_form)).to be true
      end
    end

    it 'returns false if it is a successful apply_1 application' do
      application_choice = build(:application_choice, :offered)
      application_form = build(:application_form, phase: 'apply_1', application_choices: [application_choice])

      travel_temporarily_to(one_hour_before_apply2_deadline) do
        expect(described_class.show_apply_2_deadline_banner?(application_form)).to be false
      end
    end

    it 'returns false after the configured date' do
      unsuccessful_application_form = build(:application_form, phase: 'apply_2', application_choices: [build(:application_choice, :rejected)])

      travel_temporarily_to(one_hour_after_apply2_deadline) do
        expect(described_class.show_apply_2_deadline_banner?(unsuccessful_application_form)).to be false
      end
    end
  end

  describe '.show_non_working_days_banner?' do
    context 'when within the Christmas period' do
      let(:one_hour_after_christmas_period) { described_class.holidays[:christmas].last.end_of_day + 1.hour }

      it 'returns false if before the 20 day period' do
        travel_temporarily_to(one_hour_after_next_year_cycle_opens) do
          expect(described_class.show_non_working_days_banner?).to be false
        end
      end

      it 'returns true if after the 20 day period' do
        travel_temporarily_to(twenty_days_after_next_year_cycle_opens) do
          expect(described_class.show_non_working_days_banner?).to be true
        end
      end

      it 'returns false after the Christmas period' do
        travel_temporarily_to(one_hour_after_christmas_period) do
          expect(described_class.show_non_working_days_banner?).to be false
        end
      end
    end

    context 'when within the Easter period' do
      let(:eleven_days_before_easter_period) { 11.business_days.before(described_class.holidays[:easter].first) }
      let(:within_easter_period) { described_class.holidays[:easter].first + 1.hour }
      let(:one_hour_after_easter_period) { described_class.holidays[:easter].last.end_of_day + 1.hour }

      it 'returns false if before the holiday period' do
        travel_temporarily_to(eleven_days_before_easter_period) do
          expect(described_class.show_non_working_days_banner?).to be false
        end
      end

      it 'returns true if within holiday period' do
        travel_temporarily_to(within_easter_period) do
          expect(described_class.show_non_working_days_banner?).to be true
        end
      end

      it 'returns false after the holiday period' do
        travel_temporarily_to(one_hour_after_easter_period) do
          expect(described_class.show_non_working_days_banner?).to be false
        end
      end
    end
  end

  describe '.between_cycles_apply_1?' do
    it 'returns false before the configured date' do
      travel_temporarily_to(one_hour_before_apply1_deadline) do
        expect(described_class.between_cycles_apply_1?).to be false
      end
    end

    it 'returns true after the configured date' do
      travel_temporarily_to(one_hour_after_apply1_deadline) do
        expect(described_class.between_cycles_apply_1?).to be true
      end
    end

    it 'returns true between find and apply reopening' do
      travel_temporarily_to(one_hour_after_find_opens) do
        expect(described_class.between_cycles_apply_2?).to be true
      end
    end

    it 'returns false after the new cycle opens' do
      travel_temporarily_to(one_hour_after_next_year_cycle_opens) do
        expect(described_class.between_cycles_apply_1?).to be false
      end
    end
  end

  describe '.between_apply_1_deadline_and_find_closes?' do
    it 'returns false before the configured date' do
      travel_temporarily_to(one_hour_before_apply1_deadline) do
        expect(described_class.between_apply_1_deadline_and_find_closes?).to be false
      end
    end

    it 'returns true during the configured date' do
      travel_temporarily_to(one_hour_after_apply1_deadline) do
        expect(described_class.between_apply_1_deadline_and_find_closes?).to be true
      end
    end

    it 'returns false after the configured date' do
      travel_temporarily_to(one_hour_after_find_reopens) do
        expect(described_class.between_apply_1_deadline_and_find_closes?).to be false
      end
    end
  end

  describe '.between_cycles_apply_2?' do
    it 'returns false before the configured date' do
      travel_temporarily_to(one_hour_before_apply2_deadline) do
        expect(described_class.between_cycles_apply_2?).to be false
      end
    end

    it 'returns true after the configured date' do
      travel_temporarily_to(one_hour_after_apply2_deadline) do
        expect(described_class.between_cycles_apply_2?).to be true
      end
    end

    it 'returns true between find and apply reopening' do
      travel_temporarily_to(one_hour_after_find_opens) do
        expect(described_class.between_cycles_apply_2?).to be true
      end
    end

    it 'returns false after the new cycle opens' do
      travel_temporarily_to(one_hour_after_next_year_cycle_opens) do
        expect(described_class.between_cycles_apply_2?).to be false
      end
    end
  end

  describe '.find_down?' do
    it 'returns false before find closes' do
      travel_temporarily_to(one_hour_before_find_closes) do
        expect(described_class.find_down?).to be false
      end
    end

    it 'returns false after find_reopens' do
      travel_temporarily_to(one_hour_after_find_opens) do
        expect(described_class.find_down?).to be false
      end
    end

    it 'returns true between find_closes and find_reopens' do
      travel_temporarily_to(one_hour_after_find_closes) do
        expect(described_class.find_down?).to be true
      end
    end
  end

  describe '.days_until_find_reopens' do
    it 'returns the number of days until Find reopens' do
      travel_temporarily_to(three_days_before_find_reopens) do
        expect(described_class.days_until_find_reopens).to eq(3)
      end
    end
  end

  describe '.valid_cycle?' do
    def create_application_for(recruitment_cycle_year)
      create(:application_form, recruitment_cycle_year:)
    end

    it 'returns true for an application for courses in the current cycle' do
      expect(
        described_class.valid_cycle?(create_application_for(RecruitmentCycle.current_year)),
      ).to be true
    end

    it 'returns false for an application for courses in the previous cycle' do
      expect(
        described_class.valid_cycle?(create_application_for(RecruitmentCycle.previous_year)),
      ).to be false
    end
  end

  describe 'can_add_course_choice?' do
    let(:execute_service) { described_class.can_add_course_choice?(application_form) }

    context 'application form is in the apply1 state' do
      let(:application_form) { build_stubbed(:application_form) }

      context 'when the date is after the apply1 submission deadline' do
        it 'returns false' do
          travel_temporarily_to(one_hour_after_apply1_deadline) do
            expect(execute_service).to be false
          end
        end
      end

      context 'when the date is before the apply1 submission deadline' do
        it 'returns true' do
          travel_temporarily_to(one_hour_before_apply1_deadline) do
            expect(execute_service).to be true
          end
        end
      end
    end

    context 'application form is in the apply again state' do
      let(:application_form) { build_stubbed(:application_form, phase: :apply_2) }

      context 'when the date is after the apply again submission deadline' do
        it 'returns false' do
          travel_temporarily_to(one_hour_after_apply2_deadline) do
            expect(execute_service).to be false
          end
        end
      end

      context 'when the date is before the apply again submission deadline' do
        it 'returns true' do
          travel_temporarily_to(one_hour_before_apply2_deadline) do
            expect(execute_service).to be true
          end
        end
      end
    end

    context 'application form is from a previous recruitment cycle' do
      let(:application_form) { build_stubbed(:application_form, recruitment_cycle_year: this_year) }

      it 'returns false' do
        travel_temporarily_to(described_class.apply_opens) do
          expect(execute_service).to be false
        end
      end
    end
  end

  describe '.can_submit?', :mid_cycle do
    it 'returns true for an application in the current recruitment cycle' do
      application_form = build(:application_form, recruitment_cycle_year: RecruitmentCycle.current_year)
      expect(described_class.can_submit?(application_form)).to be true
    end

    it 'returns false for an application in the previous recruitment cycle' do
      application_form = build(:application_form, recruitment_cycle_year: RecruitmentCycle.previous_year)
      expect(described_class.can_submit?(application_form)).to be false
    end
  end

  describe '.need_to_send_deadline_reminder?' do
    it 'does not return for a non deadline date' do
      travel_temporarily_to(described_class.apply_1_deadline_first_reminder - 1.day) do
        expect(described_class.need_to_send_deadline_reminder?).to be_nil
      end
    end

    it 'returns apply_1 when it is the first apply 1 deadline' do
      travel_temporarily_to(described_class.apply_1_deadline_first_reminder) do
        expect(described_class.need_to_send_deadline_reminder?).to be :apply_1
      end
    end

    it 'returns apply_1 when it is the second apply 1 deadline' do
      travel_temporarily_to(described_class.apply_1_deadline_second_reminder) do
        expect(described_class.need_to_send_deadline_reminder?).to be :apply_1
      end
    end

    it 'returns apply_2 when it is the first apply 2 deadline' do
      travel_temporarily_to(described_class.apply_2_deadline_first_reminder) do
        expect(described_class.need_to_send_deadline_reminder?).to be :apply_2
      end
    end

    it 'returns apply_2 when it is the second apply 2 deadline' do
      travel_temporarily_to(described_class.apply_2_deadline_second_reminder) do
        expect(described_class.need_to_send_deadline_reminder?).to be :apply_2
      end
    end
  end

  describe '.next_apply_deadline' do
    context 'after cycle start and before apply 1 deadline' do
      it 'returns apply_1_deadline' do
        travel_temporarily_to(one_hour_before_apply1_deadline) do
          expect(described_class.next_apply_deadline).to eq(described_class.apply_1_deadline)
        end
      end
    end

    context 'after apply 1 deadline and before apply 2 deadline' do
      it 'returns apply_2_deadline' do
        travel_temporarily_to(one_hour_after_apply1_deadline) do
          expect(described_class.next_apply_deadline).to eq(described_class.apply_2_deadline)
        end
      end
    end

    context 'after apply 2 deadline' do
      it 'returns apply_1_deadline for next cycle' do
        travel_temporarily_to(one_hour_after_apply2_deadline) do
          expect(described_class.next_apply_deadline).to eq(CycleTimetable::CYCLE_DATES[described_class.next_year][:apply_1_deadline])
        end
      end
    end
  end

  describe 'apply_1_deadline_has_passed?' do
    context 'it is before the apply 1 deadline' do
      it 'returns false' do
        travel_temporarily_to(described_class.apply_opens) do
          application_form = build(:application_form)
          expect(described_class.apply_1_deadline_has_passed?(application_form)).to be(false)
        end
      end
    end

    context 'it is after the apply 1 deadline' do
      it 'returns true' do
        travel_temporarily_to(described_class.apply_2_deadline) do
          application_form = build(:application_form)
          expect(described_class.apply_1_deadline_has_passed?(application_form)).to be(true)
        end
      end
    end
  end

  describe 'apply_2_deadline_has_passed?' do
    context 'it is before the apply 2 deadline' do
      it 'returns false' do
        travel_temporarily_to(described_class.apply_opens) do
          application_form = build(:application_form)
          expect(described_class.apply_1_deadline_has_passed?(application_form)).to be(false)
        end
      end
    end

    context 'it is after the apply 1 deadline' do
      it 'returns true' do
        travel_temporarily_to(described_class.find_closes) do
          application_form = build(:application_form)
          expect(described_class.apply_1_deadline_has_passed?(application_form)).to be(true)
        end
      end
    end
  end

  describe '.cycle_year_range' do
    context 'with no year passed in' do
      it 'returns the `current_year to next_year`' do
        allow(described_class).to receive(:current_year).and_return(next_year)
        expect(described_class.cycle_year_range).to eq "#{next_year} to #{next_next_year}"
      end
    end

    context 'with a year passed in' do
      it 'returns `year to year + 1`' do
        expect(described_class.cycle_year_range(next_next_year)).to eq "#{next_next_year} to #{next_year + 2}"
      end
    end
  end

  describe 'cycle switcher' do
    it 'correctly sets can_add_course_choice? and can_submit? between cycles', time: mid_cycle(2023) do
      SiteSetting.set(name: 'cycle_schedule', value: :today_is_mid_cycle)

      application_form = create(:application_form, phase: 'apply_1')

      SiteSetting.set(name: 'cycle_schedule', value: :today_is_after_apply_1_deadline_passed)

      new_application = CarryOverApplication.new(application_form).call

      expect(described_class.can_add_course_choice?(new_application)).to be false
      expect(described_class.can_submit?(new_application)).to be false

      SiteSetting.set(name: 'cycle_schedule', value: :today_is_after_find_opens)

      expect(described_class.can_add_course_choice?(new_application)).to be_truthy
      expect(described_class.can_submit?(new_application)).to be false

      SiteSetting.set(name: 'cycle_schedule', value: :today_is_after_apply_opens)

      expect(described_class.can_add_course_choice?(new_application)).to be_truthy
      expect(described_class.can_submit?(new_application)).to be true
    ensure
      SiteSetting.set(name: 'cycle_schedule', value: nil)
    end

    context 'when cycle_schedule is set to today_is_after_find_opens', time: mid_cycle(2023) do
      it 'changes the CycleTimetable.current_year to the next year' do
        current_year = described_class.current_year
        next_year = described_class.next_year

        expect {
          SiteSetting.set(name: 'cycle_schedule', value: :today_is_after_find_opens)
        }.to change { described_class.current_year }.from(current_year).to(next_year)
      end
    end

    context 'when cycle_schedule is set to today_is_after_apply_opens', time: mid_cycle(2023) do
      it 'changes the CycleTimetable.current_year to the next year' do
        current_year = described_class.current_year
        next_year = described_class.next_year

        expect {
          SiteSetting.set(name: 'cycle_schedule', value: :today_is_after_apply_opens)
        }.to change { described_class.current_year }.from(current_year).to(next_year)
      end
    end
  end

  describe '.send_find_has_opened_email?' do
    context 'it is before find reopens' do
      it 'returns false' do
        travel_temporarily_to(described_class.find_opens - 1.hour) do
          expect(described_class.send_find_has_opened_email?).to be(false)
        end
      end
    end

    context 'it is after find reopens' do
      it 'returns true' do
        travel_temporarily_to(described_class.find_opens + 1.hour) do
          expect(described_class.send_find_has_opened_email?).to be(true)
        end
      end
    end
  end

  describe '.service_opens_today?' do
    let(:year) { RecruitmentCycle.current_year }

    it 'is true when the service is Apply and the time is within business hours' do
      travel_temporarily_to(1.minute.since(described_class.apply_opens(year))) do
        expect(described_class.service_opens_today?(:apply, year:)).to be true
      end
    end

    it 'is false when the service is Apply and the time is outside of business hours' do
      travel_temporarily_to(12.hours.since(described_class.apply_opens(year))) do
        expect(described_class.service_opens_today?(:apply, year:)).to be false
      end
    end

    it 'is true when the service is Find and the time is within business hours' do
      travel_temporarily_to(1.minute.since(described_class.find_opens(year))) do
        expect(described_class.service_opens_today?(:find, year:)).to be true
      end
    end

    it 'is false when the service is Find and the time is outside of business hours' do
      travel_temporarily_to(12.hours.since(described_class.find_opens(year))) do
        expect(described_class.service_opens_today?(:find, year:)).to be false
      end
    end
  end

  describe '.send_new_cycle_has_started_email?' do
    context 'it is before apply reopens' do
      it 'returns false' do
        travel_temporarily_to(described_class.apply_reopens - 1.day) do
          expect(described_class.send_new_cycle_has_started_email?).to be(false)
        end
      end
    end

    context 'it is after apply reopens' do
      it 'returns true' do
        travel_temporarily_to(described_class.apply_opens) do
          expect(described_class.send_new_cycle_has_started_email?).to be(true)
        end
      end
    end
  end

  describe '.between_reject_by_default_and_find_reopens?' do
    context 'it is before reject by default date' do
      it 'returns false' do
        travel_temporarily_to(described_class.reject_by_default - 1.day) do
          expect(described_class.between_reject_by_default_and_find_reopens?).to be(false)
        end
      end
    end

    context 'it is after reject by default date' do
      it 'returns true' do
        travel_temporarily_to(described_class.reject_by_default + 1.day) do
          expect(described_class.between_reject_by_default_and_find_reopens?).to be(true)
        end
      end
    end
  end

  describe '.before_apply_opens?' do
    context 'one second until apply_opens' do
      it 'opens at exactly the right time' do
        travel_temporarily_to(1.second.until(described_class.apply_opens)) do
          expect(described_class.before_apply_opens?).to be(true)
        end
      end
    end

    context 'one second after apply_opens' do
      it 'opens at exactly the right time' do
        travel_temporarily_to(1.second.after(described_class.apply_opens)) do
          expect(described_class.before_apply_opens?).to be(false)
        end
      end
    end
  end

  describe 'reset_holidays' do
    it 'updates holidays when timetravelling' do
      travel_temporarily_to('10 Dec 2024') do
        described_class.reset_holidays
        expect(30.business_days.from_now).to eq(Time.zone.parse('7 Feb 2025'))
      end

      travel_temporarily_to('10 Dec 2025') do
        described_class.reset_holidays
        expect(30.business_days.from_now).to eq(Time.zone.parse('26 Jan 2026'))
      end

      travel_temporarily_to('10 Dec 2024') do
        described_class.reset_holidays
        expect(30.business_days.from_now).to eq(Time.zone.parse('7 Feb 2025'))
      end
    end
  end
end
