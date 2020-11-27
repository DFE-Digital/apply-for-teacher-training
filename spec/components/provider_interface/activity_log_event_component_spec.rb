require 'rails_helper'

RSpec.describe ProviderInterface::ActivityLogEventComponent do
  def component_for(event)
    described_class.new(activity_log_event: event)
  end

  describe '#event_description' do
    examples = {
      awaiting_provider_decision: '<candidate> submitted an application',
      withdrawn: '<candidate> withdrew their application',
      with_rejection: '<user> rejected <candidate>’s application',
      with_rejection_by_default: '<candidate>’s application was rejected automatically',
      with_rejection_by_default_and_feedback: '<user> sent feedback to <candidate>',
      with_offer: '<user> made an offer to <candidate>',
      with_modified_offer: '<user> made an offer to <candidate>',
      with_accepted_offer: '<candidate> accepted an offer',
      with_declined_offer: '<candidate> declined an offer',
      with_declined_by_default_offer: '<candidate>’s offer was declined automatically',
      with_withdrawn_offer: '<user> withdrew <candidate>’s offer',
      with_recruited: '<user> recruited <candidate>',
      with_deferred_offer: '<user> deferred <candidate>’s offer',
    }

    def with_event(trait)
      event = create(:application_choice_audit, trait)
      user = event.user.display_name
      candidate = event.auditable.application_form.full_name
      yield event, user, candidate
    end

    examples.each do |trait, template|
      it "for application #{trait}" do
        with_event(trait) do |event, user, candidate|
          expected = template.gsub('<user>', user).gsub('<candidate>', candidate)
          expect(component_for(event).event_description).to eq(expected)
        end
      end
    end
  end

  it 'shows the original course option until the offer stage' do
    # expect(render_inline(component_for(event)).to_html).to eq ''
  end
end
