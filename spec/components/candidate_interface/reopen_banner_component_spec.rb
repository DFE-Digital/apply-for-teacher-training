require 'rails_helper'

RSpec.describe CandidateInterface::ReopenBannerComponent do
  describe '#render' do
    let(:application_form) { build(:application_form) }
    let(:flash) { double }

    def configure_conditions_for_rendering_banner(phase)
      application_form.phase = phase
      FeatureFlag.activate(:deadline_notices)
      allow(flash).to receive(:empty?).and_return true
      allow(CycleTimetable).to receive_messages(between_cycles_apply_1?: true, between_cycles_apply_2?: true, current_year: 2021, apply_opens: Time.zone.local(2020, 10, 13, 9), apply_reopens: Time.zone.local(2021, 10, 12, 9))
      allow(CycleTimetable).to receive(:cycle_year_range).with(2021).and_return('2021 to 2022')
      allow(CycleTimetable).to receive(:cycle_year_range).with(2022).and_return('2022 to 2023')
    end

    context 'before find reopens' do
      before do
        TestSuiteTimeMachine.travel_permanently_to(CycleTimetable.apply_2_deadline + 1.day)
      end

      it 'renders the banner for an Apply 1 app with the correct details' do
        configure_conditions_for_rendering_banner('apply_1')

        render_inline(
          described_class.new(phase: application_form.phase, flash_empty: flash.empty?),
        ) do |result|
          expect(result.text).to include('Applications for courses starting in the 2021 to 2022 academic year are closed')
          expect(result.text).to include('Submit your application from 9am on 12 October 2021 for courses starting in the 2022 to 2023 academic year.')
        end
      end

      it 'renders the banner for an Apply 2 app' do
        configure_conditions_for_rendering_banner('apply_2')

        render_inline(
          described_class.new(phase: application_form.phase, flash_empty: flash.empty?),
        ) do |result|
          expect(result.text).to include('Applications for courses starting in the 2021 to 2022 academic year are closed')
          expect(result.text).to include('Submit your application from 9am on 12 October 2021 for courses starting in the 2022 to 2023 academic year.')
        end
      end
    end

    context 'after find opens' do
      before do
        TestSuiteTimeMachine.travel_permanently_to(CycleTimetable.find_reopens + 1.day)
      end

      it 'renders the banner for an Apply 1 app with the correct details' do
        configure_conditions_for_rendering_banner('apply_1')

        render_inline(
          described_class.new(phase: application_form.phase, flash_empty: flash.empty?),
        ) do |result|
          expect(result.text).to include('Applications for courses starting in the 2021 to 2022 academic year are closed')
          expect(result.text).to include('Submit your application from 9am on 12 October 2021 for courses starting in the 2022 to 2023 academic year.')
        end
      end

      it 'renders the banner for an Apply 2 app' do
        configure_conditions_for_rendering_banner('apply_2')

        render_inline(
          described_class.new(phase: application_form.phase, flash_empty: flash.empty?),
        ) do |result|
          expect(result.text).to include('Applications for courses starting in the 2021 to 2022 academic year are closed')
          expect(result.text).to include('Submit your application from 9am on 12 October 2021 for courses starting in the 2022 to 2023 academic year.')
        end
      end
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
