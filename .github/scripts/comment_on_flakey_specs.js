module.exports = ({github, context}) => {
  class FlakeySpecError extends Error {
    constructor(message) {
      super(message);
      this.name = 'FlakeySpecError';
    }
  }

  const { FLAKEY_TEST_DATA, GITHUB_HEAD_REF } = process.env;
  if (FLAKEY_TEST_DATA.length) {
    const { issue: { number: issue_number }, repo: { owner, repo } } = context;
    const heading = 'You have one or more flakey tests on this branch!';
    let commentBody = `<h2>${heading} :snowflake: :snowflake: :snowflake:</h2>`;
    let dataStr, dataAry, attempts, retryCount, errorLocation, errorPath, errorMessages, errorLink;
    let branchName = GITHUB_HEAD_REF.split('/').pop();
    let createComment = false;
    let rows = FLAKEY_TEST_DATA.split("\n");
    let rowsLength = rows.length;
    for (var idx = 0; idx < rowsLength; idx++) {
      dataStr = rows[idx];
      if (dataStr.length) {
        dataAry = dataStr.split(',');
        [attempts, retryCount, errorLocation, ...errorMessages] = dataAry;
        errorPath = `/${owner}/${repo}/blob/${branchName}/${errorLocation.replace(':', '#L')}`;
        errorLink = `<a href="${errorPath}">${errorLocation}</a>`;
        commentBody += `Failed ${attempts} out of ${retryCount} times at ${errorLink}: :warning: ${errorMessages.toString()}<br>`;
        createComment = true;
      }
    }
    if (createComment) {
      github.issues.createComment({ issue_number, owner, repo, body: commentBody });
      throw new FlakeySpecError(heading);
    }
  }
}
