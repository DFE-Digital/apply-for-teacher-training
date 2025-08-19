require 'rails_helper'

RSpec.describe ProviderInterface::RejectByDefaultBannerComponent, type: :component do
  describe '#render' do
    it 'renders between Apply deadline and Reject by default deadline' do
      travel_temporarily_to(current_timetable.apply_deadline_at + 1.day) do
        deadline_time = current_timetable.reject_by_default_at.to_fs(:govuk_time)
        deadline_date = current_timetable.reject_by_default_at.to_fs(:govuk_date)
        result = render_inline(described_class.new)
        expect(result.text).to include(
          "All applications that you have not made a decision on will be rejected automatically at #{deadline_time} on #{deadline_date}.",
        )
      end
    end

    it 'does not render outside of date range' do
      travel_temporarily_to(current_timetable.apply_deadline_at - 2.weeks) do
        result = render_inline(described_class.new)
        expect(result.text).to eq('')
      end
    end
  end
end
