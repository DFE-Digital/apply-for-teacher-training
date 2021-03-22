import initWarnOnUnsavedChanges from './warn-on-unsaved-changes'

describe('initWarnOnUnsavedChanges', () => {
  let $form, event

  beforeEach(() => {
    $form = { addEventListener: jest.fn() }
    event = { preventDefault: jest.fn() }
    initWarnOnUnsavedChanges($form)
  })

  it('does not throw if called with no element', () => {
    expect(() => initWarnOnUnsavedChanges(undefined)).not.toThrow()
  })

  it('allows leaving if the form has not been changed', () => {
    expect(window.onbeforeunload(event)).toBeUndefined()
  })

  it('prevents leaving if the form has been changed', () => {
    const changeCallback = getCallback($form.addEventListener, 'change')
    changeCallback()

    const expectedText =
      'You have unsaved changes, are you sure you want to leave?'

    expect(window.onbeforeunload(event)).toEqual(expectedText)
    expect(event.returnValue).toEqual(expectedText)
    expect(event.preventDefault).toHaveBeenCalled()
  })

  it('allows submitting', () => {
    const submitCallback = getCallback($form.addEventListener, 'submit')
    submitCallback()

    expect(window.onbeforeunload).toBeNull()
  })

  const getCallback = (jestFn, eventType) => {
    const [, callback] = jestFn.mock.calls.find(
      ([type, callback]) => type === eventType
    )
    return callback
  }
})
