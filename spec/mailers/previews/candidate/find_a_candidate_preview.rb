class Candidate::FindACandidatePreview < ActionMailer::Preview
  def candidate_invite
    candidate = FactoryBot.create(:candidate)
    application_form = FactoryBot.create(
      :application_form,
      :minimum_info,
      candidate: candidate,
      first_name: 'Fred',
    )

    provider = FactoryBot.create(:provider)
    course = FactoryBot.create(:course,
                               provider: provider,
                               fee_domestic: 9535,
                               fee_international: 15430)

    invite = FactoryBot.create(
      :pool_invite,
      :sent_to_candidate,
      candidate:,
      application_form:,
      provider:,
      course:,
      provider_message: true,
      message_content: "# Hello\r\n## Please apply to my course\r\n\r\n^ Some content\r\n\r\nByee",
    )

    CandidateMailer.candidate_invite(invite)
  end

  def candidate_invite_limit_reached
    candidate = FactoryBot.create(:candidate)
    application_form = FactoryBot.create(
      :application_form,
      :minimum_info,
      candidate: candidate,
      first_name: 'Fred',
    )

    provider = FactoryBot.create(:provider)
    course = FactoryBot.create(:course,
                               provider: provider,
                               fee_domestic: 9535,
                               fee_international: 15430)

    invite = FactoryBot.create(
      :pool_invite,
      :sent_to_candidate,
      candidate:,
      application_form:,
      provider:,
      course:,
      provider_message: true,
      message_content: "# Hello\r\n## Please apply to my course\r\n\r\n^ Some content\r\n\r\nByee",
    )
    _second_invite = FactoryBot.create(
      :pool_invite,
      :sent_to_candidate,
      candidate:,
      application_form:,
      provider:,
      course:,
    )

    CandidateMailer.candidate_invite(invite)
  end

  def invites_chaser
    application_form = FactoryBot.create(
      :application_form,
      :minimum_info,
      first_name: 'Fred',
    )

    invite = FactoryBot.create(
      :pool_invite,
      :sent_to_candidate,
      application_form:,
    )
    second_invite = FactoryBot.create(
      :pool_invite,
      :sent_to_candidate,
      application_form:,
    )

    CandidateMailer.invites_chaser([invite, second_invite])
  end

  def pool_opt_in
    candidate = FactoryBot.create(:candidate)
    application_form = FactoryBot.create(
      :application_form,
      :minimum_info,
      candidate:,
      first_name: 'Fred',
    )
    FactoryBot.create(
      :candidate_preference,
      application_form:,
    )

    CandidateMailer.pool_opt_in(application_form)
  end

  def pool_opt_out
    candidate = FactoryBot.create(:candidate)
    application_form = FactoryBot.create(
      :application_form,
      :minimum_info,
      candidate:,
      first_name: 'Fred',
    )
    FactoryBot.create(
      :candidate_preference,
      pool_status: 'opt_out',
      application_form:,
    )

    CandidateMailer.pool_opt_out(application_form)
  end

  def pool_opt_out_after_opting_in
    candidate = FactoryBot.create(:candidate)
    application_form = FactoryBot.create(
      :application_form,
      :minimum_info,
      candidate:,
      first_name: 'Fred',
    )
    FactoryBot.create(
      :candidate_preference,
      pool_status: 'opt_out',
      application_form:,
    )

    CandidateMailer.pool_opt_out_after_opting_in(application_form)
  end

  def pool_re_opt_in
    candidate = FactoryBot.create(:candidate)
    application_form = FactoryBot.create(
      :application_form,
      :minimum_info,
      candidate:,
      first_name: 'Fred',
    )
    FactoryBot.create(:email, mail_template: 'pool_re_opt_in')
    FactoryBot.create(
      :candidate_preference,
      application_form:,
    )

    CandidateMailer.pool_re_opt_in(application_form)
  end
end
