require 'rails_helper'

RSpec.describe ProviderInterface::ProviderPartnerPermissionBreakdownComponent do
  let(:provider) { create(:provider) }
  let(:allowed_training_providers) do
    ['Hogwarts SCITT', 'University of Typing', 'Great White School'].map { |name| create(:provider, name: name) }
  end
  let(:allowed_ratifying_providers) do
    ['Mars SCITT', 'University of Twix'].map { |name| create(:provider, name: name) }
  end
  let(:prohibited_training_providers) do
    ['Chicken School', 'Egg SCITT'].map { |name| create(:provider, name: name) }
  end
  let(:prohibited_ratifying_providers) do
    ['ABC SCITT', 'University of XYZ'].map { |name| create(:provider, name: name) }
  end
  let(:non_configured_providers) do
    ['School of Rock', 'Musical High School'].map { |name| create(:provider, name: name) }
  end
  let(:render) do
    render_inline(described_class.new(provider: provider, permission: :make_decisions))
  end

  describe '#partners_for_which_permission_applies' do
    before do
      allowed_training_providers.each do |training_provider|
        create(:provider_relationship_permissions,
               training_provider: training_provider,
               ratifying_provider: provider,
               ratifying_provider_can_make_decisions: true,
               training_provider_can_make_decisions: false)
      end

      allowed_ratifying_providers.each do |training_provider|
        create(:provider_relationship_permissions,
               training_provider: provider,
               ratifying_provider: training_provider,
               training_provider_can_make_decisions: true,
               ratifying_provider_can_make_decisions: false)
      end
    end

    it 'returns a list of all providers that allow the specified provider to make decisions on their behalf' do
      expected_provider_names = (allowed_training_providers + allowed_ratifying_providers).map(&:name).sort
      expect(render.css('#partners-for-which-permission-applies li').map(&:text)).to eq(expected_provider_names)
    end
  end

  describe '#partners_for_which_permission_does_not_apply' do
    before do
      prohibited_training_providers.each do |training_provider|
        create(:provider_relationship_permissions,
               training_provider: training_provider,
               ratifying_provider: provider,
               training_provider_can_make_decisions: true,
               ratifying_provider_can_make_decisions: false)
      end

      prohibited_ratifying_providers.each do |training_provider|
        create(:provider_relationship_permissions,
               training_provider: provider,
               ratifying_provider: training_provider,
               training_provider_can_make_decisions: false,
               ratifying_provider_can_make_decisions: true)
      end

      non_configured_providers.each do |training_provider|
        create(:provider_relationship_permissions,
               :not_set_up_yet,
               training_provider: training_provider,
               ratifying_provider: provider)
      end
    end

    it 'returns a list of all providers that allow the specified provider to make decisions on their behalf' do
      expected_provider_names = (prohibited_training_providers + prohibited_ratifying_providers + non_configured_providers).map(&:name).sort
      expect(render.css('#partners-for-which-permission-does-not-apply li').map(&:text)).to eq(expected_provider_names)
    end
  end

  describe '#partners_for_which_permission_applies_text' do
    context 'when there are only partners where permission applies' do
      before do
        allowed_training_providers.each do |training_provider|
          create(:provider_relationship_permissions,
                 training_provider: training_provider,
                 ratifying_provider: provider,
                 ratifying_provider_can_make_decisions: true,
                 training_provider_can_make_decisions: false)
        end
      end

      it 'indicates that the permission applies to all partners' do
        expect(render.css('.govuk-body')[0].text)
          .to include('It currently applies to courses you work on with all of your partner organisations:')
      end
    end

    context 'when there are both partners where permission applies and partners where it does not apply' do
      before do
        allowed_training_providers.each do |training_provider|
          create(:provider_relationship_permissions,
                 training_provider: training_provider,
                 ratifying_provider: provider,
                 ratifying_provider_can_make_decisions: true,
                 training_provider_can_make_decisions: false)
        end

        prohibited_ratifying_providers.each do |training_provider|
          create(:provider_relationship_permissions,
                 training_provider: provider,
                 ratifying_provider: training_provider,
                 training_provider_can_make_decisions: false,
                 ratifying_provider_can_make_decisions: true)
        end
      end

      it 'does not indicate that the permission applies to all partners' do
        expect(render.css('.govuk-body')[0].text)
          .to include('It currently applies to courses you work on with:')
      end
    end
  end

  describe '#partners_for_which_permission_does_not_apply_text' do
    context 'when there are only partners where permission does not apply' do
      before do
        prohibited_ratifying_providers.each do |training_provider|
          create(:provider_relationship_permissions,
                 training_provider: provider,
                 ratifying_provider: training_provider,
                 training_provider_can_make_decisions: false,
                 ratifying_provider_can_make_decisions: true)
        end
      end

      it 'indicates that the permission applies to all partners' do
        expect(render.css('.govuk-body')[0].text)
          .to include('It currently does not apply to courses you work on with any of your partner organisations:')
      end
    end

    context 'when there are both partners where permission applies and partners where it does not apply' do
      before do
        allowed_training_providers.each do |training_provider|
          create(:provider_relationship_permissions,
                 training_provider: training_provider,
                 ratifying_provider: provider,
                 ratifying_provider_can_make_decisions: true,
                 training_provider_can_make_decisions: false)
        end

        prohibited_ratifying_providers.each do |training_provider|
          create(:provider_relationship_permissions,
                 training_provider: provider,
                 ratifying_provider: training_provider,
                 training_provider_can_make_decisions: false,
                 ratifying_provider_can_make_decisions: true)
        end
      end

      it 'does not indicate that the permission applies to all partners' do
        expect(render.css('.govuk-body')[1].text)
          .to include('It currently does not apply to courses you work on with:')
      end
    end
  end
end
