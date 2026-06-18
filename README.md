# billing-cobol (demo repo subset)

Minimal repo slice for the VibePath-Subset demo.

## Files
- `INTCALC.cbl` — COBOL program implementing BR-INT-001 (overdue invoice late-fee interest calculation)
- `INVCREC.cpy` — copybook defining the invoice record layout consumed by `INTCALC`

## Notes for CodeConversionAgent
- `INTCALC` is a batch, file-based program (LINE SEQUENTIAL reads/writes). The Java conversion should preserve the same business logic (tiered daily interest rate + 25% fee cap) but may modernize I/O (e.g., accept a list of invoice objects rather than flat files) — confirm against design_specs.md before changing I/O shape.
- The 25% fee cap was a later amendment; see JIRA VPM-101 for the acceptance criteria and VPM-100 for the original tiered-rate rule.