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

  describe '#set_course_option_id' do
    context 'existing course option id is valid for selected course' do
      it 'does not change course_option_id' do
        original_course_option = create(:course_option)
        subject = described_class.new(
          course_option_id: original_course_option.id,
          provider_id: original_course_option.provider.id,
          course_id: original_course_option.course_id,
          study_mode: original_course_option.study_mode,
        )
        subject.set_course_option_id
        expect(subject.course_option_id).to eq original_course_option.id
      end
    end

    context 'existing course option id is not valid for selected course, but site is' do
      it 'updates the course option to one with the same site' do
        original_course_option = create(:course_option)
        new_course = create(:course, provider: original_course_option.provider)
        new_course_option = create(
          :course_option,
          course: new_course,
          site: original_course_option.site,
          study_mode: original_course_option.study_mode,
        )
        subject = described_class.new(
          course_option_id: original_course_option.id,
          provider_id: original_course_option.provider.id,
          course_id: new_course_option.course_id,
          study_mode: original_course_option.study_mode,
        )
        subject.set_course_option_id
        expect(subject.course_option_id).to eq new_course_option.id
      end
    end

    context 'when site is not valid for selected course' do
      it 'returns an empty string' do
        original_course_option = create(:course_option)
        new_course = create(:course, provider: original_course_option.provider)
        new_course_option = create(
          :course_option,
          course: new_course,
          study_mode: original_course_option.study_mode,
        )
        subject = described_class.new(
          course_option_id: original_course_option.id,
          provider_id: original_course_option.provider.id,
          course_id: new_course_option.course_id,
          study_mode: original_course_option.study_mode,
        )
        subject.set_course_option_id
        expect(subject.course_option_id).to eq ''
      end
    end
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
          course_option_id_raw: course_option.site.name_and_address(' - '),
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
