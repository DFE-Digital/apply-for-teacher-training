require 'rails_helper'

RSpec.describe SupportInterface::ApplicationsTableComponent do
  let(:application_form_apply_again) { create(:application_form, updated_at: 1.day.ago, phase: 'apply_2') }
  let(:application_forms) { [application_form_apply_again] + create_list(:application_form, 3, updated_at: 1.day.ago) }

  it 'renders the apply again text for the first application', recruitment_cycle: 2020 do
    expect(render_result.text).to include('(2020, apply again)')
  end

  def render_result
    render_inline(described_class.new(application_forms: application_forms))
  end
end
