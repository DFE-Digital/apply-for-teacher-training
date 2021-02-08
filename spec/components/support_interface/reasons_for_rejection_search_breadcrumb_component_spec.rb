require 'rails_helper'

RSpec.describe SupportInterface::ReasonsForRejectionSearchBreadcrumbComponent do
  def render_result(
    search_attribute = :quality_of_application_y_n,
    search_value = 'Yes'
  )
    @rendered_result ||= render_inline(
      described_class.new(
        search_attribute: search_attribute,
        search_value: search_value,
      ),
    )
  end

  context 'for a top-level reason' do
    before do
      render_result
    end

    it 'renders the correct title' do
      expect(@rendered_result.text).to include('Quality of application')
    end
  end

  context 'for a sub-reason' do
    before do
      render_result(:qualifications_which_qualifications, :no_degree)
    end

    it 'renders the correct title' do
      expect(@rendered_result.text).to include('No degree')
    end

    it 'renders the link back to qualifications' do
      expect(@rendered_result.css("a[href='/support/performance/reasons-for-rejection/application-choices?structured_rejection_reasons%5Bqualifications_y_n%5D=Yes']")).to be_present
    end
  end
end
