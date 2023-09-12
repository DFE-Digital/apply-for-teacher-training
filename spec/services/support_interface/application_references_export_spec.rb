require 'rails_helper'

RSpec.describe SupportInterface::ApplicationReferencesExport, :bullet do
  describe 'documentation' do
    before do
      application_form = create(:application_form)
      create(:reference, feedback_status: 'feedback_refused', referee_type: 'academic', application_form:)
      create(:reference, feedback_status: 'feedback_refused', referee_type: 'professional', application_form:)
      create(:reference, feedback_status: 'feedback_requested', referee_type: 'school-based', application_form:)
      create(:reference, feedback_status: 'feedback_requested', referee_type: 'character', application_form:)
    end

    it_behaves_like 'a data export'
  end

  describe '#data_for_export' do
    it 'returns an array of hashes containing non duplicate reference types' do
      application_form_one = create(:application_form, created_at: 1.day.ago)

      ref1 = create(:reference, feedback_status: 'feedback_refused', referee_type: 'academic', application_form: application_form_one)
      ref2 = create(:reference, feedback_status: 'feedback_refused', referee_type: 'professional', application_form: application_form_one)
      ref3 = create(:reference, feedback_status: 'feedback_requested', referee_type: 'school-based', application_form: application_form_one)
      ref4 = create(:reference, feedback_status: 'feedback_requested', referee_type: 'character', application_form: application_form_one)

      ref3.update!(feedback_status: 'feedback_provided')
      ref4.update!(feedback_status: 'feedback_provided')

      application_form_two = DuplicateApplication.new(
        application_form_one,
        target_phase: 'apply_2',
      ).duplicate

      new_reference1 = create(:reference, feedback_status: 'feedback_refused', referee_type: 'academic', application_form: application_form_two)
      new_reference2 = create(:reference, feedback_status: 'feedback_provided', referee_type: 'school-based', application_form: application_form_two)

      data = Bullet.profile { described_class.new.data_for_export }

      expect(data).to contain_exactly(
        {
          recruitment_cycle_year: application_form_one.recruitment_cycle_year,
          support_reference: application_form_one.support_reference,
          phase: application_form_one.phase,
          application_state: ApplicationFormStateInferrer.new(application_form_one).state,
          ref_1_type: ref1.referee_type,
          ref_1_state: ref1.feedback_status,
          ref_1_requested_at: ref1.requested_at,
          ref_1_received_at: nil,
          ref_2_type: ref2.referee_type,
          ref_2_state: ref2.feedback_status,
          ref_2_requested_at: ref2.requested_at,
          ref_2_received_at: nil,
          ref_3_type: ref3.referee_type,
          ref_3_state: ref3.feedback_status,
          ref_3_requested_at: ref3.requested_at,
          ref_3_received_at: ref3.feedback_provided_at,
          ref_4_type: ref4.referee_type,
          ref_4_state: ref4.feedback_status,
          ref_4_requested_at: ref4.requested_at,
          ref_4_received_at: ref4.feedback_provided_at,
        },
        {
          recruitment_cycle_year: application_form_two.recruitment_cycle_year,
          support_reference: application_form_two.support_reference,
          phase: application_form_two.phase,
          application_state: ApplicationFormStateInferrer.new(application_form_two).state,
          ref_1_type: new_reference1.referee_type,
          ref_1_state: new_reference1.feedback_status,
          ref_1_requested_at: new_reference1.requested_at,
          ref_1_received_at: nil,
          ref_2_type: new_reference2.referee_type,
          ref_2_state: new_reference2.feedback_status,
          ref_2_requested_at: new_reference2.requested_at,
          ref_2_received_at: new_reference2.feedback_provided_at,
        },
      )

      expect(application_form_two.reload.application_references.count).to eq(4)
    end
  end
end
