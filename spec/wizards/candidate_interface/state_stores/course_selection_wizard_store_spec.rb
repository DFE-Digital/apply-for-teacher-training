require 'rails_helper'

RSpec.describe CandidateInterface::StateStores::CourseSelectionWizardStore, type: :model do
  subject(:state_store) { described_class.new(repository:) }

  let(:repository) do
    DfE::Wizard::Repository::InMemory.new
  end
  let(:wizard) do
    CandidateInterface::CourseSelectionWizard.new(
      current_step:,
      current_step_params:,
      state_store:,
    ).tap do |wizard|
      wizard.current_application = current_application
    end
  end
  let(:current_application) { create(:completed_application_form) }
  let(:current_step) { :do_you_know_the_course }
  let(:current_step_params) { {} }

  before { wizard }

  describe '.know_the_course_to_apply?' do
    context 'when answer is yes' do
      before do
        state_store.write(answer: 'yes')
      end

      it 'returns true' do
        expect(state_store.know_the_course_to_apply?).to be(true)
      end
    end

    context 'when answer is no' do
      before do
        state_store.write(answer: 'no')
      end

      it 'returns true' do
        expect(state_store.know_the_course_to_apply?).to be(false)
      end
    end
  end

  describe '.provider' do
    context 'when provider id is present' do
      let(:current_step) { :provider_selection }
      let(:provider) { create(:provider) }

      before do
        state_store.write(provider_id: provider.id)
      end

      it 'returns the provider associated with the provider id' do
        expect(state_store.provider).to eq(provider)
      end
    end

    context 'when course id is present' do
      let(:current_step) { :which_course_are_you_applying_to }
      let(:course) { create(:course) }

      before do
        state_store.write(course_id: course.id)
      end

      it 'returns the provider associated with the provider id' do
        expect(state_store.provider).to eq(course.provider)
      end
    end

    context 'when application choice id is present' do
      let(:application_choice) { create(:application_choice, application_form: current_application) }

      before do
        state_store.write(application_choice_id: application_choice.id, current_application_id: current_application.id)
      end

      it 'returns the provider associated with the application choice' do
        expect(state_store.provider).to eq(application_choice.provider)
      end
    end
  end

  describe '.provider_exists?' do
    let(:application_choice) { create(:application_choice, application_form: current_application) }

    context 'when a provider exists' do
      before do
        state_store.write(application_choice_id: application_choice.id, current_application_id: current_application.id)
      end

      it 'returns true' do
        expect(state_store.provider_exists?).to be(true)
      end
    end

    context 'when a provider does not exist' do
      before do
        state_store.write(application_choice_id: nil, current_application_id: current_application.id)
      end

      it 'returns true' do
        expect(state_store.provider_exists?).to be(false)
      end
    end
  end

  describe '.course' do
    context 'when course id is present' do
      let(:current_step) { :which_course_are_you_applying_to }
      let(:course) { create(:course) }

      before do
        state_store.write(course_id: course.id)
      end

      it 'returns the course associated with the course id' do
        expect(state_store.course).to eq(course)
      end
    end

    context 'when application choice id is present' do
      let(:application_choice) { create(:application_choice, application_form: current_application) }

      before do
        state_store.write(application_choice_id: application_choice.id, current_application_id: current_application.id)
      end

      it 'returns the provider associated with the application choice' do
        expect(state_store.course).to eq(application_choice.course)
      end
    end
  end

  describe '.current_application' do
    before do
      state_store.write(current_application_id: current_application.id)
    end

    it 'returns the application form' do
      expect(state_store.current_application).to eq(current_application)
    end
  end

  describe '.existing_application_choices' do
    let(:choice_1) { create(:application_choice, application_form: current_application) }
    let(:choice_2) { create(:application_choice, application_form: current_application) }

    before do
      state_store.write(current_application_id: current_application.id)

      choice_1
      choice_2
    end

    context 'when not giving a application choice id' do
      it 'returns all application application choices' do
        expect(state_store.existing_application_choices).to contain_exactly(choice_1, choice_2)
      end
    end

    context 'when given an application choice id' do
      before { state_store.write(application_choice_id: choice_1.id) }

      it 'returns all application application choices, except the given application choice' do
        expect(state_store.existing_application_choices).to contain_exactly(choice_2)
      end
    end
  end

  describe 'reapplication_limit_reached?' do
    let(:current_step) { :which_course_are_you_applying_to }
    let(:course) { create(:course) }
    let(:course_option) { create(:course_option, course: course) }

    before do
      state_store.write(current_application_id: current_application.id, course_id: course.id)
    end

    context 'when the candidate has not reached the reapplication limit for this course' do
      it 'returns false' do
        expect(state_store.reapplication_limit_reached?).to be(false)
      end
    end

    context 'when the candidate has reached the reapplication limit for this course' do
      before do
        create(:application_choice, :rejected, application_form: current_application, course_option: course_option)
        create(:application_choice, :rejected, application_form: current_application, course_option: course_option)
      end

      it 'returns true' do
        expect(state_store.reapplication_limit_reached?).to be(true)
      end
    end
  end

  describe '.duplicate_course?' do
    let(:current_step) { :which_course_are_you_applying_to }
    let(:course) { create(:course) }
    let(:course_option) { create(:course_option, course: course) }

    before do
      state_store.write(current_application_id: current_application.id, course_id: course.id)
    end

    context 'when the course has not already been applied for' do
      it 'returns false' do
        expect(state_store.duplicate_course?).to be(false)
      end
    end

    context 'when the course has already been applied for' do
      before do
        create(:application_choice, :awaiting_provider_decision, application_form: current_application, course_option: course_option)
      end

      it 'returns false' do
        expect(state_store.duplicate_course?).to be(true)
      end
    end
  end

  describe '.course_closed?' do
    let(:current_step) { :which_course_are_you_applying_to }

    before do
      state_store.write(current_application_id: current_application.id, course_id: course.id)
    end

    context 'when the course is closed' do
      let(:course) { create(:course, :closed) }

      it 'returns true' do
        expect(state_store.course_closed?).to be(true)
      end
    end

    context 'when the course is open' do
      let(:course) { create(:course, :open) }

      it 'returns false' do
        expect(state_store.course_closed?).to be(false)
      end
    end
  end

  describe '.course_unavailable?' do
    let(:current_step) { :which_course_are_you_applying_to }

    before do
      state_store.write(current_application_id: current_application.id, course_id: course.id)
    end

    context 'when the course has already is available' do
      let(:course) { create(:course) }

      before { create(:course_option, course:) }

      it 'returns false' do
        expect(state_store.course_unavailable?).to be(false)
      end
    end

    context 'when the course has already is unavailable' do
      let(:course) { create(:course, :unavailable) }

      it 'returns true' do
        expect(state_store.course_unavailable?).to be(true)
      end
    end
  end

  describe '.not_multiple_sites_or_study_modes?' do
    let(:current_step) { :which_course_are_you_applying_to }
    let(:provider) { create(:provider, selectable_school: true) }

    before do
      state_store.write(current_application_id: current_application.id, course_id: course.id)
    end

    context 'when the course has multiple study modes' do
      let(:course) { create(:course, :with_both_study_modes, provider:) }

      before do
        create(:course_option, :full_time, course:)
        create(:course_option, :part_time, course:)
      end

      it 'returns false' do
        expect(state_store.not_multiple_sites_or_study_modes?).to be(false)
      end
    end

    context 'when the course has multiple sites' do
      let(:course) { create(:course, provider:) }

      before do
        create(:course_option, course:)
        create(:course_option, course:)
      end

      it 'returns false' do
        expect(state_store.not_multiple_sites_or_study_modes?).to be(false)
      end
    end

    context "when the candidate's visa expires soon" do
      let(:course) { create(:course, provider:) }
      let(:course_option) { create(:course_option, course: course) }
      let(:application_choice) { create(:application_choice, application_form: current_application, course_option:) }

      before do
        FeatureFlag.activate('2027_visa_expiry')
        current_application.update!(visa_expired_at: 1.month.from_now)
        state_store.write(application_choice_id: application_choice.id)
      end

      after do
        FeatureFlag.deactivate('2027_visa_expiry')
      end

      it 'returns false' do
        expect(state_store.not_multiple_sites_or_study_modes?).to be(false)
      end
    end

    context 'when course no multiple sites and study modes or visa expires soon' do
      let(:course) { create(:course, provider:) }
      let(:course_option) { create(:course_option, course: course) }
      let(:application_choice) { create(:application_choice, application_form: current_application, course_option:) }

      before do
        FeatureFlag.activate('2027_visa_expiry')
        current_application.update!(visa_expired_at: 2.years.from_now)
        state_store.write(application_choice_id: application_choice.id)
      end

      after do
        FeatureFlag.deactivate('2027_visa_expiry')
      end

      it 'returns true' do
        expect(state_store.not_multiple_sites_or_study_modes?).to be(true)
      end
    end
  end

  describe '.multiple_study_modes?' do
    let(:current_step) { :which_course_are_you_applying_to }
    let(:provider) { create(:provider, selectable_school: true) }

    before do
      state_store.write(current_application_id: current_application.id, course_id: course.id)
    end

    context 'when the course has multiple study modes' do
      let(:course) { create(:course, :with_both_study_modes, provider:) }

      before do
        create(:course_option, :full_time, course:)
        create(:course_option, :part_time, course:)
      end

      it 'returns true' do
        expect(state_store.multiple_study_modes?).to be(true)
      end
    end

    context 'when the course has one study mode' do
      let(:course) { create(:course, provider:) }

      before do
        create(:course_option, :full_time, course:)
      end

      it 'returns false' do
        expect(state_store.multiple_study_modes?).to be(false)
      end
    end
  end

  describe '.multiple_sites?' do
    let(:current_step) { :which_course_are_you_applying_to }
    let(:provider) { create(:provider, selectable_school: true) }

    before do
      state_store.write(current_application_id: current_application.id, course_id: course.id)
    end

    context 'when the course has multiple sites' do
      let(:course) { create(:course, provider:) }

      before do
        create(:course_option, course:)
        create(:course_option, course:)
      end

      it 'returns true' do
        expect(state_store.multiple_sites?).to be(true)
      end
    end

    context 'when the course has one site' do
      let(:course) { create(:course, provider:) }

      before do
        create(:course_option, course:)
      end

      it 'returns false' do
        expect(state_store.multiple_sites?).to be(false)
      end
    end
  end

  describe '.not_multiple_sites?' do
    let(:current_step) { :which_course_are_you_applying_to }
    let(:provider) { create(:provider, selectable_school: true) }

    before do
      state_store.write(current_application_id: current_application.id, course_id: course.id)
    end

    context 'when the course has multiple sites' do
      let(:course) { create(:course, provider:) }

      before do
        create(:course_option, course:)
        create(:course_option, course:)
      end

      it 'returns false' do
        expect(state_store.not_multiple_sites?).to be(false)
      end
    end

    context 'when the course has one site' do
      let(:course) { create(:course, provider:) }

      before do
        create(:course_option, course:)
      end

      it 'returns true' do
        expect(state_store.not_multiple_sites?).to be(true)
      end
    end
  end

  describe '.find_course_selected?' do
    let(:current_step) { :find_course_selection }
    let(:provider) { create(:provider, selectable_school: true) }

    before do
      state_store.write(current_application_id: current_application.id, course_id: course.id)
    end

    context 'when the course has multiple study modes' do
      let(:course) { create(:course, :with_both_study_modes, provider:) }

      before do
        create(:course_option, :full_time, course:)
        create(:course_option, :part_time, course:)
        state_store.write(confirm: 'true')
      end

      it 'returns false' do
        expect(state_store.find_course_selected?).to be(false)
      end
    end

    context 'when the course has multiple sites' do
      let(:course) { create(:course, provider:) }

      before do
        create(:course_option, course:)
        create(:course_option, course:)
        state_store.write(confirm: 'true')
      end

      it 'returns false' do
        expect(state_store.find_course_selected?).to be(false)
      end
    end

    context 'when the confirm attribute is "false"' do
      let(:course) { create(:course, provider:) }

      before { state_store.write(confirm: 'false') }

      it 'returns false' do
        expect(state_store.find_course_selected?).to be(false)
      end
    end

    context 'when the confirm attribute is "true"' do
      let(:course) { create(:course, provider:) }

      before { state_store.write(confirm: 'true') }

      it 'returns true' do
        expect(state_store.find_course_selected?).to be(true)
      end
    end
  end

  describe '.find_course_not_selected?' do
    let(:current_step) { :find_course_selection }
    let(:provider) { create(:provider, selectable_school: true) }

    before do
      state_store.write(current_application_id: current_application.id, course_id: course.id)
    end

    context 'when the course has multiple study modes' do
      let(:course) { create(:course, :with_both_study_modes, provider:) }

      before do
        create(:course_option, :full_time, course:)
        create(:course_option, :part_time, course:)
        state_store.write(confirm: 'true')
      end

      it 'returns true' do
        expect(state_store.find_course_not_selected?).to be(true)
      end
    end

    context 'when the course has multiple sites' do
      let(:course) { create(:course, provider:) }

      before do
        create(:course_option, course:)
        create(:course_option, course:)
        state_store.write(confirm: 'true')
      end

      it 'returns true' do
        expect(state_store.find_course_not_selected?).to be(true)
      end
    end

    context 'when the confirm attribute is "false"' do
      let(:course) { create(:course, provider:) }

      before { state_store.write(confirm: 'false') }

      it 'returns true' do
        expect(state_store.find_course_not_selected?).to be(true)
      end
    end

    context 'when the confirm attribute is "true"' do
      let(:course) { create(:course, provider:) }

      before { state_store.write(confirm: 'true') }

      it 'returns false' do
        expect(state_store.find_course_not_selected?).to be(false)
      end
    end
  end

  describe '.confirm_answer?' do
    let(:current_step) { :find_course_selection }
    let(:course) { create(:course) }

    before do
      state_store.write(
        current_application_id: current_application.id,
        course_id: course.id,
      )
    end

    context 'when confirm is "false"' do
      before { state_store.write(confirm: 'false') }

      it 'returns false' do
        expect(state_store.confirm_answer?).to be(false)
      end
    end

    context 'when confirm is "true"' do
      before { state_store.write(confirm: 'true') }

      it 'returns true' do
        expect(state_store.confirm_answer?).to be(true)
      end
    end
  end

  describe '.application_choice' do
    context 'when not given an application choice' do
      before do
        state_store.write(current_application_id: current_application.id)
      end

      it 'returns nil' do
        expect(state_store.application_choice).to be_nil
      end
    end

    context 'when given an application choice' do
      let(:application_choice) { create(:application_choice, application_form: current_application) }

      before do
        state_store.write(current_application_id: current_application.id, application_choice_id: application_choice.id)
      end

      it 'returns the application choice' do
        expect(state_store.application_choice).to eq(application_choice)
      end
    end
  end

  describe '.visa_expires_soon?' do
    before { FeatureFlag.activate('2027_visa_expiry') }

    after { FeatureFlag.deactivate('2027_visa_expiry') }

    let(:application_choice) { create(:application_choice, application_form: current_application) }

    context "when the candidate's visa expires soon" do
      before do
        current_application.update!(visa_expired_at: 1.month.from_now)
        state_store.write(current_application_id: current_application.id, application_choice_id: application_choice.id)
      end

      it 'returns true' do
        expect(state_store.visa_expires_soon?).to be(true)
      end
    end

    context 'when not given an application choice id' do
      before do
        state_store.write(current_application_id: current_application.id)
      end

      it 'returns false' do
        expect(state_store.visa_expires_soon?).to be(false)
      end
    end

    context "when the candidate's visa does not expire soon" do
      before do
        current_application.update!(visa_expired_at: 2.years.from_now)
        state_store.write(current_application_id: current_application.id, application_choice_id: application_choice.id)
      end

      it 'returns false' do
        expect(state_store.visa_expires_soon?).to be(false)
      end
    end
  end
end
