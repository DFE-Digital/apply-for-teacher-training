require 'rails_helper'

RSpec.describe CandidateInterface::ReopenBannerComponent do
  describe '#render' do
    let(:application_form) { build(:application_form) }
    let(:flash) { double }

    def configure_conditions_for_rendering_banner(phase)
      application_form.phase = phase
      FeatureFlag.activate(:deadline_notices)
      allow(flash).to receive(:empty?).and_return true
      allow(CycleTimetable).to receive(:between_cycles_apply_1?).and_return(true)
      allow(CycleTimetable).to receive(:between_cycles_apply_2?).and_return(true)
    end

    it 'renders the banner for an Apply 1 app' do
      configure_conditions_for_rendering_banner('apply_1')

      result = render_inline(
        described_class.new(
          phase: application_form.phase,
          flash_empty: flash.empty?,
        ),
      )

      expect(result.text).to include('Applications for courses starting this academic year have now closed')
      expect(result.text).to include('Submit your application from 12 October 2021 for courses starting in the next academic year.')
    end

    it 'renders the banner for an Apply 2 app' do
      configure_conditions_for_rendering_banner('apply_2')

      result = render_inline(
        described_class.new(
          phase: application_form.phase,
          flash_empty: flash.empty?,
        ),
      )

      expect(result.text).to include('Applications for courses starting this academic year have now closed')
      expect(result.text).to include('Submit your application from 12 October 2021 for courses starting in the next academic year.')
    end

    it 'does not render when we are not between cycles' do
      configure_conditions_for_rendering_banner('apply_1')
      allow(CycleTimetable).to receive(:between_cycles_apply_1?).and_return(false)

      result = render_inline(
        described_class.new(
          phase: application_form.phase,
          flash_empty: flash.empty?,
        ),
      )

      expect(result.text).not_to include('Applications for courses starting this academic year have now closed')
    end

    it 'renders nothing if the flash contains something' do
      configure_conditions_for_rendering_banner('apply_1')
      allow(flash).to receive(:empty?).and_return false

      result = render_inline(described_class.new(phase: application_form.phase, flash_empty: flash.empty?))

      expect(result.text).to be_blank
    end
  end
end
