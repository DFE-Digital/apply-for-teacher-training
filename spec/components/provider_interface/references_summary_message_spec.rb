require 'rails_helper'

RSpec.describe ProviderInterface::ReferencesSummaryMessage do
  let(:application_form) { create(:application_form) }

  subject(:result) do
    render_inline(described_class.new(application_form.application_references, 'Joe Bloggs'))
  end

  context 'when no feedback provided' do
    before do
      create_list(:reference, 2, feedback_status: :feedback_requested, application_form:)
    end

    it 'renders number of references requested' do
      expect(result.text).to include('The candidate has requested 2 references. You should not share the contents of any references with Joe Bloggs.')
    end
  end

  context 'when all feedback provided' do
    before do
      create_list(:reference, 2, feedback_status: :feedback_provided, application_form:)
    end

    it 'renders number of references provided' do
      expect(result.text).to include('The candidate has received 2 references. You should not share the contents of any references with Joe Bloggs.')
    end
  end

  context 'when one feedback provided and one requested' do
    before do
      create(:reference, :feedback_requested, application_form:)
      create(:reference, :feedback_provided, application_form:)
    end

    it 'renders number of references' do
      expect(result.text).to include('The candidate has received 1 reference and has requested 1 other reference. You should not share the contents of any references with Joe Bloggs.')
    end
  end

  context 'when some feedback provided and some requested' do
    before do
      create_list(:reference, 2, feedback_status: :feedback_requested, application_form:)
      create_list(:reference, 2, feedback_status: :feedback_provided, application_form:)
    end

    it 'renders number of references' do
      expect(result.text).to include('The candidate has received 2 references and has requested 2 other references. You should not share the contents of any references with Joe Bloggs.')
    end
  end
end
