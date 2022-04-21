require 'rails_helper'

RSpec.describe CandidateInterface::DegreeSubjectForm do
  describe '#subject' do
    subject(:form) do
      described_class.new(
        subject: 'Chemistry',
        subject_raw: subject_raw,
      )
    end

    context 'when subject raw is present' do
      let(:subject_raw) { 'Math' }

      it 'returns raw value' do
        expect(form.subject).to eq(subject_raw)
      end
    end

    context 'when subject raw is empty' do
      let(:subject_raw) { '' }

      it 'returns raw value' do
        expect(form.subject).to eq(subject_raw)
      end
    end

    context 'when subject raw is nil' do
      let(:subject_raw) { nil }

      it 'returns original value' do
        expect(form.subject).to eq('Chemistry')
      end
    end
  end

  describe '#save' do
    context 'when missing subject' do
      it 'returns false and has errors' do
        form = described_class.new

        expect(form.save).to be false
        expect(form.errors.full_messages).to eq ['Subject Enter your degree subject']
      end
    end

    context 'when subject matches a HESA entry' do
      let(:form) do
        described_class.new(
          degree: build(:degree_qualification), subject: 'Metallurgy',
        )
      end

      before do
        form.save
      end

      it 'updates the degree subject and HESA code' do
        expect(form.degree.subject).to eq 'Metallurgy'
        expect(form.degree.subject_hesa_code).to eq '100033'
      end

      it 'updates the degree subject uuid' do
        expect(form.degree.degree_subject_uuid).to eq '317f70f0-5dce-e911-a985-000d3ab79618'
      end
    end

    context 'when subject does not match a HESA entry' do
      let(:form) do
        described_class.new(
          degree: build(:degree_qualification), subject: 'Non-HESA subject',
        )
      end

      before do
        form.save
      end

      it 'updates the degree subject' do
        expect(form.degree.subject).to eq 'Non-HESA subject'
        expect(form.degree.subject_hesa_code).to be_nil
      end

      it 'saves the subject uuid as nil' do
        expect(form.degree.degree_subject_uuid).to be_nil
      end
    end
  end
end
