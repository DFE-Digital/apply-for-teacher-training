require 'rails_helper'

RSpec.describe SupportInterface::ExternalReportCandidatesExport do
  describe '#data_for_export' do
    it 'generates the full report with the correct totals' do
      hash = create_base_hash_with_key

      generate_test_data
      hash = add_test_data_to_hash(hash)
      output = described_class.new.data_for_export.sort
      expected_output = hash.values.sort.each do |row|
        row['Total'] = '0 to 4' if row['Total'] <= 4
      end

      expect(output).to eq(expected_output)
    end

  private

    def create_base_hash_with_key
      hash = {}

      ExternalReportCandidates::SEX.each_value do |sex|
        ExternalReportCandidates::AREAS.each_value do |area|
          ExternalReportCandidates::AGE_GROUPS.each do |age_group|
            ExternalReportCandidates::STATUSES.each do |status|
              hash[construct_key(sex, area, age_group, status)] = {
                'Sex' => sex,
                'Area' => area,
                'Age group' => age_group,
                'Status' => status,
                'Total' => 0,
              }
            end
          end
        end
      end

      hash
    end

    def generate_test_data
      region_codes = ApplicationForm.region_codes.keys + [nil]
      statuses = ApplicationChoice.statuses.keys.reject { |status| %w[unsubmitted cancelled application_not_sent offer_deferred].include?(status) }
      sexes = ExternalReportCandidates::SEX.keys

      20.times do
        date_of_birth = rand(Time.zone.now - 75.years..Time.zone.now - 20.years)
        region_code = region_codes.sample
        status = statuses.sample
        sex = sexes.sample

        rand(1..7).times do
          application_form = if sex.nil?
                               create(:application_form, equality_and_diversity: nil, submitted_at: Time.zone.now, date_of_birth: date_of_birth, region_code: region_code)
                             else
                               create(:application_form, :with_equality_and_diversity_data, submitted_at: Time.zone.now, date_of_birth: date_of_birth, region_code: region_code)
                             end

          create(:application_choice, status: status, application_form: application_form)
          create(:application_choice, :with_rejection, application_form: application_form)
        end
      end

      5.times do
        date_of_birth = rand(Time.zone.now - 75.years..Time.zone.now - 20.years)
        region_code = region_codes.sample
        status = %w[pending_conditions recruited].sample
        sex = sexes.sample

        rand(1..7).times do
          application_form = if sex.nil?
                               create(:application_form, equality_and_diversity: nil, recruitment_cycle_year: RecruitmentCycle.previous_year, submitted_at: Time.zone.now, date_of_birth: date_of_birth, region_code: region_code)
                             else
                               create(:application_form, :with_equality_and_diversity_data, recruitment_cycle_year: RecruitmentCycle.previous_year, submitted_at: Time.zone.now, date_of_birth: date_of_birth, region_code: region_code)
                             end

          create(:application_choice, :with_deferred_offer, status_before_deferral: status, application_form: application_form)
        end
      end
    end

    def add_test_data_to_hash(hash)
      ApplicationForm.all.each do |application_form|
        states = application_form.application_choices.map(&:status)
        states = application_form.application_choices.map(&:status_before_deferral) if states.include?('offer_deferred')

        hash[construct_key(
          ExternalReportCandidates::SEX[application_form.equality_and_diversity&.dig('sex')],
          ExternalReportCandidates::AREAS[application_form.region_code],
          map_age_group(application_form.date_of_birth),
          map_status(states),
        )]['Total'] += 1
      end

      hash
    end

    def construct_key(sex, area, age_group, status)
      "#{sex},#{area},#{age_group},#{status}"
    end

    def map_age_group(date_of_birth)
      if date_of_birth > Date.new(RecruitmentCycle.current_year - 22, 8, 31)
        '21 and under'
      elsif date_of_birth.between?(Date.new(RecruitmentCycle.current_year - 23, 9, 1), Date.new(RecruitmentCycle.current_year - 22, 8, 31))
        '22'
      elsif date_of_birth.between?(Date.new(RecruitmentCycle.current_year - 24, 9, 1), Date.new(RecruitmentCycle.current_year - 23, 8, 31))
        '23'
      elsif date_of_birth.between?(Date.new(RecruitmentCycle.current_year - 25, 9, 1), Date.new(RecruitmentCycle.current_year - 24, 8, 31))
        '24'
      elsif date_of_birth.between?(Date.new(RecruitmentCycle.current_year - 30, 9, 1), Date.new(RecruitmentCycle.current_year - 25, 8, 31))
        '25 to 29'
      elsif date_of_birth.between?(Date.new(RecruitmentCycle.current_year - 35, 9, 1), Date.new(RecruitmentCycle.current_year - 30, 8, 31))
        '30 to 34'
      elsif date_of_birth.between?(Date.new(RecruitmentCycle.current_year - 40, 9, 1), Date.new(RecruitmentCycle.current_year - 35, 8, 31))
        '35 to 39'
      elsif date_of_birth.between?(Date.new(RecruitmentCycle.current_year - 45, 9, 1), Date.new(RecruitmentCycle.current_year - 40, 8, 31))
        '40 to 44'
      elsif date_of_birth.between?(Date.new(RecruitmentCycle.current_year - 50, 9, 1), Date.new(RecruitmentCycle.current_year - 45, 8, 31))
        '45 to 49'
      elsif date_of_birth.between?(Date.new(RecruitmentCycle.current_year - 55, 9, 1), Date.new(RecruitmentCycle.current_year - 50, 8, 31))
        '50 to 54'
      elsif date_of_birth.between?(Date.new(RecruitmentCycle.current_year - 60, 9, 1), Date.new(RecruitmentCycle.current_year - 55, 8, 31))
        '55 to 59'
      elsif date_of_birth.between?(Date.new(RecruitmentCycle.current_year - 65, 9, 1), Date.new(RecruitmentCycle.current_year - 60, 8, 31))
        '60 to 64'
      elsif date_of_birth < Date.new(RecruitmentCycle.current_year - 65, 9, 1)
        '65 and over'
      end
    end

    def map_status(states)
      if states.include?('recruited')
        'Recruited'
      elsif states.include?('pending_conditions')
        'Conditions pending'
      elsif states.include?('offer') || states.include?('interviewing')
        'Received an offer'
      elsif states.include?('awaiting_provider_decision')
        'Awaiting provider decisions'
      elsif states.include?('conditions_not_met') || states.include?('rejected') || states.include?('declined') || states.include?('withdrawn') || states.include?('offer_withdrawn')
        'Unsuccessful'
      end
    end
  end
end
