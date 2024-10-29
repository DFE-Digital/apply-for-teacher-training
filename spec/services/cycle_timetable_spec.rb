require 'rails_helper'

RSpec.describe CycleTimetable do
  let(:this_year) { Time.zone.now.year }
  let(:next_year) { this_year + 1 }
  let(:last_year) { this_year - 1 }
  let(:next_next_year) { this_year + 2 }
  let(:one_hour_before_apply_deadline) { described_class.apply_deadline(this_year) - 1.hour }
  let(:one_hour_after_apply_deadline) { described_class.apply_deadline(this_year) + 1.hour  }
  let(:one_hour_after_this_year_cycle_opens) { described_class.apply_opens(this_year) + 1.hour }
  let(:one_hour_after_near_year_apply_opens) { described_class.apply_opens(next_year) + 1.hour }
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
      travel_temporarily_to(one_hour_after_near_year_apply_opens) do
        expect(described_class.current_year).to eq(next_year)
      end
    end

    it 'returns this_year for the date of `apply_opens`' do
      travel_temporarily_to(described_class.apply_opens(this_year)) do
        expect(described_class.current_year).to eq(this_year)
      end
    end

    it 'returns last_year for current_year(CycleTimetable.find_opens(this_year))' do
      # What this test shows that right at the moment find_opens, #current_year returns the year before.
      # Like we haven't quite started the cycle yet.
      # This doesn't make sense to have the first date that defines a cycle not be included in the cycle.
      expect(described_class.current_year(described_class.find_opens(this_year))).to eq(last_year)
    end

    context 'when now is nil' do
      it 'returns nil' do
        expect(described_class.current_year(nil)).to be_nil
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
      travel_temporarily_to(one_hour_after_near_year_apply_opens) do
        expect(described_class.next_year).to eq(next_next_year)
      end
    end
  end

  describe '.show_apply_deadline_banner?' do
    it 'returns true before the deadline and the choices have not been successful' do
      application_choices = [build(:application_choice, :withdrawn)]
      application_form = build(:application_form, application_choices:)

      travel_temporarily_to(one_hour_before_apply_deadline) do
        expect(described_class.show_apply_deadline_banner?(application_form)).to be true
      end
    end

    it 'returns true if there are no application choices' do
      application_form = build(:application_form)

      travel_temporarily_to(one_hour_before_apply_deadline) do
        expect(described_class.show_apply_deadline_banner?(application_form)).to be true
      end
    end

    it 'returns false if it is a successful application' do
      application_choice = build(:application_choice, :offered)
      application_form = build(:application_form, phase: 'apply_1', application_choices: [application_choice])

      travel_temporarily_to(one_hour_before_apply_deadline) do
        expect(described_class.show_apply_deadline_banner?(application_form)).to be false
      end
    end

    it 'returns false after the configured date' do
      application_form = build(:application_form)

      travel_temporarily_to(one_hour_after_apply_deadline) do
        expect(described_class.show_apply_deadline_banner?(application_form)).to be false
      end
    end
  end

  describe '.show_non_working_days_banner?' do
    context 'when within the Christmas period' do
      let(:one_hour_after_christmas_period) { described_class.holidays[:christmas].last.end_of_day + 1.hour }

      it 'returns false if before the 20 day period' do
        travel_temporarily_to(one_hour_after_near_year_apply_opens) do
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

  describe '.between_cycles?' do
    it 'returns false before if apply deadline has not passed' do
      travel_temporarily_to(one_hour_before_apply_deadline) do
        expect(described_class.between_cycles?).to be false
      end
    end

    it 'returns true after apply deadline has passed but find is still open' do
      travel_temporarily_to(one_hour_after_apply_deadline) do
        expect(described_class.between_cycles?).to be true
      end
    end

    it 'returns true between find and apply reopening' do
      travel_temporarily_to(one_hour_after_find_opens) do
        expect(described_class.between_cycles?).to be true
      end
    end

    it 'returns false after the new cycle opens' do
      travel_temporarily_to(one_hour_after_near_year_apply_opens) do
        expect(described_class.between_cycles?).to be false
      end
    end
  end

  describe '.between_apply_deadline_and_find_closes?' do
    it 'returns false before the configured date' do
      travel_temporarily_to(one_hour_before_apply_deadline) do
        expect(described_class.between_apply_deadline_and_find_closes?).to be false
      end
    end

    it 'returns true during the configured date' do
      travel_temporarily_to(one_hour_after_apply_deadline) do
        expect(described_class.between_apply_deadline_and_find_closes?).to be true
      end
    end

    it 'returns false after the configured date' do
      travel_temporarily_to(one_hour_after_find_reopens) do
        expect(described_class.between_apply_deadline_and_find_closes?).to be false
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
          travel_temporarily_to(one_hour_after_apply_deadline) do
            expect(execute_service).to be false
          end
        end
      end

      context 'when the date is before the apply1 submission deadline' do
        it 'returns true' do
          travel_temporarily_to(one_hour_before_apply_deadline) do
            expect(execute_service).to be true
          end
        end
      end
    end

    context 'application form is in the apply again state' do
      let(:application_form) { build_stubbed(:application_form, phase: :apply_2) }

      context 'when the date is after the apply again submission deadline' do
        it 'returns false' do
          travel_temporarily_to(one_hour_after_apply_deadline) do
            expect(execute_service).to be false
          end
        end
      end

      context 'when the date is before the apply again submission deadline' do
        it 'returns true' do
          travel_temporarily_to(one_hour_before_apply_deadline) do
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

  describe '.next_apply_deadline' do
    context 'after cycle start and before apply deadline' do
      it 'returns apply_deadline' do
        travel_temporarily_to(one_hour_before_apply_deadline) do
          expect(described_class.next_apply_deadline).to eq(described_class.apply_deadline)
        end
      end
    end

    context 'after apply deadline' do
      it 'returns apply_deadline for next year' do
        travel_temporarily_to(one_hour_after_apply_deadline) do
          expect(described_class.next_apply_deadline).to eq(described_class.apply_deadline(next_year))
        end
      end
    end
  end

  describe 'apply_deadline_has_passed?' do
    context 'it is before the apply deadline' do
      it 'returns false' do
        travel_temporarily_to(described_class.apply_opens) do
          application_form = build(:application_form)
          expect(described_class.apply_deadline_has_passed?(application_form)).to be(false)
        end
      end
    end

    context 'it is after the apply deadline' do
      it 'returns true' do
        travel_temporarily_to(described_class.find_closes) do
          application_form = build(:application_form)
          expect(described_class.apply_deadline_has_passed?(application_form)).to be(true)
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
    it 'correctly sets can_add_course_choice? and can_submit? between cycles', time: mid_cycle do
      SiteSetting.set(name: 'cycle_schedule', value: :today_is_mid_cycle)

      application_form = create(:application_form)

      SiteSetting.set(name: 'cycle_schedule', value: :today_is_after_apply_deadline_passed)

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

    context 'when cycle_schedule is set to today_is_after_find_opens', time: mid_cycle do
      it 'changes the CycleTimetable.current_year to the next year' do
        current_year = described_class.current_year
        next_year = described_class.next_year

        expect {
          SiteSetting.set(name: 'cycle_schedule', value: :today_is_after_find_opens)
        }.to change { described_class.current_year }.from(current_year).to(next_year)
      end
    end

    context 'when cycle_schedule is set to today_is_after_apply_opens', time: mid_cycle do
      it 'changes the CycleTimetable.current_year to the next year' do
        current_year = described_class.current_year
        next_year = described_class.next_year

        expect {
          SiteSetting.set(name: 'cycle_schedule', value: :today_is_after_apply_opens)
        }.to change { described_class.current_year }.from(current_year).to(next_year)
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

  describe '.current_cycle_week' do
    # Sunday the week before find opens
    let(:date) { Time.zone.local(2023, 10, 1) }

    context 'the last week of the previous cycle' do
      it 'returns 52' do
        travel_temporarily_to(date) do
          expect(described_class.current_cycle_week).to be 52
        end
      end
    end

    context 'when Monday first week' do
      it 'returns 1' do
        travel_temporarily_to(date + 1.day) do
          expect(described_class.current_cycle_week).to be 1
        end
      end
    end

    context 'when Sunday first week' do
      it 'returns 1' do
        travel_temporarily_to(date + 7.days) do
          expect(described_class.current_cycle_week).to be 1
        end
      end
    end

    context 'when Monday second week' do
      it 'returns 2' do
        travel_temporarily_to(date + 8.days) do
          expect(described_class.current_cycle_week).to be 2
        end
      end
    end

    context 'when mid cycle' do
      it 'returns the week number' do
        travel_temporarily_to(date + 5.weeks) do
          expect(described_class.current_cycle_week).to be 5
        end
      end
    end

    context 'when last cycle week' do
      it 'returns 52' do
        travel_temporarily_to(date + 52.weeks) do
          expect(described_class.current_cycle_week).to be 52
        end
      end
    end

    context 'when the first week of the next cycle' do
      it 'returns 1' do
        travel_temporarily_to(date + 53.weeks) do
          expect(described_class.current_cycle_week).to be 1
        end
      end
    end

    context 'when the first week of the next cycle passed explicitly' do
      it 'returns 1' do
        expect(described_class.current_cycle_week(date + 53.weeks)).to be 1
      end
    end
  end

  describe '#cycle_week_date_range' do
    let(:date) { Time.zone.local(2023, 10, 30) }

    before { TestSuiteTimeMachine.travel_permanently_to(date) }

    it 'returns the correct date range for cycle_week 5' do
      cycle_week_date_range = described_class.cycle_week_date_range(5)

      expect(cycle_week_date_range).to eql(date.all_week)
    end
  end

  describe '#start_of_cycle_week' do
    context 'without time argument' do
      let(:date) { Time.zone.local(2023, 10, 30) }

      before { TestSuiteTimeMachine.travel_permanently_to(date) }

      it 'returns this monday when given current_cycle_week' do
        start_of_current_cycle_week = described_class.start_of_cycle_week(described_class.current_cycle_week)
        expect(start_of_current_cycle_week.to_date).to eq '2023-10-30'.to_date
        expect(start_of_current_cycle_week.wday).to eq 1
      end

      it 'returns the monday of the cycle week in the current cycle year' do
        start_of_week_10 = described_class.start_of_cycle_week(10)
        expect(start_of_week_10.to_date).to eq '2023-12-04'.to_date
        expect(start_of_week_10.wday).to eq 1
      end

      it 'returns the monday before find_opens for the first week of the cycle' do
        start_of_week_one = described_class.start_of_cycle_week(1)
        expect(start_of_week_one.to_date).to eq described_class.find_opens.beginning_of_week.to_date
      end

      it 'only returns dates in current cycle year' do
        start_of_week_65 = described_class.start_of_cycle_week(65)
        expect(start_of_week_65).to eq described_class.start_of_cycle_week(13)
      end
    end
  end

  describe '#cancel_unsubmitted_applicaions?' do
    before { TestSuiteTimeMachine.travel_permanently_to(date) }

    context 'mid-cycle' do
      let(:date) { mid_cycle }

      it 'returns false' do
        expect(described_class.cancel_unsubmitted_applications?).to be false
      end
    end

    context 'on reject by default date' do
      let(:date) { described_class.reject_by_default }

      it 'returns false' do
        expect(described_class.cancel_unsubmitted_applications?).to be false
      end
    end

    context 'on cancel date' do
      let(:date) { cancel_application_deadline }

      it 'returns false' do
        expect(described_class.cancel_unsubmitted_applications?).to be true
      end
    end

    context 'after find reopens' do
      let(:date) { after_apply_reopens }

      it 'returns false' do
        expect(described_class.cancel_unsubmitted_applications?).to be false
      end
    end
  end

  describe '#run_decline_by_default?' do
    before { TestSuiteTimeMachine.travel_permanently_to(date) }

    context 'after find closes' do
      let(:date) { described_class.find_closes + 1.minute }

      it 'returns false' do
        expect(described_class.run_decline_by_default?).to be false
      end
    end

    context 'after reject by default' do
      let(:date) { described_class.reject_by_default }

      it 'returns false' do
        expect(described_class.run_decline_by_default?).to be false
      end
    end

    context 'more than a day before find closes' do
      let(:date) { described_class.find_closes - 25.hours }

      it 'returns false' do
        expect(described_class.run_decline_by_default?).to be false
      end
    end

    context 'day before find closes' do
      let(:date) { described_class.find_closes - 23.hours }

      it 'returns true' do
        expect(described_class.run_decline_by_default?).to be true
      end
    end
  end

  describe '#run_reject_by_default?' do
    before { TestSuiteTimeMachine.travel_permanently_to(date) }

    context 'before reject by default date' do
      let(:date) { described_class.reject_by_default - 1.minute }

      it 'returns false' do
        expect(described_class.run_reject_by_default?).to be false
      end
    end

    context 'over a day after the reject by default date' do
      let(:date) { described_class.reject_by_default + 1.day + 1.second }

      it 'returns false' do
        expect(described_class.run_reject_by_default?).to be false
      end
    end

    context 'within one day of the reject by default date' do
      let(:date) { described_class.reject_by_default + 1.day }

      it 'returns true' do
        expect(described_class.run_reject_by_default?).to be true
      end
    end
  end
end
