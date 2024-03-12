# 21. Add TDA Courses to Apply / Manage

**Date:** 01/03/2024

## Status:

Proposed

## Glossary

TDA - The degree apprenticeship

## Context

Trainee teachers can now pursue degrees through apprenticeships, offering them a pathway into the profession while gaining practical experience and earning a salary. These degree apprenticeships, known as TDA courses, allow trainees to study for undergraduate or master's degrees while working, with off-the-job training integrated into their work schedule. As part of our platform-wide initiative to support TDA courses, several enhancements and modifications are proposed across various modules.

## Decision:

1. **Publish Integration Enhancement:**
   - Modify the Publish integration to accommodate TDA courses, aligning with the platform-wide decision to support TDA courses across all modules.

2. **Apply Change for Degree Section:**
   - Update Apply to allow the degree section to remain incomplete when submitting a TDA course, ensuring accurate processing without unnecessary degree information.

3. **Vendor API Change:**
   - Adjust the Vendor API to reflect TDA applications without degrees, updating the degrees node in the qualifications attribute to be an empty collection. Communicate this change with vendors/providers to ensure compatibility for applications with TDA courses.

4. **Register API Change:**
   - Similarly, modify the Register API to handle TDA applications without degrees, updating the qualifications attribute accordingly. Communicate this change with the Register team for applications involving TDA courses.

5. **Support Interface Enhancement:**
   - Add a new row in the support interface application choice to indicate the course awards, facilitating identification of TDA courses for developers and support agents.

6. **Improving TDA Application Information in Manage:**
   - Collaborate with designers to enhance the clarity of TDA application qualifications displayed in the Manage interface for providers reviewing candidate applications.

7. **Changing HESA and Application Reports in Manage:**
   - Accommodate TDA applications in HESA and application reports in Manage by returning blank fields for degree-related information when candidates apply for TDA courses without degrees.

8. **Add TDA Filter in Manage:**
   - Implement a TDA applications filter in Manage to enable providers to quickly search for applications related to courses that award degrees, improving efficiency in application management.

9. **Hide Degrees Section for TDA Applications:**
   - Omit displaying the degrees section in Manage when providers view individual applications for TDA courses, as degrees are not a requirement for these programs.

## Consequences

- **Improved System Compatibility:** These changes ensure that the platform effectively supports TDA courses across all modules, enhancing compatibility and user experience.
- **Enhanced Visibility and Efficiency:** The addition of TDA-related features and filters in interfaces such as Support and Manage improves visibility and efficiency in managing TDA applications for providers.
- **Communication and Collaboration:** Effective communication with vendors, designers, and teams such as Register, Providers and Vendors is crucial to ensure seamless integration and understanding of the changes related to TDA courses.
