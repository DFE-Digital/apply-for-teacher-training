require 'rails_helper'

RSpec.describe SupportInterface::QualificationsComponent, type: :component do
  let(:application_form) { create(:application_form, :completed, :with_bachelor_degree) }
  let(:component) do
    described_class.new(application_form: application_form)
  end
  let(:support_user) { create(:support_user) }

  before do
    # rubocop:disable-next RSpec/AnyInstance
    without_partial_double_verification do
      allow_any_instance_of(ActionView::Base).to receive(:current_support_user).and_return(support_user)
    end
  end

  subject(:result) { render_inline(component) }

  it 'renders degrees information' do
    expect(result.text).to include('Change')
    expect(result.text).to include('HESA codes')
    expect(result.text).to include(application_form.application_qualifications.degrees.first.subject)
  end
end
