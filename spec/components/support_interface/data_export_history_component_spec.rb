require 'rails_helper'

RSpec.describe SupportInterface::DataExportHistoryComponent do
  subject(:component) { described_class.new(data_exports: data_exports) }

  around do |example|
    Timecop.freeze { example.run }
  end

  def render_result(show_name:)
    create(
      :data_export,
      name: 'Providers',
      created_at: 2.days.ago,
      initiator: build(:support_user, first_name: 'Bob', last_name: 'Roberts'),
    )
    data_exports = DataExport.all.page(1).per(10)
    @render_result ||= render_inline(described_class.new(data_exports: data_exports, show_name: show_name))
  end

  it 'renders the date and initiator of each export if `show_name` is false' do
    result = render_result(show_name: false)
    expect(result.text).not_to include('Providers')
    expect(result.text).to include('Bob Roberts')
    expect(result.text).to include(2.days.ago.to_s(:govuk_date_and_time))
  end

  it 'renders the date, name and initiator of each export if `show_name` is true' do
    result = render_result(show_name: true)
    expect(result.text).to include('Providers')
    expect(result.text).to include('Bob Roberts')
    expect(result.text).to include(2.days.ago.to_s(:govuk_date_and_time))
  end
end
