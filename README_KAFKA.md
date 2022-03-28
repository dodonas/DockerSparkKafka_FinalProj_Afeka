# Kafka Standalone Local Cluster #

The approach taken here is to run Kafka service locally in a JVM, not in a Docker Container.
  
Kafka dependancies:
+ Java
+ Zookeeper

#### Default Port Settings ####

Apache Kafka will run on port 9092 and Apache Zookeeper will run on port 2181.

## Part 1 - Java Install ##

Install JDK that is suitable for the versions of Zookeeper and Kafka that will used.

- Install the **JDK**, not JRE version of Java.


## Part 2 - Zookeeper Install ##
Zookeeper acts as a coordinator service for managing processes in a distributed compute environment.  

Zookeper install instructions are here:  https://zookeeper.apache.org/doc/r3.4.5/zookeeperStarted.html

Download Zookeeper and follow the instructions for **Standalone Operation**. 

+ Create a dedicated folder for the Zookeeper software  
+ Create a dedicated folder for the Zookeeper process to persist logs and memory snapshots  
+ Unzip and Un-Tar the zipped archive downloaded from the Zookeeper Apache website  
+ Create a new `zoo.cfg` file (the name is arbitrary) in the `conf` directory that exists in the extracted Zookeeper installation package  

**cfg Example:**  
```
tickTime=2000
dataDir=/var/lib/zookeeper
clientPort=2181
admin.serverPort=9876
```
+ Change the `dataDir` entry to match the Zookeeper data persist location created earlier.  
For Windows installations, use a forward-slash separator between folders, EG `dataDir=C:/Software/zookeeper/data`. 

+ Change the `admin.serverPort` so that the Zookeeper admin server port (default is 8080) doesn't clash with the Spark Master on port 8080.   
The Zookeper admin server can be viewed in a web-browser at `localhost:9876/commands` (assuming the port has been changed to 9876).  
  


## Part 3 - Kafka Install and Configure ##

1. Download binary from http://kafka.apache.org/downloads.html  *Take care to download the binary version, not the source-code version.*  
2. Extract to a dedicated folder - EG on Windows `C:\Software\kafka\*.*.*` or on Mac ` /usr/local/kafka`
3. Set up the configuration in the `./config` folder where the Kafka software is extracted.

#### Kafka server.properties changes ####

Each broker must have it's own properties config.  Copy the sample configuration in `./conf/server.properties` and make a copy for each broker, EG
- Broker 1: `server.b1.properties`  
- Broker 2: `server.b2.properties`  
  
Set the Broker ID in each server properties file for the brokers.  Each broker must have a unique ID, EG:
- Broker 1: `server.b1.properties`  set `broker.id=1`  
- Broker 2: `server.b2.properties`  set `broker.id=2`    
  
- Set the Log Location in each properties file.  If working in a Windows environment, it is possible to use Windows-style absolute paths (but *escape backslashes with another backslash*), EG:  
`log.dirs=C:\\Software\\kafka\\logs`.  On a Mac, set to something like `log.dirs=/tmp/kafka-logs` 
  
Leave the rest of the configuration options with their default values for a simple test configuration.   

#### Additional windows notes

To avoid issues connecting from within a Docker container back to the Kafka server (default location = `host.docker.internal:9092`),
it may be necessary to follow the workaround in this discussion: https://github.com/docker/for-win/issues/2402.

Edit the C:\Windows\System32\drivers\etc\hosts file and comment out
```
192.168.1.170 host.docker.internal
192.168.1.170 gateway.docker.internal
```
and change it to
```
127.0.0.1 host.docker.internal
127.0.0.1 gateway.docker.internal
```

## Part 4 - Start Zookeeper ##

**Start Zookeeper**
```commandline
bin/zkServer.sh start
```

**Start Zookeeper in Windows Command Shell**
```commandline
bin\zkServer.cmd
```
(CTRL-C to exit)  
  
**Check Zookeeper Status**
```commandline
bin/zkServer.sh status
```

## Part 5 -  Start Kafka ##

### Starting on Mac ###
- In a command-window, change to the location where Kafka was installed, EG:
```
cd /usr/local/kafka
```
- Use the `kafka-server-start.sh` script to start a Kafka server, specifying the correct broker properties file, EG: 
```
./bin/kafka-server-start.sh ./config/server.b1.properties
```

### Starting on Windows ###

- Open a Windows CMD window and change directory to the `bin\windows` subdirectory, EG:  
 `cd C:\software\kafka\*.*.*\bin\windows`
 
- Use the `kafka-server-start.bat` script to start a Kafka server, specifying the correct broker properties file, EG:  
`kafka-server-start.bat ..\..\config\server.b1.properties` 

- At this point, the connection should be detected by Zookeeper and a note pasted in the Zookeeper console output:  
` [myid:] - INFO  [SyncThread:0:FileTxnLog@216] - Creating new log file: log.1`  

### Quick-Start Test on Mac ###
Ref: https://kafka.apache.org/25/documentation.html#quickstart

- Open another command window (separate from the Kafka server window)  
   
- **create a topic** named "quickstart-events" with a single partition and only one replica:
```
./bin/kafka-topics.sh --create --topic quickstart-events --bootstrap-server localhost:9092
```

- Run the **console producer client** to write a few events into the `quickstart-events` topic.  
By default, each line entered will result in a separate event being written to the topic.  

```
./bin/kafka-console-producer.sh --topic quickstart-events --bootstrap-server localhost:9092
```
enter text into the STDIN reader to add new events:
```
This is my first event
This is my second event
```

(CTRL-C to stop entering new events)
- Run the **console consumer client** to consume the events (open another command window to do this):
```
./bin/kafka-console-consumer.sh  --topic quickstart-events --from-beginning --bootstrap-server localhost:9092
```
### Quick-Start Test on Windows ###

Ref: https://kafka.apache.org/25/documentation.html#quickstart

-  Open another command window (separate from the Kafka server window)  
   
- **create a topic** named "quickstart-events" with a single partition and only one replica:
```
bin\windows\kafka-topics.bat --create --topic quickstart-events --bootstrap-server localhost:9092
```


- Run the **console producer client** to write a few events into the `quickstart-events` topic (this can run in the CMD window that was used to create a new topic).  
By default, each line entered will result in a separate event being written to the topic.  

```
bin\windows\kafka-console-producer.bat --topic quickstart-events --bootstrap-server localhost:9092
```
enter text into the STDIN reader to add new events:
```
This is my first event
This is my second event
```

(CTRL-C to stop entering new events)

- Run the **console consumer client** to consume the events (open another command window to do this):

```
bin\windows\kafka-console-consumer.bat --topic quickstart-events --from-beginning --bootstrap-server localhost:9092
```

### Consume Events *from-beginning* Vs New Events ###

The `--from-beginning` flag reads *all* records from the earliest available record.

Just omit this flag to only consume new events as they are produced
```
bin\windows\kafka-console-consumer.bat --topic quickstart-events --bootstrap-server localhost:9092
```
### Change the Message Rention Period ###

MacOS - set to 1 hour:
```
bin/kafka-configs --zookeeper localhost:2181 \
  --entity-type topics \
  --alter --add-config retention.ms=3600000 \
  --entity-name quickstart-events
```  
Windows - set to 1 hour:
```
bin\windows\kafka-configs.bat --zookeeper localhost:2181 --entity-type topics --alter --add-config retention.ms=3600000 --entity-name quickstart-events  
```