require 'rails_helper'

RSpec.describe CandidateInterface::AddAnotherCourseForm, type: :model do
  let(:form) { described_class.new(add_another_course) }
  let(:add_another_course) do
    { 'add_another_course' => 'yes' }
  end

  it { is_expected.to validate_presence_of(:add_another_course) }

  describe '#add_another_course?' do
    context 'when the add_another_course value is yes' do
      it 'returns true' do
        expect(form.add_another_course?).to be_truthy
      end
    end

    context 'when the add_another_course value is no' do
      let(:add_another_course) do
        { 'add_another_course' => 'no' }
      end

      it 'returns false' do
        expect(form.add_another_course?).to be_falsey
      end
    end
  end
end
