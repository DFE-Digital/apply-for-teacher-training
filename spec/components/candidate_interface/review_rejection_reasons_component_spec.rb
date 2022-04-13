require 'rails_helper'

RSpec.describe CandidateInterface::ReviewRejectionReasonsComponent do
  it 'renders a single rejection reason with a label' do
    rejection_details = { id: 'quality_of_writing_details', text: 'Quality Bad' }
    rejection_reasons = [RejectionReasons::Reason.new(id: 'quality_of_writing', label: 'Quality of writing', details: rejection_details)]

    result = render_inline(described_class.new(rejection_reasons))

    expect(result.css('p').text).to include('Quality of writing:Quality Bad')
  end

  it 'renders multiple rejections reason with a label' do
    qualitfy_rejection_details = { id: 'quality_of_writing_details', text: 'Quality Bad' }
    personal_statement_rejection_details = { id: 'personal_statement_other_details', text: 'Personal statement Bad' }
    rejection_reasons = [
      RejectionReasons::Reason.new(id: 'quality_of_writing', label: 'Quality of writing', details: qualitfy_rejection_details),
      RejectionReasons::Reason.new(id: 'personal_statement_other', label: 'Other', details: personal_statement_rejection_details),
    ]

    result = render_inline(described_class.new(rejection_reasons))

    expect(result.css('p').text).to include('Quality of writing:Quality Bad')
    expect(result.css('p').text).to include('Other:Personal statement Bad')
  end

  it 'does not render the other label for a single rejection reason' do
    personal_statement_rejection_details = { id: 'personal_statement_other_details', text: 'Personal statement Bad' }
    rejection_reasons = [
      RejectionReasons::Reason.new(id: 'personal_statement_other', label: 'Other', details: personal_statement_rejection_details),
    ]

    result = render_inline(described_class.new(rejection_reasons))

    expect(result.css('p').text).not_to include('Other:')
    expect(result.css('p').text).to include('Personal statement Bad')
  end

  describe '#hide_other_label?' do
    it 'returns true if there is a single other rejection reasons' do
      personal_statement_rejection_details = { id: 'personal_statement_other_details', text: 'Personal statement Bad' }
      rejection_reasons = [
        RejectionReasons::Reason.new(id: 'personal_statement_other', label: 'Other', details: personal_statement_rejection_details),
      ]

      result = described_class.new(rejection_reasons)

      expect(result.hide_other_label?).to be(true)
    end

    it 'returns false if there is a single non other details rejection reasons' do
      rejection_details = { id: 'quality_of_writing_details', text: 'Quality Bad' }
      rejection_reasons = [RejectionReasons::Reason.new(id: 'quality_of_writing', label: 'Quality of writing', details: rejection_details)]

      result = described_class.new(rejection_reasons)

      expect(result.hide_other_label?).to be(false)
    end

    it 'returns false if there are multiple rejection reasons' do
      qualitfy_rejection_details = { id: 'quality_of_writing_details', text: 'Quality Bad' }
      personal_statement_rejection_details = { id: 'personal_statement_other_details', text: 'Personal statement Bad' }
      rejection_reasons = [
        RejectionReasons::Reason.new(id: 'quality_of_writing', label: 'Quality of writing', details: qualitfy_rejection_details),
        RejectionReasons::Reason.new(id: 'personal_statement_other', label: 'Other', details: personal_statement_rejection_details),
      ]

      result = described_class.new(rejection_reasons)

      expect(result.hide_other_label?).to be(false)
    end
  end
end
