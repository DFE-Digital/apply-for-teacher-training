require 'rails_helper'

RSpec.describe ProviderInterface::WorkHistoryComponent do
  it 'renders each history item' do
    application_form = instance_double(ApplicationForm)
    allow(application_form).to receive(:application_work_experiences).and_return([])

    rendered = render_inline(described_class, application_form: application_form)
    expect(rendered).to eq :foo
  end
end
