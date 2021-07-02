require 'rails_helper'

RSpec.describe SupportInterface::AuditTrailItemComponent::AuditTrailChange do
  def change(values:, attribute: 'default')
    described_class.new(
      attribute: attribute,
      values: values,
    )
  end

  it 'renders an update application form audit record' do
    expect(change(values: %w[old new]).formatted_values).to match(/old → new/)
  end

  it 'renders an update with an initial nil value' do
    expect(change(values: [nil, 'first']).formatted_values).to match(/nil → first/)
  end

  it 'renders an create with a single value' do
    expect(change(values: 'only_one').formatted_values).to match(/only_one/)
  end

  it 'renders an update with hash values' do
    expect(change(values: [{ 'fox' => 'in socks' }, { 'cat' => 'in hat' }]).formatted_values).to include('{"fox"=>"in socks"} → {"cat"=>"in hat"}')
  end

  it 'renders an update with an integer value' do
    expect(change(values: [nil, 40]).formatted_values).to include('40')
  end

  it 'renders a create with a hash value' do
    expect(change(values: { 'fox' => 'in socks' }).formatted_values).to eq('{"fox"=>"in socks"}')
  end

  describe 'redaction' do
    it 'redacts sensitive information on creates' do
      expect(change(values: { 'sex' => 'male' }).formatted_values).to eq('{"sex"=>"[REDACTED]"}')
    end

    it 'redacts sensitive information on updates' do
      expect(change(values: [{ 'sex' => 'male' }, { 'sex' => 'male', 'disabilities' => [] }]).formatted_values)
        .to include('{"sex"=>"[REDACTED]"} → {"sex"=>"[REDACTED]", "disabilities"=>"[REDACTED]"}')
    end

    it 'redacts top level keys as well as nested hashes' do
      expect(change(attribute: 'sex', values: [nil, 'male']).formatted_values)
        .to include('[REDACTED]')
    end

    it 'redacts HESA codes for sensitive information' do
      expect(change(values: [{ 'hesa_sex' => 2 }, { 'hesa_sex' => 2, 'hesa_ethnicity' => 32 }]).formatted_values)
        .to include('{"hesa_sex"=>"[REDACTED]"} → {"hesa_sex"=>"[REDACTED]", "hesa_ethnicity"=>"[REDACTED]"}')
    end
  end
end
