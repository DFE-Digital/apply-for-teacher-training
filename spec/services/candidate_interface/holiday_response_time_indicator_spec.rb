require 'rails_helper'

RSpec.describe CandidateInterface::HolidayResponseTimeIndicator do
  describe '#christmas_response_time_delay_possible?' do
    context 'application is submitted well before christmas' do
      let(:sent_to_provider_at) { 1.day.after(current_timetable.apply_opens_at) }

      it 'returns false' do
        application_choice = create(:application_choice, sent_to_provider_at:)

        expect(described_class.new(application_choice:).christmas_response_time_delay_possible?).to be false
      end
    end

    context 'application unsubmitted, current date well before christmas' do
      it 'returns false' do
        travel_temporarily_to(1.day.after(current_timetable.apply_opens_at)) do
          application_choice = create(:application_choice, sent_to_provider_at: nil)
          expect(described_class.new(application_choice:).christmas_response_time_delay_possible?).to be false
        end
      end
    end

    context 'application submitted after christmas holiday period' do
      let(:sent_to_provider_at) { 2.business_days.after(Time.zone.local(current_year, 1, 1)) }

      it 'returns false' do
        application_choice = create(:application_choice, sent_to_provider_at:)

        expect(described_class.new(application_choice:).christmas_response_time_delay_possible?).to be false
      end
    end

    context 'application unsubmitted, current time after the holiday period' do
      it 'returns false' do
        travel_temporarily_to(2.business_days.after(Time.zone.local(current_year, 1, 1))) do
          application_choice = create(:application_choice, sent_to_provider_at: nil)
          expect(described_class.new(application_choice:).christmas_response_time_delay_possible?).to be false
        end
      end
    end

    context 'application submitted just before the christmas holiday' do
      let(:sent_to_provider_at) { 2.business_days.before(Time.zone.local(current_year - 1, 12, 25)) }

      it 'returns true' do
        application_choice = create(:application_choice, sent_to_provider_at:)

        expect(described_class.new(application_choice:).christmas_response_time_delay_possible?).to be true
      end
    end

    context 'application unsubmitted, current time just before the christmas holidays' do
      it 'returns true' do
        travel_temporarily_to(2.business_days.before(Time.zone.local(current_year - 1, 12, 25))) do
          application_choice = create(:application_choice, sent_to_provider_at: nil)
          expect(described_class.new(application_choice:).christmas_response_time_delay_possible?).to be true
        end
      end
    end

    context 'application submitted during the holiday period' do
      let(:sent_to_provider_at) { Time.zone.local(current_year - 1, 12, 27) }

      it 'returns true' do
        application_choice = create(:application_choice, sent_to_provider_at:)

        expect(described_class.new(application_choice:).christmas_response_time_delay_possible?).to be true
      end
    end

    context 'application unsubmitted, current time during the holiday period' do
      it 'returns true' do
        travel_temporarily_to(Time.zone.local(current_year - 1, 12, 27)) do
          application_choice = create(:application_choice, sent_to_provider_at: nil)
          expect(described_class.new(application_choice:).christmas_response_time_delay_possible?).to be true
        end
      end
    end
  end

  describe '#easter_response_time_delay_possible?' do
    let(:easter_monday) do
      Holidays.between(Time.zone.local(current_year, 1, 1), Time.zone.local(current_year, 6, 1), :gb_eng, :observed).find do |h|
        h[:name] == 'Easter Monday'
      end[:date]
    end

    context 'application choice submitted well before easter' do
      let(:sent_to_provider_at) { 11.business_days.before(easter_monday) }

      it 'returns false' do
        application_choice = create(:application_choice, sent_to_provider_at:)

        expect(described_class.new(application_choice:).easter_response_time_delay_possible?).to be false
      end
    end

    context 'application choice not submitted, current time well before easter' do
      it 'returns false' do
        travel_temporarily_to(11.business_days.before(easter_monday)) do
          application_choice = create(:application_choice, sent_to_provider_at: nil)
          expect(described_class.new(application_choice:).easter_response_time_delay_possible?).to be false
        end
      end
    end

    context 'application choice submitted well after easter' do
      let(:sent_to_provider_at) { 11.business_days.after(easter_monday).end_of_day }

      it 'returns false' do
        application_choice = create(:application_choice, sent_to_provider_at:)

        expect(described_class.new(application_choice:).easter_response_time_delay_possible?).to be false
      end
    end

    context 'application choice unsubmitted, current time well after easter' do
      it 'returns false' do
        travel_temporarily_to(11.business_days.after(easter_monday)) do
          application_choice = create(:application_choice, sent_to_provider_at: nil)
          expect(described_class.new(application_choice:).easter_response_time_delay_possible?).to be false
        end
      end
    end

    context 'application choice submitted just before easter' do
      let(:sent_to_provider_at) { 9.business_days.before(easter_monday) }

      it 'returns true' do
        application_choice = create(:application_choice, sent_to_provider_at:)
        expect(described_class.new(application_choice:).easter_response_time_delay_possible?).to be true
      end
    end

    context 'application choice unsubmitted, current time just before easter' do
      it 'returns true' do
        travel_temporarily_to(9.business_days.before(easter_monday)) do
          application_choice = create(:application_choice, sent_to_provider_at: nil)
          expect(described_class.new(application_choice:).easter_response_time_delay_possible?).to be true
        end
      end
    end

    context 'application choice submitted just after easter' do
      let(:sent_to_provider_at) { 9.business_days.after(easter_monday) }

      it 'returns true' do
        application_choice = create(:application_choice, sent_to_provider_at:)
        expect(described_class.new(application_choice:).easter_response_time_delay_possible?).to be true
      end
    end

    context 'application choice unsubmitted, current time is just after easter' do
      it 'returns true' do
        travel_temporarily_to(9.business_days.after(easter_monday)) do
          application_choice = create(:application_choice, sent_to_provider_at: nil)
          expect(described_class.new(application_choice:).easter_response_time_delay_possible?).to be true
        end
      end
    end
  end
end
