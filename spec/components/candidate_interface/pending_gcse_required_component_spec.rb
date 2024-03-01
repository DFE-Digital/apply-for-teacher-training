require 'rails_helper'

RSpec.describe CandidateInterface::PendingGcseRequiredComponent, type: :component do
  let(:application_form) { create(:application_form) }

  let(:course_option1) { create(:course_option, course: create(:course, :open_on_apply, accept_pending_gcse: true)) }
  let(:course_option2) { create(:course_option, course: create(:course, :open_on_apply, accept_pending_gcse: false)) }

  let(:application_choice1) do
    build_stubbed(
      :application_choice,
      status: :unsubmitted,
      course_option: course_option1,
      application_form:,
    )
  end

  let(:application_choice2) do
    build_stubbed(
      :application_choice,
      status: :unsubmitted,
      course_option: course_option2,
      application_form:,
    )
  end

  context 'course accepts pending gcses' do
    it 'renders the correct gcse row content without guidance' do
      result = render_inline(described_class.new(application_choice1, application_form.application_qualifications))
      expect(result.text).to include('This provider will consider candidates with pending GCSEs')
    end
  end

  context 'application has pending gcses that are not accepted' do
    context 'application has one pending gcse and course does not accept them' do
      it 'renders the gcse row with guidance' do
        create(
          :gcse_qualification,
          subject: 'english',
          currently_completing_qualification: true,
          application_form:,
        )

        result = render_inline(described_class.new(application_choice2, application_form.application_qualifications))
        expect(result.text).to include('You said you are currently studying for a qualification in English')
      end
    end

    context 'application has two pending gcses and course does not accept them' do
      it 'renders the gcse row with guidance' do
        create(
          :gcse_qualification,
          subject: 'english',
          currently_completing_qualification: true,
          application_form:,
        )

        create(
          :gcse_qualification,
          subject: 'maths',
          currently_completing_qualification: true,
          application_form:,
        )

        result = render_inline(described_class.new(application_choice2, application_form.application_qualifications.sort_by(&:subject)))
        expect(result.text).to include('You said you are currently studying for a qualification in English and maths')
      end
    end

    context 'application has three pending gcses and course does not accept them' do
      it 'renders the gcse row with guidance' do
        create(
          :gcse_qualification,
          subject: 'english',
          currently_completing_qualification: true,
          application_form:,
        )
        create(
          :gcse_qualification,
          subject: 'maths',
          currently_completing_qualification: true,
          application_form:,
        )
        create(
          :gcse_qualification,
          subject: 'science',
          currently_completing_qualification: true,
          application_form:,
        )

        result = render_inline(described_class.new(application_choice2, application_form.application_qualifications.sort_by(&:subject)))
        expect(result.text).to include('You said you are currently studying for a qualification in English, maths and science')
      end
    end
  end
end
