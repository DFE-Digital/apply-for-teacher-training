require 'rails_helper'

RSpec.describe SupportInterface::CandidatesTableComponent do
  let(:application_form_apply_again) { create(:application_form, updated_at: 1.day.ago, phase: 'apply_2') }
  let(:application_forms) { create_list(:application_form, 3, updated_at: 1.day.ago) }
  let(:candidates) { ([application_form_apply_again] + application_forms).map(&:candidate) }

  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  it 'renders the candidate emails' do
    candidates.collect(&:email_address).each do |email_address|
      expect(render_result.text).to include(email_address)
    end
  end

  it 'renders the apply again text for the first application' do
    expect(render_result.css('td').first.text).to include('Apply again')
  end

  def render_result
    render_inline(described_class.new(candidates: candidates))
  end
end
