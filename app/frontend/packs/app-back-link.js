const initBackLinks = () => {
  if (history.length <= 1) return;

  const backLinks = document.querySelectorAll(".app-back-link");

  Array.from(backLinks)
    .filter((backLink) => backLink.href === "javascript:history.back()")
    .forEach((backLink) => backLink.classList.remove("app-back-link--no-js"));
};

export default initBackLinks;
