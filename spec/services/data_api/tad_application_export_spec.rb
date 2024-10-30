require 'rails_helper'

RSpec.describe DataAPI::TADApplicationExport, :with_audited do
  describe '#as_json' do
    it 'returns json' do
      application_choice = create(:application_choice, :offer_deferred_after_recruitment)
      application_form = application_choice.application_form
      candidate = application_choice.candidate
      equality_and_diversity = application_form.equality_and_diversity.to_h
      degree = application_form.application_qualifications.find { |q| q.level == 'degree' }
      accrediting_provider = application_choice.current_accredited_provider || application_choice.current_provider

      application_choice.update!(status: :recruited) # confirm deferred offer

      export = described_class.new(application_choice)
      expected_response = {
        extract_date: Time.zone.now.iso8601,
        candidate_id: candidate.id,
        application_choice_id: application_choice.id,
        application_form_id: application_form.id,
        status: 'recruited',
        phase: 'apply_1',
        submitted_at: application_form.submitted_at.iso8601,
        first_name: application_form.first_name,
        last_name: application_form.last_name,
        date_of_birth: Date.new(
          application_form.date_of_birth.year,
          application_form.date_of_birth.month,
          application_form.date_of_birth.day,
        ),
        email: candidate.email_address,
        postcode: application_form.postcode,
        country: application_form.country,
        nationality: 'GB|US',
        sex: equality_and_diversity['hesa_sex'],
        disability: equality_and_diversity['hesa_disabilities'],
        ethnicity: equality_and_diversity['hesa_ethnicity'],
        degree_classification: degree&.grade,
        degree_classification_hesa_code: degree&.grade_hesa_code,
        provider_code: application_choice.current_provider.code,
        provider_id: application_choice.current_provider.id,
        provider_name: application_choice.current_provider.name,
        accrediting_provider_code: accrediting_provider.code,
        accrediting_provider_id: accrediting_provider.id,
        accrediting_provider_name: accrediting_provider.name,
        course_level: application_choice.current_course.level,
        program_type: application_choice.current_course.program_type,
        programme_outcome: application_choice.current_course.description,
        course_name: application_choice.current_course.name,
        course_code: application_choice.current_course.code,
        nctl_subject: application_choice.current_course.subjects.map(&:code).join,
        offer_deferred_at: application_choice.offer_deferred_at.iso8601,
        offer_originally_deferred_at: application_choice.offer_deferred_at.iso8601,
        offer_reconfirmed_at: application_choice.audits.last.created_at.iso8601,
        offer_reconfirmed_cycle_year: RecruitmentCycle.current_year,
        recruitment_cycle_year: application_choice.recruitment_cycle,
        accepted_at: application_choice.accepted_at.iso8601,
        withdrawn_at: nil,
      }

      expect(export.as_json).to eq(expected_response)
    end

    context 'when application_choice.offer_deferred_at has changed' do
      it 'returns json with with original offer_deffered_at' do
        application_choice = create(:application_choice, :offer_deferred)

        original_offer_deferred_at = application_choice.offer_deferred_at.iso8601
        application_choice.update!(offer_deferred_at: 2.days.from_now)
        json = described_class.new(application_choice).as_json

        expect(json[:offer_originally_deferred_at]).to eq(original_offer_deferred_at)
      end
    end

    context 'when application_choice offer is not deferred' do
      it 'returns export json without offer_deferred timestamps' do
        application_choice = create(:application_choice, :accepted)

        json = described_class.new(application_choice).as_json

        expect(json[:offer_originally_deferred_at]).to be_nil
        expect(json[:offer_reconfirmed_at]).to be_nil
        expect(json[:offer_reconfirmed_cycle_year]).to be_nil
      end
    end

    context 'when application_choice is withdrawn' do
      it 'returns json with withdrawn_at' do
        application_choice = create(:application_choice, :withdrawn)

        json = described_class.new(application_choice).as_json

        expect(json[:withdrawn_at]).to eq(application_choice.withdrawn_at.iso8601)
      end
    end
  end
end
