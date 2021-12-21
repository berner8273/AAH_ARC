# Introduction 
This repository contains java test code that is intended to be 

* Unzip Java to c:\Java
    * Current version of java is java-11-openjdk-11.0.8.10-2
    * Add JAVA_HOME environment variable and point to C:\java\java-11-openjdk-11.0.8.10-2.windows.redhat.x86_64

## Install Gradle
* got to https://gradle.org/install/
* Download the binary only and follow the manually installation for windows
* Unzip gradle to c:\Gradle to be consistent with the vscode settings that have been committed to the repo
    
## Initialize Gradle    
* Open up the AAH repository root foler with VS code
* open a powershell command prompt run the commande to build java directly using the gradle wrapper
    .\gradlew -version
        

## Build with Gradle Wrapper
* open a powershell command prompt run the commande to build java directly using the gradle wrapper
    .\gradlew -Penv=CI compileJava

## VS Code setup
* In vs code, install the java extention pack. Note 'Visual Studio Intellicode' is not required.

## Test requirements
* Insure all tables used as a Seed, Expected result OR cleardown have an entry in the AAHTablenameConstants file
* Insure EURGAAPADJ is inserted in FR_POSTING_SCHEMA table, original cleardown removes 'STN' schemas
* Check for '?' used in ER shared sql files and replace with appropriate column name
* grant delete on hopper_cession_event and hopper_journal_line to UNITTEST:
AS APTITUDE USER, 
grant delete on fdr.fr_stan_raw_acc_event to STN with grant option
grant delete on stn.hopper_cession_event to UNITTEST
grant delete on fdr.fr_stan_raw_adjustment to STN with grant option
grant delete on stn.hopper_journal_line to unittest

grant delete on rr_glint_journal_line to UNITTEST

## Run Tests
* In vs code, click on the testing icon and confirm the aah tets show up
* try running the com.aptitudesoftware.test.aah.tests.test.TestTheTestFramework from the Java test explorer
* Execute the tests directly with the gradle wrapper
    ./gradlew -Penv=ci testing:testSuite:test --tests "*TestTheTestFramework*" --rerun-tasks