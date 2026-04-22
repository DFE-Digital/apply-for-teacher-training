require 'rails_helper'

RSpec.describe TestApplications do
  let(:courses_to_apply_to) { create_list(:course, 1, :with_a_course_option, recruitment_cycle_year:) }
  let(:states) { [:awaiting_provider_decision] }
  let(:recruitment_cycle_year) { 2026 }
  let(:test_applications) { described_class.new }

  describe '.create_application' do
    subject(:create_application) do
      test_applications.create_application(recruitment_cycle_year:, states:, courses_to_apply_to:)
    end

    it 'creates a test application' do
      expect { create_application }.to change { ApplicationForm.count }.by(1)
      application_form = ApplicationForm.last
      application_choice = application_form.application_choices.first
      expect(application_choice.course).to eq(courses_to_apply_to.last)
      expect(application_form.recruitment_cycle_year).to eq(recruitment_cycle_year)
    end

    context 'when the course accepts visas' do
      let(:courses_to_apply_to) {
        create_list(
          :course,
          2,
          :with_a_course_option,
          recruitment_cycle_year:,
          can_sponsor_skilled_worker_visa: true,
          can_sponsor_student_visa: true,
        )
      }
      let(:states) { %i[awaiting_provider_decision awaiting_provider_decision] }

      it 'creates an international application' do
        expect { create_application }.to change { ApplicationChoice.count }.by(2)
        application_form = ApplicationForm.last
        expect(application_form.english_proficiency.present?).to be(true)
        expect(application_form.first_nationality).to eq('American')
        expect(application_form.second_nationality).to be_nil
        expect(application_form.address_type).to eq('international')
        expect(application_form.right_to_work_or_study).to eq('yes')
        expect(application_form.immigration_status).to eq('student_visa')
        expect(application_form.region_code).to eq('rest_of_the_world')
        expect(application_form.efl_completed).to be(true)
      end

      context 'when 2027_visa_expiry feature flag is on', feature_flag: '2027_visa_expiry' do
        it 'assigns visa expiry details to the application' do
          expect { create_application }.to change { ApplicationChoice.count }.by(2)
          application_form = ApplicationForm.last
          expect(application_form.visa_expired_at.to_date).to eq(2.years.from_now.to_date)

          application_choices = application_form.application_choices
          expect(application_choices.pluck(:visa_explanation).uniq).to contain_exactly('expires_after_course')
          expect(application_choices.map { |ac| ac.visa_explanation_details.present? }.uniq).to contain_exactly(true)
        end
      end
    end
  end
end
