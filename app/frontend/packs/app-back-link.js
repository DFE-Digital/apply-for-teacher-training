const initBackLinks = () => {
  if (history.length <= 1) return

  const backLinks = document.querySelectorAll('.app-back-link--fallback')

  Array.from(backLinks).forEach((backLink) => {
    backLink.href = 'javascript:history.back()'
    backLink.classList.remove('app-back-link--no-js')
  })
}

export default initBackLinks
