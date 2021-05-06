const sortByFilter = () => {
  const filter = document.querySelector('[data-module="sort-by-filter-option"]')
  if (filter) {
    filter.addEventListener('change', (event) => {
      event.target.form.submit()
    })
  };
}

export default sortByFilter
