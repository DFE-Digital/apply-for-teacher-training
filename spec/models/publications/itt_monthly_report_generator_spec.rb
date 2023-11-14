require 'rails_helper'

RSpec.describe Publications::ITTMonthlyReportGenerator do
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

  describe '#first_cycle_week' do
    context 'when we are on 2023 recruitment cycle' do
      it 'returns first monday week of beginning of the cycle' do
        travel_temporarily_to(Time.zone.local(2023, 9, 1)) do
          expect(described_class.new.first_cycle_week).to eq(Time.zone.local(2022, 10, 3))
        end
      end
    end

    context 'when we are on 2024 recruitment cycle' do
      it 'returns first monday week of beginning of the cycle' do
        travel_temporarily_to(Time.zone.local(2023, 11, 15)) do
          expect(described_class.new.first_cycle_week).to eq(Time.zone.local(2023, 10, 2))
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

  describe '#to_h' do
    subject(:report) do
      described_class.new(generation_date:).to_h
    end

    let(:generation_date) { Time.zone.local(2023, 11, 22) }
    let(:publication_date) { generation_date + 1.week }
    let(:candidate_headline_statistics) do
      {
        cycle_week: 7,
        first_date_in_week: Date.new(2023, 11, 13),
        last_date_in_week: Date.new(2023, 11, 19),
        number_of_candidates_accepted_to_date: 538,
        number_of_candidates_accepted_to_same_date_previous_cycle: 478,
        number_of_candidates_submitted_to_date: 8586,
        number_of_candidates_submitted_to_same_date_previous_cycle: 5160,
        number_of_candidates_who_did_not_meet_any_offer_conditions_this_cycle_to_date: 0,
        number_of_candidates_who_did_not_meet_any_offer_conditions_this_cycle_to_same_date_previous_cycle: 0,
        number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date: 246,
        number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle: 131,
        number_of_candidates_with_all_accepted_offers_withdrawn_this_cycle_to_date: 1,
        number_of_candidates_with_all_accepted_offers_withdrawn_this_cycle_to_same_date_previous_cycle: 0,
        number_of_candidates_with_deferred_offers_from_this_cycle_to_date: 0,
        number_of_candidates_with_deferred_offers_from_this_cycle_to_same_date_previous_cycle: 0,
        number_of_candidates_with_offers_to_date: 598,
        number_of_candidates_with_offers_to_same_date_previous_cycle: 567,
        number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date: 285,
        number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle: 213,
      }
    end
    let(:age_group) do
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
      }
    end
    let(:sex) { age_group.dup.merge(nonsubject_filter: 'Male') }
    let(:area) { age_group.dup.merge(nonsubject_filter: 'Gondor') }
    let(:phase) { age_group.dup.merge(subject_filter: 'Primary') }
    let(:route_into_teaching) { age_group.dup.merge(nonsubject_filter: 'Higher education') }
    let(:primary_subject) { age_group.dup.merge(subject_filter: 'Primary with English') }
    let(:secondary_subject) { age_group.dup.merge(subject_filter: 'Drama') }
    let(:provider_region) { age_group.dup.merge(nonsubject_filter: 'Hogsmeade') }

    before do
      allow(DfE::Bigquery::ApplicationMetrics).to receive(:candidate_headline_statistics)
        .with(cycle_week: 7)
        .and_return(DfE::Bigquery::ApplicationMetrics.new(candidate_headline_statistics))

      allow(DfE::Bigquery::ApplicationMetrics).to receive(:age_group)
        .with(cycle_week: 7)
        .and_return([DfE::Bigquery::ApplicationMetrics.new(age_group)])

      allow(DfE::Bigquery::ApplicationMetrics).to receive(:sex)
        .with(cycle_week: 7)
        .and_return([DfE::Bigquery::ApplicationMetrics.new(sex)])

      allow(DfE::Bigquery::ApplicationMetrics).to receive(:area)
        .with(cycle_week: 7)
        .and_return([DfE::Bigquery::ApplicationMetrics.new(area)])

      allow(DfE::Bigquery::ApplicationMetrics).to receive(:phase)
        .with(cycle_week: 7)
        .and_return([DfE::Bigquery::ApplicationMetrics.new(phase)])

      allow(DfE::Bigquery::ApplicationMetrics).to receive(:route_into_teaching)
        .with(cycle_week: 7)
        .and_return([DfE::Bigquery::ApplicationMetrics.new(route_into_teaching)])

      allow(DfE::Bigquery::ApplicationMetrics).to receive(:primary_subject)
        .with(cycle_week: 7)
        .and_return([DfE::Bigquery::ApplicationMetrics.new(primary_subject)])

      allow(DfE::Bigquery::ApplicationMetrics).to receive(:secondary_subject)
        .with(cycle_week: 7)
        .and_return([DfE::Bigquery::ApplicationMetrics.new(secondary_subject)])

      allow(DfE::Bigquery::ApplicationMetrics).to receive(:provider_region)
        .with(cycle_week: 7)
        .and_return([DfE::Bigquery::ApplicationMetrics.new(provider_region)])
    end

    it 'returns meta information' do
      expect(report[:meta]).to eq({
        generation_date:,
        publication_date:,
        period: 'From 2 October 2023 to 19 November 2023',
        cycle_week: 7,
      })
    end

    it 'returns candidate headline statistics' do
      expect(report[:candidate_headline_statistics]).to eq({
        title: 'Candidate Headline statistics',
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
          deferred: {
            title: 'Deferred',
            this_cycle: 0,
            last_cycle: 0,
          },
          withdrawn: {
            title: 'Withdrawn',
            this_cycle: 1,
            last_cycle: 0,
          },
          conditions_not_met: {
            title: 'Offer conditions not met',
            this_cycle: 0,
            last_cycle: 0,
          },
        },
      })
    end

    it 'returns age group' do
      expect(report[:candidate_age_group]).to eq({
        title: 'Candidate statistics by age group',
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
          deferred: [
            {
              title: '21',
              this_cycle: 0,
              last_cycle: 0,
            },
          ],
          withdrawn: [
            {
              title: '21',
              this_cycle: 200,
              last_cycle: 100,
            },
          ],
          conditions_not_met: [
            {
              title: '21',
              this_cycle: 30,
              last_cycle: 15,
            },
          ],
        },
      })
    end

    it 'returns sex data' do
      expect(report[:candidate_sex]).to eq(
        {
          title: 'Candidate statistics by sex',
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
            deferred: [
              {
                title: 'Male',
                this_cycle: 0,
                last_cycle: 0,
              },
            ],
            withdrawn: [
              {
                title: 'Male',
                this_cycle: 200,
                last_cycle: 100,
              },
            ],
            conditions_not_met: [
              {
                title: 'Male',
                this_cycle: 30,
                last_cycle: 15,
              },
            ],
          },
        },
      )
    end

    it 'returns area data' do
      expect(report[:candidate_area]).to eq(
        {
          title: 'Candidate statistics by UK region or country, or other area',
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
            deferred: [
              {
                title: 'Gondor',
                this_cycle: 0,
                last_cycle: 0,
              },
            ],
            withdrawn: [
              {
                title: 'Gondor',
                this_cycle: 200,
                last_cycle: 100,
              },
            ],
            conditions_not_met: [
              {
                title: 'Gondor',
                this_cycle: 30,
                last_cycle: 15,
              },
            ],
          },
        },
      )
    end

    it 'returns phase data' do
      expect(report[:candidate_phase]).to eq(
        {
          title: 'Candidate statistics by course phase',
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
            deferred: [
              {
                title: 'Primary',
                this_cycle: 0,
                last_cycle: 0,
              },
            ],
            withdrawn: [
              {
                title: 'Primary',
                this_cycle: 200,
                last_cycle: 100,
              },
            ],
            conditions_not_met: [
              {
                title: 'Primary',
                this_cycle: 30,
                last_cycle: 15,
              },
            ],
          },
        },
      )
    end

    it 'returns route into teaching data' do
      expect(report[:candidate_route_into_teaching]).to eq(
        {
          title: 'Candidate statistics by route into teaching',
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
            deferred: [
              {
                title: 'Higher education',
                this_cycle: 0,
                last_cycle: 0,
              },
            ],
            withdrawn: [
              {
                title: 'Higher education',
                this_cycle: 200,
                last_cycle: 100,
              },
            ],
            conditions_not_met: [
              {
                title: 'Higher education',
                this_cycle: 30,
                last_cycle: 15,
              },
            ],
          },
        },
      )
    end

    it 'returns primary subject data' do
      expect(report[:candidate_primary_subject]).to eq(
        {
          title: 'Candidate statistics by primary specialist subject',
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
            deferred: [
              {
                title: 'Primary with English',
                this_cycle: 0,
                last_cycle: 0,
              },
            ],
            withdrawn: [
              {
                title: 'Primary with English',
                this_cycle: 200,
                last_cycle: 100,
              },
            ],
            conditions_not_met: [
              {
                title: 'Primary with English',
                this_cycle: 30,
                last_cycle: 15,
              },
            ],
          },
        },
      )
    end

    it 'returns secondary subject data' do
      expect(report[:candidate_secondary_subject]).to eq(
        {
          title: 'Candidate statistics by secondary subject',
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
            deferred: [
              {
                title: 'Drama',
                this_cycle: 0,
                last_cycle: 0,
              },
            ],
            withdrawn: [
              {
                title: 'Drama',
                this_cycle: 200,
                last_cycle: 100,
              },
            ],
            conditions_not_met: [
              {
                title: 'Drama',
                this_cycle: 30,
                last_cycle: 15,
              },
            ],
          },
        },
      )
    end

    it 'returns provider region data' do
      expect(report[:candidate_provider_region]).to eq(
        {
          title: 'Candidate statistics by training provider region of England',
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
            deferred: [
              {
                title: 'Hogsmeade',
                this_cycle: 0,
                last_cycle: 0,
              },
            ],
            withdrawn: [
              {
                title: 'Hogsmeade',
                this_cycle: 200,
                last_cycle: 100,
              },
            ],
            conditions_not_met: [
              {
                title: 'Hogsmeade',
                this_cycle: 30,
                last_cycle: 15,
              },
            ],
          },
        },
      )
    end
  end
end
