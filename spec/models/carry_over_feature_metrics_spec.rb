require 'rails_helper'

RSpec.describe CarryOverFeatureMetrics, with_audited: true do
  subject(:feature_metrics) { described_class.new }

  def create_unsuccessful_application_from_last_cycle
    create(
      :completed_application_form,
      application_choices_count: 3,
      recruitment_cycle_year: RecruitmentCycle.previous_year,
    )
  end

  def create_carry_over_application(
    original_application = create_unsuccessful_application_from_last_cycle
  )
    carry_over_application_form = DuplicateApplication.new(
      original_application,
      target_phase: 'apply_1',
      recruitment_cycle_year: RecruitmentCycle.current_year,
    ).duplicate

    carry_over_application_form
  end

  describe '#carry_over_count' do
    context 'without any data' do
      it 'returns 0' do
        expect(feature_metrics.carry_over_count(1.month.ago)).to be(0)
      end
    end

    context 'with carried over applications' do
      it 'returns 0 when there are no carried over applications' do
        create_unsuccessful_application_from_last_cycle
        expect(feature_metrics.carry_over_count(1.month.ago)).to be(0)
      end

      it 'returns 1 when there is one carried over application' do
        create_carry_over_application
        expect(feature_metrics.carry_over_count(1.month.ago)).to be(1)
      end

      it 'returns the right counts when there are multiple carried over applications over time' do
        @today = Time.zone.local(2021, 3, 10, 12)
        Timecop.freeze(@today - 8.months) do
          @previous_application_forms = create_list(
            :completed_application_form,
            3,
            recruitment_cycle_year: 2020,
          )
        end
        Timecop.freeze(@today - 20.days) do
          create_carry_over_application(@previous_application_forms[0])
        end
        Timecop.freeze(@today - 5.days) do
          create_carry_over_application(@previous_application_forms[1])
        end
        Timecop.freeze(@today) do
          expect(feature_metrics.carry_over_count(25.days.ago, 10.days.ago)).to be(1)
          expect(feature_metrics.carry_over_count(10.days.ago)).to be(1)
          expect(feature_metrics.carry_over_count(25.days.ago)).to be(2)
        end
      end
    end
  end
end
