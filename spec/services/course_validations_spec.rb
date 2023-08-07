require 'rails_helper'
RSpec.describe CourseValidations, type: :model do
  subject(:course_choice) { described_class.new(application_choice:, course_option:) }

  let(:application_choice) { nil }
  let(:course_option) { create(:course_option, course:) }
  let(:course) { create(:course, :open_on_apply) }

  context 'validations' do
    it { is_expected.to validate_presence_of(:course_option) }

    describe '#identical_to_existing_course?' do
      context 'when the course details are identical to the existing course' do
        let(:application_choice) { create(:application_choice, current_course_option: course_option, course_option:) }
        let(:course_option) { build(:course_option, :open_on_apply) }

        it 'raises an IdenticalCourseError' do
          expect { course_choice.valid? }.to raise_error(IdenticalCourseError)
        end
      end
    end

    describe '#course_already_exists_on_application?' do
      context 'when the course to be updated already exists on the application form' do
        let!(:application_form) { create(:application_form, application_choices: [first_application_choice, application_choice]) }
        let(:first_application_choice) { build(:application_choice, current_course_option: course_option, course_option:) }
        let(:application_choice) { build(:application_choice, current_course_option: course_option2, course_option: course_option2) }
        let(:course) { create(:course, :with_accredited_provider) }
        let(:course_option) { create(:course_option, :open_on_apply, course:) }
        let(:course_option2) { create(:course_option, :open_on_apply, course:) }

        it 'raises an ExistingCourseError' do
          expect { course_choice.valid? }.to raise_error(ExistingCourseError)
        end
      end
    end

    describe '#ratifying_provider_changed?' do
      context 'when the ratifying provider is different than the one of the requested course' do
        let(:candidate) { create(:candidate) }
        let(:application_choice) { create(:application_choice, current_course_option:) }
        let!(:application_form) { create(:application_form, phase: 'apply_1', candidate:, application_choices: [application_choice]) }
        let(:current_course_option) { create(:course_option, :open_on_apply) }
        let(:course_option) { build(:course_option, :open_on_apply) }

        it 'adds a :different_ratifying_provider error' do
          expect(course_choice).not_to be_valid

          expect(course_choice.errors[:base]).to contain_exactly('The course\'s ratifying provider must be the same as the one originally requested')
        end
      end
    end
  end
end
