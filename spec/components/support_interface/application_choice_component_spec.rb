require 'rails_helper'

RSpec.describe SupportInterface::ApplicationChoiceComponent do
  include Rails.application.routes.url_helpers

  context 'Declined offer' do
    let(:declined_offer) do
      create(:application_choice, :with_completed_application_form, :declined)
    end

    it 'Renders a link to the reinstate offer page if the application choice is not declined by default' do
      result = render_inline(described_class.new(declined_offer))

      expect(result.css('.govuk-summary-list__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.support_interface_application_form_application_choice_reinstate_offer_path(
          application_form_id: declined_offer.application_form.id,
          application_choice_id: declined_offer.id,
        ),
      )
      expect(result.css('.govuk-summary-list__actions').text.strip).to include('Reinstate offer')
    end

    it 'Does not render a link to the reinstate offer page if the application choice is declined by default' do
      application_choice = create(:application_choice, :with_completed_application_form, :declined_by_default)

      render_inline(described_class.new(application_choice))

      expect(page).to have_no_css '.govuk-summary-list__actions a', text: 'Reinstate offer'
    end
  end

  context 'Conditions pending' do
    let(:accepted_choice) do
      create(:application_choice, :with_completed_application_form, :accepted)
    end

    it 'renders a link to the change the offered course choice' do
      result = render_inline(described_class.new(accepted_choice))

      expect(result.css('.govuk-summary-list__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.support_interface_application_form_application_choice_change_offered_course_search_path(
          application_form_id: accepted_choice.application_form.id,
          application_choice_id: accepted_choice.id,
        ),
      )
      expect(result.css('.govuk-summary-list__actions').text.strip).to include('Change offered course')
    end

    context 'with conditions' do
      it 'renders a link to change conditions' do
        result = render_inline(described_class.new(accepted_choice))

        expect(result.css('.app-summary-card .govuk-summary-list__actions a')[1].text.squish).to eq 'Change conditions'
      end
    end

    context 'without conditions' do
      it 'renders a link to change conditions' do
        accepted_choice = create(:application_choice, :with_completed_application_form, :accepted, offer: build(:offer, conditions: []))
        result = render_inline(described_class.new(accepted_choice))

        expect(result.css('.app-summary-card .govuk-summary-list__actions a')[1].text.squish).to eq 'Change conditions'
      end
    end

    context 'with a SKE condition' do
      let(:application_choice_with_ske) { create(:application_choice, :offered, offer: create(:offer, :with_ske_conditions)) }

      it 'renders the SKE component' do
        result = render_inline(described_class.new(application_choice_with_ske))

        expect(result).to have_content('Subject knowledge enhancement course')
      end
    end

    context 'without a SKE condition' do
      let(:application_choice_without_ske) { create(:application_choice, :offered) }

      it 'does not render the SKE component' do
        result = render_inline(described_class.new(application_choice_without_ske))

        expect(result).to have_no_content('Subject knowledge enhancement course')
      end
    end
  end

  context 'Recruited' do
    let(:recruited_choice) do
      create(
        :application_choice,
        :with_completed_application_form,
        :recruited,
      )
    end

    it 'renders a link to revert the application choice to pending conditions' do
      result = render_inline(described_class.new(recruited_choice))

      expect(result.css('.govuk-summary-list__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.support_interface_application_form_application_choice_revert_to_pending_conditions_path(
          application_form_id: recruited_choice.application_form.id,
          application_choice_id: recruited_choice.id,
        ),
      )
      expect(result.css('.govuk-summary-list__actions a').text.strip).to include('Revert to pending conditions')
    end

    it 'does render a link to change conditions' do
      result = render_inline(described_class.new(recruited_choice))

      expect(result.css('.app-summary-card .govuk-summary-list__actions a').text.squish).to include 'Change conditions'
    end
  end

  context 'Conditions not met' do
    let(:conditions_not_met_choice) do
      create(
        :application_choice,
        :with_completed_application_form,
        :conditions_not_met,
      )
    end

    it 'renders a link to revert the application choice to pending conditions' do
      result = render_inline(described_class.new(conditions_not_met_choice))

      expect(result.css('.govuk-summary-list__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.support_interface_application_form_application_choice_revert_to_pending_conditions_path(
          application_form_id: conditions_not_met_choice.application_form.id,
          application_choice_id: conditions_not_met_choice.id,
        ),
      )
      expect(result.css('.govuk-summary-list__actions a').text.strip).to include('Revert to pending conditions')
    end
  end

  context 'Offer deferred' do
    let(:offer_deferred_choice) do
      create(
        :application_choice,
        :with_completed_application_form,
        :offer_deferred,
      )
    end

    it 'renders a link to revert the application choice to pending conditions' do
      result = render_inline(described_class.new(offer_deferred_choice))

      expect(result.css('.govuk-summary-list__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.support_interface_application_form_application_choice_revert_to_pending_conditions_path(
          application_form_id: offer_deferred_choice.application_form.id,
          application_choice_id: offer_deferred_choice.id,
        ),
      )
      expect(result.css('.govuk-summary-list__actions a').text.strip).to include('Revert to pending conditions')
    end
  end

  context 'Unconditional offer' do
    let(:unconditional_offer) do
      create(:application_choice,
             :with_completed_application_form,
             :offered,
             :recruited,
             offer: build(:unconditional_offer))
    end

    it 'renders a link to the change the offered course choice' do
      result = render_inline(described_class.new(unconditional_offer))

      expect(result.css('.govuk-summary-list__actions a')[1].attr('href')).to include(
        Rails.application.routes.url_helpers.support_interface_application_form_application_choice_change_offered_course_search_path(
          application_form_id: unconditional_offer.application_form.id,
          application_choice_id: unconditional_offer.id,
        ),
      )
      expect(result.css('.govuk-summary-list__actions a').text.strip).to include('Change offered course')
    end
  end

  context 'Rejected application' do
    let(:rejected_application_choice) { create(:application_choice, :with_completed_application_form, :rejected) }

    it 'Renders a link to the revert rejection page when application was manually rejected' do
      result = render_inline(described_class.new(rejected_application_choice))

      expect(result.css('.govuk-summary-list__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.support_interface_application_form_revert_rejection_path(
          application_form_id: rejected_application_choice.application_form.id,
          application_choice_id: rejected_application_choice.id,
        ),
      )
      expect(result.css('.govuk-summary-list__actions').text.strip).to include('Revert rejection')
    end

    it 'Does not render a link to the revert rejection page when application was rejected by default' do
      rejected_application_choice.update!(
        rejected_by_default: true,
      )
      render_inline(described_class.new(rejected_application_choice))

      expect(page).to have_no_css '.govuk-summary-list__actions a', text: 'Revert rejection'
    end
  end

  context 'Withdrawn application' do
    let(:application_form) { create(:completed_application_form) }
    let(:withdrawn_application) { create(:application_choice, :withdrawn, application_form:) }

    it 'renders a link to revert the withdrawn application' do
      result = render_inline(described_class.new(withdrawn_application))

      expect(result.css('.govuk-summary-list__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.support_interface_application_form_application_choice_revert_withdrawal_path(
          application_form_id: withdrawn_application.application_form.id,
          application_choice_id: withdrawn_application.id,
        ),
      )
      expect(result.css('.govuk-summary-list__actions').text.strip).to include('Revert withdrawal')
    end

    it 'does not render a link to revert the withdrawn application when the candidate has accepted an offer' do
      create(:application_choice, :accepted, application_form:)

      render_inline(described_class.new(withdrawn_application))

      expect(page).to have_no_css '.govuk-summary-list__actions a', text: 'Revert withdrawal'
    end

    context 'withdrawn by provider on behalf of candidate' do
      let(:withdrawn_choice) do
        create(:application_choice, :withdrawn, withdrawn_or_declined_for_candidate_by_provider: true, application_form:)
      end

      it 'renders correct reason' do
        render_inline(described_class.new(withdrawn_choice))
        expect(page).to have_text 'Withdrawn by provider on behalf of candidate'
      end
    end

    context 'has provided an old reason (before Jan 2025)' do
      let(:withdrawn_choice) do
        create(:application_choice, :withdrawn, structured_withdrawal_reasons: %w[applying_to_teacher_training_next_year concerns_about_time_to_train])
      end

      it 'renders correct reasons' do
        render_inline(described_class.new(withdrawn_choice))

        expect(page).to have_text 'I have concerns that I will not have time to train'
        expect(page).to have_text 'I’ve decided to apply for teacher training next year'
      end
    end

    context 'no reason given (before Jan 2025)' do
      let(:withdrawn_choice) do
        create(:application_choice, :withdrawn, withdrawal_reasons: [])
      end

      it 'renders no reason given' do
        render_inline(described_class.new(withdrawn_choice))
        expect(page).to have_text 'No reason given'
      end
    end

    context 'has provided new reasons (after Jan 2025)' do
      let(:withdrawn_choice) do
        create(
          :application_choice,
          :withdrawn,
          application_form:,
          withdrawal_reasons: [
            build(:withdrawal_reason, :published, reason: 'applying-to-another-provider.personal-circumstances-have-changed.concerns-about-cost-of-doing-course'),
            build(:withdrawal_reason, :published, reason: 'applying-to-another-provider.other', comment: 'I have other reasons for applying to another provider'),
          ],
        )
      end

      it 'renders the expected reasons' do
        render_inline(described_class.new(withdrawn_choice))

        expect(page).to have_text 'I am going to apply (or have applied) to a different training provider because my personal circumstances have changed: I have concerns about the cost of doing the course'
        expect(page).to have_text 'I am going to apply (or have applied) to a different training provider: I have other reasons for applying to another provider'
      end
    end
  end

  context 'Awaiting provider decision' do
    let(:application_choice) do
      create(
        :application_choice,
        :with_completed_application_form,
        :awaiting_provider_decision,
      )
    end

    it 'does not render a link to change conditions' do
      result = render_inline(described_class.new(application_choice))

      expect(result.css('.app-summary-card .govuk-summary-list__actions a').text.squish).not_to include 'Change conditions'
    end
  end

  context 'Changing a course choice' do
    let(:course_option) { create(:course_option) }
    let(:application_choice) do
      create(
        :application_choice,
        :with_completed_application_form,
        :awaiting_provider_decision,
        course_option:,
        current_course_option: course_option,
      )
    end

    it 'Renders a link when the application is awaiting provider decision' do
      result = render_inline(described_class.new(application_choice))

      expect(result.css('.govuk-summary-list__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.support_interface_application_form_change_course_choice_path(
          application_form_id: application_choice.application_form.id,
          application_choice_id: application_choice.id,
        ),
      )

      expect(result.css('.govuk-summary-list__actions').text.strip).to include('Change course choice')
    end

    it 'Renders a link when the application is interviewing' do
      course_option = create(:course_option)
      application_choice = create(
        :application_choice,
        :with_completed_application_form,
        :interviewing,
        course_option:,
        current_course_option: course_option,
      )

      result = render_inline(described_class.new(application_choice))

      expect(result.css('.govuk-summary-list__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.support_interface_application_form_change_course_choice_path(
          application_form_id: application_choice.application_form.id,
          application_choice_id: application_choice.id,
        ),
      )

      expect(result.css('.govuk-summary-list__actions').text.strip).to include('Change course choice')
    end

    it 'Renders a link when the application has an offer' do
      application_choice = create(
        :application_choice,
        :with_completed_application_form,
        :offered,
        offered_at: Time.zone.local(2020, 1, 1, 10),
      )

      render_inline(described_class.new(application_choice))

      change_course_path = Rails.application.routes.url_helpers.support_interface_application_form_change_course_choice_path(
        application_form_id: application_choice.application_form.id,
        application_choice_id: application_choice.id,
      )

      expect(page).to have_css(".govuk-summary-list__actions a[href='#{change_course_path}']", text: 'Change course choice')
    end
  end

  it 'displays the date an application was rejected' do
    application_choice = create(:application_choice,
                                :with_completed_application_form,
                                :rejected,
                                rejected_at: Time.zone.local(2020, 1, 1, 10, 0, 0))

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('Rejected at')
    expect(result.text).to include('1 January 2020 at 10am')
  end

  it 'displays the date an application was rejected by default' do
    application_choice = create(:application_choice,
                                :with_completed_application_form,
                                :rejected_by_default,
                                rejected_at: Time.zone.local(2020, 1, 1, 10, 0, 0))

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('Rejected by default at')
    expect(result.text).to include('1 January 2020 at 10am')
  end

  it 'displays reasons for rejection on rejected application with structured reasons' do
    application_choice = create(:application_choice,
                                :with_completed_application_form,
                                :with_old_structured_rejection_reasons)

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('Rejection reason')
    expect(result.text).to include('Something you did')
    expect(result.text).to include('Persistent scratching')
  end

  it 'displays reasons for rejection on rejected application without structured reasons' do
    application_choice = create(:application_choice,
                                :with_completed_application_form,
                                :rejected)

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('Rejection reason')
    expect(result.text).to include(application_choice.rejection_reason)
  end

  it 'displays offer date for offered applications' do
    application_choice = create(
      :application_choice,
      :with_completed_application_form,
      :offered,
      offered_at: Time.zone.local(2020, 1, 1, 10),
    )

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('Offer made at')
    expect(result.text).to include('1 January 2020 at 10am')
  end

  it 'does not display DBD date for offered applications when it has not yet been set' do
    application_choice = create(
      :application_choice,
      :with_completed_application_form,
      :offered,
      offered_at: Time.zone.local(2020, 1, 1, 10),
    )

    result = render_inline(described_class.new(application_choice))

    expect(result.text).not_to include('Decline by default at')
  end

  it 'displays the course offered by the provider when the applied course is different' do
    application_choice = create(
      :application_choice,
      :with_completed_application_form,
      :offered,
      current_course_option: create(:course_option),
      offered_at: Time.zone.local(2020, 1, 1, 10),
    )

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('Course offered')
  end

  it 'offers the Vendor and Register API representations if appropriate' do
    application_choice = create(
      :application_choice,
      :with_completed_application_form,
      :awaiting_provider_decision,
      current_course_option: create(:course_option),
    )

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('See this application as it appears over the Vendor API')
    expect(result.text).to include('the application isn’t available over the Register API')
  end

  it 'offers the Register API representation if appropriate' do
    application_choice = create(
      :application_choice,
      :with_completed_application_form,
      :recruited,
    )

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('See this application as it appears over the Register API')
  end

  context 'recommended courses row' do
    it 'does not render the recommended courses row if the application choice has not been submitted' do
      application_choice = create(
        :application_choice,
        :with_completed_application_form,
        :unsubmitted,
      )

      result = render_inline(described_class.new(application_choice))

      expect(result.text).not_to include('Recommended courses')
    end

    it 'renders the recommended courses row if the application choice has been submitted' do
      application_choice = create(
        :application_choice,
        :with_completed_application_form,
        :awaiting_provider_decision,
      )

      result = render_inline(described_class.new(application_choice))

      expect(result.text).to include('Recommended courses')
    end
  end
end
