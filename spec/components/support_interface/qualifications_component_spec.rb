require 'rails_helper'

RSpec.describe SupportInterface::QualificationsComponent, type: :component do
  let(:application_form) { create(:application_form, :completed, :with_bachelor_degree) }
  let(:component) do
    described_class.new(application_form: application_form)
  end

  subject(:result) { render_inline(component) }

  it 'renders degrees information' do
    expect(result.text).to include('Change')
    expect(result.text).to include('HESA codes')
    expect(result.text).to include(application_form.application_qualifications.degrees.first.subject)
  end
end
