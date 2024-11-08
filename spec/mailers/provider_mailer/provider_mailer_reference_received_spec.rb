require 'rails_helper'

RSpec.describe ProviderMailer do
  include TestHelpers::MailerSetupHelper

  describe '.reference_received' do
    let(:provider) { create(:provider, code: 'ABC', user: provider_user) }
    let(:provider_user) { create(:provider_user, first_name: 'Johny', last_name: 'English') }
    let(:course) { create(:course, provider:, name: 'Computer Science', code: '6IND') }
    let(:course_option) { create(:course_option, course:) }
    let(:application_choices) do
      [create(:application_choice, :awaiting_provider_decision, course_option:,
                                                                current_course_option: course_option)]
    end
    let(:application_form) do
      create(:completed_application_form, first_name: 'Harry',
                                          last_name: 'Potter',
                                          support_reference: '123A',
                                          application_choices:,
                                          references_count: 0)
    end

    let(:reference) { create(:reference, :feedback_provided, application_form:, feedback_provided_at: Time.zone.now) }
    let(:email) { described_class.reference_received(provider_user:, application_choice: application_choices.first, reference:, course:) }

    before do
      application_form.application_references << create(:reference, :feedback_provided, application_form:, feedback_provided_at: Time.zone.now)
      application_form.application_references << create(:reference, :feedback_provided, application_form:, feedback_provided_at: Time.zone.now)
    end

    it_behaves_like('a mail with subject and content',
                    'Harry Potter’s third reference received - manage teacher training applications',
                    'provider name' => 'Dear Johny English',
                    'course name and code' => 'Computer Science (6IND)',
                    'reference link' => /http:\/\/localhost:3000\/provider\/applications\/\d+\/references/)
  end
end
