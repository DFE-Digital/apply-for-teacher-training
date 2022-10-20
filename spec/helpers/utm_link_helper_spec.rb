require 'rails_helper'

RSpec.describe UtmLinkHelper, type: :helper do
  let(:application_form) { create(:application_form, :minimum_info, phase: 'apply_1') }

  before { allow(HostingEnvironment).to receive(:environment_name).and_return('production') }

  describe '#govuk_link_to_with_utm_params' do
    let(:link_text) { 'Somewhere over the rainbow' }
    let(:utm_campaign) { 'candidate_interface/degrees/degree-new_enic' }
    let(:link_url) { '/some/link' }
    let(:utm_content) { application_form.phase }

    context 'GIT links in production' do
      it 'returns govuk_link_to html with utm params and encoded utm campaign' do
        link = helper.govuk_link_to_with_utm_params(link_text, link_url, utm_campaign, utm_content)

        expect(link).to eq('<a class="govuk-link" href="/some/link?utm_source=apply-for-teacher-training.service.gov.uk&amp;utm_medium=referral&amp;utm_campaign=candidate_interface%2Fdegrees%2Fdegree-new_enic&amp;utm_content=apply_1">Somewhere over the rainbow</a>')
        expect(link).to include('class="govuk-link"')
      end

      it 'returns govuk_link_to with correct extra css' do
        extra_option = { class: 'govuk-footer__link' }
        link = helper.govuk_link_to_with_utm_params(link_text, link_url, utm_campaign, utm_content, **extra_option)

        expect(link).to include('govuk-link govuk-footer__link')
      end
    end

    context 'GIT links in non-production envs' do
      it 'returns govuk_link_to html without utm params' do
        allow(HostingEnvironment).to receive(:environment_name).and_return('development')

        link = helper.govuk_link_to_with_utm_params(link_text, link_url, utm_campaign, utm_content)

        expect(link).to eq('<a class="govuk-link" href="/some/link">Somewhere over the rainbow</a>')
        expect(link).to include('class="govuk-link"')
      end
    end

    context 'when GIT links are accessed before auth' do
      let(:application_form) { nil }
      let(:utm_campaign) { 'candidate_interface/sign_up-new' }
      let(:utm_content) { 'candidate_not_logged_in' }

      it 'returns a user-friendly message in utm_content' do
        link = helper.govuk_link_to_with_utm_params(link_text, link_url, utm_campaign, utm_content)

        expect(link).to eq('<a class="govuk-link" href="/some/link?utm_source=apply-for-teacher-training.service.gov.uk&amp;utm_medium=referral&amp;utm_campaign=candidate_interface%2Fsign_up-new&amp;utm_content=candidate_not_logged_in">Somewhere over the rainbow</a>')
      end
    end
  end

  describe '#email_link_with_utm_params' do
    let(:link_url) { '/some/link' }
    let(:utm_campaign) { 'new_cycle_has_started' }
    let(:utm_content) { application_form.phase }

    context 'GIT links in production' do
      it 'returns link with utm params' do
        link = helper.email_link_with_utm_params(link_url, utm_campaign, utm_content)

        expect(link).to eq('/some/link?utm_source=apply-for-teacher-training.service.gov.uk&utm_medium=referral&utm_campaign=new_cycle_has_started&utm_content=apply_1')
        expect(link).not_to include('class="govuk-link"')
      end
    end

    context 'GIT links in non-production envs' do
      it 'returns link without utm params' do
        allow(HostingEnvironment).to receive(:environment_name).and_return('qa')
        link = helper.email_link_with_utm_params(link_url, utm_campaign, utm_content)

        expect(link).to eq('/some/link')
        expect(link).not_to include('class="govuk-link"')
      end
    end
  end

  describe '#utm_campaign' do
    let(:params) { { controller: 'candidate_interface/degrees/degree', action: 'new_enic' } }

    it 'returns correct value derived from params' do
      utm_campaign = helper.utm_campaign(params)

      expect(utm_campaign).to eq('candidate_interface/degrees/degree-new_enic')
    end
  end
end
