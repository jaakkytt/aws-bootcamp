# AWS Bootcamp Lab 1

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

1. For Linux users no horsing around with VMs required. Just make sure that the `docker` service is running--easy.

        $ sudo service docker start

2. Check that Docker is working.

        $ docker info

## Clone the Bootcamp GitHub repo

Clone the `aws-bootcamp` repo with your favorite Git client. For example on Ubuntu or OS X open a terminal window and run:

    $ git clone https://github.com/b4nk/aws-bootcamp.git

Note that you're going to need the path to your local clone later. This will be passed as an argument to Docker when you start the container. This way you'll be able to share the `aws-bootcamp` folder between your OS and the Docker container. Makes editing files etc. easier.

## Start the lab environment Docker container

### Windows 7

1. Pull the latest version of the lab image.

        PS > .\docker.exe pull taavitani/aws-bootcamp:latest

2. Start the container. Pay attention to the `-v` option. If the cloned repository is not in your Desktop folder then you'll have to adjust accordingly.

        PS > .\docker.exe run -i -t -v /c/Users/$Env:username/Desktop/aws-bootcamp/:/root/aws-bootcamp --name aws-bootcamp taavitani/aws-bootcamp /bin/bash

3. If this works as expected you should have a shell running inside the container. You could try running a command.

        ~/aws-bootcamp# aws --version
        aws-cli/1.9.2 Python/3.4.3 Linux/4.1.10-boot2docker botocore/1.3.2

Should you exit the container shell accidentally you can start and re-enter the container like this.

    PS > .\docker.exe start aws-bootcamp
    PS > .\docker.exe exec -i -t aws-bootcamp /bin/bash

### OS X and Ubuntu

1. Pull the latest version of the lab image.

        $ docker pull taavitani/aws-bootcamp:latest

2. Start the container. Pay attention to the `-v` option. If the cloned repository is not in your home folder then you'll have to adjust accordingly.

        $ docker run -i -t -v ~/aws-bootcamp:/root/aws-bootcamp --name aws-bootcamp taavitani/aws-bootcamp /bin/bash

3. If this works as expected you should be presented with a shell running inside the container. You could try running a command.

        ~/aws-bootcamp# aws --version
        aws-cli/1.9.2 Python/3.4.3 Linux/4.1.10-boot2docker botocore/1.3.2

Should you exit the container shell accidentally you can start and re-enter the container like this.

    $ docker start aws-bootcamp
    $ docker exec -i -t aws-bootcamp /bin/bash

## Download your AWS Access Key

1. Head over to the AWS Web Console. And choose `Security Credentials` from the account menu in the top left corner.
2. Choose `Users` from the Details menu on the left hand side.
3. Find and select you AWS account from the list.
4. On you account page open the `Security Credentials` tab and click the `Create Access Key` button.
5. In the `Create Access Key` dialog box that opened click `Download Credentials`. Now you should have the file `credentials.csv` on you disk somewhere, you'll be needing this later.

## AWS CLI configuration

Use a text editor to open the `credentials.csv` file you downloaded earlier. It should be pretty straightforward to parse--you'll only need the Key ID and Access Key.

Start the configuration wizard and enter your Key ID and Access Key when prompted.

    # aws configure
    # aws configure
    AWS Access Key ID [None]: ****
    AWS Secret Access Key [None]: ****
    Default region name [None]:
    Default output format [None]:

Also set the default AWS region to `eu-central-1` (Frankfurt).

    # aws configure set region eu-central-1

Now take a look at your configuration. It should look something like this.

    # aws configure list
          Name                    Value             Type    Location
          ----                    -----             ----    --------
        profile                <not set>             None    None
    access_key      ******************* shared-credentials-file
    secret_key      ******************* shared-credentials-file
        region             eu-central-1      config-file    ~/.aws/config


### Find the latest Amazon Linux AMI

First we need to find the latest Amazon Linux AMI. Run the provided helper script to fetch a list of all available Amazon Linux AMIs.

    ~/aws-bootcamp# bash lab-2/amazon_ami_helper.sh > amis.json

Now let's have a little bit of fun with `jq` to find the _latest_ version of Amazon Linux from the list you just downloaded. Take a look at the `amis.json` file to get a sense of how that JSON document is laid out.

Alternative `jqplay`
Go with `jqplay`. Cmdline alternative

The file JSON documents is an array of objects each representing an AMI. We can extract the first element like this.

Step-by-step a pipeline to filter sort extract.

Can skip ahead

    ~/aws-bootcamp# cat amis.json | jq '.[0]'
    {
      "ImageType": "machine",
      "OwnerId": "137112412989",
      "RootDeviceType": "ebs",
    ...

We can filter out the the fields that are actually of interest at the moment. This u

    ~/aws-bootcamp# cat amis.json | jq '.[0] | {Name, CreationDate, ImageId}'

And to do the same with

    ~/aws-bootcamp# cat amis.json | jq '[.[] | {Name, CreationDate, ImageId}]'

    ~/aws-bootcamp# cat amis.json | jq '[.[] | {Name, CreationDate, ImageId}] | sort_by(.CreationDate)'

    ~/aws-bootcamp# cat amis.json | jq '[.[] | {Name, CreationDate, ImageId}] | sort_by(.CreationDate) | last'

You actually need only the image id of the AMI in the next step.

    ~/aws-bootcamp# cat amis.json | jq -r '[.[] | {Name, CreationDate, ImageId}] | sort_by(.CreationDate) | last | .ImageId'

Verify. The Description should.
To be sure...

    ~/aws-bootcamp# aws ec2 describe-images --image-id ami-abcd1234 | jq '.Images[0].Description'
    "Amazon Linux AMI 2015.09.1 x86_64 HVM GP2"
## "Hello World!"

And now let's make an actual API request using the CLI to make sure that your configuration is valid.

    # aws iam describe-regions
