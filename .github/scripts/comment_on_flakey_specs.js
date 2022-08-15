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
    let branchName = GITHUB_HEAD_REF.split('/').pop();
    let createComment = false;
    JSON.parse(FLAKEY_TEST_DATA).forEach(function(error) {
      let errorPath = `/${owner}/${repo}/blob/${branchName}/${error['location'].replace(':', '#L')}`;
      let errorLink = `<a href="${errorPath}">${error['location']}</a>`;
      commentBody += `Failed ${error['attempts']} out of ${error['retry_count']} times at ${errorLink}: :warning: ${error['messages'].toString()}<br>`;
      createComment = true;
    })
    if (createComment) {
      github.rest.issues.createComment({ issue_number, owner, repo, body: commentBody });
      throw new FlakeySpecError(heading);
    }
  }
}
