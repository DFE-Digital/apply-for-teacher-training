require 'rails_helper'

RSpec.describe ProviderMailer do
  describe '.set_up_organisation_permissions' do
    let(:email) { described_class.set_up_organisation_permissions(provider_user, relationships_to_set_up) }

    describe 'set_up_organisation_permissions for single provider with one relationship' do
      let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
      let(:relationships_to_set_up) do
        { 'University of Selsdon' => ['University of Croydon'] }
      end

      it_behaves_like(
        'a mail with subject and content',
        'Set up organisation permissions - manage teacher training applications',
        'salutation' => 'Dear Johny English',
        'main paragraph' => 'Candidates can now find courses you run with:',
        'partner providers' => '- University of Croydon',
        'relationship_setup_paragraph' => 'Either you or this partner organisation',
        'when_to_setup_relationship' => 'unless your partner organisation sets them up',
        'link to applications' => 'http://localhost:3000/provider/applications',
        'footer' => 'Get help, report a problem or give feedback',
      )
    end

    describe 'set_up_organisation_permissions for single provider with multiple relationships' do
      let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
      let(:relationships_to_set_up) do
        { 'University of Selsdon' => ['University of Croydon', 'University of Purley'] }
      end

      it_behaves_like(
        'a mail with subject and content',
        'Set up organisation permissions - manage teacher training applications',
        'salutation' => 'Dear Johny English',
        'main paragraph' => 'Candidates can now find courses you run with:',
        'partner providers' => /- University of Croydon\s+- University of Purley/,
        'relationship_setup_paragraph' => 'Either you or these partner organisations',
        'when_to_setup_relationship' => 'unless your partner organisations set them up',
        'link to applications' => 'http://localhost:3000/provider/applications',
        'footer' => 'Get help, report a problem or give feedback',
      )
    end

    describe 'set_up_organisation_permissions with multiple organisations' do
      let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
      let(:relationships_to_set_up) do
        {
          'University of Dundee' => ['University of Broughty Ferry', 'University of Carnoustie'],
          'University of Selsdon' => ['University of Croydon', 'University of Purley'],
        }
      end

      it_behaves_like(
        'a mail with subject and content',
        'Set up organisation permissions - manage teacher training applications',
        'salutation' => 'Dear Johny English',
        'main paragraph' => 'Candidates can now find courses you run with the partner organisations listed below.',
        'first relationship group' => 'For University of Dundee, you need to set up permissions for courses you work on with:',
        'first group of partner providers' => /- University of Broughty Ferry\s+- University of Carnoustie/,
        'second relationship group' => 'For University of Selsdon, you need to set up permissions for courses you work on with:',
        'second group of partner providers' => /- University of Croydon\s+- University of Purley/,
        'link to applications' => 'http://localhost:3000/provider/applications',
        'footer' => 'Get help, report a problem or give feedback',
      )
    end
  end
end
