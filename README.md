# Introduction 
This repository contains java test code that is intended to be 

# Getting Started

## Setup Java
* Unzip Java to c:\Java
    * Current version of java is java-se-8u41-ri
    * Add JAVA_HOME environment variable and point to C:\java\java-se-8u41-ri

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


## Run Tests
* In vs code, click on the testing icon and confirm the aah tets show up
* try running the com.aptitudesoftware.test.aah.tests.test.TestTheTestFramework from the Java test explorer
* Execute the tests directly with the gradle wrapper
    ./gradlew -Penv=ci testing:testSuite:test --tests "*TestTheTestFramework*" --rerun-tasks