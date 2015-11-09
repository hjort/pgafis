#!/usr/bin/python

# http://www.tutorialspoint.com/python/python_multithreading.htm
# https://wiki.postgresql.org/wiki/Psycopg2_Tutorial
# http://www.tutorialspoint.com/python/python_lists.htm

import threading
import time
import psycopg2

class myThread (threading.Thread):

    def __init__(self, threadID, name, counter):
        threading.Thread.__init__(self)
        self.threadID = threadID
        self.name = name
        self.counter = counter

    def run(self):
        print "Starting " + self.name

        #try:
        self.conn = psycopg2.connect("dbname='afis' user='rodrigo' host='localhost' password='dbpass'")
        #except:
        #    print "Error connecting to the database"
        self.bpid = self.conn.get_backend_pid()
        #print "Backend PID: %d" % (self.bpid)

        self.cur = self.conn.cursor()
        self.cur.execute("""SELECT %d AS num, 'abc %d' AS str FROM pg_sleep(%d)""" % \
            (self.counter, self.counter, self.counter))
        rows = self.cur.fetchall()

        #time.sleep(10)
        #print_time(self.name, self.counter, 3)

        for row in rows:
            print "%s [%d] => %d:'%s' (%s)" % \
                (self.name, self.bpid, row[0], row[1], time.ctime(time.time()))

        self.cur.close()
        self.conn.close()

        # Get lock to synchronize threads
        threadLock.acquire()

        # Free lock to release next thread
        threadLock.release()

#def print_time(threadName, delay, counter):
#    while counter:
#        time.sleep(delay)
#        print "%s: %s" % (threadName, time.ctime(time.time()))
#        counter -= 1

threadLock = threading.Lock()
threads = []

# Create new threads
thread1 = myThread(1, "Thread-1", 5)
thread2 = myThread(2, "Thread-2", 8)
thread3 = myThread(3, "Thread-3", 3)

# Start new Threads
thread1.start()
thread2.start()
thread3.start()

# Add threads to thread list
threads.append(thread1)
threads.append(thread2)
threads.append(thread3)

# Wait for all threads to complete
for t in threads:
    t.join()
print "Exiting Main Thread"
