require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::PreviousTeacherTrainings::TeacherTrainingForm, type: :model do
  subject(:form) { described_class.new(previous_teacher_training) }

  let(:previous_teacher_training) { create(:previous_teacher_training) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:provider_name) }
    it { is_expected.to validate_length_of(:provider_name).is_at_most(100) }
    it { is_expected.to validate_presence_of(:details) }
    it { is_expected.to validate_presence_of(:audit_comment) }

    context 'when the details are too long' do
      before do
        form.assign_attributes(details: 'a ' * 201)
      end

      it 'returns false and adds an error message' do
        expect(form.save).to be(false)
        expect(form.errors[:details]).to eq(
          ['Your answer must be 200 words or less. You have 1 words too many.'],
        )
      end
    end

    context 'when started_at is nil' do
      let(:previous_teacher_training) { build(:previous_teacher_training, started_at: nil) }

      it 'is invalid' do
        expect(form.valid?).to be(false)
        expect(form.errors[:started_at]).to contain_exactly('Enter the date that the candidate started the training course')
      end
    end

    context 'when start_date_month is invalid' do
      let(:previous_teacher_training) { build(:previous_teacher_training) }

      it 'is invalid' do
        form.start_date_month = ''
        form.start_date_year = 2005

        expect(form.valid?).to be(false)
        expect(form.errors[:started_at]).to contain_exactly('Enter the month that the candidate started the training course')
      end
    end

    context 'when start_date_year is invalid' do
      let(:previous_teacher_training) { build(:previous_teacher_training) }

      it 'is invalid' do
        form.start_date_month = 1
        form.start_date_year = ''

        expect(form.valid?).to be(false)
        expect(form.errors[:started_at]).to contain_exactly('Enter the year that the candidate started the training course')
      end
    end

    context 'when started_at is after ended_at' do
      let(:previous_teacher_training) do
        build(
          :previous_teacher_training,
          started_at: Time.zone.now,
          ended_at: 2.years.ago,
          )
      end

      it 'is invalid' do
        expect(form.valid?).to be(false)
        expect(form.errors[:started_at]).to contain_exactly(
          'Enter a course start date that is before the date the candidate left the course',
        )
      end
    end

    context 'when ended_at is nil' do
      let(:previous_teacher_training) { build(:previous_teacher_training, ended_at: nil) }

      it 'is invalid' do
        expect(form.valid?).to be(false)
        expect(form.errors[:ended_at]).to contain_exactly('Enter the date that the candidate left the training course')
      end
    end

    context 'when end_date_month is invalid' do
      let(:previous_teacher_training) { build(:previous_teacher_training) }

      it 'is invalid' do
        form.end_date_month = ''
        form.end_date_year = 2005

        expect(form.valid?).to be(false)
        expect(form.errors[:ended_at]).to contain_exactly('Enter the month that the candidate left the training course')
      end
    end

    context 'when end_date_year is invalid' do
      let(:previous_teacher_training) { build(:previous_teacher_training) }

      it 'is invalid' do
        form.end_date_month = 1
        form.end_date_year = ''

        expect(form.valid?).to be(false)
        expect(form.errors[:ended_at]).to contain_exactly('Enter the year that the candidate left the training course')
      end
    end
  end

  describe '.providers' do
    it 'returns an array of all providers' do
      create_list(:provider, 2)

      expect(form.providers.count).to eq(3) # 2 created + previous teacher training provider
    end
  end

  describe '#save' do
    context 'when the attributes are not valid' do
      before do
        form.assign_attributes(
          provider_name: nil,
          details: nil,
          audit_comment: nil,
          start_date_month: nil,
          start_date_year: nil,
          end_date_month: nil,
          end_date_year: nil,
        )
      end

      it 'returns false' do
        expect(form.save).to be(false)

        expect(form.errors[:provider_name]).to eq(['Enter the name of the training provider'])
        expect(form.errors[:details]).to eq(['Enter details about the previous teacher training courses'])
        expect(form.errors[:audit_comment]).to eq(['Enter a Zendesk ticket URL'])
      end
    end

    context 'when the attributes are valid' do
      before do
        form.assign_attributes(
          provider_name: 'Test Provider',
          start_date_month: 1,
          start_date_year: 2020,
          end_date_month: 12,
          end_date_year: 2020,
          details: 'Test details',
          audit_comment: 'https://becomingateacher.zendesk.com/agent/tickets/12345',
        )
      end

      it 'returns true and updates the previous teacher training' do
        expect(form.save).to be(true)
        previous_teacher_training.reload

        expect(previous_teacher_training.started).to eq('yes')
        expect(previous_teacher_training.status).to eq('published')
        expect(previous_teacher_training.provider_name).to eq('Test Provider')
        expect(previous_teacher_training.started_at).to eq(Date.new(2020, 1))
        expect(previous_teacher_training.ended_at).to eq(Date.new(2020, 12))
        expect(previous_teacher_training.details).to eq('Test details')
      end
    end
  end
end
