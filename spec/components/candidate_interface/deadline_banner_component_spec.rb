require 'rails_helper'

RSpec.describe CandidateInterface::DeadlineBannerComponent, type: :component do
  describe '#render' do
    let(:application_form) { build(:application_form) }

    it 'does not render when flash is not empty' do
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
        deadline_date = current_timetable.apply_deadline_at.to_fs(:day_and_month)
        academic_year = current_timetable.recruitment_cycle_year

        expect(result.text).to include(
          "The deadline for applying to courses starting by the end of September #{academic_year} is #{deadline_time} on #{deadline_date}",
        )
        expect(result.text).to include(
          'Providers may close applications early if a course becomes full. You can check the number of available places with the provider.',
        )
      end
    end
  end
end
