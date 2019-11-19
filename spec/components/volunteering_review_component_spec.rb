require 'rails_helper'

RSpec.describe VolunteeringReviewComponent do
  context 'when they have no experience in volunteering' do
    it 'shows how to get school experience' do
      application_form = build_stubbed(:application_form)

      result = render_inline(VolunteeringReviewComponent, application_form: application_form)

      expect(result.css('.app-summary-card__title').text).to include(
        t('application_form.volunteering.no_experience.summary_card_title'),
      )
    end

    it 'does not show how to get school experience if volunteering experience' do
      application_form = create(:completed_application_form, volunteering_experiences_count: 1)

      result = render_inline(VolunteeringReviewComponent, application_form: application_form)

      expect(result.css('.app-summary-card__title').text).not_to include(
        t('application_form.volunteering.no_experience.summary_card_title'),
      )
    end
  end

  context 'when they have experience in volunteering' do
    let(:application_form) do
      create(:application_form) do |form|
        form.application_volunteering_experiences.create(
          id: 1,
          role: 'School Experience Intern',
          organisation: Faker::Educator.secondary_school,
          details: Faker::Lorem.paragraph_by_chars(number: 300),
          working_with_children: false,
          start_date: Time.zone.local(2018, 5, 1),
          end_date: Time.zone.local(2019, 5, 1),
        )
        form.application_volunteering_experiences.create(
          id: 2,
          role: 'School Experience Intern',
          organisation: 'A Noice School',
          details: 'I interned.',
          working_with_children: true,
          start_date: Time.zone.local(2019, 8, 1),
          end_date: nil,
        )
      end
    end

    it 'renders component with the role in the summary card title' do
      result = render_inline(VolunteeringReviewComponent, application_form: application_form)

      expect(result.css('.app-summary-card__title').text).to include('School Experience Intern')
    end

    it 'renders component with working with children in the summary card title' do
      result = render_inline(VolunteeringReviewComponent, application_form: application_form)

      expect(result.css('.app-summary-card__title')[0].text).to include(t('application_form.volunteering.working_with_children.review_text'))
    end

    it 'renders component with correct values for role' do
      result = render_inline(VolunteeringReviewComponent, application_form: application_form)

      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.volunteering.role.review_label'))
      expect(result.css('.govuk-summary-list__value').to_html).to include('School Experience Intern')
      expect(result.css('.govuk-summary-list__actions a').attr('href').value).to include(
        Rails.application.routes.url_helpers.candidate_interface_edit_volunteering_role_path(2),
      )
      expect(result.css('.govuk-summary-list__actions').text).to include("Change #{t('application_form.volunteering.role.change_action')}")
    end

    it 'renders component with correct values for organisation' do
      result = render_inline(VolunteeringReviewComponent, application_form: application_form)

      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.volunteering.organisation.review_label'))
      expect(result.css('.govuk-summary-list__value').to_html).to include('A Noice School')
      expect(result.css('.govuk-summary-list__actions a').attr('href').value).to include(
        Rails.application.routes.url_helpers.candidate_interface_edit_volunteering_role_path(2),
      )
      expect(result.css('.govuk-summary-list__actions').text).to include("Change #{t('application_form.volunteering.organisation.change_action')}")
    end

    it 'renders component with correct values for length and details of experience' do
      result = render_inline(VolunteeringReviewComponent, application_form: application_form)

      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.volunteering.length_and_details.review_label'))
      expect(result.css('.govuk-summary-list__value').to_html).to include('August 2019 - Present<br><p>I interned.</p>')
      expect(result.css('.govuk-summary-list__actions a').attr('href').value).to include(
        Rails.application.routes.url_helpers.candidate_interface_edit_volunteering_role_path(2),
      )
      expect(result.css('.govuk-summary-list__actions').text).to include("Change #{t('application_form.volunteering.length_and_details.change_action')}")
    end

    it 'renders component along with a delete link for each role' do
      result = render_inline(VolunteeringReviewComponent, application_form: application_form)

      expect(result.css('.app-summary-card__actions').text).to include(t('application_form.volunteering.delete'))
      expect(result.css('.app-summary-card__actions a').attr('href').value).to include(
        Rails.application.routes.url_helpers.candidate_interface_confirm_destroy_volunteering_role_path(2),
      )
    end

    context 'when volunteering experiences are not editable' do
      it 'renders component without an edit link' do
        result = render_inline(VolunteeringReviewComponent, application_form: application_form, editable: false)

        expect(result.css('.app-summary-list__actions').text).not_to include('Change')
      end
    end

    context 'when volunteering experiences are not deletable' do
      it 'renders component without a delete link' do
        result = render_inline(VolunteeringReviewComponent, application_form: application_form, deletable: false)

        expect(result.css('.app-summary-card__actions').text).not_to include(t('application_form.volunteering.delete'))
      end
    end
  end
end
