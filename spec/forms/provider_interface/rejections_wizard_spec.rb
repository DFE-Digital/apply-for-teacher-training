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
          course_full
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
          course_full
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

      expect(wizard.selected_reasons).to eq(%w[qualifications course_full other])
      expect(wizard.qualifications_selected_reasons).to eq(%w[no_maths_gcse no_science_gcse])
      expect(wizard.qualifications_other_details).to be_nil
      expect(wizard.personal_statement_selected_reasons).to be_empty
      expect(wizard.quality_of_writing_details).to be_nil
      expect(wizard.other_details).to eq('There were a few other reasons why we rejected your application...')
    end
  end
end
