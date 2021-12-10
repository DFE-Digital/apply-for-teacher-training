module MonthlyStatisticsTestHelper
  def generate_monthly_statistics_test_data
    hidden_candidate = create(:candidate, hide_in_reporting: true)
    form = create(:application_form, candidate: hidden_candidate)
    create(:application_choice, :with_recruited, application_form: form)

    # Apply 1
    form = create(:application_form, phase: 'apply_1')
    create(:application_choice, :with_recruited, application_form: form)

    form = create(:application_form, phase: 'apply_1')
    create(:application_choice, :with_accepted_offer, application_form: form)

    form = create(:application_form, phase: 'apply_1')
    create(:application_choice, :with_offer, application_form: form)

    form = create(:application_form, phase: 'apply_1')
    create(:application_choice, :awaiting_provider_decision, application_form: form)

    form = create(:application_form, phase: 'apply_1')
    create(:application_choice, :with_declined_offer, application_form: form)

    form = create(:application_form, phase: 'apply_1')
    create(:application_choice, :withdrawn, application_form: form)

    rejected_form = create(:application_form, phase: 'apply_1')
    create(:application_choice, :with_rejection, application_form: form)

    form = create(:application_form, phase: 'apply_1')
    create(:application_choice, :with_deferred_offer, application_form: form)

    # Apply 2
    form = create(:application_form, phase: 'apply_2', candidate: rejected_form.candidate)
    create(:application_choice, :with_recruited, application_form: form)
  end

  def expect_report_rows(column_headings:)
    expected_rows = yield.map { |row| column_headings.zip(row).to_h } # [['Status', 'Recruited'], ['First Application', 1] ...].to_h
    expect(statistics[:rows]).to match_array expected_rows
  end

  def expect_column_totals(*totals)
    expect(statistics[:column_totals]).to eq totals
  end
end
