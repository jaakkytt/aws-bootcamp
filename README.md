# AWS Bootcamp

## Setting up the lab environment

In the following we'll guide you through setting up the AWS tools we're going to be using in the labs. The tools are packaged in a Docker image so this boils down to just starting a container from the image and configuring your access
credentials.

## Getting Docker running on you laptop

For Windows 7 and OS X users--this assumes that you installed the [Docker Toolbox](https://www.docker.com/docker-toolbox) as advised. And that you already have the Docker Machine `default` created and ready to go.

### Windows 7

Open PowerShell and `cd` into the Docker Toolbox folder.

1. Start the `default` Docker machine.

    PS > .\docker-machine.exe start default

2. Set up the environment for the Docker client. Note that you have to re-enter this command if you want to run Docker in a new PowerShell window.

    PS > .\docker-machine.exe env --shell powershell default | Invoke-Expression

3. Check that Docker is working.

    PS > .\docker.exe info

### OS X

1. Open a terminal window and start the `default` Docker machine.

    $ docker-machine start default

2. Set up the environment for the Docker client. Note that you have to re-enter this command if you want to run Docker in a new terminal window.

    $ eval $(docker-machine env default)

3. Check that Docker is working.

    $ docker info

### Ubuntu

1. Make sure that the `docker` service is running.

    $ sudo service docker start

2. Check that Docker is working.

    $ docker info

## Start the lab environment Docker container

### Windows 7

1. Clone the `aws-bootcamp` repo with your favorite Git client.

2. Pull the latest version of the lab image.

    PS > .\docker.exe pull taavitani/aws-bootcamp:latest

3. Start the container. Pay attention to the `-v` option. If the cloned repository is not in your Desktop folder then you'll have to adjust accordingly.

    PS > .\docker.exe run -i -t -v /c/Users/$Env:username/Desktop/aws-bootcamp/:/root/aws-bootcamp --name aws-bootcamp taavitani/aws-bootcamp /bin/bash

4. If this works as expected you should have a shell running inside the container. You could try running a command.

    ~/aws-bootcamp# aws --version
    aws-cli/1.9.2 Python/3.4.3 Linux/4.1.10-boot2docker botocore/1.3.2

Should you exit the container shell accidentally you can start and re-enter the container like this.

    PS > .\docker.exe start aws-bootcamp
    PS > .\docker.exe exec -i -t aws-bootcamp /bin/bash

### OS X and Ubuntu

1. Clone the `aws-bootcamp` repo.

  $ git clone https://github.com/b4nk/aws-bootcamp.git ~/aws-bootcamp

2. Pull the latest version of the lab image.

    $ docker pull taavitani/aws-bootcamp:latest

3. Start the container. Pay attention to the `-v` option. If the cloned repository is not in your home folder then you'll have to adjust accordingly.

    $ docker run -i -t -v ~/aws-bootcamp:/root/aws-bootcamp --name aws-bootcamp taavitani/aws-bootcamp /bin/bash

4. If this works as expected you should be presented with a shell running inside the container. You could try running a command.

    ~/aws-bootcamp# aws --version
    aws-cli/1.9.2 Python/3.4.3 Linux/4.1.10-boot2docker botocore/1.3.2

Should you exit the container shell accidentally you can start and re-enter the container like this.

    $ docker start aws-bootcamp
    $ docker exec -i -t aws-bootcamp /bin/bash
