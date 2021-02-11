RSpec.shared_examples 'validation for an end date that cannot be blank' do |error_scope|
  describe 'end date' do
    it 'is invalid if left completely blank' do
      form = described_class.new(end_date_month: '', end_date_year: '')

      form.validate

      expect(form.errors.full_messages_for(:end_date)).to eq(
        ["End date #{t('errors.messages.blank_date', article: 'an', attribute: 'end date')}"],
      )
    end

    include_examples 'validation for an end date', error_scope
  end
end

RSpec.shared_examples 'validation for an end date that can be blank' do |error_scope|
  describe 'end date' do
    it 'is valid if left completely blank' do
      form = described_class.new(end_date_month: '', end_date_year: '')

      form.validate

      expect(form.errors.full_messages_for(:end_date)).to be_empty
    end

    include_examples 'validation for an end date', error_scope
  end
end

RSpec.shared_examples 'validation for an end date' do |_|
  it 'is invalid if month left blank' do
    form = described_class.new(end_date_month: '', end_date_year: '2019')

    form.validate

    expect(form.errors.full_messages_for(:end_date)).to eq(
      ["End date #{t('errors.messages.blank_date_fields', attribute: 'end date', fields: 'month')}"],
    )
  end

  it 'is invalid if year left blank' do
    form = described_class.new(end_date_month: '5', end_date_year: '')

    form.validate

    expect(form.errors.full_messages_for(:end_date)).to eq(
      ["End date #{t('errors.messages.blank_date_fields', attribute: 'end date', fields: 'year')}"],
    )
  end

  it 'is invalid if not well-formed' do
    form = described_class.new(end_date_month: '99', end_date_year: '2019')

    form.validate

    expect(form.errors.full_messages_for(:end_date)).to eq(
      ["End date #{t('errors.messages.invalid_date_month_and_year', article: 'an', attribute: 'end date')}"],
    )
  end

  it 'is invalid if year is beyond the current year' do
    Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 0)) do
      form = described_class.new(end_date_month: '1', end_date_year: '2029')

      form.validate

      expect(form.errors.full_messages_for(:end_date)).to eq(
        ["End date #{t('errors.messages.future', article: 'an', attribute: 'end date')}"],
      )
    end
  end

  it 'is invalid if year is the current year but month is after the current month' do
    Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 0)) do
      form = described_class.new(end_date_month: '11', end_date_year: '2019')

      form.validate

      expect(form.errors.full_messages_for(:end_date)).to eq(
        ["End date #{t('errors.messages.future', article: 'an', attribute: 'end date')}"],
      )
    end
  end

  it 'is valid if year and month are before the current year and month' do
    Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 0)) do
      form = described_class.new(end_date_month: '9', end_date_year: '2019')

      form.validate

      expect(form.errors.full_messages_for(:end_date)).to be_empty
    end
  end
end
