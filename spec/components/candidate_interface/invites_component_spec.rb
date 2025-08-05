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

        component = described_class.new(invites: [invite])
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
        component = described_class.new(invites: [invite])
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

  describe '#hint_text' do
    it 'returns no invites message when no invites' do
      component = described_class.new(invites: [])
      render_inline(component)

      expect(component.hint_text).to eq('You have no previous invitations')
    end

    it 'returns invites message when there are invites' do
      component = described_class.new(invites: [create(:pool_invite)])
      render_inline(component)

      expect(component.hint_text).to eq('You can still submit an application to open courses you have declined.')
    end
  end

  describe '#status_tag' do
    context 'with accepted invite' do
      it 'returns the green status tag' do
        invite = create(
          :pool_invite,
          application_choice: create(:application_choice, :offered),
          candidate_decision: 'accepted',
        )
        component = described_class.new(invites: [invite])
        render_inline(component)

        expect(component.status_tag(invite)).to eq(
          '<strong class="govuk-tag govuk-tag--green">Accepted</strong>',
        )
      end
    end

    context 'when invite declined' do
      it 'returns no invites message when no invites' do
        invite = create(
          :pool_invite,
          candidate_decision: 'declined',
        )
        component = described_class.new(invites: [invite])
        render_inline(component)

        expect(component.status_tag(invite)).to eq(
          '<strong class="govuk-tag govuk-tag--red">Declined</strong>',
        )
      end
    end

    context 'when course invite is closed' do
      it 'returns no invites message when no invites' do
        invite = create(
          :pool_invite,
          course_open: false,
        )
        component = described_class.new(invites: [invite])
        render_inline(component)

        expect(component.status_tag(invite)).to eq(
          '<strong class="govuk-tag govuk-tag--grey">Closed</strong>',
        )
      end
    end
  end

  describe '#action-link' do
    context 'with applied invite' do
      it 'returns the applied action_link' do
        choice = create(:application_choice, :offered)
        invite = create(
          :pool_invite,
          application_choice: choice,
          candidate_decision: 'accepted',
        )
        component = described_class.new(invites: [invite])
        render_inline(component)

        expect(rendered_content).to have_link(
          'View application',
          href: candidate_interface_offer_path(
            invite.application_choice,
            return_to: 'invites',
          ),
        )
      end
    end

    context 'with declined invite' do
      it 'returns the find url action_link' do
        invite = create(:pool_invite, candidate_decision: 'declined')
        component = described_class.new(invites: [invite])
        render_inline(component)

        expect(rendered_content).to have_link(
          'View course',
          href: invite.course.find_url,
        )
      end
    end

    context 'with course closed invite' do
      it 'returns the find url action_link' do
        invite = create(:pool_invite, course_open: false)
        component = described_class.new(invites: [invite])
        render_inline(component)

        expect(rendered_content).to have_link(
          'View course',
          href: invite.course.find_url,
        )
      end
    end
  end
end
