module Publications
  module MonthlyStatistics
    class StubbedReport
      attr_reader :data

      def initialize(publication_date: 1.day.ago, generation_date: 8.days.ago)
        @data = {
          meta: {
            publication_date:,
            generation_date:,
            period: 'From 2 October 2023 to 12 November 2023',
            cycle_week: 2,
          },
          data: {
            candidate_headline_statistics: {
              title: 'Statistics',
              subtitle: 'Headline Statistics',
              data: candidate_headline_statistics,
            },
            candidate_sex: {
              title: I18n.t('publications.itt_monthly_report_generator.candidate_sex.title'),
              subtitle: I18n.t('publications.itt_monthly_report_generator.candidate_sex.subtitle'),
              data: sex_data,
            },
            candidate_age_group: {
              title: I18n.t('publications.itt_monthly_report_generator.candidate_age_group.title'),
              subtitle: I18n.t('publications.itt_monthly_report_generator.candidate_age_group.subtitle'),
              data: age_data,
            },
            candidate_area: {
              title: I18n.t('publications.itt_monthly_report_generator.candidate_area.title'),
              subtitle: I18n.t('publications.itt_monthly_report_generator.candidate_area.subtitle'),
              data: area_data,
            },
            candidate_phase: {
              title: I18n.t('publications.itt_monthly_report_generator.candidate_phase.title'),
              subtitle: I18n.t('publications.itt_monthly_report_generator.candidate_phase.subtitle'),
              data: phase_data,
            },
            candidate_route_into_teaching: {
              title: I18n.t('publications.itt_monthly_report_generator.candidate_route_into_teaching.title'),
              subtitle: I18n.t('publications.itt_monthly_report_generator.candidate_route_into_teaching.subtitle'),
              data: route_into_teaching_data,
            },
            candidate_primary_subject: {
              title: I18n.t('publications.itt_monthly_report_generator.candidate_primary_subject.title'),
              subtitle: I18n.t('publications.itt_monthly_report_generator.candidate_primary_subject.subtitle'),
              data: primary_subject_data,
            },
            candidate_secondary_subject: {
              title: I18n.t('publications.itt_monthly_report_generator.candidate_secondary_subject.title'),
              subtitle: I18n.t('publications.itt_monthly_report_generator.candidate_primary_subject.subtitle'),
              data: secondary_subject_data,
            },
            candidate_provider_region: {
              title: I18n.t('publications.itt_monthly_report_generator.candidate_provider_region.title'),
              subtitle: I18n.t('publications.itt_monthly_report_generator.candidate_provider_region.subtitle'),
              data: provider_region_data,
            },
          },
          formats: {
            csv: {
              candidate_age_group: {
                size: 510,
                data: "Age Group,Submitted this cycle,Submitted last cycle,With offers this cycle,With offers last cycle,Accepted this cycle,Accepted last cycle,All applications rejected this cycle,All applications rejected last cycle,Reconfirmed from previous cycle this cycle,Reconfirmed from previous cycle last cycle,Deferred this cycle,Deferred last cycle,Withdrawn this cycle,Withdrawn last cycle,Offer conditions not met this cycle,Offer conditions not met last cycle\n21,400,200,598,567,20,10,100,50,285,213,0,0,200,100,30,15\n",
              },
            },
          },
        }
      end

      def to_h
        @data
      end

    private

      def candidate_headline_statistics
        {
          submitted: {
            title: 'Submitted',
            this_cycle: rand(10000),
            last_cycle: rand(10000),
          },
          with_offers: {
            title: 'With Offers',
            this_cycle: rand(10000),
            last_cycle: rand(10000),
          },
          accepted: {
            title: 'Accepted',
            this_cycle: rand(10000),
            last_cycle: rand(10000),
          },
          rejected: {
            title: 'Rejected',
            this_cycle: rand(10000),
            last_cycle: rand(10000),
          },
          reconfirmed: {
            title: 'Reconfirmed',
            this_cycle: rand(10000),
            last_cycle: rand(10000),
          },
          deferred: {
            title: 'Deferred',
            this_cycle: rand(10000),
            last_cycle: rand(10000),
          },
          withdrawn: {
            title: 'Deferred',
            this_cycle: rand(10000),
            last_cycle: rand(10000),
          },
          conditions_not_met: {
            title: 'Deferred',
            this_cycle: rand(10000),
            last_cycle: rand(10000),
          },
        }
      end

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

      def primary_subject_data
        {
          submitted: [
            { title: 'Primary', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with English', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Geography and History', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Mathematics', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Modern Languages', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Physical Education', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Science', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          with_offers: [
            { title: 'Primary', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with English', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Geography and History', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Mathematics', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Modern Languages', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Physical Education', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Science', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          accepted: [
            { title: 'Primary', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with English', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Geography and History', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Mathematics', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Modern Languages', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Physical Education', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Science', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          all_applications_rejected: [
            { title: 'Primary', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with English', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Geography and History', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Mathematics', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Modern Languages', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Physical Education', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Science', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          reconfirmed_from_previous_cycle: [
            { title: 'Primary', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with English', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Geography and History', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Mathematics', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Modern Languages', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Physical Education', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Science', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          deferred: [
            { title: 'Primary', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with English', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Geography and History', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Mathematics', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Modern Languages', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Physical Education', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Science', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          withdrawn: [
            { title: 'Primary', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with English', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Geography and History', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Mathematics', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Modern Languages', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Physical Education', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Science', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          conditions_not_met: [
            { title: 'Primary', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with English', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Geography and History', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Mathematics', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Modern Languages', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Physical Education', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Primary with Science', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
        }
      end

      def secondary_subject_data
        {
          submitted: [
            { title: 'Art & Design', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Biology', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Business Studies', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Chemistry', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Classics', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Computing', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Design & Technology', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          with_offers: [
            { title: 'Art & Design', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Biology', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Business Studies', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Chemistry', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Classics', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Computing', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Design & Technology', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          accepted: [
            { title: 'Art & Design', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Biology', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Business Studies', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Chemistry', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Classics', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Computing', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Design & Technology', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          all_applications_rejected: [
            { title: 'Art & Design', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Biology', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Business Studies', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Chemistry', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Classics', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Computing', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Design & Technology', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          reconfirmed_from_previous_cycle: [
            { title: 'Art & Design', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Biology', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Business Studies', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Chemistry', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Classics', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Computing', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Design & Technology', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          deferred: [
            { title: 'Art & Design', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Biology', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Business Studies', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Chemistry', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Classics', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Computing', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Design & Technology', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          withdrawn: [
            { title: 'Art & Design', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Biology', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Business Studies', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Chemistry', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Classics', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Computing', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Design & Technology', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          conditions_not_met: [
            { title: 'Art & Design', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Biology', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Business Studies', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Chemistry', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Classics', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Computing', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'Design & Technology', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
        }
      end

      def provider_region_data
        {
          submitted: [
            { title: 'East of England', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'East Midlands', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'London', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North East', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North West', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'South East', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'South West', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          with_offers: [
            { title: 'East of England', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'East Midlands', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'London', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North East', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North West', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'South East', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'South West', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          accepted: [
            { title: 'East of England', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'East Midlands', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'London', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North East', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North West', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'South East', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'South West', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          all_applications_rejected: [
            { title: 'East of England', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'East Midlands', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'London', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North East', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North West', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'South East', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'South West', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          reconfirmed_from_previous_cycle: [
            { title: 'East of England', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'East Midlands', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'London', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North East', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North West', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'South East', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'South West', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          deferred: [
            { title: 'East of England', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'East Midlands', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'London', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North East', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North West', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'South East', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'South West', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          withdrawn: [
            { title: 'East of England', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'East Midlands', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'London', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North East', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North West', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'South East', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'South West', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
          conditions_not_met: [
            { title: 'East of England', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'East Midlands', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'London', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North East', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'North West', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'South East', this_cycle: rand(1000), last_cycle: rand(2000) },
            { title: 'South West', this_cycle: rand(1000), last_cycle: rand(2000) },
          ],
        }
      end
    end
  end
end
