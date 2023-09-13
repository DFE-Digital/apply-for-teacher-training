require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationFormSections do
  let(:application_form) { build_stubbed(:application_form, :completed) }
  let(:application_choice) { build_stubbed(:application_choice, application_form:) }
  let(:sections) { described_class.new(application_form:, application_choice:) }

  describe '#all_completed?' do
    subject(:all_completed?) { sections.all_completed? }

    context 'when all sections are completed' do
      it { is_expected.to be(true) }
    end

    context 'when not all sections are completed' do
      let(:application_form) { build_stubbed(:application_form, :completed, contact_details_completed: nil) }

      it { is_expected.to be(false) }
    end
  end

  describe '#completed?' do
    subject(:completed?) { sections.completed?(section_name) }

    context 'when the section is completed' do
      let(:section_name) { :personal_details }

      it { is_expected.to be(true) }
    end

    context 'when the section is not completed' do
      let(:application_form) { build_stubbed(:application_form, :completed, contact_details_completed: false) }
      let(:section_name) { :contact_details }

      it { is_expected.to be(false) }
    end
  end
end
