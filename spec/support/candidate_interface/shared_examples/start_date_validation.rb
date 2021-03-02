RSpec.shared_examples 'validation for a start date' do |error_scope|
  describe 'start date' do
    it 'is invalid if the date is not present' do
      form = described_class.new(start_date_month: nil, start_date_year: nil)

      form.validate

      expected_message =
        if error_scope
          t("activemodel.errors.models.candidate_interface/#{error_scope}.attributes.start_date.blank_date")
        else
          t('errors.messages.blank_date', article: 'a', attribute: 'start date')
        end
      expect(form.errors.full_messages_for(:start_date)).to eq(
        ["Start date #{expected_message}"],
      )
    end

    it 'is invalid if not well-formed' do
      form = described_class.new(start_date_month: '99', start_date_year: '99')

      form.validate

      expect(form.errors.full_messages_for(:start_date)).to eq(
        ["Start date #{t('errors.messages.invalid_date_month_and_year', article: 'a', attribute: 'start date')}"],
      )
    end

    it 'is invalid if the date is after the end date' do
      form = described_class.new(
        start_date_month: '5', start_date_year: '2018',
        end_date_month: '5', end_date_year: '2017'
      )

      form.validate

      expected_message =
        if error_scope
          t("activemodel.errors.models.candidate_interface/#{error_scope}.attributes.start_date.before")
        else
          t('errors.messages.before')
        end
      expect(form.errors.full_messages_for(:start_date)).to eq(
        ["Start date #{expected_message}"],
      )
    end

    it 'is invalid if the date is after the time now' do
      Timecop.freeze(Time.zone.local(2020, 1, 1)) do
        form = described_class.new(
          start_date_month: '12', start_date_year: '2021',
        )

        form.validate

        expected_message =
          if error_scope
            t("activemodel.errors.models.candidate_interface/#{error_scope}.attributes.start_date.future")
          else
            t('errors.messages.future', article: 'a', attribute: 'start date')
          end

        expect(form.errors.full_messages_for(:start_date)).to eq(
          ["Start date #{expected_message}"],
        )
      end
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
