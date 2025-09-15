require 'rails_helper'

RSpec.describe CandidateInterface::CourseChoices::CourseSiteStep do
  subject(:course_site_step) do
    described_class.new(provider_id:, course_id:, course_option_id:)
  end

  let(:provider_id) { nil }
  let(:course_id) { nil }
  let(:course_option_id) { nil }

  describe '.route_name' do
    subject { course_site_step.class.route_name }

    it { is_expected.to eq('candidate_interface_course_choices_course_site') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:course_option_id) }

    context 'when there are fewer than 20 course sites' do
      let(:course) { create(:course) }
      let(:course_options) { create_list(:course_option, 19, :full_time, course:) }

      it 'valid without course_option_id_raw on course option id' do
        course_site_step = described_class.new(
          study_mode: 'full_time',
          provider_id: course.provider_id,
          course_id: course.id,
          course_option_id: course_options.pluck(:id).sample,
        )
        expect(course_site_step.valid?).to be true
      end
    end

    context 'when there are more than 20 course sites' do
      let(:course) { create(:course) }
      let(:course_options) { create_list(:course_option, 21, :full_time, course:) }

      it 'invalid with blank course_option_id_raw' do
        course_site_step = described_class.new(
          study_mode: 'full_time',
          provider_id: course.provider_id,
          course_id: course.id,
          course_option_id: course_options.pluck(:id).sample,
          course_option_id_raw: '',
        )
        expect(course_site_step.valid?).to be false
      end

      it 'invalid with random course_option_id_raw text' do
        course_site_step = described_class.new(
          study_mode: 'full_time',
          provider_id: course.provider_id,
          course_id: course.id,
          course_option_id: course_options.pluck(:id).sample,
          course_option_id_raw: 'blah blah',
        )
        expect(course_site_step.valid?).to be false
      end

      it 'valid when course option id matches raw valid for course option' do
        course_option = course_options.first

        course_site_step = described_class.new(
          study_mode: 'full_time',
          provider_id: course.provider_id,
          course_id: course.id,
          course_option_id: course_option.id,
          course_option_id_raw: "#{course_option.site.name} - #{course_option.site.full_address}",
        )
        expect(course_site_step.valid?).to be true
      end
    end
  end

  describe '#next_step' do
    it 'returns :course_study_mode' do
      expect(course_site_step.next_step).to be(:course_review)
    end
  end
end
