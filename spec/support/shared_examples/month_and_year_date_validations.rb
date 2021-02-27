RSpec.shared_examples 'month and year date validations' do |date_field, validations|
  include DateAndYearConcerns

  let("#{date_field}_day".to_sym) { date.day }
  let("#{date_field}_month".to_sym) { date.month }
  let("#{date_field}_year".to_sym) { date.year }

  describe 'when in the future', if: validations[:future] do
    let(:date) { 40.years.from_now }

    it 'returns :future error' do
      expect(model).to be_invalid

      expect(model.errors.added?(date_field,
                                 :future,
                                 article: article(date_field),
                                 attribute: humanize(date_field))).to eq(true)
    end
  end

  describe 'when not present', if: validations[:verify_presence] do
    let(:date) { Struct.new(:day, :month, :year).new(nil, nil, nil) }

    it 'returns :blank_date error' do
      expect(model).to be_invalid

      expect(model.errors.added?(date_field,
                                 :blank_date,
                                 article: article(date_field),
                                 attribute: humanize(date_field))).to eq(true)
    end
  end

  describe 'when invalid' do
    let(:date) { Date.new(1700, 5, 1) }

    it 'returns :invalid_date_month_and_year error' do
      expect(model).to be_invalid

      expect(model.errors.added?(date_field,
                                 :invalid_date_month_and_year,
                                 article: article(date_field),
                                 attribute: humanize(date_field))).to eq(true)
    end
  end

  describe 'when information is missing' do
    let(:date) { Struct.new(:day, :month, :year).new(nil, 2, nil) }

    it 'returns :blank_date_fields error' do
      expect(model).to be_invalid

      expect(model.errors.added?(date_field,
                                 :blank_date_fields,
                                 attribute: humanize(date_field),
                                 fields: 'year')).to eq(true)
    end
  end
end
