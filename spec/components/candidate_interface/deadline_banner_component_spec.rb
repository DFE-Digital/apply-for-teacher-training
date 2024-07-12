require 'rails_helper'

RSpec.describe CandidateInterface::DeadlineBannerComponent, type: :component do
  describe '#render' do
    let(:application_form) { build(:application_form) }
    let(:flash) { double }

    it 'does not render when flash is not empty' do
      allow(flash).to receive(:empty?).and_return(false)
      allow(CycleTimetable).to receive_messages(show_apply_deadline_banner?: true)

      result = render_inline(described_class.new(application_form:, flash_empty: flash.empty?))

      expect(result.text).to eq('')
    end

    it 'does not render when a deadline banner should not be shown' do
      allow(flash).to receive(:empty?).and_return(true)
      allow(CycleTimetable).to receive_messages(show_apply_deadline_banner?: false)

      result = render_inline(described_class.new(application_form:, flash_empty: flash.empty?))

      expect(result.text).to eq('')
    end

    it 'renders the banner when the right conditions are met' do
      allow(flash).to receive(:empty?).and_return(true)
      allow(CycleTimetable).to receive_messages(show_apply_deadline_banner?: true)

      result = render_inline(described_class.new(application_form:, flash_empty: flash.empty?))

      expect(result.text).to include(
        "The deadline for applying to courses starting in #{academic_year} is #{deadline_time(:apply_deadline)} on #{deadline_date(:apply_deadline)}",
      )
    end
  end

  def academic_year
    "#{application_form.recruitment_cycle_year} to #{application_form.recruitment_cycle_year + 1}"
  end

  def deadline_time(deadline)
    CycleTimetable.date(deadline).to_fs(:govuk_time)
  end

  def deadline_date(deadline)
    CycleTimetable.date(deadline).to_fs(:govuk_date)
  end
end
