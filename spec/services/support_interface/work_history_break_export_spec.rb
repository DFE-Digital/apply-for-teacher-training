require 'rails_helper'

RSpec.describe SupportInterface::WorkHistoryBreakExport do
  describe '#data_for_export' do
    let(:candidate) { build(:candidate) }
    let(:application_form) do
      build(:completed_application_form,
            candidate: candidate,
            date_of_birth: Date.new(1982, 1, 1),
            submitted_at: Date.new(2020, 12, 31))
    end

    before do
      create(:application_choice, application_form: application_form, status: :offer)
    end

    describe 'documentation' do
      before do
        create(:application_work_experience,
               application_form: application_form,
               start_date: Date.new(2000, 1, 1),
               end_date: Date.new(2005, 12, 31))
        create(:application_work_history_break,
               application_form: application_form,
               start_date: Date.new(2006, 1, 1),
               end_date: Date.new(2007, 12, 31))
      end

      it_behaves_like 'a data export'
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
            candidate_id: candidate.id,
            application_form_id: application_form.id,
            submitted_at: Time.zone.local(2020, 12, 31, 0, 0, 0).iso8601,
            course_choice_statuses: %w[offer],
            start_of_working_life: Time.zone.local(2000, 1, 1, 0, 0, 0).iso8601,
            total_time_in_employment: 72,
            total_time_of_explained_breaks: 24,
            total_time_volunteering_during_explained_breaks: 0,
            number_of_explained_breaks: 1,
            number_of_explained_breaks_in_last_five_years: 0,
            number_of_explained_breaks_that_coincide_with_a_volunteering_experience: 0,
            number_of_explained_breaks_that_were_over_fifty_percent_volunteering: 0,
            total_time_of_unexplained_breaks: 156,
            total_time_volunteering_during_unexplained_breaks: 0,
            number_of_unexplained_breaks: 1,
            number_of_unexplained_breaks_in_last_five_years: 0,
            number_of_unexplained_breaks_that_coincide_with_studying_for_a_degree: 0,
            number_of_unexplained_breaks_that_coincide_with_a_volunteering_experience: 0,
            number_of_unexplained_breaks_that_were_over_fifty_percent_volunteering: 0,
          },
        )
      end
    end

    describe 'end date calculations' do
      it 'uses today’s date for submission date if application form is unsubmitted' do
        create(:completed_application_form,
               candidate: candidate,
               date_of_birth: Date.new(1982, 1, 1),
               submitted_at: nil)

        data = described_class.new.data_for_export[0]
        expect(data[:submitted_at]).to eq(Time.zone.now.iso8601)
      end

      it 'uses application submitted date for experience end date if experience is ongoing' do
        create(:application_work_experience,
               application_form: application_form,
               start_date: Date.new(2000, 1, 1),
               end_date: nil)

        data = described_class.new.data_for_export[0]
        expect(data[:total_time_in_employment]).to eq(252)
      end

      it 'uses today’s date for experience end date if experience is ongoing and application form is unsubmitted' do
        new_application_form = create(:completed_application_form,
                                      candidate: candidate,
                                      date_of_birth: Date.new(1982, 1, 1),
                                      submitted_at: nil)

        create(:application_work_experience,
               application_form: new_application_form,
               start_date: Date.new(2000, 1, 1),
               end_date: nil)

        expected_number_of_months = (((Time.zone.now - Time.zone.local(2000, 1, 1, 0, 0, 0))) / ActiveSupport::Duration::SECONDS_PER_MONTH).round
        data = described_class.new.data_for_export[0]
        expect(data[:total_time_in_employment]).to eq(expected_number_of_months)
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
        expect(data[:total_time_of_explained_breaks]).to eq(24)
        expect(data[:number_of_explained_breaks]).to eq(2)
        expect(data[:number_of_explained_breaks_in_last_five_years]).to eq(1)
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
        expect(data[:total_time_of_explained_breaks]).to eq(60)
        expect(data[:total_time_volunteering_during_explained_breaks]).to eq(48)
        expect(data[:number_of_explained_breaks]).to eq(1)
        expect(data[:number_of_explained_breaks_that_coincide_with_a_volunteering_experience]).to eq(1)
        expect(data[:number_of_explained_breaks_that_were_over_fifty_percent_volunteering]).to eq(1)
      end
    end

    describe 'creates unexplained breaks data' do
      it 'calculates details of unexplained breaks' do
        create(:application_work_experience,
               application_form: application_form,
               start_date: Date.new(2010, 1, 1),
               end_date: Date.new(2019, 12, 31))

        data = described_class.new.data_for_export[0]
        expect(data[:total_time_of_unexplained_breaks]).to eq(133)
        expect(data[:number_of_unexplained_breaks]).to eq(2)
        expect(data[:number_of_unexplained_breaks_in_last_five_years]).to eq(1)
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
        expect(data[:total_time_of_unexplained_breaks]).to eq(122)
        expect(data[:total_time_volunteering_during_unexplained_breaks]).to eq(23)
        expect(data[:number_of_unexplained_breaks]).to eq(3)
        expect(data[:number_of_unexplained_breaks_that_coincide_with_a_volunteering_experience]).to eq(2)
        expect(data[:number_of_unexplained_breaks_that_were_over_fifty_percent_volunteering]).to eq(1)
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
        expect(data[:number_of_unexplained_breaks]).to eq(2)
        expect(data[:number_of_unexplained_breaks_that_coincide_with_studying_for_a_degree]).to eq(1)
      end
    end
  end
end
