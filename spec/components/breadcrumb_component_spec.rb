require 'rails_helper'

RSpec.describe BreadcrumbComponent do
  let(:items) do
    [{ text: 'Providers', path: '#' },
     { text: 'ACME SCITT', path: '#' },
     { text: 'Courses' }]
  end

  context 'breadcrumbs appearing as selected' do
    it 'when the item is "current" then it is the last item' do
      result = render_inline(described_class.new(items: items))

      expect(result.css('.govuk-breadcrumbs__list-item[aria-current="page"]').text).to include('Courses')
    end
  end

  context 'rendering breadcrumbs' do
    it 'renders all of the items specified in the items hash passed to it' do
      result = render_inline(described_class.new(items: items))

      expect(result.text).to include('Providers')
      expect(result.text).to include('ACME SCITT')
      expect(result.text).to include('Courses')
    end
  end
end
