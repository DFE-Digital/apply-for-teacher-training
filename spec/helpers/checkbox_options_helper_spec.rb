require 'rails_helper'

RSpec.describe CheckboxOptionsHelper, type: :helper do
  describe '#disabilities_checkboxes' do
    it 'return a stuctured list of all listed disabilities' do
      id, name = CandidateInterface::EqualityAndDiversity::DisabilitiesForm::DISABILITIES.sample

      expect(disabilities_checkboxes).to include(
        OpenStruct.new(
          id: id,
          name: name,
          hint_text: I18n.t("equality_and_diversity.disabilities.#{id}.hint_text"),
        ),
      )
    end
  end
end
