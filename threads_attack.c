#include <pthread.h>
#include <stdbool.h>
#include <stdio.h>

const int NUM_ITERS = 1000000;
const int NUM_THREADS = 2;

typedef struct {
  _Atomic bool thread0WantsLock;
  _Atomic bool thread1WantsLock;
  _Atomic int turn;
} MyLock;

void acquireLock(MyLock* lock, int threadIdx) {
  if (threadIdx == 0) {
    lock->thread0WantsLock = true;
    lock->turn = 1;
    while (lock->thread1WantsLock && (lock->turn == 1)) {
      // Busy loop.
    }
  } else {
    lock->thread1WantsLock = true;
    lock->turn = 0;
    while (lock->thread0WantsLock && (lock->turn == 0)) {
      // Busy loop.
    }
  }
}

void releaseLock(MyLock* lock, int threadIdx) {
  if (threadIdx == 0) {
    lock->thread0WantsLock = false;
  } else {
    lock->thread1WantsLock = false;
  }
}

typedef struct {
  int threadIdx;
  int* result;
  MyLock* lock;
} ThreadArgument;

void* thread_work(void* _argument) {
  // Cast.
  ThreadArgument* threadArgument = (ThreadArgument*) _argument;

  for (int i = 0; i < NUM_ITERS; i++) {
    acquireLock(threadArgument->lock, threadArgument->threadIdx);
    *(threadArgument->result) += 1;
    releaseLock(threadArgument->lock, threadArgument->threadIdx);
  }

  return NULL;
}

int main() {
  pthread_t threads[NUM_THREADS];
  int result = 0;
  MyLock lock = {
    .thread0WantsLock = false,
    .thread1WantsLock = false,
    .turn = -1
  };

  ThreadArgument arg0 = {
    .threadIdx = 0,
    .result = &result,
    .lock = &lock
  };
  ThreadArgument arg1 = {
    .threadIdx = 1,
    .result = &result,
    .lock = &lock
  };

  pthread_create(&threads[0], NULL, thread_work, &arg0);
  pthread_create(&threads[1], NULL, thread_work, &arg1);
  
  pthread_join(threads[0], NULL);
  pthread_join(threads[1], NULL);
  
  printf("Result: %d\n", result);

  return 0;
}