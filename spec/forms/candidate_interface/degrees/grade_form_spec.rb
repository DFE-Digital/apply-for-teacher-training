require 'rails_helper'

RSpec.describe CandidateInterface::Degrees::GradeForm do
  subject(:wizard) { described_class.new(store, degree_params) }

  let(:degree_params) { {} }

  let(:store) { instance_double(WizardStateStores::RedisStore) }
  let(:application_form) { create(:application_form) }

  before do
    allow(store).to receive(:read)
    allow(Sentry).to receive(:capture_exception)
  end

  describe '#next_step' do
    context 'reviewing, country unchanged' do
      let(:degree_params) do
        {
          id: create(:degree_qualification, application_form:, institution_country: 'GB').id,
          application_form_id: application_form.id,
          country: 'GB',
        }
      end

      it 'returns to review' do
        expect(wizard.next_step).to eq :review
      end
    end

    context 'reviewing, but country has changed' do
      let(:degree_params) do
        {
          id: create(:degree_qualification, application_form:, institution_country: 'GB').id,
          application_form_id: application_form.id,
          country: 'NG',
        }
      end

      it 'returns goes to start year' do
        expect(wizard.next_step).to eq :start_year
      end
    end
  end

  describe '#back_link' do
    context 'reviewing and country has not changed' do
      let(:degree_params) do
        {
          id: create(:degree_qualification, application_form:, institution_country: 'GB').id,
          application_form_id: application_form.id,
          country: 'GB',
        }
      end

      it 'returns to the review path' do
        expect(wizard.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_review_path
      end
    end

    context 'reviewing, but country has changed' do
      let(:degree_params) do
        {
          id: create(:degree_qualification, application_form:, institution_country: 'GB').id,
          application_form_id: application_form.id,
          country: 'NG',
        }
      end

      it 'returns to degree completed step' do
        expect(wizard.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_completed_path
      end
    end
  end

  describe '#other_grade' do
    let(:degree_params) do
      {
        other_grade: 'Aegrotat',
        other_grade_raw:,
      }
    end

    context 'when other grade raw is present' do
      let(:other_grade_raw) { 'Something' }

      it 'returns raw value' do
        expect(wizard.other_grade).to eq(other_grade_raw)
      end
    end

    context 'when other grade raw is empty' do
      let(:other_grade_raw) { '' }

      it 'returns raw value' do
        expect(wizard.other_grade).to eq(other_grade_raw)
      end
    end

    context 'when other grade raw is nil' do
      let(:other_grade_raw) { nil }

      it 'returns original value' do
        expect(wizard.other_grade).to eq('Aegrotat')
      end
    end
  end
end
