require 'rails_helper'

RSpec.describe ProviderInterface::OrganisationPermissionsFormComponent do
  let(:provider_relationship_permission) { build_stubbed(:provider_relationship_permissions) }
  let(:training_provider) { provider_relationship_permission.training_provider }
  let(:ratifying_provider) { provider_relationship_permission.ratifying_provider }
  let(:main_provider) { nil }
  let(:provider_user) { build_stubbed(:provider_user, providers: [training_provider]) }
  let(:mode) { :setup }

  let(:render) do
    render_inline(
      described_class.new(
        provider_user: provider_user,
        provider_relationship_permission: provider_relationship_permission,
        main_provider: main_provider,
        mode: mode,
        form_url: '',
      ),
    )
  end

  context 'when mode is setup' do
    it 'renders the correct button text' do
      expect(render.css('button').text).to eq('Continue')
    end

    it 'renders the correct caption' do
      expect(render.css('.govuk-caption-l').text.squish).to eq('Set up organisation permissions')
    end

    context 'when the provider user is part of the training provider' do
      it 'renders the heading with the training provider first' do
        expected_heading = "#{training_provider.name} and #{ratifying_provider.name}"
        expect(render.css('h1').text.squish).to eq(expected_heading)
      end
    end

    context 'when the provider user is part of the ratifying provider' do
      let(:provider_user) { build_stubbed(:provider_user, providers: [ratifying_provider]) }

      it 'renders the heading with the ratifying provider first' do
        expected_heading = "#{ratifying_provider.name} and #{training_provider.name}"
        expect(render.css('h1').text.squish).to eq(expected_heading)
      end
    end

    context 'when the provider user is part of both of the providers' do
      let(:provider_user) { build_stubbed(:provider_user, providers: [training_provider, ratifying_provider]) }

      it 'renders the heading with the training provider first' do
        expected_heading = "#{training_provider.name} and #{ratifying_provider.name}"
        expect(render.css('h1').text.squish).to eq(expected_heading)
      end
    end
  end

  context 'when mode is edit' do
    let(:mode) { :edit }

    it 'renders the correct button text' do
      expect(render.css('button').text).to eq('Save organisation permissions')
    end

    it 'renders the correct heading' do
      expect(render.css('h1').text.squish).to eq('Organisation permissions')
    end

    context 'when the provider user is part of the training provider' do
      it 'renders the heading with the training provider first' do
        expected_heading = "#{training_provider.name} and #{ratifying_provider.name}"
        expect(render.css('.govuk-caption-l').text.squish).to eq(expected_heading)
      end
    end

    context 'when the provider user is part of the ratifying provider' do
      let(:provider_user) { build_stubbed(:provider_user, providers: [ratifying_provider]) }

      it 'renders the heading with the ratifying provider first' do
        expected_heading = "#{ratifying_provider.name} and #{training_provider.name}"
        expect(render.css('.govuk-caption-l').text.squish).to eq(expected_heading)
      end
    end

    context 'when the provider user is part of both of the providers' do
      let(:provider_user) { build_stubbed(:provider_user, providers: [training_provider, ratifying_provider]) }

      it 'renders the heading with the training provider first' do
        expected_heading = "#{training_provider.name} and #{ratifying_provider.name}"
        expect(render.css('.govuk-caption-l').text.squish).to eq(expected_heading)
      end
    end
  end

  context 'when the main_provider is given' do
    let(:main_provider) { training_provider }

    before do
      expected_params = {
        relationship: provider_relationship_permission,
        provider_user: provider_user,
        main_provider: training_provider,
      }
      allow(ProviderInterface::ProviderRelationshipPermissionAsProviderUserPresenter).to receive(:new).with(expected_params).and_call_original
    end

    it 'initialises a the presenter with the correct parameters' do
      render
      expect(ProviderInterface::ProviderRelationshipPermissionAsProviderUserPresenter).to have_received(:new)
    end
  end

  it 'renders the explanation about view applications permissions' do
    expect(render.css('p').text.squish).to eq('All users can view applications.')
  end

  describe 'form group legends' do
    it 'renders the correct legend for make decisions' do
      expect(render.css('legend')[0].text).to eq('Who can make offers and reject applications?')
    end

    it 'renders the correct legend for view safeguarding' do
      expect(render.css('legend')[1].text).to eq('Who can view criminal convictions and professional misconduct?')
    end

    it 'renders the correct legend for view diversity' do
      expect(render.css('legend')[2].text).to eq('Who can view sex, disability and ethnicity information?')
    end
  end

  describe 'order of checkboxes for providers' do
    context 'when the provider user is part of the training provider' do
      it 'renders the checkbox for the training provider first' do
        fieldsets = render.css('fieldset')
        fieldsets.each do |fieldset|
          expect(fieldset.css('label').first.text).to eq(training_provider.name)
          expect(fieldset.css('label').last.text).to eq(ratifying_provider.name)
        end
      end
    end

    context 'when the provider user is part of the ratifying provider' do
      let(:provider_user) { build_stubbed(:provider_user, providers: [ratifying_provider]) }

      it 'renders the checkbox for the ratifying provider first' do
        fieldsets = render.css('fieldset')
        fieldsets.each do |fieldset|
          expect(fieldset.css('label').first.text).to eq(ratifying_provider.name)
          expect(fieldset.css('label').last.text).to eq(training_provider.name)
        end
      end
    end

    context 'when the provider user is part of both of the providers' do
      let(:provider_user) { build_stubbed(:provider_user, providers: [training_provider, ratifying_provider]) }

      it 'renders the checkbox for the training provider first' do
        fieldsets = render.css('fieldset')
        fieldsets.each do |fieldset|
          expect(fieldset.css('label').first.text).to eq(training_provider.name)
          expect(fieldset.css('label').last.text).to eq(ratifying_provider.name)
        end
      end
    end
  end
end
