require 'rails_helper'

RSpec.describe ProviderRelationshipPermissions do
  let(:setup_at) { Time.zone.now }

  describe 'validations' do
    subject(:permissions) do
      described_class.new(
        ratifying_provider: build_stubbed(:provider),
        training_provider: build_stubbed(:provider),
        ratifying_provider_can_view_safeguarding_information: true,
        ratifying_provider_can_view_diversity_information: true,
        setup_at:,
      )
    end

    it 'ensures at least one permission in each pair is active' do
      expect(permissions.valid?).to be false
      expect(permissions.errors.attribute_names).to eq(%i[make_decisions])
    end

    context 'when permissions have not been set up' do
      let(:setup_at) { nil }

      it 'skips validation' do
        expect(permissions.valid?).to be true
      end

      context 'when the :setup context is used' do
        it 'ensures at least one permission in each pair is active' do
          expect(permissions.valid?(:setup)).to be false
          expect(permissions.errors.attribute_names).to eq(%i[make_decisions])
        end
      end
    end

    context 'when at least one permission in each pair is active' do
      it 'is a valid set of permissions' do
        permissions.training_provider_can_make_decisions = true

        expect(permissions.valid?).to be true
      end
    end
  end

  describe 'auditing', with_audited: true do
    let(:training_provider) { create(:provider) }
    let(:ratifying_provider) { create(:provider) }
    let(:provider_relationship_permissions) do
      create(:provider_relationship_permissions,
             training_provider:,
             ratifying_provider:,
             setup_at:)
    end

    before do
      provider_relationship_permissions
    end

    it 'creates audit entries' do
      expect {
        provider_relationship_permissions.update!(ratifying_provider_can_make_decisions: true)
      }.to change { training_provider.associated_audits.count }.by(1)
    end

    it 'creates an associated object in each audit record' do
      provider_relationship_permissions.update!(training_provider_can_make_decisions: true)

      expect(training_provider.associated_audits.last.auditable).to eq provider_relationship_permissions
      expect(provider_relationship_permissions.audits.last.associated).to eq(training_provider)
    end
  end

  describe '#all_relationships_for_providers' do
    let(:training_provider) { create(:provider) }
    let(:ratifying_provider) { create(:provider) }
    let!(:random_relationship) { create(:provider_relationship_permissions) }
    let!(:relationship) do
      create(
        :provider_relationship_permissions,
        training_provider:,
        ratifying_provider:,
      )
    end

    it 'includes training providers' do
      expect(described_class.all_relationships_for_providers([training_provider])).to eq([relationship])
    end

    it 'includes ratifying providers' do
      expect(described_class.all_relationships_for_providers([ratifying_provider])).to eq([relationship])
    end

    it 'does not include duplicates' do
      expect(described_class.all_relationships_for_providers([training_provider, ratifying_provider])).to eq([relationship])
    end
  end

  describe '#partner_organisations' do
    let(:training_provider) { create(:provider) }
    let(:ratifying_provider) { create(:provider) }
    let!(:relationship) do
      create(
        :provider_relationship_permissions,
        training_provider:,
        ratifying_provider:,
      )
    end

    context 'for a ratifying provider' do
      it 'is the training provider' do
        expect(relationship.partner_organisation(ratifying_provider)).to eq(training_provider)
      end
    end

    context 'for a training provider' do
      it 'is the ratifying provider' do
        expect(relationship.partner_organisation(training_provider)).to eq(ratifying_provider)
      end
    end
  end

  describe '#permit?' do
    let(:training_provider) { create(:provider) }
    let(:ratifying_provider) { create(:provider) }
    let!(:relationship) do
      create(
        :provider_relationship_permissions,
        training_provider:,
        ratifying_provider:,
        training_provider_can_view_diversity_information: true,
        ratifying_provider_can_view_diversity_information: false,
        training_provider_can_view_safeguarding_information: true,
        ratifying_provider_can_view_safeguarding_information: true,
        training_provider_can_make_decisions: false,
        ratifying_provider_can_make_decisions: true,
      )
    end

    it 'indicates whether the provider has a specific permission' do
      expect(relationship.permit?(:make_decisions, ratifying_provider)).to be true
      expect(relationship.permit?(:make_decisions, training_provider)).to be false
      expect(relationship.permit?(:view_safeguarding_information, ratifying_provider)).to be true
      expect(relationship.permit?(:view_safeguarding_information, training_provider)).to be true
      expect(relationship.permit?(:view_diversity_information, ratifying_provider)).to be false
      expect(relationship.permit?(:view_diversity_information, training_provider)).to be true
    end
  end

  describe '#providers_have_open_course?' do
    let(:training_provider) { create(:provider) }
    let(:ratifying_provider) { create(:provider) }
    let!(:relationship) do
      create(
        :provider_relationship_permissions,
        training_provider:,
        ratifying_provider:,
      )
    end

    context 'there are no courses' do
      it 'returns false' do
        expect(relationship.providers_have_open_course?).to be(false)
      end
    end

    context 'there is an unopened course' do
      let!(:course) { create(:course, provider: training_provider, accredited_provider: ratifying_provider) }

      it 'returns false' do
        expect(relationship.providers_have_open_course?).to be(false)
      end
    end

    context 'there is an open course' do
      let!(:course) { create(:course, :open_on_apply, provider: training_provider, accredited_provider: ratifying_provider) }

      it 'returns false' do
        expect(relationship.providers_have_open_course?).to be(true)
      end
    end
  end

  describe '.providers_have_open_course' do
    def create_relationship_with_course(course_traits: [])
      relationship = create(:provider_relationship_permissions)
      create(:course, *course_traits, provider: relationship.training_provider, accredited_provider: relationship.ratifying_provider)
      relationship
    end

    let!(:no_course_relationship) { create(:provider_relationship_permissions) }
    let!(:unopened_course_relationship) { create_relationship_with_course }
    let!(:open_course_relationship) { create_relationship_with_course(course_traits: [:open_on_apply]) }
    let!(:open_course_in_previous_cycle_relationship) { create_relationship_with_course(course_traits: %i[open_on_apply previous_year]) }

    it 'only returns the open_course_relationship' do
      expect(described_class.providers_have_open_course).to eq([open_course_relationship])
    end
  end
end
