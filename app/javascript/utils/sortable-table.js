const SortableTable = (table) => {
  let status

  const options = {}
  options.statusMessage = 'Sort by %heading% (%direction%)'
  options.ascendingText = 'ascending'
  options.descendingText = 'descending'

  createHeadingButtons()
  createStatusBox()

  function createHeadingButtons () {
    const headings = table.querySelectorAll('thead th')
    let heading

    for (let i = 0; i < headings.length; i++) {
      heading = headings[i]
      if (heading.getAttribute('aria-sort')) {
        createHeadingButton(heading, i)
      }
    }
  }

  function createHeadingButton (heading, i) {
    const text = heading.textContent
    const button = document.createElement('button')
    button.setAttribute('type', 'button')
    button.setAttribute('data-index', i)
    button.textContent = text
    button.addEventListener('click', sortButtonClicked)
    heading.textContent = ''
    heading.appendChild(button)
  }

  function sortButtonClicked (event) {
    const columnNumber = event.target.getAttribute('data-index')
    const sortDirection = event.target.parentElement.getAttribute('aria-sort')
    let newSortDirection
    if (sortDirection === 'none' || sortDirection === 'ascending') {
      newSortDirection = 'descending'
    } else {
      newSortDirection = 'ascending'
    }

    const tBodies = table.querySelectorAll('tbody')

    sortTBodies(tBodies, columnNumber, newSortDirection)

    for (let i = tBodies.length - 1; i >= 0; i--) {
      const rows = getTableRowsArray(tBodies[i])
      const sortedRows = sort(rows, columnNumber, newSortDirection)
      addRows(tBodies[i], sortedRows)
    }

    removeButtonStates()
    updateButtonState(event.target, newSortDirection)
  }

  function sortTBodies (tBodies, columnNumber, sortDirection) {
    const tBodiesAsArray = []

    for (let i = 0; i < tBodies.length; i++) {
      tBodiesAsArray.push(tBodies[i])
    }

    const newTbodies = tBodiesAsArray.sort(function (tBodyA, tBodyB) {
      let tBodyAHeaderRow = tBodyA.querySelector('th[scope="rowgroup"]')

      let tBodyBHeaderRow = tBodyB.querySelector('th[scope="rowgroup"]')

      if (tBodyAHeaderRow && tBodyBHeaderRow) {
        tBodyAHeaderRow = tBodyAHeaderRow.parentElement
        tBodyBHeaderRow = tBodyBHeaderRow.parentElement

        const tBodyACell = tBodyAHeaderRow.querySelectorAll('td, th')[columnNumber]
        const tBodyBCell = tBodyBHeaderRow.querySelectorAll('td, th')[columnNumber]

        const tBodyAValue = getCellValue(tBodyACell)
        const tBodyBValue = getCellValue(tBodyBCell)

        return compareValues(tBodyAValue, tBodyBValue, sortDirection)
      } else {
        console.log('no way to compare tbodies')
        return 0
      }
    })

    for (let i = 0; i < newTbodies.length; i++) {
      table.append(newTbodies[i])
    }
  }

  function getTableRowsArray (tbody) {
    const rows = []
    const trs = tbody.querySelectorAll('tr')
    for (let i = 0; i < trs.length; i++) {
      rows.push(trs[i])
    }
    return rows
  }

  function sort (rows, columnNumber, sortDirection) {
    const newRows = rows.sort(function (rowA, rowB) {
      const tdA = rowA.querySelectorAll('td, th')[columnNumber]
      const tdB = rowB.querySelectorAll('td, th')[columnNumber]

      const rowAIsHeader = rowA.querySelector('th[scope="rowgroup"]')
      const rowBIsHeader = rowB.querySelector('th[scope="rowgroup"]')

      const valueA = getCellValue(tdA)
      const valueB = getCellValue(tdB)

      if (rowAIsHeader) {
        return -1
      } else if (rowBIsHeader) {
        return 1
      } else {
        if (sortDirection === 'ascending') {
          if (valueA < valueB) {
            return -1
          }
          if (valueA > valueB) {
            return 1
          }
          return 0
        } else {
          if (valueB < valueA) {
            return -1
          }
          if (valueB > valueA) {
            return 1
          }
          return 0
        }
      }
    })
    return newRows
  }

  function getCellValue (cell) {
    console.log(cell)
    let cellValue = cell.getAttribute('data-sort-value') || cell.textContent
    cellValue = parseFloat(cellValue.replaceAll(',', '')) || cellValue

    console.log(cellValue)
    return cellValue
  }

  function addRows (tbody, rows) {
    for (let i = 0; i < rows.length; i++) {
      tbody.append(rows[i])
    }
  }

  function removeButtonStates () {
    const tableHeaders = table.querySelectorAll('thead th')

    for (let i = tableHeaders.length - 1; i >= 0; i--) {
      tableHeaders[i].setAttribute('aria-sort', 'none')
    }
  }

  function updateButtonState (button, direction) {
    button.parentElement.setAttribute('aria-sort', direction)
    let message = options.statusMessage
    message = message.replace(/%heading%/, button.textContent)
    message = message.replace(/%direction%/, options[direction + 'Text'])
    status.textContent = message
  }

  function compareValues (valueA, valueB, sortDirection) {
    if (sortDirection === 'ascending') {
      if (valueA < valueB) {
        return -1
      }
      if (valueA > valueB) {
        return 1
      }
      return 0
    } else {
      if (valueB < valueA) {
        return -1
      }
      if (valueB > valueA) {
        return 1
      }
      return 0
    }
  }

  function createStatusBox () {
    status = document.createElement('div')
    status.setAttribute('aria-live', 'polite')
    status.setAttribute('role', 'status')
    status.setAttribute('aria-atomic', 'true')
    status.setAttribute('class', 'sortable-table-status')

    table.parentElement.insertBefore(status, table.nextSibling)
  }
}

export default SortableTable
