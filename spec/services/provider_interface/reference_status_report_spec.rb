require 'rails_helper'

RSpec.describe ProviderInterface::ReferenceStatusReport do
  let(:reference_const) { 'Reference' }
  let(:provider) { create(:provider) }

  subject(:report_service) { described_class.new(provider) }

  describe '#headers' do
    it 'returns the correct headers' do
      expect(report_service.headers).to eq([
        'Referee name',
        'Reference status',
      ])
    end
  end

  describe '#application_link' do
    it 'returns the correct application link' do
      row = instance_double(reference_const, application_choice_id: 123)

      report_service = described_class.new(nil)
      link = report_service.application_link(row)

      expected_link = Rails.application.routes.url_helpers.provider_interface_application_choice_references_path(123)
      expect(link).to eq(expected_link)
    end
  end

  describe '#feedback_status_label' do
    it 'returns "Sent" for "feedback_requested"' do
      expect(report_service.feedback_status_label('feedback_requested')).to eq('Not Received')
    end

    it 'returns "Received" for "feedback_provided"' do
      expect(report_service.feedback_status_label('feedback_provided')).to eq('Received')
    end

    it 'returns "Other" for unknown status' do
      expect(report_service.feedback_status_label('unknown_status')).to eq('Other')
    end
  end

  describe '#rows' do
    context 'when there are rows with feedback status' do
      it 'returns rows with correct header and values' do
        application_choice1 = create(:application_choice, :with_completed_application_form)
        application_choice2 = create(:application_choice, :with_completed_application_form)
        reference1 = create(:reference, :feedback_requested, application_form: application_choice1.application_form)
        reference2 = create(:reference, :feedback_provided, application_form: application_choice2.application_form)
        rows_with_feedback =
          [
            instance_double(reference_const, feedback_status: reference1.feedback_status, name: reference1.name, application_choice_id: application_choice1.id, application_form: application_choice1.application_form),
            instance_double(reference_const, feedback_status: reference2.feedback_status, name: reference2.name, application_choice_id: application_choice2.id, application_form: application_choice2.application_form),
          ]
        report_service = described_class.new(nil)
        # Stub the report_data method to return the test data
        allow(report_service).to receive(:report_data).and_return(rows_with_feedback)

        expected_rows = [
          {
            header: application_choice1.application_form.full_name,
            link: Rails.application.routes.url_helpers.provider_interface_application_choice_references_path(application_choice1.id),
            values: [
              [
                reference1.name,
                'Not Received',
              ],
            ],
          },
          {
            header: application_choice2.application_form.full_name,
            link: Rails.application.routes.url_helpers.provider_interface_application_choice_references_path(application_choice2.id),
            values: [
              [
                reference2.name,
                'Received',
              ],
            ],
          },
        ]
        expect(report_service.rows).to eq(expected_rows)
      end
    end
  end
end
