RSpec.shared_examples 'year validations' do |year_field, validations|
  include DateAndYearConcerns

  let(year_field.to_sym) { year }

  describe 'when invalid' do
    context 'when year is not a number' do
      let(:year) { 'A950' }

      it 'returns :invalid_date_month_and_year error' do
        expect(model).to be_invalid

        expect(model.errors.added?(year_field, :invalid_year, attribute: humanize(year_field))).to eq(true)
      end
    end

    context 'when year is outside the acceptable year range' do
      let(:year) { '1850' }

      it 'returns :invalid_year error' do
        expect(model).to be_invalid

        expect(model.errors.added?(year_field, :invalid_year, attribute: humanize(year_field))).to eq(true)
      end
    end
  end

  describe 'when in the future', if: validations && validations[:future] do
    let(:year) { 40.years.from_now.year }

    it 'returns :future error' do
      expect(model).to be_invalid

      expect(model.errors.added?(year_field, :future, article: article(year_field), attribute: humanize(year_field))).to eq(true)
    end
  end
end
