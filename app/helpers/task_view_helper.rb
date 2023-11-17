module TaskViewHelper
  def task_view_header(choice)
    case choice&.task_view_group
    when 1 then 'Received over 30 days ago - make a decision now'
    when 2 then 'Received – make a decision'
    when 3 then 'Confirm deferred offers'
    when 5 then 'Give feedback: you did not make a decision in time'
    when 6 then 'Interviewing'
    when 7 then 'Offers pending conditions (previous cycle)'
    when 8 then 'Waiting for candidate to respond to offer'
    when 9 then 'Offers pending conditions (current cycle)'
    when 10 then 'Successful candidates'
    when 11 then 'Deferred offers'
    else
      'No action needed'
    end
  end

  def relative_date_text_color(choice)
    return unless choice.respond_to?(:task_view_group)

    case choice&.task_view_group
    when 1 then 'app-status-indicator--red'
    else
      ''
    end
  end

  def task_view_subheader(choice)
    return unless choice.respond_to?(:task_view_group)

    text = { 1 => 'You received these applications over 30 working days ago. You need to make a decision as soon as possible or the candidate may choose to withdraw and apply to another provider.' }.delete(choice.task_view_group)

    tag.p(text, class: 'govuk-caption-s govuk-!-font-size-16 govuk-hint') if text
  end
end
