require 'rails_helper'

RSpec.describe CandidateInterface::DegreeSubjectForm do
  describe '#save' do
    context 'when missing subject' do
      it 'returns false and has errors' do
        form = described_class.new

        expect(form.save).to eq false
        expect(form.errors.full_messages).to eq ['Subject Enter your degree subject']
      end
    end

    context 'when subject matches a HESA entry' do
      it 'updates the degree subject and HESA code' do
        form = described_class.new(
          degree: build(:degree_qualification), subject: 'Metallurgy',
        )

        form.save

        expect(form.degree.subject).to eq 'Metallurgy'
        expect(form.degree.subject_hesa_code).to eq '100033'
      end
    end

    context 'when subject does not match a HESA entry' do
      it 'updates the degree subject' do
        form = described_class.new(
          degree: build(:degree_qualification), subject: 'Non-HESA subject',
        )

        form.save

        expect(form.degree.subject).to eq 'Non-HESA subject'
        expect(form.degree.subject_hesa_code).to eq nil
      end
    end
  end
end
