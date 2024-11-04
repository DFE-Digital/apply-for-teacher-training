module TaskViewHelper
  def display_header?(application_choices, choice)
    index = application_choices.index(choice)
    return true if index.zero?

    choice.task_view_group != application_choices[index - 1].task_view_group
  end

  def task_view_header(choice)
    yield (case choice&.task_view_group
           when 1 then 'Received over 30 days ago - make a decision now'
           when 2 then 'Received – make a decision'
           when 3 then 'Confirm deferred offers'
           when 4 then 'Interviewing'
           when 5 then 'Offers pending conditions (previous cycle)'
           when 6 then 'Waiting for candidate to respond to offer'
           when 7 then 'Offers pending conditions (current cycle)'
           when 8 then 'Successful candidates'
           when 9 then 'Deferred offers'
           else
             'No action needed'
           end)
  end

  def task_view_subheader(choice)
    return unless choice.respond_to?(:task_view_group)

    text = case choice.task_view_group
           when 1 then 'You received these applications over 30 working days ago. You need to make a decision as soon as possible or the candidate may choose to withdraw and apply to another provider.'
           end
    yield text if text
  end

  def relative_date_text_color(choice)
    return unless choice.respond_to?(:task_view_group)

    case choice.task_view_group
    when 1 then 'app-status-indicator--red'
    else
      ''
    end
  end
end
