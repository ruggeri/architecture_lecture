## Questions After Lectures #1 and #2

01. What is AWS? What is EC2?
02. What is an IP address? What is a domain name? What is DNS?
03. What are the two main kinds of server software running a
  single-machine simple setup?
04. What are the two kinds of bottlenecks to performance?
05. Why is the distinction between read and write DB queries important?
06. What are the different storage devices on a machine? What is the
  difference?
07. What kind of distribution of read/write queries is favorable? Why?
08. What if the DB size is too great to fit into RAM? Is it hopeless?
09. What are the two kinds of scaling?
10. What are the advantages to scaling up? What is the main
    disadvantage?
11. What “tier” did we explore scaling out in the previous lecture?
12. What was the new kind of machine we introduced? Why did we introduce
  a load balancer?
13. What is an advantage, besides greater capacity, of having multiple
  application machines?
14. When we have one load balancer, what is a problem? (SPOF)
15. Can we eliminate the load balancer as a SPOF? How?
16. Why is having just a few load balancers not a problem?
17. What SPOF still exists? Where is our performance bottleneck?
18. What is the relative cost of our application and DB machines?

## Questions After Lecture #3

01. What is a relatively simple way to increase read capacity for the
    database tier?
02. What is the difference between leader and follower. Why can’t we
    have two leaders? (Or at least it would be complicated)
03. Would having two leaders distribute write load? Why or why not?
04. Besides additional read capacity, what do we get from having
    multiple replicas?
05. When a leader fails, what can go wrong when failing over?

## Questions After Lecture #4

01. Talked about sync and async replication. Anomolies.
02. Talk about partitioning, and denormalization.
03. Didn’t talk about downsides of updating Markov’s name.

## Questions After Lecture #5

01. So we talked about how JOIN queries don’t necessarily scale. What
    did we suggest doing about it?
02. Why might it make sense to denormalize? When is that worth it?
03. What is NoSQL mean? What are the pros/cons of SQL vs NoSQL?
04. What are ACID?
05. What is the D for?
06. What is the C for?
07. What is the A for? What’s an example of a classic atomic
    transaction?
    01. What is a transaction?
8. What is the I for?
    01. What is the “cause” for isolation problems?
    02. What is it called when you run txs one-by-one?
    03. What is concurrency?
    04. What is parallelism?
09. What is “concurrency control?”
10. How does 2PL locking work? What are the “two phases?”
11. What is a downside of 2PL?

## Questions After Lecture #6

01. We started talking about 2PC. What is it for?
02. Describe the scenario of managing two sites that *cannot reverse*
    transactions.
03. Describe how 2PC works, in the good case.
04. How is 2PC different from 2PL. Or at least: how is the “setting”
    or “context” different?
05. What kind of things can go wrong in distributed systems?
    01. Note: net splits and machine failures look the same from the
        outside.
    02. 2 generals.
06. Let’s say a coordinator sends out a lock command to both sites but
    only one responds. What could be happening with the other site?
    01. It may have failed before the lock message was sent.
    02. It may never have received the lock message (network
        partition).
    03. It may have received the lock message, locked, and then
        failed.
    04. It may have received the lock message, locked, tried to
        respond, but there is a network partition.
07. What should happen if the coordinator sends out a lock command to
    both sites, but only one responds (affirmatively)?
    01. Coordinator should time out and send abort to both machines.
    02. Coordinator must continue sending abort until both machines
        ack.
08. If a site has locked, and is waiting for a commit message that is
    doesn’t arrive, what can it do?
    01. If they don’t get it, note that this is a trick question.
    02. Might note: if the site can’t contact the other site, then it
        can’t learn the decision. This can happen with network
        partition.
09. Why doesn’t the “double commit” solution work?
    01. That is, why can’t the site rollback the change unless it
        receives a second commit msg from the coordinator?

## Lecture #7

01. Concept of “backup coordinator.”
    01. Basic problem, what if there is simply a partition?
02. CAP Theorem
03. Note that if you are trying to do reads, you still need to lock if
    you want true isolation.
    01. Mention that this has bad latency.
    02. Mention concept of snapshot reads.
04. At this point return to Drive slides.
05. Demonstrate problem with trivial leader election idea.
06. Talk about majority voting and idea of Raft.
    01. Maybe no one wins. So repeat.
07. Maybe mention Byzantine fault tolerance.
08. Maybe mention TLA+.
