/* eslint-disable */
if (!Array.prototype.filter) {
  Array.prototype.filter = function (callback, context) {
    const array = []

    for (let i = 0; i < this.length; i++) {
      if (callback.call(context, this[i], i, this)) {
        array.push(this[i])
      }
    }
    return array
  }
}
