require 'rails_helper'

RSpec.describe SupportInterface::ApplicationReferencesExport do
  describe '#data_for_export' do
    it 'returns an array of hashes containing reference types' do
      application_form = create(:application_form)

      create(:reference, feedback_status: 'feedback_refused', referee_type: 'academic', application_form: application_form)
      create(:reference, feedback_status: 'feedback_refused', referee_type: 'professional', application_form: application_form)
      create(:reference, feedback_status: 'feedback_requested', referee_type: 'school-based', application_form: application_form)
      create(:reference, feedback_status: 'feedback_requested', referee_type: 'character', application_form: application_form)

      expect(described_class.new.data_for_export).to match_array(
        [
          return_expected_hash(application_form),
        ],
      )
    end
  end

  def return_expected_hash(application_form)
    {
      'Support ref number' => application_form.support_reference,
      'Phase' => application_form.phase,
      'Application state' => ProcessState.new(application_form).state,
      'Ref 1 type' => application_form.application_references[0].referee_type,
      'Ref 1 state' => application_form.application_references[0].feedback_status,
      'Ref 2 type' => application_form.application_references[1].referee_type,
      'Ref 2 state' => application_form.application_references[1].feedback_status,
      'Ref 3 type' => application_form.application_references[2].referee_type,
      'Ref 3 state' => application_form.application_references[2].feedback_status,
      'Ref 4 type' => application_form.application_references[3].referee_type,
      'Ref 4 state' => application_form.application_references[3].feedback_status,
    }
  end
end
