require 'rails_helper'

RSpec.describe SupportInterface::DataExportHistoryComponent do
  subject(:component) { described_class.new(data_exports:) }

  def render_result(show_name:)
    create(
      :data_export,
      name: 'Who ran which export',
      created_at: 2.days.ago,
      initiator: build(:support_user, first_name: 'Bob', last_name: 'Roberts'),
      export_type: 'who_ran_which_export',
    )

    create(
      :data_export,
      name: 'Sites export',
      created_at: 3.days.ago,
      initiator: build(:support_user, first_name: 'Not Bob', last_name: 'Roberts'),
      export_type: 'sites_export',
    )
    data_exports = DataExport.all
    @render_result ||= render_inline(described_class.new(data_exports:, show_name:))
  end

  it 'renders the date and initiator of each export if `show_name` is false' do
    result = render_result(show_name: false)
    expect(result.text).not_to include('Who ran which export')
    expect(result.text).to include('Bob Roberts')
    expect(result).to have_link(2.days.ago.to_fs(:govuk_date_and_time))

    expect(result.text).to include('Not Bob Roberts')
    expect(result).to have_text(3.days.ago.to_fs(:govuk_date_and_time))
    expect(result).to have_no_link(3.days.ago.to_fs(:govuk_date_and_time))
  end

  it 'renders links for active reports only' do
    result = render_result(show_name: true)
    expect(result).to have_link('Who ran which export')
    expect(result).to have_text('Sites export')
    expect(result).to have_no_link('Sites export')
  end

  it 'renders the date, name and initiator of each export if `show_name` is true' do
    result = render_result(show_name: true)
    expect(result.text).to include('Who ran which export')
    expect(result.text).to include('Bob Roberts')
    expect(result.text).to include(2.days.ago.to_fs(:govuk_date_and_time))
  end
end
