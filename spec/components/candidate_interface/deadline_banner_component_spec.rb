require 'rails_helper'

RSpec.describe CandidateInterface::DeadlineBannerComponent, type: :component do
  describe '#render' do
    let(:application_form) { build(:application_form) }
    let(:current_timetable) { RecruitmentCycleTimetable.current_timetable }

    it 'does not render when flash is not empty', seed_timetables do
      travel_temporarily_to(current_timetable.apply_deadline_at - 1.minute) do
        result = render_inline(described_class.new(application_form:, flash_empty: false))
        expect(result.text).to eq('')
      end
    end

    it 'does not render when a deadline banner should not be shown' do
      travel_temporarily_to(current_timetable.apply_deadline_at - 13.weeks) do
        result = render_inline(described_class.new(application_form:, flash_empty: true))
        expect(result.text).to eq('')
      end

      travel_temporarily_to(current_timetable.apply_deadline_at + 1.minute) do
        result = render_inline(described_class.new(application_form:, flash_empty: true))
        expect(result.text).to eq('')
      end
    end

    it 'renders the banner when the right conditions are met' do
      travel_temporarily_to(current_timetable.apply_deadline_at - 1.minute) do
        result = render_inline(described_class.new(application_form:, flash_empty: true))
        deadline_time = current_timetable.apply_deadline_at.to_fs(:govuk_time)
        deadline_date = current_timetable.apply_deadline_at.to_fs(:govuk_date)
        academic_year = current_timetable.academic_year_range_name

        expect(result.text).to include(
          "The deadline for applying to courses starting in #{academic_year} is #{deadline_time} on #{deadline_date}",
        )
      end
    end
  end
end
