require 'rails_helper'

RSpec.describe CandidateInterface::RejectionsComponent do
  describe 'when the rejection reason is simple text' do
    let(:application_choice) { build_stubbed(:application_choice, :rejected, rejection_reason: 'Something bad') }

    it 'renders the text from ApplicationChoice#rejection_reason' do
      result = render_inline(described_class.new(application_choice:))
      expect(result.text.strip).to eq('Something bad')
    end
  end

  describe "when the rejection reasons type is 'reasons_for_rejection'" do
    let(:application_choice) { build_stubbed(:application_choice, :with_old_structured_rejection_reasons) }

    it 'renders using ReasonsForRejectionComponent' do
      result = render_inline(described_class.new(application_choice:))
      expect(result.text).to include('Something you did')
      expect(result.text).to include('Quality of application')
      expect(result.text).to include('Honesty and professionalism')
      expect(result.text).to include('Safeguarding issues')
    end

    it 'renders a link to find when rejected on qualifications' do
      provider = build_stubbed(:provider)
      course = build_stubbed(:course)
      allow(application_choice).to receive_messages(provider: provider, course: course)

      result = render_inline(described_class.new(application_choice:, render_link_to_find_when_rejected_on_qualifications: true))
      expect(result.text).to include('View the course requirements on')
      expect(result.css('.govuk-link')[0][:href]).to eq("https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{provider.code}/#{course.code}#section-entry")
      expect(result.css('.govuk-link')[0].text).to eq('Find postgraduate teacher training courses')
    end
  end

  describe "when the rejection reason type is 'rejection_reasons'" do
    let(:application_choice) { build_stubbed(:application_choice, :with_structured_rejection_reasons) }

    it 'renders using RejectionReasonsComponent' do
      result = render_inline(described_class.new(application_choice:))
      expect(result.text).to include('Qualifications')
      expect(result.text).to include('No maths GCSE at minimum grade 4 or C, or equivalent')
      expect(result.text).to include('Could not verify qualifications:')
      expect(result.text).to include('We could find no record of your GCSEs.')
      expect(result.text).to include('Personal statement')
      expect(result.text).to include('Quality of writing:')
      expect(result.text).to include('We do not accept applications written in Old Norse.')
    end

    it 'renders a link to find when rejected on qualifications' do
      provider = build_stubbed(:provider)
      course = build_stubbed(:course)
      allow(application_choice).to receive_messages(provider: provider, course: course)

      result = render_inline(described_class.new(application_choice:, render_link_to_find_when_rejected_on_qualifications: true))
      expect(result.text).to include('View the course requirements on')
      expect(result.css('.govuk-link')[0][:href]).to eq("https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{provider.code}/#{course.code}#section-entry")
      expect(result.css('.govuk-link')[0].text).to eq('Find postgraduate teacher training courses')
    end
  end

  describe "when the rejection reason type is 'vendor_api_rejection_reasons'" do
    let(:application_choice) { build_stubbed(:application_choice, :with_vendor_api_rejection_reasons) }

    it 'renders using RejectionReasonsComponent' do
      result = render_inline(described_class.new(application_choice:))
      expect(result.text).to include('Qualifications')
      expect(result.text).to include('We could find no record of your GCSEs.')
      expect(result.text).to include('Personal statement')
      expect(result.text).to include('We do not accept applications written in Old Norse.')
      expect(result.text).to include('References')
      expect(result.text).to include('We do not accept references from close family members, such as your mum.')
    end

    it 'renders a link to find when rejected on qualifications' do
      provider = build_stubbed(:provider)
      course = build_stubbed(:course)
      allow(application_choice).to receive_messages(provider: provider, course: course)

      result = render_inline(described_class.new(application_choice:, render_link_to_find_when_rejected_on_qualifications: true))
      expect(result.text).to include('View the course requirements on')
      expect(result.css('.govuk-link')[0][:href]).to eq("https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{provider.code}/#{course.code}#section-entry")
      expect(result.css('.govuk-link')[0].text).to eq('Find postgraduate teacher training courses')
    end
  end
end
