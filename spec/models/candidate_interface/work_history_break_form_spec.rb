require 'rails_helper'

RSpec.describe CandidateInterface::WorkHistoryBreakForm, type: :model do
  let(:data) do
    {
      start_date: Time.zone.local(2018, 5, 1),
      end_date: Time.zone.local(2019, 5, 1),
      reason: Faker::Lorem.sentence(word_count: 400),
    }
  end

  let(:form_data) do
    {
      start_date_month: data[:start_date].month,
      start_date_year: data[:start_date].year,
      end_date_month: data[:end_date].month,
      end_date_year: data[:end_date].year,
      reason: data[:reason],
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:reason) }

    okay_text = Faker::Lorem.sentence(word_count: 400)
    long_text = Faker::Lorem.sentence(word_count: 401)

    it { is_expected.to allow_value(okay_text).for(:reason) }
    it { is_expected.not_to allow_value(long_text).for(:reason) }

    include_examples 'validation for a start and end date', 'work_history_break_form'
  end

  describe '.build_from_break' do
    it 'creates an object based on the work history break' do
      application_work_history_break = build_stubbed(:application_work_history_break, attributes: data)
      work_break = CandidateInterface::WorkHistoryBreakForm.build_from_break(
        application_work_history_break,
      )

      expect(work_break).to have_attributes(form_data)
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      work_break = CandidateInterface::WorkHistoryBreakForm.new

      expect(work_break.save(ApplicationForm.new)).to eq(false)
    end

    it 'creates a new work experience if valid' do
      application_form = create(:application_form)
      work_break = CandidateInterface::WorkHistoryBreakForm.new(form_data)

      saved_work_break = work_break.save(application_form)

      expect(saved_work_break).to have_attributes(data)
    end
  end

  describe '#update' do
    it 'returns false if not valid' do
      work_break = CandidateInterface::WorkHistoryBreakForm.new

      expect(work_break.save(ApplicationForm.new)).to eq(false)
    end

    it 'updates work history break if valid' do
      application_work_history_break = create(
        :application_work_history_break,
        application_form: create(:application_form),
        attributes: data,
      )
      work_break = CandidateInterface::WorkHistoryBreakForm.new(form_data)
      work_break.reason = 'Updated reason.'

      work_break.update(application_work_history_break)

      expect(application_work_history_break.reason).to eq('Updated reason.')
    end
  end
end
