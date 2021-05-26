require 'rails_helper'

RSpec.shared_examples 'an action which tracks validation errors' do |action|
  it "tracks validation errors for #{action}" do
    expect { subject }.to change(ValidationError, :count).by(1)
  end
end

RSpec.describe ProviderInterface::OffersController, type: :request do
  include DfESignInHelpers

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in, :with_make_decisions) }
  let(:provider) { provider_user.providers.first }
  let(:application_form) { build(:application_form, :minimum_info) }
  let(:course) { create(:course, :open_on_apply, provider: provider) }
  let(:course_option) { build(:course_option, course: course) }

  before do
    allow(DfESignInUser).to receive(:load_from_session)
      .and_return(
        DfESignInUser.new(
          email_address: provider_user.email_address,
          dfe_sign_in_uid: provider_user.dfe_sign_in_uid,
          first_name: provider_user.first_name,
          last_name: provider_user.last_name,
        ),
      )
  end

  describe 'if application choice is not in a pending decision state' do
    let!(:application_choice) do
      create(:application_choice, :withdrawn,
             application_form: application_form,
             course_option: course_option)
    end

    context 'GET new' do
      it 'responds with 302' do
        get new_provider_interface_application_choice_offer_path(application_choice)

        expect(response.status).to eq(302)
      end
    end

    context 'POST create' do
      it 'responds with 302' do
        post provider_interface_application_choice_offer_path(application_choice)

        expect(response.status).to eq(302)
      end
    end
  end

  describe 'if application choice is not in an offered state' do
    let!(:application_choice) do
      create(:application_choice, :awaiting_provider_decision,
             application_form: application_form,
             course_option: course_option)
    end

    context 'GET edit' do
      it 'responds with 302' do
        get edit_provider_interface_application_choice_offer_providers_path(application_choice)

        expect(response.status).to eq(302)
      end
    end

    context 'PUT update' do
      it 'responds with 302' do
        put provider_interface_application_choice_offer_providers_path(application_choice)

        expect(response.status).to eq(302)
      end
    end
  end

  # rubocop:disable RSpec/AnyInstance
  describe 'validation errors' do
    let(:trait) { :offer }
    let(:application_choice) do
      create(
        :application_choice, trait,
        application_form: application_form,
        course_option: course_option
      )
    end

    before { allow_any_instance_of(ProviderInterface::OfferWizard).to receive(:valid_for_current_step?).and_return(false) }

    context 'POST to create' do
      let(:trait) { :awaiting_provider_decision }

      subject { post provider_interface_application_choice_offer_path(application_choice) }

      it_behaves_like 'an action which tracks validation errors', 'POST to create'
    end

    context 'PUT to update' do
      subject { put provider_interface_application_choice_offer_path(application_choice) }

      it_behaves_like 'an action which tracks validation errors', 'POST to create'
    end

    context 'POST to (providers) create' do
      let(:trait) { :awaiting_provider_decision }

      subject do
        post provider_interface_application_choice_offer_providers_path(application_choice),
             params: { provider_interface_offer_wizard: { provider_id: provider.id } }
      end

      it_behaves_like 'an action which tracks validation errors', 'POST to (providers) create'
    end

    context 'PUT to (providers) update' do
      subject do
        put provider_interface_application_choice_offer_providers_path(application_choice),
            params: { provider_interface_offer_wizard: { provider_id: provider.id } }
      end

      it_behaves_like 'an action which tracks validation errors', 'PUT to (providers) update'
    end

    context 'POST to (conditions) create' do
      let(:trait) { :awaiting_provider_decision }

      subject do
        post provider_interface_application_choice_offer_conditions_path(application_choice),
             params: { provider_interface_offer_wizard: { standard_conditions: %w[dance] } }
      end

      it_behaves_like 'an action which tracks validation errors', 'POST to (conditions) create'
    end

    context 'PATCH to (conditions) update' do
      subject do
        patch provider_interface_application_choice_offer_conditions_path(application_choice),
              params: { provider_interface_offer_wizard: { standard_conditions: %w[dance] } }
      end

      it_behaves_like 'an action which tracks validation errors', 'PATCH to (conditions) update'
    end

    context 'POST to (courses) create' do
      let(:trait) { :awaiting_provider_decision }

      before { allow_any_instance_of(ProviderInterface::OfferWizard).to receive(:provider_id).and_return(provider.id) }

      subject do
        post provider_interface_application_choice_offer_courses_path(application_choice),
             params: { provider_interface_offer_wizard: { course_id: course.id } }
      end

      it_behaves_like 'an action which tracks validation errors', 'POST to (courses) create'
    end

    context 'PATCH to (courses) update' do
      before { allow_any_instance_of(ProviderInterface::OfferWizard).to receive(:provider_id).and_return(provider.id) }

      subject do
        patch provider_interface_application_choice_offer_courses_path(application_choice),
              params: { provider_interface_offer_wizard: { course_id: course.id } }
      end

      it_behaves_like 'an action which tracks validation errors', 'PATCH to (courses) update'
    end

    context 'POST to (locations) create' do
      let(:trait) { :awaiting_provider_decision }

      before { allow_any_instance_of(ProviderInterface::OfferWizard).to receive(:course_id).and_return(course.id) }

      subject do
        post provider_interface_application_choice_offer_locations_path(application_choice),
             params: { provider_interface_offer_wizard: { course_option_id: course_option.id } }
      end

      it_behaves_like 'an action which tracks validation errors', 'POST to (locations) create'
    end

    context 'PATCH to (locations) update' do
      before { allow_any_instance_of(ProviderInterface::OfferWizard).to receive(:course_id).and_return(course.id) }

      subject do
        patch provider_interface_application_choice_offer_locations_path(application_choice),
              params: { provider_interface_offer_wizard: { course_option_id: course_option.id } }
      end

      it_behaves_like 'an action which tracks validation errors', 'PATCH to (locations) update'
    end

    context 'POST to (study_modes) create' do
      let(:trait) { :awaiting_provider_decision }

      before { allow_any_instance_of(ProviderInterface::OfferWizard).to receive(:course_id).and_return(course.id) }

      subject do
        post provider_interface_application_choice_offer_study_modes_path(application_choice),
             params: { provider_interface_offer_wizard: { study_mode: 'full_time' } }
      end

      it_behaves_like 'an action which tracks validation errors', 'POST to (study_modes) create'
    end

    context 'PATCH to (study_modes) update' do
      before { allow_any_instance_of(ProviderInterface::OfferWizard).to receive(:course_id).and_return(course.id) }

      subject do
        patch provider_interface_application_choice_offer_study_modes_path(application_choice),
              params: { provider_interface_offer_wizard: { study_mode: 'full_time' } }
      end

      it_behaves_like 'an action which tracks validation errors', 'PATCH to (study_modes) update'
    end
  end
  # rubocop:enable RSpec/AnyInstance
end
