require 'rails_helper'

RSpec.describe SupportInterface::CandidatesTableComponent do
  let(:application_forms) { create_list(:application_form, 4, updated_at: 1.day.ago) }
  let(:candidates) { application_forms.map(&:candidate) }

  it 'renders the candidate emails' do
    candidates.collect(&:email_address).each do |email_address|
      expect(render_result.text).to include(email_address)
    end
  end

  def render_result
    render_inline(described_class.new(candidates:))
  end
end
