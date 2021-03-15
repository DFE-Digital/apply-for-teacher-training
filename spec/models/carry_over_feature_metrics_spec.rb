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
      it 'returns 0 when there are no successful carried over applications' do
        create_unsuccessful_application_from_last_cycle
        expect(feature_metrics.carry_over_count(1.month.ago)).to be(0)
      end

      it 'returns 1 when there is one carried over application' do
        create_carry_over_application
        expect(feature_metrics.carry_over_count(1.month.ago)).to be(1)
      end
    end
  end
end
