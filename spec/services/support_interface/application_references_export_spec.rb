require 'rails_helper'

RSpec.describe SupportInterface::ApplicationReferencesExport do
  describe '#data_for_export' do
    it 'returns an array of hashes containing reference types' do
      application_form_one = create(:application_form)

      create(:reference, feedback_status: 'feedback_refused', referee_type: 'academic', application_form: application_form_one)
      create(:reference, feedback_status: 'feedback_refused', referee_type: 'professional', application_form: application_form_one)
      create(:reference, feedback_status: 'feedback_requested', referee_type: 'school-based', application_form: application_form_one)
      create(:reference, feedback_status: 'feedback_requested', referee_type: 'character', application_form: application_form_one)

      application_form_two = create(:application_form)
      create(:reference, feedback_status: 'feedback_refused', referee_type: 'academic', application_form: application_form_two)

      data = Bullet.profile { described_class.new.data_for_export }

      expect(data).to contain_exactly(
        {
          'Recruitment cycle year' => application_form_one.recruitment_cycle_year,
          'Support ref number' => application_form_one.support_reference,
          'Phase' => application_form_one.phase,
          'Application state' => ProcessState.new(application_form_one).state,
          'Ref 1 type' => application_form_one.application_references[0].referee_type,
          'Ref 1 state' => application_form_one.application_references[0].feedback_status,
          'Ref 1 requested at' => application_form_one.application_references[0].requested_at,
          'Ref 2 type' => application_form_one.application_references[1].referee_type,
          'Ref 2 state' => application_form_one.application_references[1].feedback_status,
          'Ref 2 requested at' => application_form_one.application_references[0].requested_at,
          'Ref 3 type' => application_form_one.application_references[2].referee_type,
          'Ref 3 state' => application_form_one.application_references[2].feedback_status,
          'Ref 3 requested at' => application_form_one.application_references[0].requested_at,
          'Ref 4 type' => application_form_one.application_references[3].referee_type,
          'Ref 4 state' => application_form_one.application_references[3].feedback_status,
          'Ref 4 requested at' => application_form_one.application_references[0].requested_at,
        },
        {
          'Recruitment cycle year' => application_form_two.recruitment_cycle_year,
          'Support ref number' => application_form_two.support_reference,
          'Phase' => application_form_two.phase,
          'Application state' => ProcessState.new(application_form_two).state,
          'Ref 1 type' => application_form_two.application_references[0].referee_type,
          'Ref 1 state' => application_form_two.application_references[0].feedback_status,
          'Ref 1 requested at' => application_form_one.application_references[0].requested_at,
        },
      )
    end
  end
end
