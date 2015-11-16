# AWS Bootcamp Lab 3

In this lab we'll deploy a simple Python web application that uses the Python SDK (boto3) to read data from an S3 bucket. We rely on IAM roles to provide the example application with credentials for accessing the S3 service. The instructions provided below will guide you through setting up the infrastructure and running the example application. Check the [architecture diagram](architecture.svg) to get a clearer picture.

You might also want to take a look at [the source of the example
application](https://github.com/b4nk/aws-bootcamp-example-app/blob/master/app.py).

We assume that you have the AWS CLI environment running from Lab 2. If not, please return to [Lab 2](../lab-2/) to get `aws-bootcamp` container up and running.

# Relevant Documentation

- [AWS CLI Reference:
s3](http://docs.aws.amazon.com/cli/latest/reference/s3/index.html)
- [AWS CLI Reference:
s3api](http://docs.aws.amazon.com/cli/latest/reference/s3api/index.html)
- [AWS CLI Reference:
ec2](http://docs.aws.amazon.com/cli/latest/reference/ec2/index.html)
- [Overview of IAM Policies](http://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html) - [IAM Roles for Amazon
EC2](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html)

## Create the S3 bucket and upload `hello.txt`

First we're going to create an S3 bucket. Note that bucket names have to be globally unique. So adjust the name suggested here accordingly.

Just to remind you that the shell prompt `~/aws-bootcamp#` means that these examples are meant to be executed in the `aws-bootcamp` Docker container.

    ~/aws-bootcamp# aws s3api create-bucket \
      --acl private \
      --bucket lab-3-jane-doe \
      --create-bucket-configuration LocationConstraint=eu-central-1

Now let's upload [`lab-3/hello.txt`](hello.txt) to the S3 bucket we just created. This file will be used later by the example application.

    ~/aws-bootcamp# cat lab-3/hello.txt
    ~/aws-bootcamp# aws s3 cp lab-3/hello.txt s3://lab-3-jane-doe/

You can check the contents of the S3 bucket by using the `ls` command. Or you could do this on the [S3 Web Console](https://console.aws.amazon.com/s3/).

    ~/aws-bootcamp# aws s3 ls s3://lab-3-jane-doe/

## Review the IAM role used for S3 access

We've provided you with an example IAM role for this lab: `Bootcamp-S3-Access`.

    ~/aws-bootcamp# aws iam get-role --role-name Bootcamp-S3-Access

An IAM role is usually just a list of policies. As the following command shows the example IAM role has one standard policy attached: `AmazonS3ReadOnlyAccess`.

    ~/aws-bootcamp# aws iam list-attached-role-policies --role-name Bootcamp-S3-Access

Now let's take a look at the actual policy document for `AmazonS3ReadOnlyAccess`

    ~/aws-bootcamp# aws iam get-policy-version --policy-arn arn:aws:iam::aws:policy/AmazonS3 ReadOnlyAccess --version-id v1 | jq '.PolicyVersion.Document'

You should see an IAM policy document that looks like this.

```javascript
{
  "Statement": [
    {
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ],
  "Version": "2012-10-17"
}
```

From this we can see how the policy is implemented. Read-only access to S3 is the result of allowing only `s3:Get*` and `s3:List*` API calls to the S3 service.

As a comment this policy though suitable for our lab is too permissive. The relevant part of the policy is the `"Resource": "*"` bit. This in effect says that access is allowed to all (`*`) resources, or S3 buckets in this case. For example in a production scenario this could be narrowed down to limit access to a single bucket.

We'll return to the IAM polcy topic after you've finished launching the instance.

## Launch the EC2 instance

Edit [`lab-3/parameters.json`](parameters.json) and update `KeyName` to your Key Pair name. Save and check that the result is valid JSON. The IAM profile is also specified in this file.

    ~/aws-bootcamp# cat lab-3/parameters.json | jq '.'

Now launch the instance with the `run-instances` command passing the parameters file as an argument. Note that this command is not idempotent. Running this multiple times may result in multiple instances being launched. The user data file used here [`lab-3/install_docker.sh`](install_docker.sh) is a simple shell script that installs docker.

    ~/aws-bootcamp# aws ec2 run-instances --cli-input-json file://lab-3/parameters.json --user-data file://lab-3/install_docker.sh --query 'Instances[0]' > instance.json

Take a look at the `instance.json` file that was created. And extract the id of you instance like in the following. We're going to use the file with the instance id as input for a couple of commands.

    ~/aws-bootcamp# cat instance.json | jq '{ InstanceIds: [.InstanceId] }' > instance-ids.json
    ~/aws-bootcamp# cat instance-ids.json
    {
      "InstanceIds": [
        "i-3a0fad86"
      ]
    }

Wait for the instance to start running. If this command returns immediately then the instance has already booted.

    ~/aws-bootcamp# aws ec2 wait instance-running --cli-input-json file://instance-ids.json

Tag the instance just in case you want to locate this later on the Web Console.

    ~/aws-bootcamp# aws ec2 create-tags --resources i-3a0fad86 --tags Key=Name,Value=Lab-3-Jane-Doe

And finally query the public DNS of your instance.

    ~/aws-bootcamp# aws ec2 describe-instances --cli-input-json file://instance-ids.json | jq -r '.Reservations[].Instances[].PublicDnsName'

This is optional but if you'd like then you could switch to the [EC2 Web Console](https://eu-central-1.console.aws.amazon.com/ec2/) at this point and check the results of your latest efforts.

Open a new terminal window an log in using your Key Pair. Don't forget the username--`ec2user`.

    $ ssh -i /path/to/Jane-Doe.pem ec2-user@ec2-52-28-3-17.eu-central-1.compute.amazonaws.com

Windows users will have to adapt previous command for PuTTY.

## IAM Role of the EC2 instance

Now the first thing you need to do is to check that you actually have your EC2 instance correctly set up. Check if the instance has the `Bootcamp-S3-Access` role attached. If not then you have to destroy the instance and return to the previous section.

**TODO** Kadi please test this. Untested edit.

    [ec2-user@ip-172-31-25-189 ~]$ curl http://169.254.169.254/latest/meta-data/iam/security-credentials/Bootcamp-S3-Access

Another way to test this is to check AWS CLI config on the instance. You should see the Access Key and Secret Key configured.

    [ec2-user@ip-172-31-25-189 ~]$ export AWS_DEFAULT_REGION=eu-central-1
    [ec2-user@ip-172-31-25-189 ~]$ aws configure list
          Name                    Value             Type    Location
          ----                    -----             ----    --------
       profile                <not set>             None    None
    access_key     ****************T43A         iam-role
    secret_key     ****************M+m5         iam-role
        region             eu-central-1              env    AWS_DEFAULT_REGION

This means that you can use the AWS CLI to access the S3 bucket from the instance.

    [ec2-user@ip-172-31-30-157 ~]$ aws s3 ls s3://lab-3-jane-doe/
    [ec2-user@ip-172-31-25-189 ~]$ aws s3 cp s3://lab-3-jane-doe/hello.txt -

## Run the example application

First, check that Docker is running.

    [ec2-user@ip-172-31-25-189 ~]$ docker info

Now we're ready to run the Python web application. Application This starts a new container in the background, listening on port 80.

    [ec2-user@ip-172-31-25-189 ~]$ docker run -d -p 80:80 --name example-app -e EXAMPLEAPP_S3_BUCKET=lab-3-jane-doe taavitani/aws-bootcamp-example-app

If this works as expected then you should see `example-app` running.

    [ec2-user@ip-172-31-25-189 ~]$ docker ps

You should also try `curl` to test that everything is working as expected.

    [ec2-user@ip-172-31-25-189 ~]$ curl -I http://localhost/

Now open the example app page in you browser. It should be accessible via the public DNS name you used earlier for SSHing into the instance. You should see the text from the `hello.txt` file.

Open the `aws-bootcamp` folder and edit `lab-3/hello.txt`. Switch to the terminal running the AWS CLI and upload the updated file to the S3 bucket.

    ~/aws-bootcamp# aws s3 cp lab-3/hello.txt s3://lab-3-jane-doe/

Now reload the example app page. You should see the updated contents.

## Clean-up

After you're done with the lab switch back to the AWS CLI terminal window to kill the instance and delete the S3 bucket with it's contents. If you're sick of the CLI at this point you could do this using the [Web Console](https://console.aws.amazon.com/) instead. But be careful not to remove other people's stuff by mistake.

    ~/aws-bootcamp# aws ec2 terminate-instances --cli-input-json file://instance-ids.json
    ~/aws-bootcamp# aws s3 rm s3://lab-3-jane-doe --recursive
    ~/aws-bootcamp# aws s3api delete-bucket --bucket lab-3-jane-doe
