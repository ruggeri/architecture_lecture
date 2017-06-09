#include <pthread.h>
#include <stdbool.h>
#include <stdio.h>

const int NUM_THREADS = 2;
const int NUM_ITERS = 1000000;

typedef struct {
  _Atomic bool wantsToEnter1;
  _Atomic bool wantsToEnter2;
  _Atomic int turn;
}  MyLock;

MyLock buildLock() {
  return ((MyLock) {
    .wantsToEnter1 = false,
    .wantsToEnter2 = false,
    .turn = 1
  });
}

typedef struct {
  MyLock* lock;
  int* counter;
  int threadIdx;
} ThreadArgument;

void performLock(MyLock* lock, int threadIdx) {
  if (threadIdx == 1) {
    lock->turn = 2;
    lock->wantsToEnter1 = true;
    while (lock->wantsToEnter2 && (lock->turn == 2)) {
      // Just busy wait.
    } 
  } else {
    lock->turn = 1;
    lock->wantsToEnter2 = true;
    while (lock->wantsToEnter1 && (lock->turn == 1)) {
      // Just busy wait.
    } 
  }
}

void performUnlock(MyLock* lock, int threadIdx) {
  if (threadIdx == 1) {
    lock->wantsToEnter1 = false;
  } else {
    lock->wantsToEnter2 = false;
  }
}

void* thread_main(void* argument) {
  ThreadArgument* threadArgument = (ThreadArgument*) argument;

  for (int i = 0; i < NUM_ITERS; i ++) {
    performLock(threadArgument->lock, threadArgument->threadIdx);
    *(threadArgument->counter) += 1;
    performUnlock(threadArgument->lock, threadArgument->threadIdx);
  }

  return NULL;
}

int main() {
  int counter = 0;
  MyLock lock = buildLock();
  
  ThreadArgument threadArgument1 = ((ThreadArgument) {
    .lock = &lock,
    .counter = &counter,
    .threadIdx = 1
  });
  ThreadArgument threadArgument2 = ((ThreadArgument) {
    .lock = &lock,
    .counter = &counter,
    .threadIdx = 2
  });
  
  pthread_t threads[NUM_THREADS];

  pthread_create(&threads[0], NULL, thread_main, &threadArgument1);
  pthread_create(&threads[1], NULL, thread_main, &threadArgument2);
  
  for (int i = 0; i < NUM_THREADS; i ++) {
    pthread_join(threads[i], NULL);
  }
  
  printf("Final Result: %d", counter);
  
  return 0;
}