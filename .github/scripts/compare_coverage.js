module.exports = ({github, context}) => {
  const { issue: { number: issue_number }, repo: { owner, repo } } = context;
  const NO_DATA = { 'result' : { 'line' : 0.0, 'branch' : 0.0 } };
  const { BASE_COVERAGE_DATA, PR_COVERAGE_DATA } = process.env;
  const BASE_COVERAGE_OBJ = BASE_COVERAGE_DATA.length ? JSON.parse(BASE_COVERAGE_DATA) : NO_DATA;
  const PR_COVERAGE_OBJ = PR_COVERAGE_DATA.length ? JSON.parse(PR_COVERAGE_DATA) : NO_DATA;
  const DELTA = 0.5;

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
    if (difference > DELTA) {
      return ':arrow_up:';
    } else {
      return ':arrow_down:';
    }
  }

  const baseBranchCoverage = BASE_COVERAGE_OBJ.result.branch;
  const baseLineCoverage = BASE_COVERAGE_OBJ.result.line;
  const prBranchCoverage = PR_COVERAGE_OBJ.result.branch;
  const prLineCoverage = PR_COVERAGE_OBJ.result.line;
  const branchDifference = compareCoverage(baseBranchCoverage, prBranchCoverage);
  const lineDifference = compareCoverage(baseLineCoverage, prLineCoverage);
  const reportedLineCoverage = reportedCoverage(baseLineCoverage, prLineCoverage, lineDifference);
  const reportedBranchCoverage = reportedCoverage(baseBranchCoverage, prBranchCoverage, branchDifference);

  if (reportedLineCoverage != baseLineCoverage || reportedBranchCoverage != baseBranchCoverage) {
    const coverageExplanation = `<details><summary><b>Line vs. Branch coverage</b></summary>
        <p>Branch coverage concerns itself with whether a particular branch of a condition had been executed.<br>
        Line coverage is only interested in whether a line of code has been executed.<br>
        This comes in handy for measuring one line conditionals.<br>
        eg.</p>
        <p><pre>
          def do_something_with_even_numbers(number)
            return if number.odd?
            ...
        </pre></p>
        <p>If all the code in the method was covered you would never know if the guard clause was ever triggered with line coverage as just evaluating the condition marks it as covered.</p>
      </details>`;

    let coverageBody = '<h2>Code Coverage</h2>'
    coverageBody += '<table><thead><tr><th></th><th>Coverage type</th><th>From</th><th>To</th></tr></thead><tbody>';
    coverageBody += `<tr><td>${emoji(lineDifference)}</td><td>Lines covered</td><td><b>${baseLineCoverage}%</b></td>`;
    coverageBody += `<td><b>${reportedLineCoverage}%</b></td></tr>`;
    coverageBody += `<tr><td>${emoji(branchDifference)}</td><td>Branches covered</td><td><b>${baseBranchCoverage}%</b></td>`;
    coverageBody += `<td><b>${reportedBranchCoverage}%</b></td></tr>`;
    coverageBody += '</tbody></table><br>';
    coverageBody += coverageExplanation;

    github.issues.createComment({ issue_number, owner, repo, body: coverageBody });
  }
}
