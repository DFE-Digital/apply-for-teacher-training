require 'rails_helper'

RSpec.describe CandidateInterface::CourseReviewComponent do
  describe 'course_fee' do
    let(:application_choice) do
      create(:application_choice,
             current_course_option: create(:course_option,
                                           course: create(:course, funding_type:, fee_domestic:, fee_international:)))
    end

    context 'when course is not fee based' do
      let(:fee_domestic) { 9250 }
      let(:fee_international) { 23820 }
      let(:funding_type) { %w[salary apprenticeship].sample }

      it 'does not show the course fee row' do
        result = render_inline(described_class.new(application_choice:))
        expect(result.text).not_to include 'Course fee'
        expect(result.text).not_to include 'UK students: £9,250'
        expect(result.text).not_to include 'International students: £23,820'
      end
    end

    context 'where domestic and international fees present' do
      let(:fee_domestic) { 9250 }
      let(:fee_international) { 23820 }
      let(:funding_type) { 'fee' }

      it 'shows both domestic and international fees' do
        result = render_inline(described_class.new(application_choice:))
        expect(result.text).to include 'Course fee'
        expect(result.text).to include 'UK students: £9,250'
        expect(result.text).to include 'International students: £23,820'
      end
    end

    context 'where only domestic fees are present' do
      let(:fee_domestic) { 9250 }
      let(:fee_international) { nil }
      let(:funding_type) { 'fee' }

      it 'shows only domestic fees' do
        result = render_inline(described_class.new(application_choice:))
        expect(result.text).to include 'Course fee'
        expect(result.text).to include 'UK students: £9,250'
        expect(result.text).not_to include 'International students:'
      end
    end

    context 'where only international fees are present' do
      let(:fee_domestic) { nil }
      let(:fee_international) { 23820 }
      let(:funding_type) { 'fee' }

      it 'shows only international fees' do
        result = render_inline(described_class.new(application_choice:))
        expect(result.text).to include 'Course fee'
        expect(result.text).not_to include 'UK students:'
        expect(result.text).to include 'International students: £23,820'
      end
    end
  end

  describe 'degree requirements' do
    let(:application_choice) { create(:application_choice, course_option: create(:course_option, course:)) }

    context 'when course is undergraduate but incorrectly has a degree_grade' do
      let(:course) do
        create(
          :course,
          :teacher_degree_apprenticeship,
          degree_grade: 'two_one',
        )
      end

      it 'does not render row' do
        result = render_inline(described_class.new(application_choice:))
        expect(result.text).not_to include('Degree requirements')
      end
    end

    context 'when course is postgraduate and degree grade is present' do
      let(:course) { create(:course, degree_grade: 'two_one') }

      it 'does render row' do
        result = render_inline(described_class.new(application_choice:))
        expect(result.text).to include('Degree requirements')
      end
    end

    context 'when course is postgraduate and degree grade is blank' do
      let(:course) { create(:course, degree_grade: nil) }

      it 'does not render row' do
        result = render_inline(described_class.new(application_choice:))
        expect(result.text).not_to include('Degree requirements')
      end
    end
  end
end
