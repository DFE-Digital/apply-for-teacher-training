require 'rails_helper'

RSpec.describe SupportInterface::WorkHistoryBreakExport do
  describe '#data_for_export' do
    let(:candidate) { create(:candidate) }
    let(:application_form) do
      create(:completed_application_form,
             candidate: candidate,
             date_of_birth: Date.new(1982, 1, 1),
             submitted_at: Date.new(2020, 12, 31))
    end

    before do
      create(:application_choice, application_form: application_form, status: :offer)
    end

    describe 'creates the export data' do
      it 'excludes application forms without a date of birth' do
        create(:completed_application_form,
               candidate: create(:candidate),
               date_of_birth: nil,
               submitted_at: Date.new(2020, 12, 31))

        data = described_class.new.data_for_export
        expect(data.length).to eq(1)
      end

      it 'only takes data from a candidate’s latest application' do
        create(:completed_application_form,
               candidate: candidate,
               date_of_birth: Date.new(1982, 1, 1),
               submitted_at: Date.new(2019, 12, 31))

        data = described_class.new.data_for_export
        expect(data.length).to eq(1)
      end

      it 'creates an output with all the correct columns' do
        create(:application_work_experience,
               application_form: application_form,
               start_date: Date.new(2000, 1, 1),
               end_date: Date.new(2005, 12, 31))
        create(:application_work_history_break,
               application_form: application_form,
               start_date: Date.new(2006, 1, 1),
               end_date: Date.new(2007, 12, 31))

        expect(described_class.new.data_for_export).to contain_exactly(
          {
            'Candidate id' => candidate.id,
            'Application id' => application_form.id,
            'Application submitted' => Date.new(2020, 12, 31),
            'Course choice statuses' => %w[offer],
            'Start of working life' => Date.new(2000, 1, 1),
            'Total time in employment (months)' => 72,
            'Total time of explained breaks (months)' => 24,
            'Total time volunteering during explained breaks (months)' => 0,
            'Number of explained breaks' => 1,
            'Number of explained breaks in last 5 years' => 0,
            'Number of explained breaks that coincide with a volunteering experience' => 0,
            'Number of explained breaks that were over 50% volunteering' => 0,
            'Total time of unexplained breaks (months)' => 156,
            'Total time volunteering during unexplained breaks (months)' => 0,
            'Number of unexplained breaks' => 1,
            'Number of unexplained breaks in last 5 years' => 0,
            'Number of unexplained breaks that coincide with studying for a degree' => 0,
            'Number of unexplained breaks that coincide with a volunteering experience' => 0,
            'Number of unexplained breaks that were over 50% volunteering' => 0,
          },
        )
      end
    end

    describe 'creates explained breaks data' do
      it 'calculates details of explained breaks' do
        create(:application_work_history_break,
               application_form: application_form,
               start_date: Date.new(2000, 1, 1),
               end_date: Date.new(2000, 12, 31))
        create(:application_work_history_break,
               application_form: application_form,
               start_date: Date.new(2020, 1, 1),
               end_date: Date.new(2020, 12, 31))

        data = described_class.new.data_for_export[0]
        expect(data['Total time of explained breaks (months)']).to eq(24)
        expect(data['Number of explained breaks']).to eq(2)
        expect(data['Number of explained breaks in last 5 years']).to eq(1)
      end

      it 'counts explained breaks that coincide with volunteering experiences' do
        create(:application_work_experience,
               application_form: application_form,
               start_date: Date.new(2000, 1, 1),
               end_date: Date.new(2005, 12, 31))
        create(:application_work_experience,
               application_form: application_form,
               start_date: Date.new(2010, 1, 1),
               end_date: Date.new(2015, 12, 31))
        create(:application_work_history_break,
               application_form: application_form,
               reason: 'Volunteering',
               start_date: Date.new(2016, 1, 1),
               end_date: Date.new(2020, 12, 31))
        create(:application_volunteering_experience,
               application_form: application_form,
               start_date: Date.new(2017, 1, 1),
               end_date: Date.new(2020, 12, 31))

        data = described_class.new.data_for_export[0]
        expect(data['Total time of explained breaks (months)']).to eq(60)
        expect(data['Total time volunteering during explained breaks (months)']).to eq(48)
        expect(data['Number of explained breaks']).to eq(1)
        expect(data['Number of explained breaks that coincide with a volunteering experience']).to eq(1)
        expect(data['Number of explained breaks that were over 50% volunteering']).to eq(1)
      end
    end

    describe 'creates unexplained breaks data' do
      it 'calculates details of unexplained breaks' do
        create(:application_work_experience,
               application_form: application_form,
               start_date: Date.new(2010, 1, 1),
               end_date: Date.new(2019, 12, 31))

        data = described_class.new.data_for_export[0]
        expect(data['Total time of unexplained breaks (months)']).to eq(133)
        expect(data['Number of unexplained breaks']).to eq(2)
        expect(data['Number of unexplained breaks in last 5 years']).to eq(1)
      end

      it 'counts unexplained breaks that coincide with volunteering experiences' do
        create(:application_work_experience,
               application_form: application_form,
               start_date: Date.new(2005, 1, 1),
               end_date: Date.new(2010, 12, 31))
        create(:application_volunteering_experience,
               application_form: application_form,
               start_date: Date.new(2011, 1, 1),
               end_date: Date.new(2011, 12, 31))
        create(:application_work_experience,
               application_form: application_form,
               start_date: Date.new(2015, 1, 1),
               end_date: Date.new(2019, 12, 31))
        create(:application_volunteering_experience,
               application_form: application_form,
               start_date: Date.new(2020, 1, 1),
               end_date: Date.new(2020, 12, 31))

        data = described_class.new.data_for_export[0]
        expect(data['Total time of unexplained breaks (months)']).to eq(122)
        expect(data['Total time volunteering during unexplained breaks (months)']).to eq(23)
        expect(data['Number of unexplained breaks']).to eq(3)
        expect(data['Number of unexplained breaks that coincide with a volunteering experience']).to eq(2)
        expect(data['Number of unexplained breaks that were over 50% volunteering']).to eq(1)
      end

      it 'counts unexplained breaks that coincide with degrees' do
        create(:application_qualification,
               application_form: application_form,
               level: 'degree',
               start_year: 2000,
               award_year: 2003)
        create(:application_work_experience,
               application_form: application_form,
               start_date: Date.new(2010, 1, 1),
               end_date: Date.new(2015, 12, 31))

        data = described_class.new.data_for_export[0]
        expect(data['Number of unexplained breaks']).to eq(2)
        expect(data['Number of unexplained breaks that coincide with studying for a degree']).to eq(1)
      end
    end
  end
end
