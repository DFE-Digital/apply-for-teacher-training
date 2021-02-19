require 'rails_helper'

RSpec.describe SupportInterface::TileComponent do
  subject { described_class.new(count: 3, label: 'blind mice') }

  it 'renders the count' do
    expect(rendered_result_text).to include('3')
  end

  it 'renders the label' do
    expect(rendered_result_text).to include('blind mice')
  end

  describe 'a tile with an overridden colour' do
    subject { described_class.new(count: 3, label: 'blind mice', colour: :blue) }

    it 'applies the override CSS class' do
      expect(rendered_result_html).to include('app-card--blue')
    end
  end

  describe 'a tile with a link' do
    subject { described_class.new(count: 3, label: 'blind mice', href: '#cheese') }

    it 'renders the link' do
      expect(rendered_result_html).to include('app-card__link')
      expect(page).to have_link(nil, href: '#cheese')
    end
  end

  describe 'a secondary tile' do
    subject { described_class.new(count: 3, label: 'blind mice', size: :secondary) }

    it 'has different (smaller) text' do
      expect(rendered_result_html).to include('app-card__secondary-count')
    end
  end

  def rendered_result_html
    render_inline(subject).to_html
  end

  def rendered_result_text
    render_inline(subject).text
  end
end
