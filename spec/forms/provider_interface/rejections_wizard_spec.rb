require 'rails_helper'

RSpec.describe ProviderInterface::RejectionsWizard do
  let(:attrs) { { current_step: 'edit' } }
  let(:store) { instance_double(WizardStateStores::RedisStore) }

  before { allow(store).to receive(:read) }

  subject(:instance) { described_class.new(store, attrs) }

  describe '.rejection_reasons' do
    it 'builds rejection reasons from configuration' do
      rejection_reasons = described_class.rejection_reasons
      expect(rejection_reasons).to be_a(RejectionReasons)
      expect(rejection_reasons.reasons.first).to be_a(RejectionReasons::Reason)
      expect(rejection_reasons.reasons.first.reasons.first).to be_a(RejectionReasons::Reason)
      expect(rejection_reasons.reasons.last.details).to be_a(RejectionReasons::Details)
    end
  end

  describe '.reasons' do
    it 'includes non-deprecated reasons' do
      expect(described_class.reasons.find { |r| r.id == 'personal_statement' }).to be_present
    end

    it 'includes deprecated reasons' do
      expect(described_class.reasons.find { |r| r.id == 'references' }).to be_present
    end
  end

  describe '.selectable_reasons' do
    it 'includes non-deprecated reasons' do
      expect(described_class.selectable_reasons.map(&:id)).to include(
        'qualifications',
        'personal_statement',
        'teaching_knowledge',
        'communication_and_scheduling',
        'safeguarding',
        'visa_sponsorship',
        'course_full',
        'school_placement',
        'other',
      )
    end

    it 'does not include deprecated reasons' do
      expect(described_class.selectable_reasons.find { |r| r.id == 'references' }).to be_nil
    end
  end

  describe '#selectable_reasons' do
    subject(:selectable_reasons) do
      instance.selectable_reasons(application_choice)
    end

    let(:application_choice) { create(:application_choice, course_option: create(:course_option, course:)) }
    let(:qualification_reasons) do
      selectable_reasons.find { |reason| reason.id == 'qualifications' }.reasons
    end

    context 'when undergraduate application' do
      let(:course) { create(:course, :teacher_degree_apprenticeship) }

      it 'includes the A level rejection reason' do
        expect(qualification_reasons.map(&:id)).to include('unsuitable_a_levels')
      end

      it 'includes other qualification-related reasons' do
        expect(qualification_reasons.map(&:id)).to include(
          'no_maths_gcse',
          'no_english_gcse',
          'no_science_gcse',
          'no_degree',
          'unsuitable_a_levels',
          'unsuitable_degree',
          'unsuitable_degree_subject',
          'unverified_qualifications',
          'unverified_equivalency_qualifications',
          'already_qualified',
          'qualifications_other',
        )
      end
    end

    context 'when postgraduate application' do
      let(:course) { create(:course, program_type: 'scitt_programme') }

      it 'does not include the A level rejection reason' do
        expect(qualification_reasons.map(&:id)).not_to include('unsuitable_a_levels')
      end

      it 'still includes other qualification-related reasons' do
        expect(qualification_reasons.map(&:id)).to include(
          'no_maths_gcse',
          'no_english_gcse',
          'no_science_gcse',
          'no_degree',
          'unsuitable_degree',
          'unsuitable_degree_subject',
          'unverified_qualifications',
          'unverified_equivalency_qualifications',
          'already_qualified',
          'qualifications_other',
        )
      end
    end
  end

  describe 'dynamic attributes' do
    it 'defines accessors for all attributes' do
      described_class.attribute_names.each do |attr_name|
        expect(instance.respond_to?(attr_name)).to be(true)
        expect(instance.respond_to?("#{attr_name}=")).to be(true)
      end
    end
  end

  describe 'validations' do
    it 'checks that rejection reasons are valid' do
      wizard = described_class.new(store, {
        selected_reasons: %w[qualifications],
        qualifications_selected_reasons: %w[no_maths_gcse qualifications_other],
        qualifications_other_details: '',
      })

      expect(wizard.valid?).to be false
      expect(wizard.errors.attribute_names).to eq([:qualifications_other_details])
    end
  end

  describe 'resetting attributes' do
    let(:attrs) do
      {
        selected_reasons: %w[
          qualifications
          course_full_selected_reasons
          other
        ],
        qualifications_selected_reasons: %w[
          no_maths_gcse
          no_science_gcse
        ],
        personal_statement_selected_reasons: %w[quality_of_writing],
        qualifications_other_details: 'There was no record of any of your qualifications.',
        quality_of_writing_details: 'We cannot accept applications written in Old Norse.',
        other_details: 'There were a few other reasons why we rejected your application...',
      }
    end

    let(:stored_data) do
      {
        selected_reasons: %w[
          qualifications
          personal_statement
          course_full_selected_reasons
          other
        ],
        qualifications_selected_reasons: %w[
          no_maths_gcse
          no_english_gcse
          no_science_gcse
          qualifications_other
        ],
        personal_statement_selected_reasons: %w[quality_of_writing],
        qualifications_other_details: 'There was no record of any of your qualifications.',
        quality_of_writing_details: 'We cannot accept applications written in Old Norse.',
        other_details: 'There were a few other reasons why we rejected your application...',
      }
    end

    it 'resets child attributes when the parent is deselected' do
      allow(store).to receive(:read).and_return(stored_data.to_json)
      wizard = described_class.new(store, attrs.merge(current_step: 'new'))

      expect(wizard.selected_reasons).to eq(%w[qualifications course_full_selected_reasons other])
      expect(wizard.qualifications_selected_reasons).to eq(%w[no_maths_gcse no_science_gcse])
      expect(wizard.qualifications_other_details).to be_nil
      expect(wizard.personal_statement_selected_reasons).to be_empty
      expect(wizard.quality_of_writing_details).to be_nil
      expect(wizard.other_details).to eq('There were a few other reasons why we rejected your application...')
    end
  end
end
