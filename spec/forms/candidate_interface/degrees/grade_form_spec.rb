require 'rails_helper'

RSpec.describe CandidateInterface::Degrees::GradeForm do
  subject(:grade_form) { described_class.new(store, degree_params) }

  let(:store) { instance_double(WizardStateStores::RedisStore) }
  let(:application_form) { create(:application_form) }

  before do
    allow(store).to receive(:read)
  end

  describe 'sanitize attributes' do
    # This method is called by the parent class when the class is initialized
    context 'an candidate has selected yes (international candidates) or other (uk candidates)' do
      let(:degree_params) do
        {
          grade: %w[Yes Other].sample,
          other_grade: nil,
          other_grade_raw: '3.9 GPA',
        }
      end

      it 'the attributes are not changed' do
        expect(grade_form.other_grade_raw).to eq '3.9 GPA'
      end
    end

    context 'a candidate has selected a defined grade' do
      let(:degree_params) do
        {
          grade: 'Third-class honours',
          other_grade: 'some text here',
          other_grade_raw: '3.9 GPA',
        }
      end

      it 'clears the other grade data' do
        expect(grade_form.grade).to eq 'Third-class honours'
        expect(grade_form.other_grade).to be_nil
        expect(grade_form.other_grade_raw).to be_nil
      end
    end
  end

  describe 'grade validation' do
    context 'when specified grades are required' do
      let(:degree_params) { { degree_level: %w[master bachelor].sample, grade: '' } }

      it 'returns the correct validation message' do
        expect(grade_form.valid?).to be false
        expect(grade_form.errors[:grade]).to eq ['Select your degree grade']
      end
    end

    context 'when specified grades are not required' do
      let(:degree_params) { { degree_level: 'doctor', grade: '' } }

      it 'returns the correct validation message' do
        expect(grade_form.valid?).to be false
        expect(grade_form.errors[:grade]).to eq ['Select if your qualification gives a grade']
      end
    end

    context 'other_grade missing, validation' do
      let(:degree_params) do
        { degree_level: %w[master bachelor].sample, grade: 'Other', other_grade: nil, other_grade_raw: nil }
      end

      it 'returns the correct validation message' do
        expect(grade_form.valid?).to be false
        expect(grade_form.errors[:other_grade]).to eq ['Enter your degree grade']
      end
    end

    context 'other grade, too long, validation' do
      let(:degree_params) do
        {
          degree_level: %w[master bachelor].sample,
          grade: 'Other',
          other_grade: nil,
          other_grade_raw: Faker::Lorem.sentence(word_count: 256),
        }
      end

      it 'returns the correct validation message' do
        expect(grade_form.valid?).to be false
        expect(grade_form.errors[:other_grade]).to eq ['Your degree grade must be 255 characters or fewer']
      end
    end
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
        expect(grade_form.next_step).to eq :review
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
        expect(grade_form.next_step).to eq :start_year
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
        expect(grade_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_review_path
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
        expect(grade_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_completed_path
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
        expect(grade_form.other_grade).to eq(other_grade_raw)
      end
    end

    context 'when other grade raw is empty' do
      let(:other_grade_raw) { '' }

      it 'returns raw value' do
        expect(grade_form.other_grade).to eq(other_grade_raw)
      end
    end

    context 'when other grade raw is nil' do
      let(:other_grade_raw) { nil }

      it 'returns original value' do
        expect(grade_form.other_grade).to eq('Aegrotat')
      end
    end
  end
end
