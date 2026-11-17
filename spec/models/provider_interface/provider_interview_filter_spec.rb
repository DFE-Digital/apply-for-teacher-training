require 'rails_helper'

RSpec.describe ProviderInterface::ProviderInterviewFilter do
  let(:provider) { create(:provider) }
  let(:mathematics) { create(:subject, name: 'Mathematics') }
  let(:history) { create(:subject, name: 'History') }
  let(:maths_course) { create(:course, provider:, name: 'Maths course', subjects: [mathematics]) }
  let(:history_course) { create(:course, provider:, name: 'History course', subjects: [history]) }

  let!(:maths_interview) { create_interview_for(maths_course) }
  let!(:history_interview) { create_interview_for(history_course) }

  let(:interviews) { Interview.where(id: [maths_interview.id, history_interview.id]) }

  def create_interview_for(course)
    application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      course_option: create(:course_option, course:),
    )
    create(:interview, :future_date_and_time, application_choice:)
  end

  def build_filter(params = {})
    described_class.new(params: ActionController::Parameters.new(params), interviews:)
  end

  describe '#filters' do
    it 'returns a subject filter with subjects from the interviewed courses' do
      subject_filter = build_filter.filters.first

      expect(subject_filter).to include(type: :checkbox_filter, heading: 'Subject', name: 'subject')
      expect(subject_filter[:options]).to eq(
        [
          { value: history.id, label: 'History', checked: false },
          { value: mathematics.id, label: 'Mathematics', checked: false },
        ],
      )
    end

    it 'returns a course filter with the interviewed courses' do
      course_filter = build_filter.filters.last

      expect(course_filter).to include(type: :checkboxes, heading: 'Course', name: 'course_ids')
      expect(course_filter[:options]).to eq(
        [
          { value: history_course.id, label: history_course.name_and_code, checked: false },
          { value: maths_course.id, label: maths_course.name_and_code, checked: false },
        ],
      )
    end

    it 'does not include subjects or courses without interviews' do
      create(:course, provider:, subjects: [create(:subject, name: 'Physics')])

      labels = build_filter.filters.flat_map { |filter| filter[:options].pluck(:label) }

      expect(labels).not_to include('Physics')
    end

    it 'marks selected options as checked' do
      filter = build_filter(subject: [mathematics.id.to_s], course_ids: [history_course.id.to_s])
      subject_filter, course_filter = filter.filters

      expect(subject_filter[:options].find { |o| o[:value] == mathematics.id }[:checked]).to be(true)
      expect(subject_filter[:options].find { |o| o[:value] == history.id }[:checked]).to be(false)
      expect(course_filter[:options].find { |o| o[:value] == history_course.id }[:checked]).to be(true)
      expect(course_filter[:options].find { |o| o[:value] == maths_course.id }[:checked]).to be(false)
    end
  end

  describe '#filters_applied?' do
    it 'returns false when no filters are applied' do
      expect(build_filter.filters_applied?).to be(false)
    end

    it 'returns false when only blank values are given' do
      expect(build_filter(subject: [''], course_ids: ['']).filters_applied?).to be(false)
    end

    it 'returns true when a subject is selected' do
      expect(build_filter(subject: [mathematics.id.to_s]).filters_applied?).to be(true)
    end

    it 'returns true when a course is selected' do
      expect(build_filter(course_ids: [history_course.id.to_s]).filters_applied?).to be(true)
    end
  end

  describe '#applied_filters' do
    it 'returns all interviews when no filters are applied' do
      expect(build_filter.applied_filters).to contain_exactly(maths_interview, history_interview)
    end

    it 'ignores blank values' do
      expect(build_filter(subject: [''], course_ids: ['']).applied_filters)
        .to contain_exactly(maths_interview, history_interview)
    end

    it 'filters by subject' do
      expect(build_filter(subject: [mathematics.id.to_s]).applied_filters).to contain_exactly(maths_interview)
    end

    it 'filters by course' do
      expect(build_filter(course_ids: [history_course.id.to_s]).applied_filters).to contain_exactly(history_interview)
    end

    it 'filters by multiple subjects' do
      expect(build_filter(subject: [mathematics.id.to_s, history.id.to_s]).applied_filters)
        .to contain_exactly(maths_interview, history_interview)
    end

    it 'combines subject and course filters' do
      filter = build_filter(subject: [mathematics.id.to_s], course_ids: [history_course.id.to_s])

      expect(filter.applied_filters).to be_empty
    end

    context 'when the course has changed' do
      let(:geography) { create(:subject, name: 'Geography') }
      let(:geography_course) { create(:course, provider:, name: 'Geography course', subjects: [geography]) }
      let!(:changed_course_interview) do
        interview = create_interview_for(history_course)
        interview.application_choice.update!(current_course_option: create(:course_option, course: geography_course))
        interview
      end

      let(:interviews) { Interview.where(id: [maths_interview.id, history_interview.id, changed_course_interview.id]) }

      it 'filters by the current course' do
        expect(build_filter(course_ids: [geography_course.id.to_s]).applied_filters)
          .to contain_exactly(changed_course_interview)
        expect(build_filter(course_ids: [history_course.id.to_s]).applied_filters)
          .to contain_exactly(history_interview)
      end

      it 'filters by the subject of the current course' do
        expect(build_filter(subject: [geography.id.to_s]).applied_filters)
          .to contain_exactly(changed_course_interview)
        expect(build_filter(subject: [history.id.to_s]).applied_filters)
          .to contain_exactly(history_interview)
      end
    end
  end
end
