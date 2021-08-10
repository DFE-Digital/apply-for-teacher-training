require 'rails_helper'

RSpec.describe ProviderInterface::ReportTableComponent do
  let(:headers) { ['Course', 'Received', 'Interviewing', 'Offered', 'Awaiting conditions', 'Ready to enrol'] }
  let(:data) do
    {
      headers: headers,
      rows: [
        {
          header: 'Mathematics',
          subheader: 'Hogwards University',
          values: [1, 3, 2, 5, 4],
        },
        {
          header: 'English',
          subheader: 'University of Maximegalon',
          values: [2, 3, 4, 5, 6],
        },
      ],
    }
  end
  let(:render) { render_inline described_class.new(data) }

  describe 'header rows' do
    it 'correctly outputs header data' do
      expect(render.css('thead th')[0].text).to eq(headers[0])
      expect(render.css('thead th')[1].text).to eq(headers[1])
      expect(render.css('thead th')[2].text).to eq(headers[2])
      expect(render.css('thead th')[3].text).to eq(headers[3])
      expect(render.css('thead th')[4].text).to eq(headers[4])
    end
  end

  describe 'rows' do
    it 'correctly outputs row data' do
      expect(render.css('tbody th')[0].text).to include('Mathematics')
      expect(render.css('tbody th span')[0].text).to eq('Hogwards University')
      expect(render.css('tbody td')[0].text).to eq('1')
      expect(render.css('tbody td')[1].text).to eq('3')
      expect(render.css('tbody td')[2].text).to eq('2')
      expect(render.css('tbody td')[3].text).to eq('5')
      expect(render.css('tbody td')[4].text).to eq('4')

      expect(render.css('tbody th')[1].text).to include('English')
      expect(render.css('tbody th span')[1].text).to eq('University of Maximegalon')
      expect(render.css('tbody td')[5].text).to eq('2')
      expect(render.css('tbody td')[6].text).to eq('3')
      expect(render.css('tbody td')[7].text).to eq('4')
      expect(render.css('tbody td')[8].text).to eq('5')
      expect(render.css('tbody td')[9].text).to eq('6')
    end
  end

  describe 'footer' do
    it 'calculates and outputs the totals of each row' do
      expect(render.css('tfoot th')[0].text).to eq('Total')
      expect(render.css('tfoot td')[0].text).to eq('3')
      expect(render.css('tfoot td')[1].text).to eq('6')
      expect(render.css('tfoot td')[2].text).to eq('6')
      expect(render.css('tfoot td')[3].text).to eq('10')
      expect(render.css('tfoot td')[4].text).to eq('10')
    end
  end

  describe 'when show_footer is set to false' do
    let(:render) { render_inline described_class.new(data.merge!(show_footer: false)) }

    it 'does not render a footer' do
      expect(render.css('tfoot')).to be_empty
    end
  end
end
