require 'rails_helper'

RSpec.describe SupportInterface::AuditTrailChangeComponent do
  def render_result(attribute: 'title', values: %w[old new])
    @render_result ||= render_inline(
      described_class.new(
        attribute: attribute,
        values: values,
        last_change: false,
      ),
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

  it 'renders an update with hash values' do
    expect(render_result(values: [{ 'fox' => 'in socks' }, { 'cat' => 'in hat' }]).text).to include('{"fox"=>"in socks"} → {"cat"=>"in hat"}')
  end

  it 'renders an update with an integer value' do
    expect(render_result(values: [nil, 40]).text).to include('40')
  end

  it 'renders a create with a hash value' do
    expect(render_result(values: { 'fox' => 'in socks' }).text).to include('{"fox"=>"in socks"}')
  end

  describe 'redaction' do
    it 'redacts sensitive information on creates' do
      expect(render_result(values: { 'sex' => 'male' }).text).to include('{"sex"=>"[REDACTED]"}')
    end

    it 'redacts sensitive information on updates' do
      expect(render_result(values: [{ 'sex' => 'male' }, { 'sex' => 'male', 'disabilities' => [] }]).text)
        .to include('{"sex"=>"[REDACTED]"} → {"sex"=>"[REDACTED]", "disabilities"=>"[REDACTED]"}')
    end

    it 'redacts top level keys as well as nested hashes' do
      expect(render_result(attribute: 'sex', values: [nil, 'male']).text)
        .to include('[REDACTED]')
    end

    it 'redacts HESA codes for sensitive information' do
      expect(render_result(values: [{ 'hesa_sex' => 2 }, { 'hesa_sex' => 2, 'hesa_ethnicity' => 32 }]).text)
        .to include('{"hesa_sex"=>"[REDACTED]"} → {"hesa_sex"=>"[REDACTED]", "hesa_ethnicity"=>"[REDACTED]"}')
    end
  end
end
