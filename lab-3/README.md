# AWS Bootcamp Lab 3

In this lab we'll deploy a simple Python web application that uses the Python SDK (boto3) to read data from an S3 bucket. We rely on IAM roles to provide the example application with credentials for accessing the S3 service. The instructions provided below will guide you through setting up the infrastructure and running the example application.

## Create the S3 bucket and upload `hello.txt`

First we're going to create an S3 bucket. Note that bucket names have to be globally unique. So adjust the name suggested here accordingly.

    ~/aws-bootcamp# aws s3api create-bucket \
      --acl private \
      --bucket lab-3-jane-doe \
      --create-bucket-configuration LocationConstraint=eu-central-1

Now let's upload `lab-3/hello.txt` to the S3 bucket we just created. This file will be used later by the example application.

    ~/aws-bootcamp# cat lab-3/hello.txt
    ~/aws-bootcamp# aws s3 cp lab-3/hello.txt s3://lab-3-jane-doe/

You can check the contents of the S3 bucket by using the `ls` command. Or you could do this on the [S3 Web Console](https://console.aws.amazon.com/s3/).

    ~/aws-bootcamp# aws s3 ls s3://lab-3-jane-doe/
    2015-11-12 11:03:05         14 hello.txt

## Launch the EC2 instance

example role
prepared ec2 role. allow read-only access to s3 buckets.
enables if attached application running on the ec2 instance access to files stored s3 buckets. permissive for testing purposes this could be further to restrict access to a single bucket only.
see it in action when we launch the instance

First let's take a moment to have a look at the EC2 role

    ~/aws-bootcamp# aws iam get-role --role-name Bootcamp-S3-Access
    ~/aws-bootcamp# aws iam list-attached-role-policies --role-name Bootcamp-S3-Access

edit template: ami, ssh key

launch ec2 instance
user_data: docker provisioning

how to find out key name.
You'll need the name of the Key Pair you created

expand on parameters used to launch the instance

table

which values need changing

file parameters.json.template

replace %KEY% or put key on cmdline and skip template edit step

validate with jq
not idempotent so careful not to start multiple instances

    ~/aws-bootcamp# aws ec2 run-instances --cli-input-json file://lab-3/parameters.json --user-data file://lab-3/install_docker.sh --query 'Instances[0]' > instance.json

    ~/aws-bootcamp# cat instance.json | jq '{ InstanceIds: [.InstanceId] }' > instance-ids.json
    ~/aws-bootcamp# cat instance-ids.json
    {
      "InstanceIds": [
        "i-3a0fad86"
      ]
    }

wait

    ~/aws-bootcamp# aws ec2 wait instance-running --cli-input-json file://instance-ids.json

create tags. replace the instance id in the resources param.

    ~/aws-bootcamp# aws ec2 create-tags --resources i-3a0fad86 --tags Key=Name,Value=Lab-3-Jane-Doe

get instance public dns. copy the instance name

    ~/aws-bootcamp# aws ec2 describe-instances --cli-input-json file://instance-ids.json | jq -r '.Reservations[].Instances[].PublicDnsName'
  ec2-52-28-3-17.eu-central-1.compute.amazonaws.com

ec2 web console url https://eu-central-1.console.aws.amazon.com/ec2/

Use the SSH key (.pem file) you downloaded earlier

Open a new terminal window/ putty
Open a new terminal window or

ssh -i ~/path/to/you/key_pair.pem ec2-user@ec2-52-28-3-17.eu-central-1.compute.amazonaws.com

Windows start PuTTY

# EC2 role


    [ec2-user@ip-172-31-25-189 ~]$ ec2-metadata
    ...
    security-groups: Bootcamp-Security-Group
    ...

    [ec2-user@ip-172-31-25-189 ~]$ export AWS_DEFAULT_REGION=eu-central-1

AWS CLI running on the instance picks the IAM role up.

    [ec2-user@ip-172-31-25-189 ~]$ aws configure list
          Name                    Value             Type    Location
          ----                    -----             ----    --------
       profile                <not set>             None    None
    access_key     ****************T43A         iam-role
    secret_key     ****************M+m5         iam-role
        region             eu-central-1              env    AWS_DEFAULT_REGION

    [ec2-user@ip-172-31-30-157 ~]$ aws s3 ls s3://lab-3-jane-doe/
2015-11-12 21:41:55         14 hello.txt

    [ec2-user@ip-172-31-25-189 ~]$ aws s3 cp s3://lab-3-jane-doe/hello.txt -
    Hello, World!

alternative. use --region option for this little test

write access denied. role policy. unlike the keys used in

## Run the example application

First, check that Docker is running.

    [ec2-user@ip-172-31-25-189 ~]$ docker info

Now we're ready to run the Python web application. Application This starts a new container in the background, listening on port 80.

    [ec2-user@ip-172-31-25-189 ~]$ docker run -d -p 80:80 --name example-app -e EXAMPLEAPP_S3_BUCKET=lab-3-jane-doe taavitani/aws-bootcamp-example-app

If this works as expected then you should see `example-app` running.

    [ec2-user@ip-172-31-25-189 ~]$ docker ps

You should also try `curl` to test that everything is working as expected.

    [ec2-user@ip-172-31-25-189 ~]$ curl -I http://localhost/

Now open the example app page in you browser. It should be accessible via the public DNS name you used earlier for SSHing into the instance. You should see something like this.

docker logs example-app


load page from browser

Open the `aws-bootcamp` folder and edit `lab-3/hello.txt`. Switch to the terminal running the AWS CLI and upload the updated file to the S3 bucket.

    ~/aws-bootcamp# aws s3 cp lab-3/hello.txt s3://lab-3-jane-doe/

Now reload the example app page. You should see the updated contents.

## Clean-up

After you're done with the lab switch back to the AWS CLI terminal window to kill the instance and delete the S3 bucket with it's contents. If you're sick of the CLI at this point you could do this using the [Web Console](https://console.aws.amazon.com/) instead. But be careful not to remove other people's stuff by mistake.

    ~/aws-bootcamp# aws ec2 terminate-instances --cli-input-json file://instance-ids.json
    ~/aws-bootcamp# aws s3 rm s3://lab-3-jane-doe --recursive
    ~/aws-bootcamp# aws s3api delete-bucket --bucket lab-3-jane-doe
