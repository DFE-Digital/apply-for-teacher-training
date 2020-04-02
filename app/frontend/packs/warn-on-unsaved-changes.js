const initWarnOnUnsavedChanges = ($form) => {
  if (!$form) return;

  let hasChanged = false;

  $form.addEventListener("submit", () => {
    window.onbeforeunload = null;
  });

  $form.addEventListener("change", () => {
    hasChanged = true;
  });

  window.onbeforeunload = (event) => {
    if (!hasChanged) return;

    // Used to handle browsers that use legacy onbeforeunload
    // https://developer.mozilla.org/en-US/docs/Web/API/Window/beforeunload_event
    event.preventDefault();

    event.returnValue =
      "You have unsaved changes, are you sure you want to leave?";
    return event.returnValue;
  };
};

export default initWarnOnUnsavedChanges;
