require 'rails_helper'

RSpec.describe SummaryCardHeaderComponent do
  it 'renders a summary card header component with a title only' do
    result = render_inline(SummaryCardHeaderComponent.new(title: 'Lando Calrissian'))
    expect(result.css('.app-summary-card__title').text).to include('Lando Calrissian')
    expect(result.css('.app-summary-card__meta').text).not_to be_present
    expect(result.css('.app-icon').text).not_to be_present
  end

  it 'renders a summary card header component with a custom heading level' do
    result = render_inline(SummaryCardHeaderComponent.new(title: 'Lando Calrissian', heading_level: 6))
    expect(result.css('h6.app-summary-card__title')).to be_present
  end

  it 'renders a summary card header component with a title and check icon' do
    result = render_inline(SummaryCardHeaderComponent.new(title: 'Lando Calrissian', check_icon: true))
    expect(result.css('.app-summary-card__title').text).to include('Lando Calrissian')
    expect(result.css('.app-summary-card__meta').text).to include(t('application_form.review.role_involved_working_with_children'))
    expect(result.css('.app-icon')).to be_present
  end

  it 'does not render a summary card header component with a title and check icon when it is specifically false' do
    result = render_inline(SummaryCardHeaderComponent.new(title: 'Lando Calrissian', check_icon: false))
    expect(result.css('.app-summary-card__title').text).to include('Lando Calrissian')
    expect(result.css('.app-summary-card__meta').text).not_to include(t('application_form.review.role_involved_working_with_children'))
    expect(result.css('.app-icon')).not_to be_present
  end

  context 'renders a summary card check_icon when its value is a string literal' do
    it 'renders the icon when the check_icon when the value is "true"' do
      result = render_inline(SummaryCardHeaderComponent.new(title: 'Lando Calrissian', check_icon: 'true'))
      expect(result.css('.app-summary-card__title').text).to include('Lando Calrissian')
      expect(result.css('.app-summary-card__meta').text).to include(t('application_form.review.role_involved_working_with_children'))
      expect(result.css('.app-icon')).to be_present
    end

    it 'does not render the icon when the check_icon when the value is "false"' do
      result = render_inline(SummaryCardHeaderComponent.new(title: 'Lando Calrissian', check_icon: 'false'))
      expect(result.css('.app-summary-card__title').text).to include('Lando Calrissian')
      expect(result.css('.app-summary-card__meta').text).not_to include(t('application_form.review.role_involved_working_with_children'))
      expect(result.css('.app-icon')).not_to be_present
    end

    it 'raises an error if check_icon is not true, false, "true", or "false"' do
      expect { SummaryCardHeaderComponent.new(title: 'Lando Calrissian', check_icon: 'maybe') }.to raise_error(ArgumentError)
    end
  end
end
