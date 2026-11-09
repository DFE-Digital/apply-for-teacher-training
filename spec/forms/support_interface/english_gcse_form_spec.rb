require 'rails_helper'

RSpec.describe SupportInterface::EnglishGcseForm do
  let(:qualification) { create(:application_qualification) }

  subject(:form) { described_class.build_from_qualification(qualification) }

  describe 'validations' do
    it { is_expected.to validate_length_of(:grade).is_at_most(256) }

    it 'does not prevent support from editing an application from a previous cycle' do
      create(:application_choice, application_form: qualification.application_form)
      qualification.application_form.update_columns(recruitment_cycle_year: previous_year)
      RequestStore.store[:allow_unsafe_application_choice_touches] = false

      form.valid?

      expect(form.errors[:base]).to be_empty
    end
  end
end
