      ******************************************************************
      * PROGRAM:     INTCALC
      * BUSINESS RULE: BR-INT-001 (Overdue Invoice Late-Fee Interest)
      * DESCRIPTION: Computes late-fee interest on overdue invoices.
      *              Reads invoice records, applies a tiered daily
      *              interest rate based on days overdue, and writes
      *              the computed late fee back to the output record.
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. INTCALC.
       AUTHOR. VIBEPATH-DEMO.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INVOICE-FILE ASSIGN TO "INVOICES.DAT"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT RESULT-FILE ASSIGN TO "RESULTS.DAT"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  INVOICE-FILE.
       COPY INVCREC.

       FD  RESULT-FILE.
       01  RESULT-RECORD               PIC X(80).

       WORKING-STORAGE SECTION.
       01  WS-EOF-FLAG                 PIC X(1) VALUE 'N'.
       01  WS-DAYS-OVERDUE             PIC 9(5) VALUE ZERO.
       01  WS-DAILY-RATE               PIC 9(1)V9(4) VALUE ZERO.
       01  WS-LATE-FEE                 PIC 9(7)V9(2) VALUE ZERO.
       01  WS-PRINCIPAL-PLUS-FEE       PIC 9(7)V9(2) VALUE ZERO.

      * BR-INT-001 TIERED DAILY RATES:
      *   1-30 days overdue   : 0.0150% per day  (0.000150)
      *   31-60 days overdue  : 0.0250% per day  (0.000250)
      *   61+ days overdue    : 0.0400% per day  (0.000400)
      * Late fee is simple (non-compounding) interest:
      *   LATE-FEE = INVOICE-AMOUNT * DAILY-RATE * DAYS-OVERDUE
      * Maximum late fee is capped at 25% of INVOICE-AMOUNT
      * (cap defined by BR-INT-001 amendment, see JIRA VPM-101).
       01  WS-FEE-CAP-PCT              PIC 9(1)V9(2) VALUE 0.25.
       01  WS-MAX-FEE                  PIC 9(7)V9(2) VALUE ZERO.

       PROCEDURE DIVISION.
       MAIN-LOGIC.
           OPEN INPUT INVOICE-FILE
           OPEN OUTPUT RESULT-FILE

           PERFORM UNTIL WS-EOF-FLAG = 'Y'
               READ INVOICE-FILE
                   AT END
                       MOVE 'Y' TO WS-EOF-FLAG
                   NOT AT END
                       PERFORM PROCESS-INVOICE
               END-READ
           END-PERFORM

           CLOSE INVOICE-FILE
           CLOSE RESULT-FILE
           STOP RUN.

       PROCESS-INVOICE.
           MOVE INV-DAYS-OVERDUE TO WS-DAYS-OVERDUE

           IF WS-DAYS-OVERDUE <= 0
               MOVE ZERO TO WS-LATE-FEE
           ELSE
               PERFORM DETERMINE-RATE
               COMPUTE WS-LATE-FEE ROUNDED =
                   INV-INVOICE-AMOUNT * WS-DAILY-RATE
                   * WS-DAYS-OVERDUE

               COMPUTE WS-MAX-FEE ROUNDED =
                   INV-INVOICE-AMOUNT * WS-FEE-CAP-PCT

               IF WS-LATE-FEE > WS-MAX-FEE
                   MOVE WS-MAX-FEE TO WS-LATE-FEE
               END-IF
           END-IF

           COMPUTE WS-PRINCIPAL-PLUS-FEE =
               INV-INVOICE-AMOUNT + WS-LATE-FEE

           PERFORM WRITE-RESULT.

       DETERMINE-RATE.
           IF WS-DAYS-OVERDUE <= 30
               MOVE 0.000150 TO WS-DAILY-RATE
           ELSE
               IF WS-DAYS-OVERDUE <= 60
                   MOVE 0.000250 TO WS-DAILY-RATE
               ELSE
                   MOVE 0.000400 TO WS-DAILY-RATE
               END-IF
           END-IF.

       WRITE-RESULT.
           STRING INV-INVOICE-ID  DELIMITED BY SIZE
                  " "             DELIMITED BY SIZE
                  WS-LATE-FEE     DELIMITED BY SIZE
                  " "             DELIMITED BY SIZE
                  WS-PRINCIPAL-PLUS-FEE DELIMITED BY SIZE
                  INTO RESULT-RECORD
           WRITE RESULT-RECORD.