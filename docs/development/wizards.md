# Wizards

To simplify the process of creating multi-step processes with no intermediate persistence, a number of reusable model and controller modules have been implemented. They require minimal configuration and make using wizards a lot easier.

- [Wizard](#wizard)
- [Wizard::PathHistory](#wizardpathhistory)
- [ClearWizardCache](#clearwizardcache)
- [Things to note](#things-to-note)

## Wizard

The `Wizard` is the only mandatory module, and must be included in any multi-step form models as it implements the minimum required wizard functionality, managing the state store (merging attributes, clearing and saving the state and, checking for the validity of a steps) and checking for the validity of steps.

### How it works

#### Set up

A wizard accepts the state store and attributes that it needs to store.

`WizardFormClass.new(state_store, attrs)`

It does a deep merge to ensure that attributes at all levels are always updated.

#### Attribute sanitisation (optional)

To enable attribute sanitisation, `sanitize_attrs(attrs)` must to be implemented in the form model.

_For example, the offer flow requires `study_mode` and `course_option_id` to be reset if `course_id` changes_

```ruby
def sanitize_attrs(attrs)
  if !last_saved_state.empty? && attrs[:course_id].present? && last_saved_state['course_id'] != attrs[:course_id]
    attrs.merge!(study_mode: nil, course_option_id: nil)
  end
  attrs
end
```

#### Extending the initializer (optional)

To run any additional actions as part of the initializer, you need to implement `initialize_extra`.

_The example below is part of the InviteUserWizard as the checking_answers flag needs to be reset when the user is on the `check` step_

```ruby
def initialize_extra(_attrs)
  self.checking_answers = false if current_step == :check
end
```

#### Excluding attributes from the data store (optional)

To avoid persisting any attributes in the data store, you can override the `state_excluded_attributes` method. By default, `state_store`, `errors` and `validation_context` are excluded.


#### Usage

The wizard model should be initialized through the controller, who should also be responsible for handling the state store.

The wizard state should be saved when the wizard is valid for the current step (on `create` or `update`) and also when entering other steps that don't modify any attributes, such as `new` or `edit`. The latter is required in order for the latest step to be saved.

_For example, when attempting to submit the providers step of the OffersWizard:_

```ruby
def create
  @wizard = OfferWizard.new(offer_store, attributes_for_wizard)

  if @wizard.valid_for_current_step?
    @wizard.save_state!

    # redirect to new
  else
    # do something else
    track_validation_error(@wizard)


    # render the required partial without storing the state, as that would result in your wizard being invalid
    render :new
  end
end
```

## Wizard::PathHistory

The `Wizard::PathHistory` module stores and manages the steps taken by the user, making it possible to calculate the correct value to map to the back button. Below you can find the required configuration that must be put in place in the controller and view in order to achieve that.


### Controller

To enable back button support you need to make sure to implement `action` in your base controller (in this instance InterviewsController), and to ensure that action is passed in to all instances of your wizard (only in the actions where the state is stored, such as `new` and/or `edit`).

```ruby
def action
   'back' if !!params[:back]
end
```

```ruby
@wizard = InterviewWizard.new(interview_store, interview_form_context_params.merge(current_step: 'input',
                                                                                   action: action))
# used in the view helper to map to the correct path when the previous step is the referer
@wizard.referer ||= request.referer
@wizard.save_state!
```

### View

```ruby
<% content_for :before_content, govuk_back_link_to(interview_path_for(@application_choice, @wizard, interview, @wizard.previous_step, back: true)) %>
```

#### Helper

```ruby
module InterviewPathHelper
  def interview_path_for(application_choice, wizard, interview, step, params = {})
    if step.to_sym == :referer
      wizard.referer
    elsif step.to_sym == :input
      new_provider_interface_application_choice_interview_path(application_choice, params)
    elsif step.to_sym == :edit
      ...
    else
      ...
    end
  end
end
```

## ClearWizardCache

An issue with the current wizard implementation has been the state not being cleared after navigating away and restarting the process before the wizard cache expires. To avoid this, the state store needs to be manually cleared when re-entering the process (which is usually through the `new` and/or `edit` actions).

```ruby
clear_wizard_if_new_entry(InterviewWizard.new(interview_store, {}))
```

There are two possible configurations for the `ClearWizardCache` module. The suggested one (a) is to setup the wizard flow controller and to explicitly exclude paths that the cache does not apply to (usually the index page). However, in some instances because of the structure of the wizard flow and not using CRUD that can be impossible to achieve so (b) is a possible alternative solution.

a. Ensures that access to the wizard from any route not included in the specified controller(s) will always result in the cache being cleared.

```ruby
def wizard_controller_excluded_paths
  [provider_interface_application_choice_interviews_path]
end

def wizard_flow_controllers
  ['provider_interface/interviews', 'provider_interface/interviews/checks'].freeze
end
```

b. Clears the state store when the wizard is accessed from specific entrypoints.

```ruby
def wizard_entrypoint_paths
  [new_provider_interface_application_choice_decision_path]
end
```

## Things to note

### Controller actions

For better separation of the code and all modules to be supported you should only be using CRUD rather than specifying custom actions.

For example, for creating a new set of data, use `new` and `create`, and for amending existing data, use `edit` and `update`. To check the user input, instead of implementing a `check` action add a nested ChecksController (you can find an example of that in `interviews/checks_controller`) . The flow should look something similar to the ones illustrated in the diagrams below.


#### Simple flow

The simple flow illustrates the interview flow, which consists of the input and verification steps.

![Screenshot of simple wizard flow](./simple-wizard-flow.png)

#### Multi-step flow

Below is a diagram of the Offer flow, which uses a multi-step wizard. The steps rendered as part of the flow can vary depending on different properties of the course option requested by a candidate.

![Screenshot of simple wizard flow](./multi-step-wizard-flow.png)


### Exiting process when the state store is empty

To avoid any errors caused by the user either re-entering the flow when the state store is not setup, make sure redirection is in place.

```ruby
# remember to restrict to actions where this is applicable
before_action :redirect_to_index_if_store_cleared, only: %i[create]

def redirect_to_index_if_store_cleared
  return if data_store.read.present? # do nothing

  redirect to wizard index path
end
```
