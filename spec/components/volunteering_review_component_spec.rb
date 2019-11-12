require 'rails_helper'

RSpec.describe VolunteeringReviewComponent do
  context 'when they have no experience in volunteering' do
    it 'renders component with how to get school experience' do
      application_form = build_stubbed(:application_form)

      result = render_inline(VolunteeringReviewComponent, application_form: application_form)

      expect(result.css('.app-summary-card__title').text).to include(
        t('application_form.volunteering.no_experience.summary_card_title'),
      )
    end
  end
end
