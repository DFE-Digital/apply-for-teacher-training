module DfE
  module Bigquery
    class StubbedReport
      attr_reader :data

      def initialize
        @data = {
          meta: {
            publication_date: 1.day.ago,
            generation_date: 8.days.ago,
            period: 'From 2 October 2023 to 12 November 2023',
            cycle_week: 2,
          },
          data: {
            candidate_headline_statistics: {
              title: 'Statistics',
              data: { deferred_applications_count: 100 },
            },
            candidate_sex: {
              title: I18n.t('publications.itt_monthly_report_generator.sex.title'),
              data: sex_data,
            },
            candidate_age_group: {
              title: I18n.t('publications.itt_monthly_report_generator.age_group.title'),
              data: age_data,
            },
            candidate_area: {
              title: I18n.t('publications.itt_monthly_report_generator.area.title'),
              data: area_data,
            },
            candidate_phase: {
              title: I18n.t('publications.itt_monthly_report_generator.phase.title'),
              data: phase_data,
            },
            candidate_route_into_teaching: {
              title: I18n.t('publications.itt_monthly_report_generator.route_into_teaching.title'),
              data: route_into_teaching_data,
            },
          },
        }
      end

      def to_h
        @data
      end

    private

      def sex_data
        {
          submitted: [
            { title: 'Female', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Male', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Other', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Prefer not to say', this_cycle: rand(50), last_cycle: rand(100) },
          ],
          with_offers: [
            { title: 'Female', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Male', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Other', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Prefer not to say', this_cycle: rand(50), last_cycle: rand(100) },
          ],
          accepted: [
            { title: 'Female', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Male', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Other', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Prefer not to say', this_cycle: rand(50), last_cycle: rand(100) },
          ],
          all_applications_rejected: [
            { title: 'Female', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Male', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Other', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Prefer not to say', this_cycle: rand(50), last_cycle: rand(100) },
          ],
          reconfirmed_from_previous_cycle: [
            { title: 'Female', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Male', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Other', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Prefer not to say', this_cycle: rand(50), last_cycle: rand(100) },
          ],
          deferred: [
            { title: 'Female', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Male', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Other', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Prefer not to say', this_cycle: rand(50), last_cycle: rand(100) },
          ],
          withdrawn: [
            { title: 'Female', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Male', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Other', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Prefer not to say', this_cycle: rand(50), last_cycle: rand(100) },
          ],
          conditions_not_met: [
            { title: 'Female', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Male', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Other', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Prefer not to say', this_cycle: rand(50), last_cycle: rand(100) },
          ],
        }
      end

      def age_data
        {
          submitted: [
            { title: '18 - 21', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '21-35', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '36-50', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '51-65', this_cycle: rand(50), last_cycle: rand(100) },
          ],
          with_offers: [
            { title: '18 - 21', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '21-35', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '36-50', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '51-65', this_cycle: rand(50), last_cycle: rand(100) },
          ],
          accepted: [
            { title: '18 - 21', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '21-35', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '36-50', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '51-65', this_cycle: rand(50), last_cycle: rand(100) },
          ],
          all_applications_rejected: [
            { title: '18 - 21', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '21-35', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '36-50', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '51-65', this_cycle: rand(50), last_cycle: rand(100) },
          ],
          reconfirmed_from_previous_cycle: [
            { title: '18 - 21', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '21-35', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '36-50', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '51-65', this_cycle: rand(50), last_cycle: rand(100) },
          ],
          deferred: [
            { title: '18 - 21', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '21-35', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '36-50', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '51-65', this_cycle: rand(50), last_cycle: rand(100) },
          ],
          withdrawn: [
            { title: '18 - 21', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '21-35', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '36-50', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '51-65', this_cycle: rand(50), last_cycle: rand(100) },
          ],
          conditions_not_met: [
            { title: '18 - 21', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '21-35', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '36-50', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: '51-65', this_cycle: rand(50), last_cycle: rand(100) },
          ],
        }
      end

      def area_data
        {
          submitted: [
            { title: 'London', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'West', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'East', this_cycle: rand(50), last_cycle: rand(100) },
            { title: 'South', this_cycle: rand(50), last_cycle: rand(100) },
          ],
          with_offers: [
            { title: 'London', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'West', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'East', this_cycle: rand(50), last_cycle: rand(100) },
            { title: 'South', this_cycle: rand(50), last_cycle: rand(100) },
          ],
          accepted: [
            { title: 'London', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'West', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'East', this_cycle: rand(50), last_cycle: rand(100) },
            { title: 'South', this_cycle: rand(50), last_cycle: rand(100) },
          ],
          all_applications_rejected: [
            { title: 'London', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'West', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'East', this_cycle: rand(50), last_cycle: rand(100) },
            { title: 'South', this_cycle: rand(50), last_cycle: rand(100) },
          ],
          reconfirmed_from_previous_cycle: [
            { title: 'London', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'West', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'East', this_cycle: rand(50), last_cycle: rand(100) },
            { title: 'South', this_cycle: rand(50), last_cycle: rand(100) },
          ],
          deferred: [
            { title: 'London', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'West', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'East', this_cycle: rand(50), last_cycle: rand(100) },
            { title: 'South', this_cycle: rand(50), last_cycle: rand(100) },
          ],
          withdrawn: [
            { title: 'London', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'West', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'East', this_cycle: rand(50), last_cycle: rand(100) },
            { title: 'South', this_cycle: rand(50), last_cycle: rand(100) },
          ],
          conditions_not_met: [
            { title: 'London', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'West', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'East', this_cycle: rand(50), last_cycle: rand(100) },
            { title: 'South', this_cycle: rand(50), last_cycle: rand(100) },
          ],
        }
      end

      def phase_data
        {
          submitted: [
            { title: 'Primary', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Secondar', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          with_offers: [
            { title: 'Primary', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Secondar', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          accepted: [
            { title: 'Primary', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Secondar', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          all_applications_rejected: [
            { title: 'Primary', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Secondar', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          reconfirmed_from_previous_cycle: [
            { title: 'Primary', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Secondar', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          deferred: [
            { title: 'Primary', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Secondar', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          withdrawn: [
            { title: 'Primary', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Secondar', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          conditions_not_met: [
            { title: 'Primary', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Secondar', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
        }
      end

      def route_into_teaching_data
        {
          submitted: [
            { title: 'Higher education', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Postgraduate teaching apprenticeship', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School Direct (fee-paying)', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School Direct (salaried)', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School-centred initial teacher training (SCITT)', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          with_offers: [
            { title: 'Higher education', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Postgraduate teaching apprenticeship', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School Direct (fee-paying)', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School Direct (salaried)', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School-centred initial teacher training (SCITT)', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          accepted: [
            { title: 'Higher education', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Postgraduate teaching apprenticeship', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School Direct (fee-paying)', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School Direct (salaried)', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School-centred initial teacher training (SCITT)', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          all_applications_rejected: [
            { title: 'Higher education', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Postgraduate teaching apprenticeship', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School Direct (fee-paying)', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School Direct (salaried)', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School-centred initial teacher training (SCITT)', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          reconfirmed_from_previous_cycle: [
            { title: 'Higher education', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Postgraduate teaching apprenticeship', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School Direct (fee-paying)', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School Direct (salaried)', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School-centred initial teacher training (SCITT)', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          deferred: [
            { title: 'Higher education', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Postgraduate teaching apprenticeship', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School Direct (fee-paying)', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School Direct (salaried)', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School-centred initial teacher training (SCITT)', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          withdrawn: [
            { title: 'Higher education', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Postgraduate teaching apprenticeship', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School Direct (fee-paying)', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School Direct (salaried)', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School-centred initial teacher training (SCITT)', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          conditions_not_met: [
            { title: 'Higher education', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Postgraduate teaching apprenticeship', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School Direct (fee-paying)', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School Direct (salaried)', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'School-centred initial teacher training (SCITT)', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
        }
      end
    end
  end
end
