require 'rails_helper'

RSpec.describe ApplicationChoicePolicy do
  describe 'scope' do
    describe '#resolve' do
      it 'resolves the scope' do
        application_form = create(:application_form)
        scoped_application_choice = create(:application_choice, application_form:)
        _another_application_choice = create(:application_choice)

        scope = described_class::Scope.new(
          application_form.candidate,
          ApplicationChoice,
        ).resolve

        expect(scope).to eq([scoped_application_choice])
      end
    end
  end
end
