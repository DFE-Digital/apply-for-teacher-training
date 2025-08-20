require 'rails_helper'

RSpec.describe SupportInterface::ApplicationsTableComponent do
  let(:previous_application) { create(:application_form, recruitment_cycle_year: current_year - 1) }
  let(:application_form_with_previous) { create(:application_form, updated_at: 1.day.ago, previous_application_form: previous_application) }
  let(:application_forms) { [application_form_with_previous] + create_list(:application_form, 3, updated_at: 1.day.ago) }

  it 'renders the carried over text for applications with previous applications' do
    # Since we removed apply_again concept, we now show "carried over" for applications with previous applications
    expect(render_result.text).to include("(#{current_year}, carried over)")
  end

  def render_result
    render_inline(described_class.new(application_forms:))
  end
end
