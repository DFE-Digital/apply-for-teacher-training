require 'rails_helper'

RSpec.describe CandidateInterface::CourseChoicesReviewVisaStatusComponent do
  context 'when course is salaried' do
    context 'and provider does NOT sponsor Skilled Worker visas' do
      it 'renders component with warning' do
        application_choice = setup_application(
          funding_type: :salary,
          can_sponsor_skilled_worker_visa: false,
          can_sponsor_student_visa: false,
        )
        result = render_inline(described_class.new(application_choice: application_choice))

        expect(result.css('.app-inset-text__title').text).to include('Visa sponsorship is not available for this course')
      end
    end

    context 'and provider does sponsor Skilled Worker visas' do
      it 'renders component with message that visas are sponsored' do
        application_choice = setup_application(
          funding_type: :salary,
          can_sponsor_skilled_worker_visa: true,
          can_sponsor_student_visa: false,
        )
        result = render_inline(described_class.new(application_choice: application_choice))

        expect(result.text).to include('Visas can be sponsored')
      end
    end
  end

  context 'when course has a fee' do
    context 'and provider does NOT sponsor Student visas' do
      it 'renders component with warning' do
        application_choice = setup_application(
          funding_type: :fee,
          can_sponsor_skilled_worker_visa: false,
          can_sponsor_student_visa: false,
        )
        result = render_inline(described_class.new(application_choice: application_choice))

        expect(result.css('.app-inset-text__title').text).to include('Visa sponsorship is not available for this course')
      end
    end

    context 'and provider does sponsor Student visas' do
      it 'renders component with message that visas are sponsored' do
        application_choice = setup_application(
          funding_type: :fee,
          can_sponsor_skilled_worker_visa: false,
          can_sponsor_student_visa: true,
        )
        result = render_inline(described_class.new(application_choice: application_choice))

        expect(result.text).to include('Visas can be sponsored')
      end
    end
  end

  def setup_application(
    funding_type:,
    can_sponsor_skilled_worker_visa:,
    can_sponsor_student_visa:
  )
    course_option = create(
      :course_option,
      course: create(
        :course,
        provider: create(
          :provider,
          can_sponsor_skilled_worker_visa: can_sponsor_skilled_worker_visa,
          can_sponsor_student_visa: can_sponsor_student_visa,
        ),
        funding_type: funding_type,
      ),
    )
    create(
      :application_choice,
      :with_completed_application_form,
      course_option: course_option,
    )
  end
end
