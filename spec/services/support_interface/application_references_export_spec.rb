require 'rails_helper'

RSpec.describe SupportInterface::ApplicationReferencesExport do
  describe '#call' do
    it 'returns an array of hashes containing reference types' do
      application_form = create(:application_form)

      create(:reference, feedback_status: 'feedback_refused', referee_type: 'academic', application_form: application_form)
      create(:reference, feedback_status: 'feedback_refused', referee_type: 'professional', application_form: application_form)
      create(:reference, feedback_status: 'feedback_requested', referee_type: 'school-based', application_form: application_form)
      create(:reference, feedback_status: 'feedback_requested', referee_type: 'character', application_form: application_form)

      expect(described_class.call).to match_array(
        [
          return_expected_hash(application_form),
        ],
      )
    end
  end

  describe '#header_row' do
    it 'returns an array containing column headings' do
      expect(described_class.header_row).to eq(
        [
          'Support Ref Number',
          'Phase',
          'Ref 1 type',
          'Ref 1 state',
          'Ref 2 type',
          'Ref 2 state',
          'Ref 3 type',
          'Ref 3 state',
          'Ref 4 type',
          'Ref 4 state',
          'Ref 5 type',
          'Ref 5 state',
          'Ref 6 type',
          'Ref 6 state',
          'Ref 7 type',
          'Ref 7 state',
          'Ref 8 type',
          'Ref 8 state',
          'Ref 9 type',
          'Ref 9 state',
          'Ref 10 type',
          'Ref 10 state',
        ],
      )
    end
  end

  def return_expected_hash(application_form)
    {
      'Support Ref Number' => application_form.support_reference,
      'Phase' => application_form.phase,
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
