require 'rails_helper'

RSpec.describe CandidateInterface::DeadlineBannerComponent, type: :component do
  describe '#render' do
    let(:application_form) { build(:application_form) }
    let(:flash) { double }

    def configure_conditions_for_rendering_banner(phase)
      application_form.phase = phase
      allow(flash).to receive(:empty?).and_return true
      allow(CycleTimetable).to receive(:show_apply_1_deadline_banner?).and_return(true)
      allow(CycleTimetable).to receive(:show_apply_2_deadline_banner?).and_return(true)
    end

    it 'renders the Apply 1 banner when the right conditions are met' do
      configure_conditions_for_rendering_banner('apply_1')

      result = render_inline(described_class.new(application_form: application_form, flash_empty: flash.empty?))

      expect(result.text).to include("The deadline for applying to courses starting in the #{application_form.recruitment_cycle_year} to #{application_form.recruitment_cycle_year + 1} academic year is 6pm on #{CycleTimetable.date(:apply_1_deadline).to_s(:govuk_date)}")
    end

    it 'renders the Apply 2 banner when the right conditions are met' do
      configure_conditions_for_rendering_banner('apply_2')

      result = render_inline(described_class.new(application_form: application_form, flash_empty: flash.empty?))

      expect(result.text).to include("The deadline for applying to courses starting in the #{application_form.recruitment_cycle_year} to #{application_form.recruitment_cycle_year + 1} academic year is 6pm on #{CycleTimetable.date(:apply_2_deadline).to_s(:govuk_date)}")
    end

    it 'renders nothing if the flash contains something' do
      configure_conditions_for_rendering_banner('apply_1')
      allow(flash).to receive(:empty?).and_return false

      result = render_inline(described_class.new(application_form: application_form, flash_empty: flash.empty?))

      expect(result.text).to be_blank
    end

    it 'renders nothing if it\'s not the right time to show the banner' do
      configure_conditions_for_rendering_banner('apply_1')
      allow(CycleTimetable).to receive(:show_apply_1_deadline_banner?).and_return(false)
      allow(CycleTimetable).to receive(:show_apply_2_deadline_banner?).and_return(false)

      result = render_inline(described_class.new(application_form: application_form, flash_empty: flash.empty?))

      expect(result.text).to be_blank
    end

    it 'renders a banner if the timetable says only one of them should be shown' do
      configure_conditions_for_rendering_banner('apply_2')
      allow(CycleTimetable).to receive(:show_apply_1_deadline_banner?).and_return(false)

      result = render_inline(described_class.new(application_form: application_form, flash_empty: flash.empty?))

      expect(result.text).to include("The deadline for applying to courses starting in the #{application_form.recruitment_cycle_year} to #{application_form.recruitment_cycle_year + 1} academic year is 6pm on #{CycleTimetable.date(:apply_2_deadline).to_s(:govuk_date)}")
    end
  end
end
