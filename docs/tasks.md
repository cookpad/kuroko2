# Default Tasks

## env

`env` set environment variables.

**Option**

One or more `KEY=VALUE` style pairs. The pairs are separated by spaces.

**Example**

```
env: ACCESS_KEY=JW969LDG SECRET_KEY=3b83e0d6
```

## rails_env

`rails_env` sets rails environment variables.

**Option**

`staging` or `production`

**Example**

```
rails_env: staging
```


## execute

`execute` executes command in a subshell.

**Option**

Command to execute.

**Example**

```
execute: curl http://169.254.169.254/latest/meta-data/hostname
```

## fork

`fork` task applies its child branches in parallel.

**Option**

None

**Example**

```
fork:
  execute: say -v "Alex" "I'm Alex"
  execute: say -v "Victoria"" "I'm Victoria"
```

## parallel_fork

`parallel_fork` task applies its child branches the specified number of times in parallel,
and adds the enviroment value `KUROKO2_PARALLEL_FORK_INDEX` and `KUROKO2_PARALLEL_FORK_SIZE` automatically.

**Option**

A number of parallel size.

**Example**

```
parallel_fork: 5
  execute: sleep $KUROKO2_PARALLEL_INDEX
  execute: echo $KUROKO2_PARALLEL_FORK_INDEX $KUROKO2_PARALLEL_FORK_SIZE
```

## noop

`noop` does nothing. This is a task for test purpose.

**Option**

None

**Example**

```
noop:
```

## queue

`queue` set the queue name to work on command-executor.

**Option**

A queue name. The name must be alphanumeric characters.

**Example**

```
queue: urgent
execute: ruby urgent_job.rb # this is work on urgent queue.
```

## sequence

`sequence` task applies its child branches sequentialy.

**Option**

None

**Example**

```
sequence:
  execute: echo 1
  execute: echo 2
  execute: echo 3
```

## auto_skip_error

`auto_skip_error` task skips errors automatically when task has error.

**Option**

`true` or `false`

**Example**

```
auto_skip_error: true
```

## sleep

`sleeps` task stop the job until a given number of seconds have passed.

**Option**

Number of seconds.

**Example**
```
sleep: 10 # Sleeps over 10 seconds.
```

## sub_process

`sub_process` task launches another job definition.

**Option**

Job definition ID to be launched.

**Example**

```
sub_process: 1 # Another Job Definition
```

## timeout

`timeout` set timeout of command execution. The execution is killed by TERM signal.

**Option**

Number of minutes or `10h` or `10m`

**Example**

```
timeout: 1
execute: sleep 120 # This execution will be killed after a minute.
```

## expected_time

`expected_time` set expectation elasped time of command execution.
When the job running time is longer than `expected_time`, kuroko2 alerts administrators by email and chat,

**Option**

Number of minutes or `10h` or `10m`

**Example**

```
expected_time: 10m
execute: sleep 601 # kuroko2 alerts administrators!
```

## wait

`wait` task waits for the given upstream jobs completion.

**Option**

Upstream Job Definition ID and execution period, and optional `timeout` option.

The execution period has options hourly/daily/weekly/monthly.
The timeout option is number of minutes or `10h` or `10m` (default timeout: 60m).

**Example**

```
wait: 100/hourly 101/daily timeout=60m
```

## echo

`echo` task shows given message.

**Option**

The message to show.

**Example**

```
echo: Hello world!
```

## retry

`retry` task retries the job from a failed task automatically.

**Option**

`count` option and optional `sleep_time` option.
`count` option is required.

The count option is the number of attempts to execute each task.
The sleep time option is the number of seconds in an interval of retries.

**Example**

```
retry: count=3 sleep_time=30
  execute: echo 1
  execute: test -e /tmp/foo.txt
```

Assume that you have more than one command. and the command which triggered not first, was failed.
In this case, the retried job started from the command which make job failed. For instance, you have above task definition:

- `execute: test -e /tmp/foo.txt` failed (first command is success, and the second was fail)
- The retried job starts from `execute: test -e /tmp/foo.txt`