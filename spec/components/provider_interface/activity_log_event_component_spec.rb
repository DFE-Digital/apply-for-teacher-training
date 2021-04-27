require 'rails_helper'

RSpec.describe ProviderInterface::ActivityLogEventComponent do
  def component_for(audit)
    described_class.new(activity_log_event: ActivityLogEvent.new(audit: audit))
  end

  def with_audit(trait)
    audit = create(:application_choice_audit, trait)
    user = audit.user.display_name
    candidate = audit.auditable.application_form.full_name
    yield audit, user, candidate
  end

  describe '#event_description' do
    examples = {
      awaiting_provider_decision: 'Application received from <candidate>',
      withdrawn: '<candidate> withdrew their application',
      with_rejection: '<user> rejected <candidate>’s application',
      with_rejection_by_default: '<candidate>’s application was automatically rejected',
      with_rejection_by_default_and_feedback: '<user> sent feedback to <candidate>',
      with_offer: '<user> made an offer to <candidate>',
      with_modified_offer: '<user> made an offer to <candidate>',
      with_changed_offer: '<user> changed the offer made to <candidate>',
      with_accepted_offer: '<candidate> accepted an offer',
      with_declined_offer: '<candidate> declined an offer',
      with_declined_by_default_offer: '<candidate>’s offer was automatically declined',
      with_withdrawn_offer: '<user> withdrew <candidate>’s offer',
      with_conditions_not_met: '<user> marked <candidate>’s offer conditions as not met',
      with_recruited: '<user> marked <candidate>’s offer conditions as all met',
      with_deferred_offer: '<user> deferred <candidate>’s offer',
    }

    examples.each do |trait, template|
      it "for application #{trait}" do
        with_audit(trait) do |audit, user, candidate|
          expected = template.gsub('<user>', user).gsub('<candidate>', candidate)
          expect(component_for(audit).event_description).to eq(expected)
        end
      end
    end
  end

  describe '#event_description for an interview audit' do
    it 'presents interview details' do
      audit = build_stubbed(
        :interview_audit,
        audited_changes: {},
        auditable: build_stubbed(:interview),
        associated: build_stubbed(:application_choice),
      )

      expected = "#{audit.user.full_name} set up an interview with #{audit.associated.application_form.full_name}"
      expect(component_for(audit).event_description).to eq(expected)
    end
  end

  describe '#link' do
    let(:routes) { Rails.application.routes.url_helpers }

    it 'shows a link to View application in most cases' do
      with_audit(:awaiting_provider_decision) do |audit, _user, _candidate|
        expect(component_for(audit).link).to eq({
          url: routes.provider_interface_application_choice_path(audit.auditable),
          text: 'View application',
        })
      end
    end

    it 'links to View offer if application is at offer stage' do
      with_audit(:with_offer) do |audit, _user, _candidate|
        expect(component_for(audit).link).to eq({
          url: routes.provider_interface_application_choice_offer_path(audit.auditable),
          text: 'View offer',
        })
      end
    end

    it 'links to View conditions if application is at pending_conditions stage' do
      with_audit(:with_accepted_offer) do |audit, _user, _candidate|
        expect(component_for(audit).link).to eq({
          url: routes.provider_interface_application_choice_offer_path(audit.auditable),
          text: 'View offer',
        })
      end
    end

    it 'says View feedback if showing a feedback event' do
      with_audit(:with_rejection_by_default_and_feedback) do |audit, _user, _candidate|
        expect(component_for(audit).link).to eq({
          url: routes.provider_interface_application_choice_feedback_path(audit.auditable),
          text: 'View feedback',
        })
      end
    end

    it 'links to View offer for change offer events if at offer stage' do
      with_audit(:with_changed_offer) do |audit, _user, _candidate|
        expect(component_for(audit).link).to eq({
          url: routes.provider_interface_application_choice_offer_path(audit.auditable),
          text: 'View offer',
        })
      end
    end

    it 'links to the interview tab for an interview audit' do
      interview = build_stubbed(:interview)
      application_choice = build_stubbed(:application_choice)
      audit = build_stubbed(
        :interview_audit,
        audited_changes: {},
        auditable: interview,
        associated: application_choice,
      )

      expect(component_for(audit).link).to eq({
        url: routes.provider_interface_application_choice_interviews_path(application_choice, anchor: "interview-#{interview.id}"),
        text: 'View interview',
      })
    end

    it 'hides the interview link for an interview which has been cancelled' do
      audit = build_stubbed(
        :interview_audit,
        audited_changes: {},
        auditable: build_stubbed(:interview, :cancelled),
        associated: build_stubbed(:application_choice),
      )

      expect(component_for(audit).link).to be_nil
    end

    context 'rendering' do
      it 'nothing is rendered if there is no link to display' do
        audit = build_stubbed(
          :interview_audit,
          audited_changes: {},
          auditable: build_stubbed(:interview, :cancelled),
          associated: build_stubbed(:application_choice),
        )

        expect(render_inline(component_for(audit)).css('a')).to be_empty
      end

      it 'the link is rendered if there is a link to display' do
        with_audit(:with_accepted_offer) do |audit, _user, _candidate|
          expect(render_inline(component_for(audit)).css('a').first.text).to eq('View offer')
        end
      end
    end
  end

  describe '#course_option' do
    context 'shows the original course option until the offer can be changed' do
      examples = %i[
        awaiting_provider_decision
        with_rejection
        with_rejection_by_default
        with_rejection_by_default_and_feedback
      ]

      examples.each do |trait|
        it "for application #{trait}" do
          with_audit(trait) do |audit, _user, _candidate|
            choice = audit.auditable
            choice.update_columns(current_course_option_id: create(:course_option).id)
            expect(component_for(audit).course_option.id).to eq(choice.course_option.id)
          end
        end
      end
    end

    context 'shows the most up-to-date course option if the offer may have been changed' do
      examples = %i[
        withdrawn
        with_accepted_offer
        with_declined_offer
        with_declined_by_default_offer
        with_withdrawn_offer
        with_recruited
        with_deferred_offer
      ]

      examples.each do |trait|
        it "for application #{trait}" do
          with_audit(trait) do |audit, _user, _candidate|
            choice = audit.auditable
            choice.update_columns(current_course_option_id: create(:course_option).id)
            expect(component_for(audit).course_option.id).to eq(choice.current_course_option.id)
          end
        end
      end
    end

    context 'for offer and change offer events' do
      examples = %i[
        with_modified_offer
        with_changed_offer
      ]

      examples.each do |trait|
        it "#{trait} uses the course option from the event, not the application" do
          with_audit(trait) do |audit, _user, _candidate|
            audit.auditable.update_columns(current_course_option_id: create(:course_option).id)
            expected = audit.audited_changes['current_course_option_id'].second
            expect(component_for(audit).course_option.id).to eq(expected)
          end
        end
      end
    end

    context 'for old offer and change offer events' do
      examples = %i[
        with_old_modified_offer
        with_old_changed_offer
      ]

      examples.each do |trait|
        it "#{trait} uses the course option from the event, not the application" do
          with_audit(trait) do |audit, _user, _candidate|
            audit.auditable.update_columns(current_course_option_id: create(:course_option).id)
            expected = audit.audited_changes['current_course_option_id'].second
            expect(component_for(audit).course_option.id).to eq(expected)
          end
        end
      end
    end
  end

  it 'does actually render html :)' do
    with_audit(:awaiting_provider_decision) do |audit, _user, _candidate|
      expect(render_inline(component_for(audit)).to_html).to be_present
    end
  end

  describe '#event_content' do
    it 'renders the correct message when event_content is called multiple times' do
      accredited_provider = create(:provider)
      course = create(:course, accredited_provider: accredited_provider)
      course_option = create(:course_option, course: course)
      application_choice = create(:application_choice, course_option: course_option)
      audit = create(:application_choice_audit, application_choice: application_choice)
      component_for(audit).event_content

      expect(component_for(audit).event_content).to eq("#{course_option.provider.name} – ratified by #{accredited_provider.name}")
    end
  end
end
