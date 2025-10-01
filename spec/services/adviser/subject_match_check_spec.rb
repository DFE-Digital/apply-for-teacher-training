require 'rails_helper'

RSpec.describe Adviser::SubjectMatchCheck do
  describe 'quickfire_subject_match?' do
    context 'when there is a matching uuid' do
      let(:degree_subject) { Hesa::Subject.find_by_name('Mathematics') }
      let(:degree) do
        create(:degree_qualification, degree_subject_uuid: degree_subject.id, subject: degree_subject.name)
      end

      it 'returns true' do
        expect(described_class.quickfire_subject_match?(degree)).to be true
      end
    end

    context 'when there is a uuid that does not match' do
      let(:degree_subject) { Hesa::Subject.find_by_name('History') }
      let(:degree) do
        create(:degree_qualification, degree_subject_uuid: degree_subject.id, subject: degree_subject.name)
      end

      it 'returns false' do
        expect(described_class.quickfire_subject_match?(degree)).to be false
      end
    end

    context 'when the free text matches a synonym' do
      let(:degree) do
        create(:degree_qualification, degree_subject_uuid: nil, subject: 'Applied Maths')
      end

      it 'returns true' do
        expect(described_class.quickfire_subject_match?(degree)).to be true
      end
    end

    context 'when the free text matches a suggestion' do
      let(:degree) do
        create(:degree_qualification, degree_subject_uuid: nil, subject: 'mfl')
      end

      it 'returns true' do
        expect(described_class.quickfire_subject_match?(degree)).to be true
      end
    end

    context 'when free text matches previously identified free text' do
      let(:degree) do
        create(:degree_qualification, degree_subject_uuid: nil, subject: 'applied science and forensic investigation')
      end

      it 'returns true' do
        expect(described_class.quickfire_subject_match?(degree)).to be true
      end
    end

    context 'when free text does not match previously identified free text' do
      let(:degree) do
        create(:degree_qualification, degree_subject_uuid: nil, subject: 'some kind of science')
      end

      it 'returns false' do
        expect(described_class.quickfire_subject_match?(degree)).to be false
      end
    end
  end
end
