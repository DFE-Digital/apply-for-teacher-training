# Reasons for rejection

Apply allows provider users and vendor API users to reject applications.
It is necessary to give reasons for rejecting the application.

We've iterated the way we capture reasons for rejections several times and this has led to a variety of ways we store the rejection reasons data.

- As a single text field value in `ApplicationChoice#rejection_reason`
- As a complex set of flat attributes as JSON in `ApplicationChoice#structured_rejection_reasons`
- As a complex set of nested attributes as JSON in `ApplicationChoice#structured_rejection_reasons`

We use the field and corresponding enum [`ApplicationChoice#rejection_reasons_type`](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/models/application_choice.rb#L52-L56) to denote the reasons data format.

- `rejection_reason` - Single text field value predating structured reasons, still writeable via the Vendor API.
- `reasons_for_rejection` - Initial iteration of structured reasons, which can be inflated into the `ReasonsForRejection` model.
- `rejection_reasons` - Current iteration of structured reasons, which can be inflated into the `RejectionReasons` model.

We still read and render all three types of reasons in various components and presenters and via the Vendor API.

We currently only write `rejection_reasons` type data to the db as JSON.

We currently stil support writing rejection reason text as a single field in `ApplicationChoice#rejection_reason` via the Vendor API.
