export default function personalStatementToggle() {
  document.addEventListener('DOMContentLoaded', function () {
    const showMoreLink = document.querySelector('.app-show-more-toggle');
    const showLessLink = document.querySelector('.app-show-less-toggle');
    const truncated = document.getElementById('app-truncated-personal-statement');
    const full = document.getElementById('app-full-personal-statement');

    if (showMoreLink && showLessLink && truncated && full) {
      showMoreLink.addEventListener('click', function (e) {
        e.preventDefault();
        truncated.classList.add('govuk-visually-hidden');
        full.classList.remove('govuk-visually-hidden');
        showMoreLink.classList.add('govuk-visually-hidden');
        showLessLink.classList.remove('govuk-visually-hidden');
      });

      showLessLink.addEventListener('click', function (e) {
        e.preventDefault();
        full.classList.add('govuk-visually-hidden');
        truncated.classList.remove('govuk-visually-hidden');
        showLessLink.classList.add('govuk-visually-hidden');
        showMoreLink.classList.remove('govuk-visually-hidden');
        truncated.scrollIntoView({ block: 'center' });
      });
    }
  });
}
