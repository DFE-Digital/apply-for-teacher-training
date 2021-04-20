require 'rails_helper'

RSpec.describe SupportInterface::ApplicationReferencesExport do
  describe 'documentation' do
    before do
      application_form = create(:application_form)
      create(:reference, feedback_status: 'feedback_refused', referee_type: 'academic', application_form: application_form)
      create(:reference, feedback_status: 'feedback_refused', referee_type: 'professional', application_form: application_form)
      create(:reference, feedback_status: 'feedback_requested', referee_type: 'school-based', application_form: application_form)
      create(:reference, feedback_status: 'feedback_requested', referee_type: 'character', application_form: application_form)
    end

    it_behaves_like 'a data export'
  end

  describe '#data_for_export' do
    it 'returns an array of hashes containing reference types' do
      application_form_one = create(:application_form, created_at: 1.day.ago)

      create(:reference, feedback_status: 'feedback_refused', referee_type: 'academic', application_form: application_form_one)
      create(:reference, feedback_status: 'feedback_refused', referee_type: 'professional', application_form: application_form_one)
      create(:reference, feedback_status: 'feedback_requested', referee_type: 'school-based', application_form: application_form_one)
      create(:reference, feedback_status: 'feedback_requested', referee_type: 'character', application_form: application_form_one)

      application_form_one.application_references[3].update!(feedback_status: 'feedback_provided')

      application_form_two = create(:application_form, created_at: 1.day.ago)
      create(:reference, feedback_status: 'feedback_refused', referee_type: 'academic', application_form: application_form_two)

      data = Bullet.profile { described_class.new.data_for_export }

      expect(data).to contain_exactly(
        {
          recruitment_cycle_year: application_form_one.recruitment_cycle_year,
          support_reference: application_form_one.support_reference,
          phase: application_form_one.phase,
          application_state: ProcessState.new(application_form_one).state,
          ref_1_type: application_form_one.application_references[0].referee_type,
          ref_1_state: application_form_one.application_references[0].feedback_status,
          ref_1_requested_at: application_form_one.application_references[0].requested_at,
          ref_1_received_at: nil,
          ref_2_type: application_form_one.application_references[1].referee_type,
          ref_2_state: application_form_one.application_references[1].feedback_status,
          ref_2_requested_at: application_form_one.application_references[1].requested_at,
          ref_2_received_at: nil,
          ref_3_type: application_form_one.application_references[2].referee_type,
          ref_3_state: application_form_one.application_references[2].feedback_status,
          ref_3_requested_at: application_form_one.application_references[2].requested_at,
          ref_3_received_at: nil,
          ref_4_type: application_form_one.application_references[3].referee_type,
          ref_4_state: application_form_one.application_references[3].feedback_status,
          ref_4_requested_at: application_form_one.application_references[3].requested_at,
          ref_4_received_at: application_form_one.application_references[3].feedback_provided_at,
        },
        {
          recruitment_cycle_year: application_form_two.recruitment_cycle_year,
          support_reference: application_form_two.support_reference,
          phase: application_form_two.phase,
          application_state: ProcessState.new(application_form_two).state,
          ref_1_type: application_form_two.application_references[0].referee_type,
          ref_1_state: application_form_two.application_references[0].feedback_status,
          ref_1_requested_at: application_form_one.application_references[0].requested_at,
          ref_1_received_at: nil,
        },
      )
    end
  end
end
