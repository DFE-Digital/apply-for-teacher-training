require 'rails_helper'

RSpec.describe CandidateInterface::CourseChoicesReviewVisaStatusComponent do
  context 'when course is salaried' do
    context 'and provider does NOT sponsor Skilled Worker visas' do
      it 'renders component with warning' do
        course_option = create(
          :course_option,
          course: create(
            :course,
            provider: create(
              :provider,
              can_sponsor_skilled_worker_visa: false,
            ),
            funding_type: :salary,
          ),
        )
        application_choice = create(
          :application_choice,
          :with_completed_application_form,
          course_option: course_option,
        )
        result = render_inline(described_class.new(application_choice: application_choice))

        expect(result.css('.app-inset-text__title').text).to include('This provider cannot sponsor Skilled Worker visas')
      end
    end

    context 'and provider does sponsor Skilled Worker visas' do
      it 'renders component with message that visas are sponsored' do
        course_option = create(
          :course_option,
          course: create(
            :course,
            provider: create(
              :provider,
              can_sponsor_skilled_worker_visa: true,
            ),
            funding_type: :salary,
          ),
        )
        application_choice = create(
          :application_choice,
          :with_completed_application_form,
          course_option: course_option,
        )
        result = render_inline(described_class.new(application_choice: application_choice))

        expect(result.text).to include('Visas can be sponsored')
      end
    end
  end

  context 'when course has a fee' do
    context 'and provider does NOT sponsor Student visas' do
      it 'renders component with warning' do
        course_option = create(
          :course_option,
          course: create(
            :course,
            provider: create(
              :provider,
              can_sponsor_student_visa: false,
            ),
            funding_type: :fee,
          ),
        )
        application_choice = create(
          :application_choice,
          :with_completed_application_form,
          course_option: course_option,
        )
        result = render_inline(described_class.new(application_choice: application_choice))

        expect(result.css('.app-inset-text__title').text).to include('This provider cannot sponsor Student visas')
      end
    end

    context 'and provider does sponsor Student visas' do
      it 'renders component with message that visas are sponsored' do
        course_option = create(
          :course_option,
          course: create(
            :course,
            provider: create(
              :provider,
              can_sponsor_student_visa: true,
            ),
            funding_type: :fee,
          ),
        )
        application_choice = create(
          :application_choice,
          :with_completed_application_form,
          course_option: course_option,
        )
        result = render_inline(described_class.new(application_choice: application_choice))

        expect(result.text).to include('Visas can be sponsored')
      end
    end
  end
end
