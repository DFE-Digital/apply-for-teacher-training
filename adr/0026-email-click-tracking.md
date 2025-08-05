# 26. Email Click Tracking

Date: 2022-04-26

## Status

Accepted

## Context

We need to track when candidates click on links within emails sent by the Apply for Teacher Training service. This helps us understand email engagement rates, measure the effectiveness of our email communications, and gather analytics on user behavior patterns.

Previously, we had no visibility into whether recipients were actually clicking through from our emails to the application, making it difficult to optimize our email communications and understand user engagement.

## Decision

We will implement email click tracking using UTM parameters and a dedicated database table to record click events.

The implementation consists of:

1. **UTM Parameter Generation**: When emails are sent via GOV.UK Notify, we append the email's `notify_reference` as a `utm_source` parameter to all links within the email body.

2. **Click Detection**: A `before_action` filter (`track_email_click`) runs on all candidate interface requests to check for the presence of `utm_source` parameters.

3. **Click Recording**: When a `utm_source` parameter is detected, we:
   - Look up the corresponding `Email` record using the `notify_reference`
   - Create an `EmailClick` record associated with that email
   - Store the full request path to understand which page the user landed on

4. **Data Model**:
   - `Email` model has a `has_many :email_clicks` relationship
   - `EmailClick` model stores the associated email ID, the path clicked, and timestamps
   - Foreign key constraint with cascade delete ensures data integrity

## Implementation Details

### Controller Integration
```ruby
class CandidateInterfaceController < ApplicationController
  before_action :track_email_click

  private

  def track_email_click
    if params[:utm_source].present?
      email = Email.where(notify_reference: params[:utm_source]).first
      email&.email_clicks&.create(path: request.fullpath)
    end
  end
end
```

### Database Schema
```ruby
create_table :email_clicks do |t|
  t.references :email, null: false, foreign_key: true
  t.string :path, null: false
  t.timestamps
end
```

## Consequences

### Positive
- **Email Engagement Analytics**: We can now measure email click-through rates and understand which emails are most effective
- **User Journey Tracking**: We can see which pages users land on from email links, helping optimize the user experience
- **Campaign Effectiveness**: We can measure the success of different email campaigns and nudges
- **Data-Driven Decisions**: Email communication strategies can be informed by actual engagement data

### Negative
- **Additional Database Load**: Every click from an email creates a new database record
- **Privacy Considerations**: We're tracking user behavior, though this is limited to click events and paths
- **Maintenance Overhead**: The tracking system needs to be maintained and the data may need periodic cleanup

### Neutral
- **Data Retention**: Email click data is included in production data sanitization scripts to protect user privacy
- **Performance Impact**: Minimal impact as the tracking is a simple database lookup and insert operation
- **Dependency on UTM Parameters**: The system relies on UTM parameters being present and correctly formatted in emails

## Notes

This feature was implemented as part of improving our understanding of user engagement with email communications. The tracking is passive and does not interfere with the user experience, while providing valuable insights for service improvement.

The implementation integrates seamlessly with our existing email infrastructure using GOV.UK Notify and follows Rails conventions for model relationships and database design.
