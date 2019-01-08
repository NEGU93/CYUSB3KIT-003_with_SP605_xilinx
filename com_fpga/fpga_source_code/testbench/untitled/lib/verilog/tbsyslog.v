module tbsyslog;

  integer WarningCount;
  integer ErrorCount;

  reg EnableNoteMessages;
  reg EnableWarningMessages;
  
  integer FH;
  initial
  begin
    FH = $fopen("tb.log");
  end
  
  initial
    begin
    WarningCount = 0;
    ErrorCount = 0;

    `ifdef TB_DISABLE_NOTE_MESSAGES
      EnableNoteMessages = 0;
    `else
      EnableNoteMessages = 1;
    `endif
    
    `ifdef TB_DISABLE_WARNING_MESSAGES
      EnableWarningMessages = 0;
    `else 
      EnableWarningMessages = 1;
    `endif

    end
      
  task IncErrorCount;
    begin
    ErrorCount = ErrorCount + 1;
    end
  endtask
    
  task IncWarningCount;
    begin
    WarningCount = WarningCount + 1;
    end
  endtask
  
  task DisplayLogSummary;
    begin
    $display("TB> Total Warnings = %d", WarningCount);
    $display("TB> Total Errors = %d", ErrorCount);
    end 
  endtask  
 
endmodule