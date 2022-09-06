require 'rails_helper'

RSpec.describe CandidateInterface::VolunteeringReviewComponent do
  context 'when they have no experience in volunteering' do
    it 'confirms that they have no volunteering experience' do
      application_form = build_stubbed(:application_form)

      result = render_inline(described_class.new(application_form:))

      expect(result.css('.app-summary-card__body').text).to include(
        t('application_form.volunteering.experience.label'),
      )
    end

    it 'does not confirm that they have no volunteering experience' do
      application_form = create(:completed_application_form, volunteering_experiences_count: 1)

      result = render_inline(described_class.new(application_form:))

      expect(result.css('.app-summary-card__title').text).not_to include(
        t('application_form.volunteering.no_experience.summary_card_title'),
      )
    end

    it 'shows how to get school experience' do
      application_form = build_stubbed(:application_form)

      result = render_inline(described_class.new(application_form:, show_experience_advice: true))

      expect(result.css('.govuk-inset-text').text).to include(
        t('application_form.volunteering.no_experience.get_experience'),
      )
    end

    it 'does not show how to get school experience' do
      application_form = build_stubbed(:application_form)

      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-inset-text').text).not_to include(
        t('application_form.volunteering.no_experience.get_experience'),
      )
    end
  end

  context 'when they have experience in volunteering' do
    let(:application_form) { create(:application_form) }
    let!(:volunteering_role) do
      application_form.application_volunteering_experiences.create(
        role: 'School Experience Intern',
        organisation: 'A Noice School',
        details: 'I interned.',
        working_with_children: true,
        start_date: Time.zone.local(2019, 8, 1),
        end_date: nil,
      )
    end

    it 'renders component with the role in the summary card title' do
      result = render_inline(described_class.new(application_form:))

      expect(result.css('.app-summary-card__title').text).to include('School Experience Intern')
    end

    it 'renders component with correct values for role' do
      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.volunteering.role.review_label'))
      expect(result.css('.govuk-summary-list__value').to_html).to include('School Experience Intern')
      expect(result.css('.govuk-summary-list__actions a').attr('href').value).to include(
        Rails.application.routes.url_helpers.candidate_interface_edit_volunteering_role_path(volunteering_role),
      )
      expect(result.css('.govuk-summary-list__actions').text).to include(
        "Change #{t('application_form.volunteering.role.change_action')} for School Experience Intern, A Noice School",
      )
    end

    it 'renders component with correct values for organisation' do
      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.volunteering.organisation.review_label'))
      expect(result.css('.govuk-summary-list__value').to_html).to include('A Noice School')
      expect(result.css('.govuk-summary-list__actions a').attr('href').value).to include(
        Rails.application.routes.url_helpers.candidate_interface_edit_volunteering_role_path(volunteering_role),
      )
      expect(result.css('.govuk-summary-list__actions').text).to include(
        "Change #{t('application_form.volunteering.organisation.change_action')} for School Experience Intern, A Noice School",
      )
    end

    it 'renders component with correct values for working with children' do
      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.volunteering.working_with_children.review_label'))
      expect(result.css('.govuk-summary-list__value').to_html).to include('Yes')
      expect(result.css('.govuk-summary-list__actions a').attr('href').value).to include(
        Rails.application.routes.url_helpers.candidate_interface_edit_volunteering_role_path(volunteering_role),
      )
      expect(result.css('.govuk-summary-list__actions').text).to include(
        "Change #{t('application_form.volunteering.working_with_children.change_action')} for School Experience Intern, A Noice School",
      )
    end

    it 'renders component with correct values for length' do
      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.volunteering.length.review_label'))
      expect(result.css('.govuk-summary-list__value').to_html).to include('August 2019 - Present')
      expect(result.css('.govuk-summary-list__actions a').attr('href').value).to include(
        Rails.application.routes.url_helpers.candidate_interface_edit_volunteering_role_path(volunteering_role),
      )
      expect(result.css('.govuk-summary-list__actions').text).to include(
        "Change #{t('application_form.volunteering.length.change_action')} for School Experience Intern, A Noice School",
      )
    end

    it 'renders component with correct values for details of experience' do
      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.volunteering.details.review_label'))
      expect(result.css('.govuk-summary-list__value').to_html).to include('<p class="govuk-body">I interned.</p>')
      expect(result.css('.govuk-summary-list__actions a').attr('href').value).to include(
        Rails.application.routes.url_helpers.candidate_interface_edit_volunteering_role_path(volunteering_role),
      )
      expect(result.css('.govuk-summary-list__actions').text).to include(
        "Change #{t('application_form.volunteering.details.change_action')} for School Experience Intern, A Noice School",
      )
    end

    it 'renders component along with a delete link for each role' do
      result = render_inline(described_class.new(application_form:))

      expect(result.css('.app-summary-card__actions').text.strip).to include(
        "#{t('application_form.volunteering.delete.action')} for School Experience Intern, A Noice School",
      )
      expect(result.css('.app-summary-card__actions a').attr('href').value).to include(
        Rails.application.routes.url_helpers.candidate_interface_confirm_destroy_volunteering_role_path(volunteering_role),
      )
    end

    it 'appends dates to "Change" links if same role at same organisation' do
      application_form.application_volunteering_experiences.create(
        role: 'School Experience Intern',
        organisation: 'Gyorfi School',
        details: 'I interned.',
        working_with_children: true,
        start_date: Time.zone.local(2019, 1, 1),
        end_date: Time.zone.local(2019, 6, 1),
      )
      application_form.application_volunteering_experiences.create(
        role: 'School Experience Intern',
        organisation: 'Gyorfi School',
        details: 'I interned again.',
        working_with_children: true,
        start_date: Time.zone.local(2019, 6, 1),
        end_date: Time.zone.local(2019, 8, 1),
      )

      result = render_inline(described_class.new(application_form:))

      change_role_for_unique = result.css('.govuk-summary-list__actions')[10].text.strip
      change_role_for_same1 = result.css('.govuk-summary-list__actions')[5].text.strip
      change_role_for_same2 = result.css('.govuk-summary-list__actions')[0].text.strip

      expect(change_role_for_unique).to eq(
        'Change role for School Experience Intern, A Noice School',
      )
      expect(change_role_for_same1).to eq(
        'Change role for School Experience Intern, Gyorfi School, January 2019 to June 2019',
      )
      expect(change_role_for_same2).to eq(
        'Change role for School Experience Intern, Gyorfi School, June 2019 to August 2019',
      )
    end

    context 'when volunteering experiences are not editable' do
      it 'renders component without an edit link' do
        result = render_inline(described_class.new(application_form:, editable: false))

        expect(result.css('.app-summary-list__actions').text).not_to include('Change')
        expect(result.css('.app-summary-card__actions').text).not_to include(t('application_form.volunteering.delete.action'))
      end
    end
  end
end
