require 'rails_helper'

RSpec.describe UCASMatches::SendResolvedOnUCASEmails do
  let(:course) { create(:course) }
  let(:course_option) { create(:course_option, course: course) }
  let(:candidate) { create(:candidate) }
  let(:application_choice) { create(:application_choice, course_option: course_option) }
  let!(:application_form) { create(:completed_application_form, candidate_id: candidate.id, application_choices: [application_choice]) }
  let(:provider_user) { create(:provider_user) }
  let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

  context 'when the application has been resolved on ucas' do
    let(:ucas_match) { create(:ucas_match, action_taken: 'resolved_on_ucas', application_form: application_form, scheme: %w[B]) }

    before do
      create(:provider_permissions, provider_id: course.provider.id, provider_user_id: provider_user.id)
      allow(CandidateMailer).to receive(:ucas_match_resolved_on_ucas_email).and_return(mail)
      allow(ProviderMailer).to receive(:ucas_match_resolved_on_ucas_email).and_return(mail)
      described_class.new(ucas_match, at_our_request: false).call
    end

    it 'sends the candidate the ucas_match_resolved_on_ucas_email' do
      expect(CandidateMailer).to have_received(:ucas_match_resolved_on_ucas_email).with(application_choice)
    end

    it 'sends the provider the ucas_match_resolved_on_ucas_email' do
      expect(ProviderMailer).to have_received(:ucas_match_resolved_on_ucas_email).with(provider_user, application_choice)
    end
  end

  context 'when the application has been resolved on ucas at our request' do
    let(:ucas_match) { create(:ucas_match, action_taken: 'resolved_on_ucas', application_form: application_form, scheme: %w[B]) }

    before do
      create(:provider_permissions, provider_id: course.provider.id, provider_user_id: provider_user.id)
      allow(CandidateMailer).to receive(:ucas_match_resolved_on_ucas_at_our_request_email).and_return(mail)
      allow(ProviderMailer).to receive(:ucas_match_resolved_on_ucas_email).and_return(mail)
      described_class.new(ucas_match, at_our_request: true).call
    end

    it 'sends the candidate the ucas_match_resolved_on_ucas_at_our_request_email' do
      expect(CandidateMailer).to have_received(:ucas_match_resolved_on_ucas_at_our_request_email).with(application_choice)
    end

    it 'sends the provider the ucas_match_resolved_on_ucas_email' do
      expect(ProviderMailer).to have_received(:ucas_match_resolved_on_ucas_email).with(provider_user, application_choice)
    end
  end
end
