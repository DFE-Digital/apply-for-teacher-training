require 'rails_helper'

RSpec.describe CandidateInterface::Steps::CourseSelectionWizard::CourseSite, type: :model do
  let(:repository) do
    DfE::Wizard::Repository::InMemory.new
  end
  let(:state_store) { CandidateInterface::StateStores::CourseSelectionWizardStore.new(repository:) }
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
  let(:current_step) { :course_site }
  let(:current_step_params) { {} }
  let(:course) { create(:course, :open) }

  before do
    state_store.write(course_id: course.id)
  end

  describe '#delegations' do
    subject(:step) { described_class.new(wizard:) }

    it { is_expected.to delegate_method(:provider).to(:wizard) }
    it { is_expected.to delegate_method(:provider_exists?).to(:wizard) }
    it { is_expected.to delegate_method(:state_store).to(:wizard) }
    it { is_expected.to delegate_method(:course).to(:wizard) }

    it { is_expected.to delegate_method(:id).to(:course).with_prefix }
  end

  describe 'attributes' do
    it 'has attributes associated with the form' do
      expect(described_class.new).to have_attributes(course_option_id: nil, course_option_id_raw: nil)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:course_option_id) }

    context 'when there are fewer than 20 course sites' do
      let(:course) { create(:course) }
      let(:course_options) { create_list(:course_option, 19, :full_time, course:) }

      it 'valid without course_option_id_raw on course option id' do
        step = described_class.new(
          wizard:,
          course_option_id: course_options.pluck(:id).sample,
        )
        expect(step.valid?).to be true
      end
    end

    context 'when there are more than 20 course sites' do
      let(:course) { create(:course) }
      let(:course_options) { create_list(:course_option, 21, :full_time, course:) }

      it 'invalid with blank course_option_id_raw' do
        step = described_class.new(
          wizard:,
          course_option_id: course_options.pluck(:id).sample,
          course_option_id_raw: '',
        )
        expect(step.valid?).to be false
      end

      it 'invalid with random course_option_id_raw text' do
        step = described_class.new(
          wizard:,
          course_option_id: course_options.pluck(:id).sample,
          course_option_id_raw: 'blah blah',
        )
        expect(step.valid?).to be false
      end

      it 'valid when course option id matches raw valid for course option' do
        course_option = course_options.first

        step = described_class.new(
          wizard:,
          course_option_id: course_option.id,
          course_option_id_raw: course_option.site.name_and_address(' - '),
        )
        expect(step.valid?).to be true
      end
    end
  end

  describe '#permitted_params' do
    it 'returns the permitted_params' do
      expect(described_class.permitted_params).to contain_exactly(:course_option_id, :course_option_id_raw)
    end
  end

  describe '.study_mode' do
    let(:step) do
      described_class.new(
        wizard:,
        course_option_id: create(:course_option, :part_time, course:).id,
        course_option_id_raw: '',
      )
    end

    context 'when the state store has a study mode' do
      before { state_store.write(study_mode: 'full_time') }

      it 'returns the study mode in the state store' do
        expect(step.study_mode).to eq('full_time')
      end
    end

    context 'when the state store does not have a study mode' do
      it 'returns the first available study mode for the course' do
        expect(step.study_mode).to eq('part_time')
      end
    end
  end

  describe '.set_course_option_id' do
    context 'when course option id blank' do
      let(:step) do
        described_class.new(
          wizard:,
          course_option_id: '',
          course_option_id_raw: '',
        )
      end

      it 'returns an empty string' do
        expect(step.set_course_option_id).to eq('')
      end
    end

    context 'when course option does not exist' do
      let(:step) do
        described_class.new(
          wizard:,
          course_option_id: '1234',
          course_option_id_raw: '',
        )
      end

      it 'returns an empty string' do
        expect(step.set_course_option_id).to eq('')
      end
    end

    context 'when course option site does not exist' do
      let(:course_option) { create(:course_option, course:) }
      let(:step) do
        described_class.new(
          wizard:,
          course_option_id: course_option.id,
          course_option_id_raw: '',
        )
      end

      before do
        site = course_option.site
        site.destroy!
      end

      it 'returns an empty string' do
        expect(step.set_course_option_id).to eq('')
      end
    end

    context 'when course option site exists' do
      let(:course_option) { create(:course_option, course:) }
      let(:step) do
        described_class.new(
          wizard:,
          course_option_id: course_option.id,
          course_option_id_raw: '',
        )
      end

      it 'returns the course option' do
        expect(step.set_course_option_id).to eq(course_option.id)
      end
    end
  end

  describe '.course_options' do
    let(:no_vacancies_option) do
      create(:course_option, :no_vacancies, course:)
    end
    let(:part_time_option) { create(:course_option, :part_time, course:) }
    let(:full_time_option) { create(:course_option, :full_time, course:) }
    let(:random_option) { create(:course_option) }
    let(:step) { described_class.new(wizard:) }

    before { state_store.write(study_mode: 'full_time') }

    it 'returns the available course options for the course' do
      expect(step.course_options).to contain_exactly(full_time_option)
    end
  end

  describe '.site_options_for_select' do
    let(:option_1) { create(:course_option, course:) }
    let(:option_2) { create(:course_option, course:) }
    let(:step) { described_class.new(wizard:) }

    before do
      option_1
      option_2
    end

    it 'returns site options as an array' do
      expect(step.site_options_for_select).to contain_exactly(
        [nil, nil],
        [option_1.site.name_and_address(' - '), option_1.id],
        [option_2.site.name_and_address(' - '), option_2.id],
      )
    end
  end

  describe 'completed?' do
    it 'returns true' do
      expect(described_class.new(wizard:).completed?).to be(true)
    end
  end
end
