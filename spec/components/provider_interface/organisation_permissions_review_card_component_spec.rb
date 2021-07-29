require 'rails_helper'

RSpec.describe ProviderInterface::OrganisationPermissionsReviewCardComponent do
  let(:provider_relationship_permission) { build_stubbed(:provider_relationship_permissions) }
  let(:training_provider) { provider_relationship_permission.training_provider }
  let(:ratifying_provider) { provider_relationship_permission.ratifying_provider }
  let(:provider_user) { build_stubbed(:provider_user, providers: [training_provider]) }
  let(:change_path) { nil }

  let(:render) do
    render_inline(
      described_class.new(
        provider_user: provider_user,
        provider_relationship_permission: provider_relationship_permission,
        change_path: change_path,
      ),
    )
  end

  describe 'heading levels' do
    let(:component_attrs) do
      {
        provider_user: provider_user,
        provider_relationship_permission: provider_relationship_permission,
      }
    end

    subject!(:render) { render_inline(described_class.new(component_attrs)) }

    it 'renders headings as h2 by default' do
      expect(page).to have_css('h2.app-summary-card__title')
    end

    context 'when heading level is specified' do
      let(:component_attrs) do
        {
          provider_user: provider_user,
          provider_relationship_permission: provider_relationship_permission,
          summary_card_heading_level: 4,
        }
      end

      it 'renders headings at the level specified' do
        expect(page).to have_css('h4.app-summary-card__title')
        expect(page).not_to have_css('h2.app-summary-card__title')
      end
    end
  end

  describe 'change link' do
    context 'when the change path is not provided' do
      it 'does not render an action link' do
        expect(render.css('a')).to be_empty
      end
    end

    context 'when the change path is provided' do
      let(:change_path) { '/path-to-change' }

      it 'renders an action link with hidden text set to the relationship description' do
        expect(render.css('a').text).to include('Change')
        expect(render.css('a .govuk-visually-hidden').text).to eq(" #{training_provider.name} and #{ratifying_provider.name}")
        expect(render.css('a').first.attributes['href'].value).to eq(change_path)
      end
    end
  end

  describe 'permissions display' do
    let(:provider_relationship_permission) do
      build_stubbed(
        :provider_relationship_permissions,
        training_provider_can_make_decisions: true,
        training_provider_can_view_safeguarding_information: false,
        training_provider_can_view_diversity_information: false,
        ratifying_provider_can_make_decisions: true,
        ratifying_provider_can_view_safeguarding_information: true,
        ratifying_provider_can_view_diversity_information: true,
      )
    end

    it 'renders the names of the providers that have the make_decision permission' do
      make_decision_row = row_with_key('Make offers and reject applications')
      expect(entries_in_row(make_decision_row)).to contain_exactly(training_provider.name, ratifying_provider.name)
    end

    it 'renders the names of the providers that have the safeguarding permission' do
      safeguarding_row = row_with_key('View criminal convictions and professional misconduct')
      expect(entries_in_row(safeguarding_row)).to contain_exactly(ratifying_provider.name)
    end

    it 'renders the names of the providers that have the diversity permission' do
      diversity_row = row_with_key('View sex, disability and ethnicity information')
      expect(entries_in_row(diversity_row)).to contain_exactly(ratifying_provider.name)
    end

    context 'when the provider user belongs to the training provider' do
      it 'renders the training provider name first' do
        make_decision_row = row_with_key('Make offers and reject applications')
        expect(entries_in_row(make_decision_row)).to eq([training_provider.name, ratifying_provider.name])
      end
    end

    context 'when the provider user belongs to the ratifying provider' do
      let(:provider_user) { build_stubbed(:provider_user, providers: [ratifying_provider]) }

      it 'renders the ratifying provider name first' do
        make_decision_row = row_with_key('Make offers and reject applications')
        expect(entries_in_row(make_decision_row)).to eq([ratifying_provider.name, training_provider.name])
      end
    end

    context 'when the provider user belongs to both providers' do
      let(:provider_user) { build_stubbed(:provider_user, providers: [training_provider, ratifying_provider]) }

      it 'renders the training provider name first' do
        make_decision_row = row_with_key('Make offers and reject applications')
        expect(entries_in_row(make_decision_row)).to eq([training_provider.name, ratifying_provider.name])
      end
    end

    def row_with_key(key)
      rows = render.css('.govuk-summary-list__row')
      rows.find { |row| row.css('.govuk-summary-list__key').text.squish == key }
    end

    def entries_in_row(row)
      row.css('.govuk-summary-list__value > ul > li').map(&:text)
    end
  end
end
