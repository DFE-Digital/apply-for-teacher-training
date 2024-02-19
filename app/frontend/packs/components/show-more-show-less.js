function ShowMoreShowLess () {
  this.link = document.getElementById('show-more-show-less')
  this.container = document.getElementById('show-more-show-less-text');
  this.isLess = true;
  this.lessText = "Show less";
  this.moreText = "Show more";

  this.addButtonListener()
}

ShowMoreShowLess.prototype.addButtonListener = function () {
  let context = this;

  this.link.addEventListener('click', function (e) {
    e.preventDefault()

    if (context.isLess) {
      context.isLess = false;
     // context.container.style.display = 'block';
      context.container.classList.remove('govuk-visually-hidden');
      context.link.innerHTML = context.lessText;
      context.container.focus();
      context.link.setAttribute('aria-expanded', true);
    } else {
      context.isLess = true;
      // context.container.style.display = 'none';
      context.container.classList.add('govuk-visually-hidden');
      context.link.innerHTML = context.moreText;
      context.link.setAttribute('aria-expanded', false);
    }
  }, false)
}

const showMoreShowLess = () => new ShowMoreShowLess()
export default showMoreShowLess
