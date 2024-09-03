require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationChoiceItemComponent do
  let(:application_choice) { create(:application_choice, status) }
  let(:component) { described_class.new(application_choice:) }
  let(:rendered) { render_inline(component) }

  shared_examples 'application choice item' do
    it 'displays correct message' do
      expect(rendered.text).to include(t("application_choice_states.#{application_choice.status}"))
      expect(rendered.text).to include(application_choice.current_course.provider.name)
      expect(rendered.text).to include(application_choice.id.to_s)
      expect(rendered.text).to include(application_choice.current_course.name_and_code)
      expect(rendered.text).to include(application_choice.site.name)
    end
  end

  it_behaves_like('application choice item') { let(:status) { :unsubmitted } }
  it_behaves_like('application choice item') { let(:status) { :awaiting_provider_decision } }
  it_behaves_like('application choice item') { let(:status) { :interviewing } }
  it_behaves_like('application choice item') { let(:status) { :withdrawn } }

  it_behaves_like('application choice item') { let(:status) { :offer } }

  it_behaves_like('application choice item') { let(:status) { :pending_conditions } }
  it_behaves_like('application choice item') { let(:status) { :offer_withdrawn } }

  it_behaves_like('application choice item') { let(:status) { :rejected } }
  it_behaves_like('application choice item') { let(:status) { :declined } }
  it_behaves_like('application choice item') { let(:status) { :inactive } }
end
