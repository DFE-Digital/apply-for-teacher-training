module SupportInterface
  class EqualityAndDiversityExport
    def data_for_export
      data_for_export = application_forms.includes(:application_choices).find_each(batch_size: 100).map do |application_form|
        application_choices = application_form.application_choices
        rejected_application_choices = application_choices.select(&:rejected?)

        output = {
          month: application_form.submitted_at&.strftime('%B') || 'Unsubmitted',
          phase: application_form.phase,
          recruitment_cycle_year: application_form.recruitment_cycle_year,
          sex: application_form.equality_and_diversity['sex'],
          ethnic_group: application_form.equality_and_diversity['ethnic_group'],
          ethnic_background: application_form.equality_and_diversity['ethnic_background'],
          application_status: I18n.t!("candidate_flow_application_states.#{ProcessState.new(application_form).state}.name"),
          provider_made_decision: provider_made_decision_on_any_application_choice?(application_form),
          application_choice_1_subject: application_choices[0]&.course&.name,
          application_choice_2_subject: application_choices[1]&.course&.name,
          application_choice_3_subject: application_choices[2]&.course&.name,
          application_choice_1_unstructured_rejection_reasons: rejected_application_choices[0]&.rejection_reason,
          application_choice_2_unstructured_rejection_reasons: rejected_application_choices[1]&.rejection_reason,
          application_choice_3_unstructured_rejection_reasons: rejected_application_choices[2]&.rejection_reason,
          application_choice_1_structured_rejection_reasons: FlatReasonsForRejectionPresenter.build_top_level_reasons(rejected_application_choices[0]&.structured_rejection_reasons),
          application_choice_2_structured_rejection_reasons: FlatReasonsForRejectionPresenter.build_top_level_reasons(rejected_application_choices[1]&.structured_rejection_reasons),
          application_choice_3_structured_rejection_reasons: FlatReasonsForRejectionPresenter.build_top_level_reasons(rejected_application_choices[2]&.structured_rejection_reasons),
        }

        disabilities = application_form.equality_and_diversity['disabilities'].to_a

        disabilities.map.with_index(1) do |disability, index|
          output[:"disability_#{index}"] = disability
        end

        output
      end

      # The DataExport class creates the header row for us so we need to ensure
      # we sort by longest hash length to ensure all headers appear
      data_for_export.sort_by(&:length).reverse
    end

  private

    def application_forms
      ApplicationForm
        .includes(:application_choices)
        .where.not(equality_and_diversity: nil)
    end

    def provider_made_decision_on_any_application_choice?(application_form)
      application_form.application_choices.any? do |application_choice|
        application_choice.status.in?(%w[offer pending_conditions recruited rejected declined conditions_not_met offer_deferred]) &&
          !application_choice.rejected_by_default
      end
    end
  end
end
