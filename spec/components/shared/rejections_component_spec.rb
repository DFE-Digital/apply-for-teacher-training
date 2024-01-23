require 'rails_helper'

RSpec.describe RejectionsComponent do
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
  end
end
