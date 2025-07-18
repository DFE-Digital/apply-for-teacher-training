require 'rails_helper'

RSpec.describe NavigationItems do
  before { FeatureFlag.activate(:candidate_preferences) }
  after { FeatureFlag.deactivate(:candidate_preferences) }

  let(:current_application) { current_candidate.current_application }

  describe '.candidate_primary_navigation' do
    let(:current_candidate) { nil }
    let(:current_controller) { nil }

    subject(:navigation_items) { described_class.candidate_primary_navigation(current_candidate:, current_controller:) }

    context 'when no candidate is provided' do
      it 'contains no navigation items' do
        expect(navigation_items).to eq([])
      end
    end

    context 'when candidate is provided', time: mid_cycle do
      let(:current_candidate) { create(:candidate, application_forms: [create(:application_form, application_choices:)]) }

      context 'when application choice is in unsubmitted state' do
        let(:application_choices) { [build(:application_choice, :unsubmitted)] }

        it 'contains the "Your details" and "Your applications" navigation items, neither are in the active state' do
          expect(navigation_items).to contain_exactly(
            {
              text: 'Your details',
              href: candidate_interface_details_path,
              active: false,
            }, # both false as the controller does not implement #choices_controller?
            {
              text: 'Your applications',
              href: candidate_interface_application_choices_path,
              active: false,
            }, # both false as the controller does not implement #choices_controller?
          )
        end
      end

      context 'when application choice is in accepted state' do
        let(:application_choices) { [build(:application_choice, :pending_conditions)] }

        it 'contains only the "Your offer" navigation item in the active state' do
          expect(navigation_items).to contain_exactly(
            {
              text: 'Your offer',
              href: candidate_interface_application_offer_dashboard_path,
              active: true,
            },
          )
        end
      end
    end

    context 'when application_choice is unsubmitted and the controller is not a choices controller', time: mid_cycle do
      let(:current_candidate) { create(:candidate, application_forms: [create(:application_form, application_choices: build_list(:application_choice, 1, :unsubmitted))]) }
      let(:current_controller) { instance_double(CandidateInterface::CandidateInterfaceController, choices_controller?: false, invites_controller?: false) }

      it 'contains the "Your details" and "Your applications" navigation items, with "Your details" in the active state' do
        expect(navigation_items).to contain_exactly(
          {
            text: 'Your details',
            href: candidate_interface_details_path,
            active: true,
          },
          {
            text: 'Your applications',
            href: candidate_interface_application_choices_path,
            active: false,
          },
        )
      end
    end

    context 'when application_choice is unsubmitted and the controller is a choices controller', time: mid_cycle do
      let(:current_candidate) { create(:candidate, application_forms: [create(:application_form, application_choices: build_list(:application_choice, 1, :unsubmitted))]) }
      let(:current_controller) { instance_double(CandidateInterface::CandidateInterfaceController, choices_controller?: true) }

      it 'contains the "Your details" and "Your applications" navigation items, with "Your applications" in the active state' do
        expect(navigation_items).to contain_exactly(
          {
            text: 'Your details',
            href: candidate_interface_details_path,
            active: false,
          },
          {
            text: 'Your applications',
            href: candidate_interface_application_choices_path,
            active: true,
          },
        )
      end
    end

    context 'when application_choice is submitted and the controller is invites controller', time: mid_cycle do
      let(:current_candidate) { create(:candidate, application_forms: [create(:application_form, :completed, submitted_application_choices_count: 1)]) }
      let(:current_controller) { instance_double(CandidateInterface::CandidateInterfaceController, choices_controller?: false, invites_controller?: true) }

      it 'contains the "Your details" and "Your applications" navigation items, with "Your applications" in the active state' do
        expect(navigation_items).to contain_exactly(
          {
            text: 'Your details',
            href: candidate_interface_details_path,
            active: false,
          },
          {
            text: 'Your applications',
            href: candidate_interface_application_choices_path,
            active: false,
          },
          {
            text: 'Application sharing',
            href: candidate_interface_invites_path,
            active: true,
          },
        )
      end
    end

    context 'when application form can be carried over' do
      context 'from a previous cycle' do
        let(:current_candidate) do
          create(
            :candidate,
            application_forms: [create(:application_form, recruitment_cycle_year: previous_year)],
          )
        end

        it 'does not render the details tab' do
          expect(navigation_items).to contain_exactly(
            {
              text: 'Your applications',
              href: candidate_interface_application_choices_path,
              active: true,
            },
          )
        end
      end

      context 'from this cycle', time: after_apply_deadline do
        let(:current_candidate) do
          create(
            :candidate,
            application_forms: [create(:application_form, recruitment_cycle_year: previous_year)],
          )
        end

        it 'does not render the details tab' do
          expect(navigation_items).to contain_exactly(
            {
              text: 'Your applications',
              href: candidate_interface_application_choices_path,
              active: true,
            },
          )
        end
      end
    end
  end

  describe '#candidate' do
    subject(:navigation_items) { described_class.candidate(current_candidate:) }

    let(:current_candidate) { nil }

    it 'returns empty array if candidate is nill' do
      expect(navigation_items).to eq([])
    end

    context 'with candidate present' do
      let(:current_candidate) { create(:candidate) }

      it 'returns sign out button if one login is not enabled' do
        expect(navigation_items).to contain_exactly(
          have_attributes(text: 'Sign out', href: candidate_interface_sign_out_path),
        )
      end
    end

    context 'with candidate and one login enabled' do
      let(:current_candidate) { create(:candidate, :with_live_session) }

      it 'returns sign out and one login link when feature is enabled, bypass is false and one login auth is present' do
        FeatureFlag.activate(:one_login_candidate_sign_in)
        allow(OneLogin).to receive(:bypass?).and_return(false)
        govuk_one_login = "GOV.UK One Login #{described_class.instance_eval { one_login_svg }}"

        expect(navigation_items).to contain_exactly(
          have_attributes(text: govuk_one_login, href: ENV['GOVUK_ONE_LOGIN_ACCOUNT_URL']),
          have_attributes(text: 'Sign out', href: auth_one_login_sign_out_path),
        )
      end

      it 'returns sign out without one login link if bypass is true' do
        FeatureFlag.activate(:one_login_candidate_sign_in)
        allow(OneLogin).to receive(:bypass?).and_return(true)

        expect(navigation_items).to contain_exactly(
          have_attributes(text: 'Sign out', href: auth_one_login_sign_out_path),
        )
      end
    end

    context 'with candidate without one login auth and one login enabled' do
      let(:current_candidate) { create(:candidate) }

      it 'returns sign out without one login link if candidate does not have one login auth' do
        FeatureFlag.activate(:one_login_candidate_sign_in)
        allow(OneLogin).to receive(:bypass?).and_return(false)

        expect(navigation_items).to contain_exactly(
          have_attributes(text: 'Sign out', href: auth_one_login_sign_out_path),
        )
      end
    end
  end
end
