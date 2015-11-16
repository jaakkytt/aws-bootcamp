# AWS Bootcamp: Lab 1

## Download your AWS Access Key

1. Head over to the AWS Web Console. And choose `Security Credentials` from the account menu in the top left corner.
2. Choose `Users` from the Details menu on the left hand side.
3. Find and select you AWS account from the list.
4. On you account page open the `Security Credentials` tab and click the `Create Access Key` button.
5. In the `Create Access Key` dialog box that opened click `Download Credentials`. Now you should have the file `credentials.csv` on you disk somewhere, you'll be needing this later.


Create and download Key Pair

Step through ec2 launch wizard

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

## "Hello World!"

And now let's make an actual API request using the CLI to make sure that your configuration is valid.

    # aws iam describe-regions
