require 'rails_helper'

RSpec.describe CandidateInterface::InvitesComponent do
  include Rails.application.routes.url_helpers

  describe '#application_choice_link' do
    context 'when choice has an offer' do
      it 'returns the offer path' do
        invite = create(
          :pool_invite,
          application_choice: create(:application_choice, :offered),
        )

        component = described_class.new(
          application_form: invite.application_form,
          invites: [invite],
        )
        render_inline(component)

        expect(component.application_choice_link(invite)).to eq(
          candidate_interface_offer_path(
            invite.application_choice,
            return_to: 'invites',
          ),
        )
      end
    end

    context 'when choice does not have offer' do
      it 'returns the review path' do
        invite = create(:pool_invite, :with_application_choice)
        component = described_class.new(
          application_form: invite.application_form,
          invites: [invite],
        )
        render_inline(component)

        expect(component.application_choice_link(invite)).to eq(
          candidate_interface_course_choices_course_review_path(
            invite.application_choice,
            return_to: 'invites',
          ),
        )
      end
    end
  end
end
