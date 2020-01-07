require 'rails_helper'

RSpec.describe SupportInterface::CandidatesTableComponent do
  let(:today) { Time.zone.local(2020, 1, 7, 12, 0, 0) }

  let(:application_forms) { create_list(:application_form, 3, updated_at: 1.day.ago) }
  let(:candidates) { application_forms.map(&:candidate) }

  around do |example|
    Timecop.freeze(today) do
      example.run
    end
  end

  subject(:component) { described_class.new(candidates: candidates) }

  it 'renders the candidate emails' do
    candidates.collect(&:email_address).each do |email_address|
      expect(render_result.text).to include(email_address)
    end
  end

  it 'renders the date last updated' do
    expect(render_result.text).to include(application_forms.first.updated_at.to_s(:govuk_date_and_time))
  end

  def render_result
    render_inline(described_class, candidates: candidates)
  end
end
