      ******************************************************************
      * COPYBOOK:    INVCREC
      * USED BY:     INTCALC (and other invoice-processing programs)
      * DESCRIPTION: Invoice record layout. One record per overdue
      *              invoice line item, including the computed days
      *              overdue used by BR-INT-001 late-fee calculation.
      ******************************************************************
       01  INVOICE-RECORD.
           05  INV-INVOICE-ID          PIC X(10).
           05  INV-CUSTOMER-ID         PIC X(8).
           05  INV-INVOICE-AMOUNT      PIC 9(7)V9(2).
           05  INV-DUE-DATE            PIC 9(8).
           05  INV-DAYS-OVERDUE        PIC 9(5).
           05  INV-STATUS-CODE         PIC X(1).
              88  INV-STATUS-OPEN      VALUE 'O'.
              88  INV-STATUS-PAID      VALUE 'P'.
              88  INV-STATUS-DISPUTED  VALUE 'D'.