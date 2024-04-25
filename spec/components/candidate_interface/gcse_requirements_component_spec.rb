require 'rails_helper'

RSpec.describe CandidateInterface::GcseRequirementsComponent, type: :component do
  let(:application_form) { create(:application_form) }

  let(:course_option) { create(:course_option, course: create(:course, accept_pending_gcse: true, accept_gcse_equivalency: true, accept_english_gcse_equivalency: true)) }

  let(:application_choice) do
    build_stubbed(
      :application_choice,
      status: :unsubmitted,
      course_option:,
      application_form:,
    )
  end

  context 'candidate has no relevant qualifications' do
    it 'renders no content' do
      create(
        :gcse_qualification,
        subject: 'maths',
        application_form:,
      )

      result = render_inline(described_class.new(application_choice))
      expect(result.text).to eq ''
    end
  end

  context 'candidate has pending gcse only' do
    it 'renders the pending gcse component' do
      create(
        :gcse_qualification,
        subject: 'maths',
        currently_completing_qualification: true,
        application_form:,
      )

      result = render_inline(described_class.new(application_choice))
      expect(result.text).to include('This provider will consider candidates with pending GCSEs')
      expect(result.text).not_to include('This provider will not accept equivalency test')
    end
  end

  context 'candidate has missing gcse only' do
    it 'renders the missing gcse component' do
      create(
        :gcse_qualification,
        subject: 'english',
        qualification_type: 'missing',
        currently_completing_qualification: false,
        application_form:,
      )

      result = render_inline(described_class.new(application_choice))
      expect(result.text).to include('This provider will accept equivalency tests in English')
      expect(result.text).not_to include('This provider will consider candidates with pending GCSEs')
    end
  end

  context 'course accepts gcse equivalencies' do
    it 'renders the correct gcse row content without guidance' do
      create(
        :gcse_qualification,
        subject: 'english',
        qualification_type: 'missing',
        currently_completing_qualification: false,
        application_form:,
      )
      create(
        :gcse_qualification,
        subject: 'maths',
        currently_completing_qualification: true,
        application_form:,
      )

      result = render_inline(described_class.new(application_choice))
      expect(result.text).to include('This provider will consider candidates with pending GCSEs')
      expect(result.text).to include('This provider will accept equivalency tests in English')
    end
  end
end
