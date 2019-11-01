require 'rails_helper'

RSpec.describe SupportInterface::AuditTrailChangeComponent do
  def render_result(attribute: 'title', values: %w[old new])
    @render_result ||= render_inline(
      described_class,
      attribute: attribute,
      values: values,
      last_change: false,
    )
  end

  it 'renders an update application form audit record' do
    expect(render_result.text).to match(/title\s*old → new/m)
  end

  it 'renders an update with an initial nil value' do
    expect(render_result(values: [nil, 'first']).text).to match(/title\s*nil → first/m)
  end

  it 'renders an create with a single value' do
    expect(render_result(values: 'only_one').text).to match(/title\s*only_one/m)
  end
end
