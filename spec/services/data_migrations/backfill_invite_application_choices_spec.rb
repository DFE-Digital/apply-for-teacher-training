require 'rails_helper'

RSpec.describe DataMigrations::BackfillInviteApplicationChoices do
  describe '#change' do
    let(:migration) { described_class.new.change }

    it 'links invites with application_choices' do
      provider = create(:provider)

      course = create(:course, :with_a_course_option, provider:)
      applied_invite = create(:pool_invite, course:, status: 'published')
      applied_choice = create(
        :application_choice,
        :awaiting_provider_decision,
        application_form: applied_invite.application_form,
        course_option: course.course_options.first,
        provider_ids: [provider.id],
      )

      original_course = create(:course, :with_a_course_option, provider:)
      changed_course_invite = create(:pool_invite, course: original_course, status: 'published')
      changed_course_choice = create(
        :application_choice,
        :awaiting_provider_decision,
        application_form: changed_course_invite.application_form,
        original_course_option: original_course.course_options.first,
        provider_ids: [provider.id],
      )

      current_course = create(:course, :with_a_course_option, provider:)
      current_course_invite = create(:pool_invite, course: current_course, status: 'published')
      current_course_choice = create(
        :application_choice,
        :awaiting_provider_decision,
        application_form: current_course_invite.application_form,
        current_course_option: current_course.course_options.first,
        provider_ids: [provider.id],
      )

      multiple_choices_course = create(:course, :with_a_course_option, provider:)
      multiple_choices_invite = create(:pool_invite, course: multiple_choices_course, status: 'published')
      first_choice = create(
        :application_choice,
        :awaiting_provider_decision,
        application_form: multiple_choices_invite.application_form,
        current_course_option: multiple_choices_course.course_options.first,
        provider_ids: [provider.id],
      )
      _second_choice = create(
        :application_choice,
        :awaiting_provider_decision,
        application_form: multiple_choices_invite.application_form,
        current_course_option: multiple_choices_course.course_options.first,
        provider_ids: [provider.id],
        created_at: 1.day.ago,
        updated_at: 1.day.ago,
      )

      linked_invite = create(:pool_invite, :with_application_choice, status: 'published')
      normal_invite = create(:pool_invite, status: 'published')

      expect { migration }.to change { applied_invite.reload.application_choice_id }.from(nil).to(applied_choice.id)
        .and(change { applied_invite.candidate_decision }.from('not_responded').to('applied'))
        .and(change { changed_course_invite.reload.application_choice_id }.from(nil).to(changed_course_choice.id))
        .and(change { changed_course_invite.candidate_decision }.from('not_responded').to('applied'))
        .and(change { current_course_invite.reload.application_choice_id }.from(nil).to(current_course_choice.id))
        .and(change { current_course_invite.candidate_decision }.from('not_responded').to('applied'))
        .and(change { multiple_choices_invite.reload.application_choice_id }.from(nil).to(first_choice.id))
        .and(change { multiple_choices_invite.candidate_decision }.from('not_responded').to('applied'))
        .and(not_change { normal_invite.reload.application_choice_id })
        .and(not_change { linked_invite.reload.application_choice_id })
    end
  end
end
