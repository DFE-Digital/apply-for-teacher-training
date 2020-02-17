RSpec.shared_examples 'validation for a start date' do |error_scope|
  describe 'start date' do
    it 'is invalid if not well-formed' do
      form = described_class.new(start_date_month: '99', start_date_year: '99')

      form.validate

      expect(form.errors.full_messages_for(:start_date)).to eq(
        ["Start date #{t("activemodel.errors.models.candidate_interface/#{error_scope}.attributes.start_date.invalid")}"],
      )
    end

    it 'is invalid if the date is after the end date' do
      form = described_class.new(
        start_date_month: '5', start_date_year: '2018',
        end_date_month: '5', end_date_year: '2017'
      )

      form.validate

      expect(form.errors.full_messages_for(:start_date)).to eq(
        ["Start date #{t("activemodel.errors.models.candidate_interface/#{error_scope}.attributes.start_date.before")}"],
      )
    end

    it 'is valid if the date is equal to the end date' do
      form = described_class.new(
        start_date_month: '5', start_date_year: '2018',
        end_date_month: '5', end_date_year: '2018'
      )

      form.validate

      expect(form.errors.full_messages_for(:start_date)).to be_empty
    end
  end
end
