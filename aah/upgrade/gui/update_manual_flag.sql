Update gui.t_ui_madj_posting_queue
set pq_status = 'U'
where pq_status = 'C';

-- reset the MJE enabled parameter
exec gui.setMADJPostingQueueParameters(PostingEnabled => 'Y');

commit;
