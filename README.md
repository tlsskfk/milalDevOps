# Milal DevOps

- [Milal DevOps](#milal-devops)
- [1. Getting Started](#1-getting-started)
- [2. Designing Infrastructure](#2-designing-infrastructure)
  - [2.1 Vite](#21-vite)
  - [2.2 React App](#22-react-app)
  - [2.3 Node](#23-node)
  - [2.4 MySQL](#24-mysql)
  - [2.5 Docker](#25-docker)
      - [2.5.1 DockerHub](#251-dockerhub)
  - [2.6 AWS](#26-aws)
      - [2.6.1 AWS-sdk](#261-aws-sdk)
      - [2.6.2 S3](#262-s3)
      - [2.6.3 EC2](#263-ec2)
      - [2.6.4 SES](#264-ses)
      - [2.6.5 Lambda](#265-lambda)
      - [2.6.6 Route53](#266-route53)
- [3. Kubernetes](#3-kubernetes)
  - [3.1 Pod Designs](#31-pod-designs)
  - [3.2 Services](#32-services)
  - [3.2 Helm Chart](#32-helm-chart)
- [4. Ansible](#4-ansible)
- [5. Terraform](#5-terraform)
  - [5.1 Initialize Terraform](#51-initialize-terraform)
        - [Prerequesite: you need to have an authenticated account](#prerequesite-you-need-to-have-an-authenticated-account)
- [6. Jenkins](#6-jenkins)
  - [6.1 ENV Variables](#61-env-variables)
  - [6.2 Github](#62-github)
  - [6.3 Pl](#63-pl)



# 1. Getting Started

# 2. Designing Infrastructure
## 2.1 Vite
## 2.2 React App
## 2.3 Node
## 2.4 MySQL
## 2.5 Docker
#### 2.5.1 DockerHub
## 2.6 AWS
#### 2.6.1 AWS-sdk
#### 2.6.2 S3
#### 2.6.3 EC2
#### 2.6.4 SES

Email is a powerful tool.  With the right containers, email can be used as an extremely well-designed api.  Consider the kindle.  If you want to load your own pdf to your kindle, you can set the accepted email addresses, and send emails to the kindle and have it loaded into your library.  How neat is that! 

Given our organization, let's try to create a similar environment with email and uploading photos to the website.  There are two main considerations here.
    - Authenticating the email.
    - Uploading and separating documents to s3
Other considerations will be solved using other open-source tools, such as deleting photos.
Since we already have both tools available in our Node server, let's try to use those.  Since SES already has some configuration available to upload straight to s3, all we need is some middleware.  Let's create a Lambda function that can do just that (next Section).

Let's do another thing with SES.  Since we created a contact form that can hold a file and give certain parameters to the contactee, let's send the organization an email with all the details.  We can create a route that points to this --

      import { SESClient, SendEmailCommand } from "@aws-sdk/client-ses";
      const ses = new SESClient({
        region,
      });
      export const sendEmail = async (req, res) => {
        const { q1, q2, q3, comments  } = req.body
        const command = new SendEmailCommand({
          Destination: {
            ToAddresses: [processs.env.HOST_EMAIL],
          },
          Message: {
            Body: {
              Text: { Data: q1, q2, q3, comments },
            },
          Subject: { Data: "SOME EMAIL TITLE" },
        },
        Source: process.env.ORG_HOST_EMAIL,
      });

        try {
          let response = await ses.send(command);
          // process data.
          return response;
        }
        catch (err) {
          console.log(err)
        }
      }
-- something like this
[Example](https://github.com/tlsskfk/milalwebsite/blob/master/api/controllers/aws.js)

#### 2.6.5 Lambda

Ok.  Full dislaimer, the last code block at SES was taken from the lambda builder.  This time, we will need to connect SES to the Node Server using a lambda function and a exposed NodePort container service.
Let's login to AWS and create the lambda function first -- 

      import boto3
      import requests
      import json

      def lambda_handler(event, context):
          
          # Extract the email header and attachments from the incoming email
          message = event['Records'][0]['Sns']['Message']
          header = message['headers']
          attachments = message['attachments']
          
          # Specify the host and port of the Docker container
          host = 'my-docker-host.com'
          port = '8080'
          
          # Construct the URL of the Docker container
          url = f'http://{host}:{port}/myapp'
          
          # Send the email header to the Docker container and receive the response
          response = requests.post(url, data=json.dumps(header))
          
          # Check the response and process the attachments if the data is true
          if response.status_code == 200:
              data = response.json()
              if data:
                  # Upload each attachment to a separate S3 bucket object
                  s3 = boto3.client('s3')
                  for attachment in attachments:
                      # Extract the attachment name and content
                      name = attachment['name']
                      content = attachment['content']
                      
                      # Upload the attachment to an S3 bucket
                      s3.put_object(Bucket='my-s3-bucket', Key=name, Body=content)
                  
                  # Return a success message if all attachments were uploaded
                  return {
                      'statusCode': 200,
                      'body': 'All attachments were uploaded successfully'
                  }
              else:
                # Return a message if the email is not authorized
                return {
                    'statusCode': 401,
                    'body': 'Unauthorized'
                }
        else:
            # Return an error if the Docker container did not return a valid response
            return {
                'statusCode': 500,
                'body': 'Invalid format or other issue has occurred'
            }

-- Let's test this, compressing the packages needed to run this environment and upload it to lambda.  Json should already be available in the Python Library lambda runs on, so you can skip that.  You're going to move to that directory in bash, run a virtual environment, pip install, and zip the needed files.  If you're using windows, you can download 7-Zip and create a .bashrc file in your home directory like this by running nano ~/.bashrc --

      export PATH=$PATH:path/to/7-zip

-- then in the cli you can source ~/.bashrc and use any exports there.  Let's go back to the cli and do --

      python -m venv venv

-- This will initialize a venv folder called venv in the directory, and you can rull the script using -- 

      source venv/Scripts/activate

-- Then run --

      pip install boto3 requests

-- Then save those dependencies to a requirements.txt file using --

      pip freeze > requirements.txt

-- compress using 7zip --

      7z a lambda_function.zip lamdba_function.py boto3 requests --

-- Now we can upload our function to lambda and an email payload [example](lambda/event.json)

Then we can write our complimentary Node.js Code to return --


-- something like this
[Example](https://github.com/tlsskfk/milalDevOps/blob/main/lambda/emailToS3.py)

#### 2.6.6 Route53

# 3. Kubernetes
## 3.1 Pod Designs
## 3.2 Services
## 3.2 Helm Chart

# 4. Ansible

# 5. Terraform

## 5.1 Initialize Terraform
Let's save Terraform to our Path Environment variable, after install, letting us use the Terraform function from anywhere.
/n
##### Prerequesite: you need to have an authenticated account
Let's create a credentials script.  I am saving to my .bashrc file in the home directory.  You may or may not have one.  You can check using 
    ls -la ~
-- Since it starts with a period you will need the -a tag since it would normally be hidden.  Then you would put this script in --
    export AWS_ACCESS_KEY=YOUR_AWS_ACCESS_KEY
    export AWS_SECRET_ACCESS_KEY=YOUR_SECRET_AWS_ACCESS_KEY
-- This way, whenever you start a new BASH process, all you need to do is -- 
    source ~/.bashrc
-- and this should initialize your credentials for terraform.  Remember to name it exactly as such and understand the preference terraform has using these [docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).  Now, you should be able terraform apply using your main.tf file.
/n
Use a boilerplate terraform file -- you can find one in the docs/tutorials of the website, and terraform destroy after.

# 6. Jenkins
## 6.1 ENV Variables
## 6.2 Github
## 6.3 Pl


