#!/bin/bash

function INIT()
{
    # build blobstore
    cd ..
    ARCH=$(uname -m)
    echo "Detected architecture: $ARCH"
    rootPath=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
    source build/cgo_env.sh
    make blobstore
    if [ $? -ne 0 ]; then
      echo "build failed"
      exit 1
    fi

    # get consul
    if [ ! -f build/bin/blobstore/consul ]; then
        if [ "$ARCH" = "aarch64" ]; then
            echo "Detected ARM64, downloading Consul for ARM64..."
            wget https://releases.hashicorp.com/consul/1.11.4/consul_1.11.4_linux_arm64.zip -O consul.zip
        else
            echo "Detected x86_64, downloading Consul for x86_64..."
            wget https://ocs-cn-south1.heytapcs.com/blobstore/consul_1.11.4_linux_amd64.zip -O consul.zip
        fi
        unzip consul.zip
        rm -f consul.zip
        mv consul build/bin/blobstore/
        if [ $? -ne 0 ]; then
          echo "prepare consul failed"
          exit 1
        fi
    fi

    # get kafka
    grep -q "export JAVA_HOME" /etc/profile
    if [[ $? -ne 0 ]] && [[ ! -d build/bin/blobstore/jdk1.8.0_321 ]]; then
        if [ "$ARCH" = "aarch64" ]; then
            echo "Detected ARM64, downloading OpenJDK 8 for ARM64..."
            wget https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u402-b06/OpenJDK8U-jdk_aarch64_linux_hotspot_8u402b06.tar.gz -O jdk.tgz
            mkdir -p build/bin/blobstore/jdk1.8.0_321
            tar -xzf jdk.tgz -C build/bin/blobstore/jdk1.8.0_321 --strip-components=1

        else
            echo "Detected AMD64, downloading JDK from existing source..."
            wget https://ocs-cn-south1.heytapcs.com/blobstore/jdk-8u321-linux-x64.tar.gz -O jdk.tgz
            tar -xzf jdk.tgz -C build/bin/blobstore/

        fi
         if [ $? -ne 0 ]; then
          echo "prepare kafka failed"
          exit 1
         fi
         rm -f jdk.tgz
    fi
    # init java
    grep -q "export JAVA_HOME" /etc/profile
    if [ $? -ne 0 ]; then
       if [ ! -f ./build/bin/blobstore/profile ]; then
         touch ./build/bin/blobstore/profile
       fi
       echo "export JAVA_HOME=$rootPath/build/bin/blobstore/jdk1.8.0_321" > ./build/bin/blobstore/profile
       echo "export PATH=$JAVA_HOME/bin:$PATH" >> ./build/bin/blobstore/profile
       echo "export CLASSPATH=$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar" >> ./build/bin/blobstore/profile
       source build/bin/blobstore/profile
    fi

    if [ ! -d build/bin/blobstore/kafka_2.13-3.1.0 ]; then
        wget https://ocs-cn-south1.heytapcs.com/blobstore/kafka_2.13-3.1.0.tgz
        tar -zxvf kafka_2.13-3.1.0.tgz -C build/bin/blobstore/
        if [ $? -ne 0 ]; then
          echo "prepare kafka failed"
          exit 1
        fi
        rm -f kafka_2.13-3.1.0.tgz
    fi
}
INIT
