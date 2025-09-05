require 'rails_helper'

RSpec.describe CandidateInterface::ReopenBannerComponent do
  subject(:rendered_component) { render_inline(described_class.new(flash_empty: flash_empty, application_form: application_form)) }

  let(:application_form) { build_stubbed(:application_form, recruitment_cycle_year: 2025) }

  context 'after the apply deadline and the flash is empty', time: after_apply_deadline(2025) do
    let(:flash_empty) { true }

    it { is_expected.to have_content('The application deadline has passed') }
    it { is_expected.to have_content('The application deadline has passed for courses starting in the 2025 to 2026 academic year.') }
    it { is_expected.to have_content('From 9am UK time on 7 October 2025 you will be able to apply for courses starting in the 2026 to 2027 academic year.') }
  end

  context 'before the apply deadline and flash is empty', time: mid_cycle(2025) do
    let(:flash_empty) { true }

    subject { rendered_component.text }

    it { is_expected.to be_blank }
  end

  context 'before the apply deadline and flash is not empty', time: after_apply_deadline(2025) do
    let(:flash_empty) { false }

    subject { rendered_component.text }

    it { is_expected.to be_blank }
  end
end
