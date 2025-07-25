require 'rails_helper'

RSpec.describe Publications::ITTMonthlyReportGenerator do
  include DfE::Bigquery::TestHelper

  let(:cycle_week) { 7 }
  let(:candidate_headline_statistics) do
    {
      cycle_week:,
      first_date_in_week: Date.new(2023, 11, 13),
      last_date_in_week: Date.new(2023, 11, 19),
      number_of_candidates_accepted_to_date: 538,
      number_of_candidates_accepted_to_same_date_previous_cycle: 478,
      number_of_candidates_submitted_to_date: 8586,
      number_of_candidates_submitted_to_same_date_previous_cycle: 5160,
      number_of_candidates_who_did_not_meet_any_offer_conditions_this_cycle_to_date: 0,
      number_of_candidates_who_did_not_meet_any_offer_conditions_this_cycle_to_same_date_previous_cycle: 1,
      number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date: 246,
      number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle: 131,
      number_of_candidates_with_all_accepted_offers_withdrawn_this_cycle_to_date: 7,
      number_of_candidates_with_all_accepted_offers_withdrawn_this_cycle_to_same_date_previous_cycle: 6,
      number_of_candidates_with_deferred_offers_from_this_cycle_to_date: 0,
      number_of_candidates_with_deferred_offers_from_this_cycle_to_same_date_previous_cycle: 0,
      number_of_candidates_with_offers_to_date: 598,
      number_of_candidates_with_offers_to_same_date_previous_cycle: 567,
      number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date: 285,
      number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle: 213,
    }
  end
  let(:age_group) { application_metrics_results.first }
  let(:sex) { age_group.dup.merge(nonsubject_filter: 'Male') }
  let(:area) { age_group.dup.merge(nonsubject_filter: 'Gondor') }
  let(:phase) { age_group.dup.merge(subject_filter: 'Primary') }
  let(:route_into_teaching) { age_group.dup.merge(nonsubject_filter: 'Higher education') }
  let(:primary_subject) { age_group.dup.merge(subject_filter: 'Primary with English') }
  let(:secondary_subject) { age_group.dup.merge(subject_filter: 'Drama') }
  let(:provider_region) { age_group.dup.merge(nonsubject_filter: 'Hogsmeade') }
  let(:first_provider_region_and_subject) do
    age_group.dup.merge(
      nonsubject_filter: 'Fangorn Forest',
      subject_filter: 'Geography',
    )
  end
  let(:second_provider_region_and_subject) do
    age_group.dup.merge(
      nonsubject_filter: 'Fangorn Forest',
      subject_filter: 'History',
    )
  end
  let(:third_provider_region_and_subject) do
    age_group.dup.merge(
      nonsubject_filter: 'Fangorn Forest',
      subject_filter: 'Music',
    )
  end
  let(:first_candidate_area_and_subject) do
    age_group.dup.merge(
      nonsubject_filter: 'Isengard',
      subject_filter: 'Drama',
    )
  end
  let(:second_candidate_area_and_subject) do
    age_group.dup.merge(
      nonsubject_filter: 'Isengard',
      subject_filter: 'Primary with Mathematics',
    )
  end
  let(:third_candidate_area_and_subject) do
    age_group.dup.merge(
      nonsubject_filter: 'Isengard',
      subject_filter: 'Mathematics',
    )
  end

  before do
    stub_bigquery_application_metrics_request(rows: [[
      { name: 'nonprovider_filter', type: 'INTEGER', value: 'Primary' },
      { name: 'nonprovider_filter_category', type: 'INTEGER', value: nil },
      { name: 'cycle_week', type: 'INTEGER', value: cycle_week.to_s },
      { name: 'id', type: 'INTEGER', value: nil },
    ]])
  end

  describe '#generation_date' do
    context 'when passing in initialize' do
      it 'returns custom generation date' do
        generation_date = 1.week.ago
        expect(described_class.new(generation_date:).generation_date).to eq(generation_date)
      end
    end

    context 'when not passing in initialize' do
      it 'returns current date' do
        generation_date = Time.zone.now

        travel_temporarily_to(generation_date, freeze: true) do
          expect(described_class.new.generation_date).to eq(generation_date)
        end
      end
    end
  end

  describe '#publication_date' do
    context 'when passing in initialize' do
      it 'returns custom publication date' do
        publication_date = 1.week.ago
        expect(described_class.new(publication_date:).publication_date).to eq(publication_date)
      end
    end

    context 'when not passing in initialize' do
      it 'returns 1 week after generation date' do
        generation_date = Time.zone.local(2023, 11, 20)

        travel_temporarily_to(generation_date, freeze: true) do
          expect(described_class.new.publication_date).to eq(generation_date + 1.week)
        end
      end
    end
  end

  describe '#report_expected_time' do
    it 'returns the last Sunday of the expected generation time' do
      generation_date = Time.zone.local(2023, 11, 8)
      expect(described_class.new(generation_date:).report_expected_time).to eq(Time.zone.local(2023, 11, 5))
    end
  end

  describe '#cycle_week' do
    context 'when first cycle week' do
      it 'returns one' do
        generation_date = Time.zone.local(2023, 10, 9)
        expect(described_class.new(generation_date:).cycle_week).to be 1
      end
    end

    context 'when mid cycle' do
      it 'returns the number of weeks' do
        generation_date = Time.zone.local(2023, 11, 20)
        expect(described_class.new(generation_date:).cycle_week).to be 7
      end
    end

    context 'when last cycle week' do
      it 'returns 52' do
        generation_date = Time.zone.local(2024, 9, 30)
        expect(described_class.new(generation_date:).cycle_week).to be 52
      end
    end
  end

  describe '#month' do
    context 'when passing generation date in initialize' do
      it 'returns month of the generation date' do
        generation_date = Time.zone.local(2023, 12, 23)
        expect(described_class.new(generation_date:).month).to eq('2023-12')
      end
    end

    context 'when not passing in initialize' do
      it 'returns current date' do
        generation_date = Time.zone.local(2024, 1, 25)

        travel_temporarily_to(generation_date, freeze: true) do
          expect(described_class.new.month).to eq('2024-01')
        end
      end
    end
  end

  describe '#call' do
    let(:generation_date) { Time.zone.local(2024, 1, 15) }
    let(:publication_date) { Time.zone.local(2024, 1, 22) }

    before do
      stub_application_metrics(cycle_week: 15)
      TestSuiteTimeMachine.travel_permanently_to(Time.zone.local(2024, 1, 15))
    end

    it 'creates monthly statistics report' do
      expect {
        described_class.new(generation_date:, publication_date:).call
      }.to change { Publications::MonthlyStatistics::MonthlyStatisticsReport.count }.by(1)
    end

    it 'saves the expected attributes' do
      model = described_class.new(generation_date:, publication_date:).call

      expect(model.generation_date).to eq(generation_date)
      expect(model.publication_date).to eq(publication_date)
      expect(model.month).to eq('2024-01')
      expect(model.statistics.keys).to eq(%w[meta data formats])
      expect(model.statistics['data'].keys).to eq(%w[
        candidate_headline_statistics
        candidate_age_group
        candidate_sex
        candidate_area
        candidate_phase
        candidate_route_into_teaching
        candidate_primary_subject
        candidate_secondary_subject
        candidate_provider_region
        candidate_provider_region_and_subject
        candidate_area_and_subject
      ])
    end
  end

  describe '#to_h' do
    before do
      TestSuiteTimeMachine.travel_permanently_to(Time.zone.local(2024, 1, 15))
      stub_application_metrics(cycle_week: 7)
    end

    subject(:report) do
      described_class.new(generation_date:).to_h
    end

    let(:generation_date) { Time.zone.local(2023, 11, 22) }
    let(:publication_date) { generation_date + 1.week }

    it 'returns meta information' do
      expect(report[:meta]).to eq({
        generation_date:,
        publication_date:,
        period: 'From 2 October 2023 to 19 November 2023',
        cycle_week: 7,
        month: '2023-11',
      })
    end

    it 'returns candidate headline statistics (ignoring status less than 3 records)' do
      expect(report[:data][:candidate_headline_statistics]).to eq({
        title: 'Candidate Headline statistics',
        subtitle: 'Headline Statistics',
        data: {
          submitted: {
            title: 'Submitted',
            this_cycle: 8586,
            last_cycle: 5160,
          },
          with_offers: {
            title: 'With offers',
            this_cycle: 598,
            last_cycle: 567,
          },
          accepted: {
            title: 'Accepted',
            this_cycle: 538,
            last_cycle: 478,
          },
          rejected: {
            title: 'All applications rejected',
            this_cycle: 246,
            last_cycle: 131,
          },
          reconfirmed: {
            title: 'Reconfirmed from previous cycle',
            this_cycle: 285,
            last_cycle: 213,
          },
          withdrawn: {
            title: 'Withdrawn',
            this_cycle: 7,
            last_cycle: 6,
          },
        },
      })
    end

    it 'returns age group' do
      expect(report[:data][:candidate_age_group]).to eq({
        title: 'Candidate statistics by age group',
        subtitle: 'Age Group',
        data: {
          submitted: [
            {
              title: '21',
              this_cycle: 400,
              last_cycle: 200,
            },
          ],
          with_offers: [
            {
              title: '21',
              this_cycle: 598,
              last_cycle: 567,
            },
          ],
          accepted: [
            {
              title: '21',
              this_cycle: 20,
              last_cycle: 10,
            },
          ],
          rejected: [
            {
              title: '21',
              this_cycle: 100,
              last_cycle: 50,
            },
          ],
          reconfirmed: [
            {
              title: '21',
              this_cycle: 285,
              last_cycle: 213,
            },
          ],
          withdrawn: [
            {
              title: '21',
              this_cycle: 200,
              last_cycle: 100,
            },
          ],
        },
      })
    end

    it 'returns sex data (ignoring status less than 3 records)' do
      expect(report[:data][:candidate_sex]).to eq(
        {
          title: 'Candidate statistics by sex',
          subtitle: 'Sex',
          data: {
            submitted: [
              {
                title: 'Male',
                this_cycle: 400,
                last_cycle: 200,
              },
            ],
            with_offers: [
              {
                title: 'Male',
                this_cycle: 598,
                last_cycle: 567,
              },
            ],
            accepted: [
              {
                title: 'Male',
                this_cycle: 20,
                last_cycle: 10,
              },
            ],
            rejected: [
              {
                title: 'Male',
                this_cycle: 100,
                last_cycle: 50,
              },
            ],
            reconfirmed: [
              {
                title: 'Male',
                this_cycle: 285,
                last_cycle: 213,
              },
            ],
            withdrawn: [
              {
                title: 'Male',
                this_cycle: 200,
                last_cycle: 100,
              },
            ],
          },
        },
      )
    end

    it 'returns area data (ignoring status less than 3 records)' do
      expect(report[:data][:candidate_area]).to eq(
        {
          title: 'Candidate statistics by UK region or country, or other area',
          subtitle: 'Area',
          data: {
            submitted: [
              {
                title: 'Gondor',
                this_cycle: 400,
                last_cycle: 200,
              },
            ],
            with_offers: [
              {
                title: 'Gondor',
                this_cycle: 598,
                last_cycle: 567,
              },
            ],
            accepted: [
              {
                title: 'Gondor',
                this_cycle: 20,
                last_cycle: 10,
              },
            ],
            rejected: [
              {
                title: 'Gondor',
                this_cycle: 100,
                last_cycle: 50,
              },
            ],
            reconfirmed: [
              {
                title: 'Gondor',
                this_cycle: 285,
                last_cycle: 213,
              },
            ],
            withdrawn: [
              {
                title: 'Gondor',
                this_cycle: 200,
                last_cycle: 100,
              },
            ],
          },
        },
      )
    end

    it 'returns phase data (ignoring status less than 3 records)' do
      expect(report[:data][:candidate_phase]).to eq(
        {
          title: 'Candidate statistics by course phase',
          subtitle: 'Course Phase',
          data: {
            submitted: [
              {
                title: 'Primary',
                this_cycle: 400,
                last_cycle: 200,
              },
            ],
            with_offers: [
              {
                title: 'Primary',
                this_cycle: 598,
                last_cycle: 567,
              },
            ],
            accepted: [
              {
                title: 'Primary',
                this_cycle: 20,
                last_cycle: 10,
              },
            ],
            rejected: [
              {
                title: 'Primary',
                this_cycle: 100,
                last_cycle: 50,
              },
            ],
            reconfirmed: [
              {
                title: 'Primary',
                this_cycle: 285,
                last_cycle: 213,
              },
            ],
            withdrawn: [
              {
                title: 'Primary',
                this_cycle: 200,
                last_cycle: 100,
              },
            ],
          },
        },
      )
    end

    it 'returns route into teaching data (ignoring status less than 3 records)' do
      expect(report[:data][:candidate_route_into_teaching]).to eq(
        {
          title: 'Candidate statistics by route into teaching',
          subtitle: 'Course type',
          data: {
            submitted: [
              {
                title: 'Higher education',
                this_cycle: 400,
                last_cycle: 200,
              },
            ],
            with_offers: [
              {
                title: 'Higher education',
                this_cycle: 598,
                last_cycle: 567,
              },
            ],
            accepted: [
              {
                title: 'Higher education',
                this_cycle: 20,
                last_cycle: 10,
              },
            ],
            rejected: [
              {
                title: 'Higher education',
                this_cycle: 100,
                last_cycle: 50,
              },
            ],
            reconfirmed: [
              {
                title: 'Higher education',
                this_cycle: 285,
                last_cycle: 213,
              },
            ],
            withdrawn: [
              {
                title: 'Higher education',
                this_cycle: 200,
                last_cycle: 100,
              },
            ],
          },
        },
      )
    end

    it 'returns primary subject data (ignoring status less than 3 records)' do
      expect(report[:data][:candidate_primary_subject]).to eq(
        {
          title: 'Candidate statistics by primary specialist subject',
          subtitle: 'Subject',
          data: {
            submitted: [
              {
                title: 'Primary with English',
                this_cycle: 400,
                last_cycle: 200,
              },
            ],
            with_offers: [
              {
                title: 'Primary with English',
                this_cycle: 598,
                last_cycle: 567,
              },
            ],
            accepted: [
              {
                title: 'Primary with English',
                this_cycle: 20,
                last_cycle: 10,
              },
            ],
            rejected: [
              {
                title: 'Primary with English',
                this_cycle: 100,
                last_cycle: 50,
              },
            ],
            reconfirmed: [
              {
                title: 'Primary with English',
                this_cycle: 285,
                last_cycle: 213,
              },
            ],
            withdrawn: [
              {
                title: 'Primary with English',
                this_cycle: 200,
                last_cycle: 100,
              },
            ],
          },
        },
      )
    end

    it 'returns secondary subject data (ignoring status less than 3 records)' do
      expect(report[:data][:candidate_secondary_subject]).to eq(
        {
          title: 'Candidate statistics by secondary subject',
          subtitle: 'Subject',
          data: {
            submitted: [
              {
                title: 'Drama',
                this_cycle: 400,
                last_cycle: 200,
              },
            ],
            with_offers: [
              {
                title: 'Drama',
                this_cycle: 598,
                last_cycle: 567,
              },
            ],
            accepted: [
              {
                title: 'Drama',
                this_cycle: 20,
                last_cycle: 10,
              },
            ],
            rejected: [
              {
                title: 'Drama',
                this_cycle: 100,
                last_cycle: 50,
              },
            ],
            reconfirmed: [
              {
                title: 'Drama',
                this_cycle: 285,
                last_cycle: 213,
              },
            ],
            withdrawn: [
              {
                title: 'Drama',
                this_cycle: 200,
                last_cycle: 100,
              },
            ],
          },
        },
      )
    end

    it 'returns provider region data (ignoring status less than 3 records)' do
      expect(report[:data][:candidate_provider_region]).to eq(
        {
          title: 'Candidate statistics by training provider region of England',
          subtitle: 'Region',
          data: {
            submitted: [
              {
                title: 'Hogsmeade',
                this_cycle: 400,
                last_cycle: 200,
              },
            ],
            with_offers: [
              {
                title: 'Hogsmeade',
                this_cycle: 598,
                last_cycle: 567,
              },
            ],
            accepted: [
              {
                title: 'Hogsmeade',
                this_cycle: 20,
                last_cycle: 10,
              },
            ],
            rejected: [
              {
                title: 'Hogsmeade',
                this_cycle: 100,
                last_cycle: 50,
              },
            ],
            reconfirmed: [
              {
                title: 'Hogsmeade',
                this_cycle: 285,
                last_cycle: 213,
              },
            ],
            withdrawn: [
              {
                title: 'Hogsmeade',
                this_cycle: 200,
                last_cycle: 100,
              },
            ],
          },
        },
      )
    end

    it 'returns provider region with subject (ignoring status less than 3 records)' do
      expect(report[:data][:candidate_provider_region_and_subject]).to eq(
        title: 'Candidate statistics by provider region of England and subject',
        subtitle: 'Region',
        data: {
          submitted: [
            {
              title: 'Fangorn Forest',
              this_cycle: 400,
              last_cycle: 200,
              subject: 'Geography',
            },
            {
              title: 'Fangorn Forest',
              this_cycle: 400,
              last_cycle: 200,
              subject: 'History',
            },
            {
              title: 'Fangorn Forest',
              this_cycle: 400,
              last_cycle: 200,
              subject: 'Music',
            },
          ],
          with_offers: [
            {
              title: 'Fangorn Forest',
              this_cycle: 598,
              last_cycle: 567,
              subject: 'Geography',
            },
            {
              title: 'Fangorn Forest',
              this_cycle: 598,
              last_cycle: 567,
              subject: 'History',
            },
            {
              title: 'Fangorn Forest',
              this_cycle: 598,
              last_cycle: 567,
              subject: 'Music',
            },
          ],
          accepted: [
            {
              title: 'Fangorn Forest',
              this_cycle: 20,
              last_cycle: 10,
              subject: 'Geography',
            },
            {
              title: 'Fangorn Forest',
              this_cycle: 20,
              last_cycle: 10,
              subject: 'History',
            },
            {
              title: 'Fangorn Forest',
              this_cycle: 20,
              last_cycle: 10,
              subject: 'Music',
            },
          ],
          rejected: [
            {
              title: 'Fangorn Forest',
              this_cycle: 100,
              last_cycle: 50,
              subject: 'Geography',
            },
            {
              title: 'Fangorn Forest',
              this_cycle: 100,
              last_cycle: 50,
              subject: 'History',
            },
            {
              title: 'Fangorn Forest',
              this_cycle: 100,
              last_cycle: 50,
              subject: 'Music',
            },
          ],
          reconfirmed: [
            {
              title: 'Fangorn Forest',
              this_cycle: 285,
              last_cycle: 213,
              subject: 'Geography',
            },
            {
              title: 'Fangorn Forest',
              this_cycle: 285,
              last_cycle: 213,
              subject: 'History',
            },
            {
              title: 'Fangorn Forest',
              this_cycle: 285,
              last_cycle: 213,
              subject: 'Music',
            },
          ],
          withdrawn: [
            {
              title: 'Fangorn Forest',
              this_cycle: 200,
              last_cycle: 100,
              subject: 'Geography',
            },
            {
              title: 'Fangorn Forest',
              this_cycle: 200,
              last_cycle: 100,
              subject: 'History',
            },
            {
              title: 'Fangorn Forest',
              this_cycle: 200,
              last_cycle: 100,
              subject: 'Music',
            },
          ],
        },
      )
    end

    it 'returns candidate area with subject (ignoring status less than 3 records)' do
      expect(report[:data][:candidate_area_and_subject]).to eq(
        title: 'Candidate statistics by UK region or country, or other area, and subject',
        subtitle: 'Area',
        data: {
          submitted: [
            {
              title: 'Isengard',
              this_cycle: 400,
              last_cycle: 200,
              subject: 'Drama',
            },
            {
              title: 'Isengard',
              this_cycle: 400,
              last_cycle: 200,
              subject: 'Primary with Mathematics',
            },
            {
              title: 'Isengard',
              this_cycle: 400,
              last_cycle: 200,
              subject: 'Mathematics',
            },
          ],
          with_offers: [
            {
              title: 'Isengard',
              this_cycle: 598,
              last_cycle: 567,
              subject: 'Drama',
            },
            {
              title: 'Isengard',
              this_cycle: 598,
              last_cycle: 567,
              subject: 'Primary with Mathematics',
            },
            {
              title: 'Isengard',
              this_cycle: 598,
              last_cycle: 567,
              subject: 'Mathematics',
            },
          ],
          accepted: [
            {
              title: 'Isengard',
              this_cycle: 20,
              last_cycle: 10,
              subject: 'Drama',
            },
            {
              title: 'Isengard',
              this_cycle: 20,
              last_cycle: 10,
              subject: 'Primary with Mathematics',
            },
            {
              title: 'Isengard',
              this_cycle: 20,
              last_cycle: 10,
              subject: 'Mathematics',
            },
          ],
          rejected: [
            {
              title: 'Isengard',
              this_cycle: 100,
              last_cycle: 50,
              subject: 'Drama',
            },
            {
              title: 'Isengard',
              this_cycle: 100,
              last_cycle: 50,
              subject: 'Primary with Mathematics',
            },
            {
              title: 'Isengard',
              this_cycle: 100,
              last_cycle: 50,
              subject: 'Mathematics',
            },
          ],
          reconfirmed: [
            {
              title: 'Isengard',
              this_cycle: 285,
              last_cycle: 213,
              subject: 'Drama',
            },
            {
              title: 'Isengard',
              this_cycle: 285,
              last_cycle: 213,
              subject: 'Primary with Mathematics',
            },
            {
              title: 'Isengard',
              this_cycle: 285,
              last_cycle: 213,
              subject: 'Mathematics',
            },
          ],
          withdrawn: [
            {
              title: 'Isengard',
              this_cycle: 200,
              last_cycle: 100,
              subject: 'Drama',
            },
            {
              title: 'Isengard',
              this_cycle: 200,
              last_cycle: 100,
              subject: 'Primary with Mathematics',
            },
            {
              title: 'Isengard',
              this_cycle: 200,
              last_cycle: 100,
              subject: 'Mathematics',
            },
          ],
        },
      )
    end

    it 'returns candidate headline statistics into CSV (ignoring status less than 3 records)' do
      expect(report[:formats][:csv][:candidate_headline_statistics]).to eq(
        size: 376,
        data: "Submitted this cycle,Submitted last cycle,With offers this cycle,With offers last cycle,Accepted this cycle,Accepted last cycle,All applications rejected this cycle,All applications rejected last cycle,Reconfirmed from previous cycle this cycle,Reconfirmed from previous cycle last cycle,Withdrawn this cycle,Withdrawn last cycle\n8586,5160,598,567,538,478,246,131,285,213,7,6\n",
      )
    end

    it 'returns candidate age group into CSV' do
      expect(report[:formats][:csv][:candidate_age_group]).to eq(
        size: 388,
        data: "Age Group,Submitted this cycle,Submitted last cycle,With offers this cycle,With offers last cycle,Accepted this cycle,Accepted last cycle,All applications rejected this cycle,All applications rejected last cycle,Reconfirmed from previous cycle this cycle,Reconfirmed from previous cycle last cycle,Withdrawn this cycle,Withdrawn last cycle\n21,400,200,598,567,20,10,100,50,285,213,200,100\n",
      )
    end

    it 'returns candidate sex into CSV' do
      expect(report[:formats][:csv][:candidate_sex]).to eq(
        size: 384,
        data: "Sex,Submitted this cycle,Submitted last cycle,With offers this cycle,With offers last cycle,Accepted this cycle,Accepted last cycle,All applications rejected this cycle,All applications rejected last cycle,Reconfirmed from previous cycle this cycle,Reconfirmed from previous cycle last cycle,Withdrawn this cycle,Withdrawn last cycle\nMale,400,200,598,567,20,10,100,50,285,213,200,100\n",
      )
    end

    it 'returns candidate area into CSV' do
      expect(report[:formats][:csv][:candidate_area]).to eq(
        size: 387,
        data: "Area,Submitted this cycle,Submitted last cycle,With offers this cycle,With offers last cycle,Accepted this cycle,Accepted last cycle,All applications rejected this cycle,All applications rejected last cycle,Reconfirmed from previous cycle this cycle,Reconfirmed from previous cycle last cycle,Withdrawn this cycle,Withdrawn last cycle\nGondor,400,200,598,567,20,10,100,50,285,213,200,100\n",
      )
    end

    it 'returns candidate phase into CSV' do
      expect(report[:formats][:csv][:candidate_phase]).to eq(
        size: 396,
        data: "Course Phase,Submitted this cycle,Submitted last cycle,With offers this cycle,With offers last cycle,Accepted this cycle,Accepted last cycle,All applications rejected this cycle,All applications rejected last cycle,Reconfirmed from previous cycle this cycle,Reconfirmed from previous cycle last cycle,Withdrawn this cycle,Withdrawn last cycle\nPrimary,400,200,598,567,20,10,100,50,285,213,200,100\n",
      )
    end

    it 'returns candidate route into teaching into CSV' do
      expect(report[:formats][:csv][:candidate_route_into_teaching]).to eq(
        size: 404,
        data: "Course type,Submitted this cycle,Submitted last cycle,With offers this cycle,With offers last cycle,Accepted this cycle,Accepted last cycle,All applications rejected this cycle,All applications rejected last cycle,Reconfirmed from previous cycle this cycle,Reconfirmed from previous cycle last cycle,Withdrawn this cycle,Withdrawn last cycle\nHigher education,400,200,598,567,20,10,100,50,285,213,200,100\n",
      )
    end

    it 'returns provider area and subject into CSV' do
      expect(report[:formats][:csv][:candidate_provider_region_and_subject]).to eq(
        size: 549,
        data: "Region,Subject,Submitted this cycle,Submitted last cycle,With offers this cycle,With offers last cycle,Accepted this cycle,Accepted last cycle,All applications rejected this cycle,All applications rejected last cycle,Reconfirmed from previous cycle this cycle,Reconfirmed from previous cycle last cycle,Withdrawn this cycle,Withdrawn last cycle\nFangorn Forest,Geography,400,200,598,567,20,10,100,50,285,213,200,100\nFangorn Forest,History,400,200,598,567,20,10,100,50,285,213,200,100\nFangorn Forest,Music,400,200,598,567,20,10,100,50,285,213,200,100\n",
      )
    end

    it 'returns candidate area and subject into CSV' do
      expect(report[:formats][:csv][:candidate_area_and_subject]).to eq(
        size: 548,
        data: "Area,Subject,Submitted this cycle,Submitted last cycle,With offers this cycle,With offers last cycle,Accepted this cycle,Accepted last cycle,All applications rejected this cycle,All applications rejected last cycle,Reconfirmed from previous cycle this cycle,Reconfirmed from previous cycle last cycle,Withdrawn this cycle,Withdrawn last cycle\nIsengard,Drama,400,200,598,567,20,10,100,50,285,213,200,100\nIsengard,Primary with Mathematics,400,200,598,567,20,10,100,50,285,213,200,100\nIsengard,Mathematics,400,200,598,567,20,10,100,50,285,213,200,100\n",
      )
    end
  end

  def stub_application_metrics(cycle_week:)
    application_metrics = instance_double(DfE::Bigquery::ApplicationMetrics)

    allow(DfE::Bigquery::ApplicationMetrics).to receive(:new)
      .with(cycle_week:)
      .and_return(application_metrics)

    allow(application_metrics).to receive(:candidate_headline_statistics)
      .and_return(DfE::Bigquery::ApplicationMetrics::Result.new(candidate_headline_statistics))

    allow(application_metrics).to receive_messages(
      age_group: [DfE::Bigquery::ApplicationMetrics::Result.new(age_group)],
      sex: [DfE::Bigquery::ApplicationMetrics::Result.new(sex)],
      phase: [DfE::Bigquery::ApplicationMetrics::Result.new(phase)],
      area: [DfE::Bigquery::ApplicationMetrics::Result.new(area)],
      route_into_teaching: [DfE::Bigquery::ApplicationMetrics::Result.new(route_into_teaching)],
      primary_subject: [DfE::Bigquery::ApplicationMetrics::Result.new(primary_subject)],
      secondary_subject: [DfE::Bigquery::ApplicationMetrics::Result.new(secondary_subject)],
      provider_region: [DfE::Bigquery::ApplicationMetrics::Result.new(provider_region)],
      provider_region_and_subject: [
        DfE::Bigquery::ApplicationMetrics::Result.new(first_provider_region_and_subject),
        DfE::Bigquery::ApplicationMetrics::Result.new(second_provider_region_and_subject),
        DfE::Bigquery::ApplicationMetrics::Result.new(third_provider_region_and_subject),
      ],
      candidate_area_and_subject: [
        DfE::Bigquery::ApplicationMetrics::Result.new(first_candidate_area_and_subject),
        DfE::Bigquery::ApplicationMetrics::Result.new(second_candidate_area_and_subject),
        DfE::Bigquery::ApplicationMetrics::Result.new(third_candidate_area_and_subject),
      ],
    )
  end

  def application_metrics_results(options = {})
    [
      {
        cycle_week: 7,
        first_date_in_week: Date.new(2023, 11, 13),
        last_date_in_week: Date.new(2023, 11, 19),
        nonsubject_filter: '21',
        number_of_candidates_submitted_to_date: 400,
        number_of_candidates_submitted_to_same_date_previous_cycle: 200,
        number_of_candidates_who_did_not_meet_any_offer_conditions_this_cycle_to_date: 30,
        number_of_candidates_who_did_not_meet_any_offer_conditions_this_cycle_to_same_date_previous_cycle: 15,
        number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date: 100,
        number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle: 50,
        number_of_candidates_with_all_accepted_offers_withdrawn_this_cycle_to_date: 200,
        number_of_candidates_with_all_accepted_offers_withdrawn_this_cycle_to_same_date_previous_cycle: 100,
        number_of_candidates_with_deferred_offers_from_this_cycle_to_date: 0,
        number_of_candidates_with_deferred_offers_from_this_cycle_to_same_date_previous_cycle: 0,
        number_of_candidates_with_offers_to_date: 598,
        number_of_candidates_with_offers_to_same_date_previous_cycle: 567,
        number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date: 285,
        number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle: 213,
        number_of_candidates_accepted_to_date: 20,
        number_of_candidates_accepted_to_same_date_previous_cycle: 10,
      }.merge(options.slice(:attributes)),
    ]
  end
end
