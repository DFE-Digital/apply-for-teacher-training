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
      course = build_stubbed(:course)
      allow(application_choice).to receive_messages(course: course)

      result = render_inline(described_class.new(application_choice:, render_link_to_find_when_rejected_on_qualifications: true))
      expect(result.text).to include('View the course requirements on')
      expect(result).to have_link(t('service_name.find'), href: "#{course.find_url}#section-entry")
    end
  end

  describe "when the rejection reason type is 'rejection_reasons'" do
    let(:application_form) { create(:application_form, :minimum_info) }
    let(:application_choice) { build_stubbed(:application_choice, :with_structured_rejection_reasons, application_form: application_form) }

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
      course = build_stubbed(:course)
      allow(application_choice).to receive_messages(course: course)

      result = render_inline(described_class.new(application_choice:, render_link_to_find_when_rejected_on_qualifications: true))
      expect(result.text).to include('View the course requirements on')
      expect(result).to have_link(t('service_name.find'), href: "#{course.find_url}#section-entry")
    end
  end

  describe 'when the rejection reason type is the non_uk qualification does not have an ENIC reference' do
    let(:application_form) { create(:application_form, :minimum_info) }
    let(:application_choice) { build_stubbed(:application_choice, :with_structured_rejection_reasons, application_form: application_form) }
    let!(:application_qualification) { create(:degree_qualification, enic_reference: nil, institution_country: 'FR', application_form: application_form) }

    it 'renders a link to Apply for a statement of comparability with no enic_reference, a non uk qualification and could not verify qualifications rejection reason' do
      course = build_stubbed(:course)
      allow(application_choice).to receive_messages(course: course)

      result = render_inline(described_class.new(application_choice:, render_link_to_find_when_rejected_on_qualifications: true))
      expect(result.text).to include('If you decide to apply again, think about including a statement of comparability from UK ENIC')
      expect(page).to have_link('Apply for a statement of comparability from UK ENIC', href: 'https://www.enic.org.uk/Qualifications/SOC/Default.aspx')
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
      course = build_stubbed(:course)
      allow(application_choice).to receive_messages(course: course)

      result = render_inline(described_class.new(application_choice:, render_link_to_find_when_rejected_on_qualifications: true))
      expect(result.text).to include('View the course requirements on')
      expect(result).to have_link(t('service_name.find'), href: "#{course.find_url}#section-entry")
    end
  end
end
