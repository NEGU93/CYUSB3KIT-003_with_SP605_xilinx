
// Example usage:
//
//      pid = addr_semaphore.GetPidIfNecessary(0);
//      if (pid != 0)
//        begin
//        while (addr_semaphore.resume_pid != pid)
//          begin
//          @(addr_semaphore.resume_pid);
//          end
//        end
//      addr_semaphore.WaitComplete(pid);
//
//        HAVE SEMAPHORE 
// 
//      addr_semaphore.Post;
      

module tbfifosemaphore;

  parameter initialCount = 1;

  integer semaphore_count;
  integer first_waiting_pid;
  integer last_waiting_pid;
  integer resume_pid;
  
  initial
    begin
    semaphore_count = initialCount;
    first_waiting_pid = 1;
    last_waiting_pid = 0;
    resume_pid = 0;
    end
    
  function integer GetNumberOfProcessesWaiting;
    input dummy;
    begin
      GetNumberOfProcessesWaiting = last_waiting_pid - first_waiting_pid + 1;
    end
  endfunction
  
  function integer GetPidIfNecessary;
    input dummy;
    begin
    if (semaphore_count == 0 || 
        GetNumberOfProcessesWaiting(0) >= semaphore_count)
      begin  // if other processes are waiting for the semaphore,
             // give them priority.
      if (GetNumberOfProcessesWaiting(0) == 0)
        begin
        last_waiting_pid = 1;
        first_waiting_pid = 1;
        end
      else
        begin
        last_waiting_pid = last_waiting_pid + 1;
        end
      
      GetPidIfNecessary = last_waiting_pid;
      end
    else
      begin
      GetPidIfNecessary = 0;
      end
    end
  endfunction
    

  task WaitComplete;
    input [31:0] pid;
    begin
    if (pid != 0)
      begin
      // reset queue to empty if this is the last pid on queue
      if (first_waiting_pid == last_waiting_pid)
        begin
        first_waiting_pid = 1;
        last_waiting_pid = 0;
        end
      else // otherwise, pull this pid of the queue
        begin
        first_waiting_pid = first_waiting_pid + 1;
        end
      resume_pid = 0; 
      end
    semaphore_count = semaphore_count - 1;
    end
  endtask

  task Post;
    begin
    semaphore_count = semaphore_count + 1;
    if (GetNumberOfProcessesWaiting(0) > 0)
      begin
      // if this semaphore has already been posted, but the first waiting 
      // process has not had a chance to respond, then wait for that process
      // to respond.
      if (resume_pid == first_waiting_pid)
        begin
        @(first_waiting_pid);     
        end
      resume_pid = first_waiting_pid;
      end
    end  
  endtask        

endmodule