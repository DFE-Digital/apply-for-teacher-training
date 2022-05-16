module.exports = ({github, context}) => {
  const { issue: { number: issue_number }, repo: { owner, repo } } = context;
  const NO_DATA = { 'result' : { 'line' : 0.0, 'branch' : 0.0 } };
  const { BASE_COVERAGE_DATA, PR_COVERAGE_DATA } = process.env;
  const BASE_COVERAGE_OBJ = BASE_COVERAGE_DATA.length ? JSON.parse(BASE_COVERAGE_DATA) : NO_DATA;
  const PR_COVERAGE_OBJ = PR_COVERAGE_DATA.length ? JSON.parse(PR_COVERAGE_DATA) : NO_DATA;
  const DELTA = 0.1;

  const compareCoverage = (baseCoverage, prCoverage) => {
    return (baseCoverage == prCoverage) ? 0 : prCoverage - baseCoverage;
  }

  const reportedCoverage = (baseCoverage, prCoverage, difference) => {
    if (Math.abs(difference) < DELTA) {
      return baseCoverage;
    } else {
      return prCoverage;
    }
  }

  const emoji = (difference) => {
    if (difference < (DELTA * -1)) {
      return ':arrow_down:';
    } else if (difference > DELTA) {
      return ':arrow_up:';
    } else {
      return ':left_right_arrow:';
    }
  }

  const baseLineCoverage = BASE_COVERAGE_OBJ.result.line;
  const prLineCoverage = PR_COVERAGE_OBJ.result.line;
  const lineDifference = compareCoverage(baseLineCoverage, prLineCoverage);
  const reportedLineCoverage = reportedCoverage(baseLineCoverage, prLineCoverage, lineDifference);

  if (reportedLineCoverage != baseLineCoverage) {
    let coverageBody = '<h2>Code Coverage</h2>'
    coverageBody += '<table><thead><tr><th></th><th>Coverage type</th><th>From</th><th>To</th></tr></thead><tbody>';
    coverageBody += `<tr><td>${emoji(lineDifference)}</td><td>Lines covered</td><td><b>${baseLineCoverage}%</b></td>`;
    coverageBody += `<td><b>${reportedLineCoverage}%</b></td></tr>`;
    coverageBody += '</tbody></table>';

    github.issues.createComment({ issue_number, owner, repo, body: coverageBody });
  }
}
