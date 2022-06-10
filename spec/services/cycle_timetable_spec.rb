require 'rails_helper'

RSpec.describe CycleTimetable do
  let(:one_hour_before_apply1_deadline) { described_class.apply_1_deadline(2020) - 1.hour }
  let(:one_hour_after_apply1_deadline) { described_class.apply_1_deadline(2020) + 1.hour  }
  let(:one_hour_before_apply2_deadline) { described_class.apply_2_deadline(2020) - 1.hour }
  let(:one_hour_after_apply2_deadline) { described_class.apply_2_deadline(2020) + 1.hour  }
  let(:one_hour_after_2020_cycle_opens) { described_class.apply_opens(2020) + 1.hour }
  let(:one_hour_after_2021_cycle_opens) { described_class.apply_opens(2021) + 1.hour }
  let(:one_hour_before_find_closes) { described_class.find_closes(2020) - 1.hour }
  let(:one_hour_after_find_closes) { described_class.find_closes(2020) + 1.hour }
  let(:one_hour_after_find_opens) { described_class.find_opens(2020) + 1.hour }
  let(:three_days_before_find_reopens) { described_class.find_reopens(2020) - 3.days }
  let(:twenty_days_after_2021_cycle_opens) { 20.business_days.after(described_class.apply_opens(2021)).end_of_day }
  let(:one_hour_before_show_summer_recruitment_banner) { described_class::CYCLE_DATES[2022][:show_summer_recruitment_banner] - 1.hour }
  let(:one_hour_after_show_summer_recruitment_banner) { described_class::CYCLE_DATES[2022][:show_summer_recruitment_banner] + 1.hour }

  describe '.current_year' do
    it 'is 2020 if we are in the middle of the 2020 cycle' do
      Timecop.travel(one_hour_after_2020_cycle_opens) do
        expect(described_class.current_year).to eq(2020)
      end
    end

    it 'is 2021 if we are in the middle of the 2021 cycle' do
      Timecop.travel(one_hour_after_2021_cycle_opens) do
        expect(described_class.current_year).to eq(2021)
      end
    end
  end

  describe '.next_year' do
    it 'is 2021 if we are in the middle of the 2020 cycle' do
      Timecop.travel(one_hour_after_2020_cycle_opens) do
        expect(described_class.next_year).to eq(2021)
      end
    end

    it 'is 2022 if we are in the middle of the 2021 cycle' do
      Timecop.travel(one_hour_after_2021_cycle_opens) do
        expect(described_class.next_year).to eq(2022)
      end
    end
  end

  describe '.show_apply_1_deadline_banner?' do
    it 'returns true before the configured date and it is an unsuccessful apply_1 application' do
      application_form = build(:application_form, phase: 'apply_1')

      Timecop.travel(one_hour_before_apply1_deadline) do
        expect(described_class.show_apply_1_deadline_banner?(application_form)).to be true
      end
    end

    it 'returns false if it is a apply_2 application' do
      application_form = build(:application_form, phase: 'apply_2')

      Timecop.travel(one_hour_before_apply1_deadline) do
        expect(described_class.show_apply_1_deadline_banner?(application_form)).to be false
      end
    end

    it 'returns false if it is a successful application' do
      application_choice = build(:application_choice, :with_offer)
      application_form = build(:application_form, phase: 'apply_1', application_choices: [application_choice])

      Timecop.travel(one_hour_before_apply1_deadline) do
        expect(described_class.show_apply_1_deadline_banner?(application_form)).to be false
      end
    end

    it 'returns false after the configured date' do
      application_form = build(:application_form, phase: 'apply_1')

      Timecop.travel(one_hour_after_apply1_deadline) do
        expect(described_class.show_apply_1_deadline_banner?(application_form)).to be false
      end
    end
  end

  describe '.show_summer_recruitment_banner?' do
    it 'returns false before the configured date' do
      Timecop.travel(one_hour_before_show_summer_recruitment_banner) do
        expect(described_class.show_summer_recruitment_banner?).to be false
      end
    end

    it 'returns true between configure date and apply 1 closes' do
      Timecop.travel(one_hour_after_show_summer_recruitment_banner) do
        expect(described_class.show_summer_recruitment_banner?).to be true
      end
    end

    it 'returns false after apply 1 closes' do
      Timecop.travel(described_class.apply_1_deadline(2022) + 1.hour) do
        expect(described_class.show_summer_recruitment_banner?).to be false
      end
    end
  end

  describe '.show_apply_2_deadline_banner?' do
    it 'returns true before the configured date and it is a phase 2 application' do
      application_form = build(:application_form, phase: 'apply_2')

      Timecop.travel(one_hour_before_apply2_deadline) do
        expect(described_class.show_apply_2_deadline_banner?(application_form)).to be true
      end
    end

    it 'returns false if it is a successful apply_1 application' do
      application_choice = build(:application_choice, :with_offer)
      application_form = build(:application_form, phase: 'apply_1', application_choices: [application_choice])

      Timecop.travel(one_hour_before_apply2_deadline) do
        expect(described_class.show_apply_2_deadline_banner?(application_form)).to be false
      end
    end

    it 'returns false after the configured date' do
      unsuccessful_application_form = build(:application_form, phase: 'apply_2', application_choices: [build(:application_choice, :with_rejection)])

      Timecop.travel(one_hour_after_apply2_deadline) do
        expect(described_class.show_apply_2_deadline_banner?(unsuccessful_application_form)).to be false
      end
    end
  end

  describe '.show_non_working_days_banner?' do
    context 'when within the Christmas period' do
      let(:one_hour_after_christmas_period) { described_class.holidays[:christmas].last + 1.hour }

      it 'returns false if before the 20 day period' do
        Timecop.travel(one_hour_after_2021_cycle_opens) do
          expect(described_class.show_non_working_days_banner?).to be false
        end
      end

      it 'returns true if after the 20 day period' do
        Timecop.travel(twenty_days_after_2021_cycle_opens) do
          expect(described_class.show_non_working_days_banner?).to be true
        end
      end

      it 'returns false after the Christmas period' do
        Timecop.travel(one_hour_after_christmas_period) do
          expect(described_class.show_non_working_days_banner?).to be false
        end
      end
    end

    context 'when within the Easter period' do
      let(:eleven_days_before_easter_period) { 11.business_days.before(described_class.holidays[:easter].first) }
      let(:within_easter_period) { described_class.holidays[:easter].first + 1.hour }
      let(:one_hour_after_easter_period) { described_class.holidays[:easter].last + 1.hour }

      it 'returns false if before the holiday period' do
        Timecop.travel(eleven_days_before_easter_period) do
          expect(described_class.show_non_working_days_banner?).to be false
        end
      end

      it 'returns true if within holiday period' do
        Timecop.travel(within_easter_period) do
          expect(described_class.show_non_working_days_banner?).to be true
        end
      end

      it 'returns false after the holiday period' do
        Timecop.travel(one_hour_after_easter_period) do
          expect(described_class.show_non_working_days_banner?).to be false
        end
      end
    end
  end

  describe '.between_cycles_apply_1?' do
    it 'returns false before the configured date' do
      Timecop.travel(one_hour_before_apply1_deadline) do
        expect(described_class.between_cycles_apply_1?).to be false
      end
    end

    it 'returns true after the configured date' do
      Timecop.travel(one_hour_after_apply1_deadline) do
        expect(described_class.between_cycles_apply_1?).to be true
      end
    end

    it 'returns true between find and apply reopening' do
      Timecop.travel(one_hour_after_find_opens) do
        expect(described_class.between_cycles_apply_2?).to be true
      end
    end

    it 'returns false after the new cycle opens' do
      Timecop.travel(one_hour_after_2021_cycle_opens) do
        expect(described_class.between_cycles_apply_1?).to be false
      end
    end
  end

  describe '.between_cycles_apply_2?' do
    it 'returns false before the configured date' do
      Timecop.travel(one_hour_before_apply2_deadline) do
        expect(described_class.between_cycles_apply_2?).to be false
      end
    end

    it 'returns true after the configured date' do
      Timecop.travel(one_hour_after_apply2_deadline) do
        expect(described_class.between_cycles_apply_2?).to be true
      end
    end

    it 'returns true between find and apply reopening' do
      Timecop.travel(one_hour_after_find_opens) do
        expect(described_class.between_cycles_apply_2?).to be true
      end
    end

    it 'returns false after the new cycle opens' do
      Timecop.travel(one_hour_after_2021_cycle_opens) do
        expect(described_class.between_cycles_apply_2?).to be false
      end
    end
  end

  describe '.find_down?' do
    it 'returns false before find closes' do
      Timecop.travel(one_hour_before_find_closes) do
        expect(described_class.find_down?).to be false
      end
    end

    it 'returns false after find_reopens' do
      Timecop.travel(one_hour_after_find_opens) do
        expect(described_class.find_down?).to be false
      end
    end

    it 'returns true between find_closes and find_reopens' do
      Timecop.travel(one_hour_after_find_closes) do
        expect(described_class.find_down?).to be true
      end
    end
  end

  describe '.days_until_find_reopens' do
    it 'returns the number of days until Find reopens' do
      Timecop.travel(three_days_before_find_reopens) do
        expect(described_class.days_until_find_reopens).to eq(3)
      end
    end
  end

  describe '.valid_cycle?' do
    def create_application_for(recruitment_cycle_year)
      create :application_form, recruitment_cycle_year: recruitment_cycle_year
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
          Timecop.travel(one_hour_after_apply1_deadline) do
            expect(execute_service).to be false
          end
        end
      end

      context 'when the date is before the apply1 submission deadline' do
        it 'returns true' do
          Timecop.travel(one_hour_before_apply1_deadline) do
            expect(execute_service).to be true
          end
        end
      end
    end

    context 'application form is in the apply again state' do
      let(:application_form) { build_stubbed(:application_form, phase: :apply_2) }

      context 'when the date is after the apply again submission deadline' do
        it 'returns false' do
          Timecop.travel(one_hour_after_apply2_deadline) do
            expect(execute_service).to be false
          end
        end
      end

      context 'when the date is before the apply again submission deadline' do
        it 'returns true' do
          Timecop.travel(one_hour_before_apply2_deadline) do
            expect(execute_service).to be true
          end
        end
      end
    end

    context 'application form is from a previous recruitment cycle' do
      let(:application_form) { build_stubbed(:application_form, recruitment_cycle_year: 2020) }

      it 'returns false' do
        Timecop.travel(described_class.apply_opens) do
          expect(execute_service).to be false
        end
      end
    end
  end

  describe '.can_submit?', mid_cycle: true do
    it 'returns true for an application in the current recruitment cycle' do
      application_form = build :application_form, recruitment_cycle_year: RecruitmentCycle.current_year
      expect(described_class.can_submit?(application_form)).to be true
    end

    it 'returns false for an application in the previous recruitment cycle' do
      application_form = build :application_form, recruitment_cycle_year: RecruitmentCycle.previous_year
      expect(described_class.can_submit?(application_form)).to be false
    end
  end

  describe '.need_to_send_deadline_reminder?' do
    it 'does not return for a non deadline date' do
      Timecop.travel(described_class.apply_1_deadline_first_reminder - 1.day) do
        expect(described_class.need_to_send_deadline_reminder?).to be_nil
      end
    end

    it 'returns apply_1 when it is the first apply 1 deadline' do
      Timecop.travel(described_class.apply_1_deadline_first_reminder) do
        expect(described_class.need_to_send_deadline_reminder?).to be :apply_1
      end
    end

    it 'returns apply_1 when it is the second apply 1 deadline' do
      Timecop.travel(described_class.apply_1_deadline_second_reminder) do
        expect(described_class.need_to_send_deadline_reminder?).to be :apply_1
      end
    end

    it 'returns apply_2 when it is the first apply 2 deadline' do
      Timecop.travel(described_class.apply_2_deadline_first_reminder) do
        expect(described_class.need_to_send_deadline_reminder?).to be :apply_2
      end
    end

    it 'returns apply_2 when it is the second apply 2 deadline' do
      Timecop.travel(described_class.apply_2_deadline_second_reminder) do
        expect(described_class.need_to_send_deadline_reminder?).to be :apply_2
      end
    end
  end

  describe 'apply_1_deadline_has_passed?' do
    context 'it is before the apply 1 deadline' do
      it 'returns false' do
        Timecop.travel(described_class.apply_opens) do
          application_form = build(:application_form)
          expect(described_class.apply_1_deadline_has_passed?(application_form)).to be(false)
        end
      end
    end

    context 'it is after the apply 1 deadline' do
      it 'returns true' do
        Timecop.travel(described_class.apply_2_deadline) do
          application_form = build(:application_form)
          expect(described_class.apply_1_deadline_has_passed?(application_form)).to be(true)
        end
      end
    end
  end

  describe 'apply_2_deadline_has_passed?' do
    context 'it is before the apply 2 deadline' do
      it 'returns false' do
        Timecop.travel(described_class.apply_opens) do
          application_form = build(:application_form)
          expect(described_class.apply_1_deadline_has_passed?(application_form)).to be(false)
        end
      end
    end

    context 'it is after the apply 1 deadline' do
      it 'returns true' do
        Timecop.travel(described_class.find_closes) do
          application_form = build(:application_form)
          expect(described_class.apply_1_deadline_has_passed?(application_form)).to be(true)
        end
      end
    end
  end

  describe '.cycle_year_range' do
    context 'with no year passed in' do
      it 'returns the `current_year to next_year`' do
        allow(described_class).to receive(:current_year).and_return(2021)
        expect(described_class.cycle_year_range).to eq '2021 to 2022'
      end
    end

    context 'with a year passed in' do
      it 'returns `year to year + 1`' do
        expect(described_class.cycle_year_range(2022)).to eq '2022 to 2023'
      end
    end
  end

  describe 'cycle switcher' do
    it 'correctly sets can_add_course_choice? and can_submit? between cycles' do
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
  end

  describe '.send_find_has_opened_email?' do
    context 'it is before find reopens' do
      it 'returns false' do
        Timecop.travel(described_class.find_opens - 1.hour) do
          expect(described_class.send_find_has_opened_email?).to be(false)
        end
      end
    end

    context 'it is after find reopens' do
      it 'returns true' do
        Timecop.travel(described_class.find_opens + 1.hour) do
          expect(described_class.send_find_has_opened_email?).to be(true)
        end
      end
    end
  end

  describe '.service_opens_today?' do
    let(:year) { RecruitmentCycle.current_year }

    it 'is true when the service is Apply and the time is within business hours' do
      Timecop.freeze(1.minute.since(described_class.apply_opens(year))) do
        expect(described_class.service_opens_today?(:apply, year: year)).to be true
      end
    end

    it 'is false when the service is Apply and the time is outside of business hours' do
      Timecop.freeze(12.hours.since(described_class.apply_opens(year))) do
        expect(described_class.service_opens_today?(:apply, year: year)).to be false
      end
    end

    it 'is true when the service is Find and the time is within business hours' do
      Timecop.freeze(1.minute.since(described_class.find_opens(year))) do
        expect(described_class.service_opens_today?(:find, year: year)).to be true
      end
    end

    it 'is false when the service is Find and the time is outside of business hours' do
      Timecop.freeze(12.hours.since(described_class.find_opens(year))) do
        expect(described_class.service_opens_today?(:find, year: year)).to be false
      end
    end
  end

  describe '.send_new_cycle_has_started_email?' do
    context 'it is before apply reopens' do
      it 'returns false' do
        Timecop.travel(described_class.apply_reopens - 1.day) do
          expect(described_class.send_new_cycle_has_started_email?).to be(false)
        end
      end
    end

    context 'it is after apply reopens' do
      it 'returns true' do
        Timecop.travel(described_class.apply_reopens + 1.hour) do
          expect(described_class.send_new_cycle_has_started_email?).to be(true)
        end
      end
    end
  end
end
