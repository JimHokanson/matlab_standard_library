TODO: Ideally these would be somewhat more organized by topic.

Possible topics:
- array extraction
- array analysis
- array manipulation

Function list:
- genFromCounts
- [roundToPrecision](md_docs/roundToPrecision.md)
- [unique](md_docs/unique.md)
- rowsToCell
- shuffle
- toCellArrayByCounts
- toCellArrayByStartsAndLength
- toMatrixFromStartsAndLength
- unique
- unique_rows

Possible Additions:
- reshape - interface to reshape that makes the input and output formats easier to manage, instead of showing transposes, size divisions, and the colon operator
  - i.e. the goal would be to simplify the following call: reshape(params(:),2,length(params)/2)';
