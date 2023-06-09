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
  - [3.2 Secrets](#32-secrets)
  - [3.3 ConfigMaps](#33-configmaps)
  - [3.4 Services](#34-services)
  - [3.5 Containers](#35-containers)
      - [3.4.1](#341)
      - [3.4.2](#342)
      - [3.4.3](#343)
      - [3.4.4 Front-end/ NGINX](#344-front-end-nginx)
      - [3.4.5](#345)
  - [3.9 Helm Chart](#39-helm-chart)
- [4. Ansible](#4-ansible)
- [5. Terraform](#5-terraform)
  - [5.1 Initialize Terraform](#51-initialize-terraform)
        - [Prerequisite: you need to have an authenticated account](#prerequisite-you-need-to-have-an-authenticated-account)
  - [5.2](#52)
  - [5.3 SSH](#53-ssh)
      - [5.3.1 Installing packages](#531-installing-packages)
- [6. Jenkins](#6-jenkins)



# 1. Getting Started

# 2. Designing Infrastructure
## 2.1 Vite
## 2.2 React App
## 2.3 Node
## 2.4 MySQL
## 2.5 Docker

Let's go to the client and api folder and create a dockerfile in each.
It should be simple as to not complicate the CICD process later on.

For the API:

        FROM node:18-alpine
        WORKDIR /api
        COPY . .
        RUN npm install --production
        CMD ["node", "index.js"]
        EXPOSE 8602

and for the client:

        FROM node:18-alpine
        WORKDIR /client
        COPY package*.json ./
        RUN npm install
        COPY . .
        RUN npm run build
        CMD ["npx", "serve", "-s", "-l", "8601", "build"]

just make sure to add node_modules and .env to your dockerignore.  We wouldn't want to clutter up the image unnecessarily or expose secrets.
We can then, in each home directory, we can now go to the cli and

        docker build -t YOUR_REPOSITORY_NAME/IMAGE_NAME:VERSION .

Don't forget the period.
Later, we can upload to our repository (make sure you have them first -- you can build it on dockerHub) using 

        docker push YOUR_REPOSITORY_NAME/IMAGE_NAME:VERSION

It is recommended that you always version your images.

#### 2.5.1 DockerHub




## 2.6 AWS
#### 2.6.1 AWS-sdk
#### 2.6.2 S3
#### 2.6.3 EC2
#### 2.6.4 SES

Email is a familiar GUI, we can use that.  With the right containers, email can be used as an extremely well-designed api.  Consider the kindle.  If you want to load your own pdf to your kindle, you can set the accepted email addresses, and send emails to the kindle and have it loaded into your library.  How neat is that! 

Given our organization, let's try to create a similar environment with email and uploading photos to the website.  There are two main considerations here.
    - Authenticating the email.
    - Uploading and separating documents to s3
Other considerations will be solved using other open-source tools, such as deleting photos.
Since we already have both tools available in our Node server, let's try to use those.  Since SES already has some configuration available to upload straight to s3, all we need is some middleware.  Let's create a Lambda function that can do just that (next Section).

Let's do another thing with SES.  Since we created a contact form that can hold a file and give certain parameters to the contactee, let's send the organization an email with all the details.  We can create a route that points to this 

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
something like this
[Example](https://github.com/tlsskfk/milalwebsite/blob/master/api/controllers/aws.js)

#### 2.6.5 Lambda

Ok.  Full dislaimer, the last code block at SES was taken from the lambda builder.  This time, we will need to connect SES to the Node Server using a lambda function and a exposed NodePort container service.
Let's login to AWS and create the lambda function first  

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

 Let's test this, compressing the packages needed to run this environment and upload it to lambda.  Json should already be available in the Python Library lambda runs on, so you can skip that.  You're going to move to that directory in bash, run a virtual environment, pip install, and zip the needed files.  If you're using windows, you can download 7-Zip and create a .bashrc file in your home directory like this by running nano ~/.bashrc 

      export PATH=$PATH:path/to/7-zip

 then in the cli you can source ~/.bashrc and use any exports there.  Let's go back to the cli and do 

      python -m venv venv

 This will initialize a venv folder called venv in the directory, and you can rull the script using  

      source venv/Scripts/activate

 Then run 

      pip install boto3 requests

 Then save those dependencies to a requirements.txt file using 

      pip freeze > requirements.txt

 compress using 7zip 

      7z a lambda_function.zip lamdba_function.py boto3 requests 

 Now we can upload our function to lambda and an email payload [example](lambda/event.json)

Then we can write our complimentary Node.js Code to return 


 something like this
[Example](https://github.com/tlsskfk/milalDevOps/blob/main/lambda/emailToS3.py)

#### 2.6.6 Route53

We are actually going to use cloudflare since they have a free DNS resolver, and route53 costs .5$ a month.  Create an A record with your eip given by your terraform show.
The Cloudflare website should tell you to change nameservers associated with the domain registrar.  I initally bought it on AWS so I went into the console for this one.  In an enterprise environment, I would definitely consider the route53 hosted zone for sake of simplicity and organization, as I could provision it in my main.tf file and have it more easily visible as an infrastructure component.


# 3. Kubernetes
## 3.1 Pod Designs
## 3.2 Secrets
We can create a list of key-value pair secrets in a secrets yaml file as shown in these [docs](https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#configure-all-key-value-pairs-in-a-secret-as-container-environment-variables).

For now, lets create a secrets file using kubectl.
For the MYSQL container, we will need the EBS_ID ...

      kubectl create secret generic mysql-dev-ebs-id --from-literal=ebs-id=YOUR_EBS_ID

Then,we can create a secrets.yaml file like so

      apiVersion: v1  
        kind: Pod 
        metadata:
          name: envfrom-secret
        spec:
          containers:
          - name: milal-mysql
            image: mysql
            envFrom:
            - secretRef:
                name: mysql-dev-ebs-id

Then kubectl create the file

      kubectl create -f FILE_LOCATION

## 3.3 ConfigMaps

For exposable configuration variables, we can create a config map.
You can go through the [docs](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) and see which method is best for your case scenario.
I think in most cases, a mixture of an imperative and key-pair.txt file is best if you're going from development to production. Let's move the exposable key-value pairs from our api env and add it to our yaml f




## 3.4 Services
## 3.5 Containers
#### 3.4.1

#### 3.4.2

#### 3.4.3

#### 3.4.4 Front-end/ NGINX


In our nginx conf, we will need to ...


If we want to pass in an environment variable as the proxy address, we need to do a strange [workaround](https://serverfault.com/questions/577370/how-can-i-use-environment-variables-in-nginx-conf), since the nginx conf wont be able to pull env variables at startup.  Instead, we can adjust the dockerfile to look like this

        FROM nginx:alpine
        COPY --from=build /client/dist /usr/share/nginx/html
        # need this step adjustment to set env for nginx.conf
        ENV DOLLAR=$$$
        COPY nginx.conf /etc/nginx/conf.d/nginx_envsubst.template
        EXPOSE 80
        CMD ["/bin/sh", "-c", "envsubst < /etc/nginx/conf.d/nginx_envsubst.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]

in the second step.  Normally, you could just do the last nginx... block, but we need to copy a template into nginx.conf, that exports the environment variables we want, and also adjust and "$" symbols with a ${DOLLAR} env, for example. Dockerfiles require two dollarsigns in order to input this special character.
#### 3.4.5

## 3.9 Helm Chart

# 4. Ansible

# 5. Terraform

## 5.1 Initialize Terraform
Let's save Terraform to our Path Environment variable, after install, letting us use the Terraform function from anywhere.
##### Prerequisite: you need to have an authenticated account
Let's create a credentials script.  I am saving to my .bashrc file in the home directory.  You may or may not have one.  You can check using 

      ls -la ~

 Since it starts with a period you will need the -a tag since it would normally be hidden.  Then you would put this script in 

      export AWS_ACCESS_KEY=YOUR_AWS_ACCESS_KEY
      export AWS_SECRET_ACCESS_KEY=YOUR_SECRET_AWS_ACCESS_KEY

 This way, whenever you start a new BASH process, your session should initialize your credentials for terraform.  Remember to name it exactly as such and understand the preference terraform has using these [docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).  Now, you should be able terraform apply in the directory of your main.tf file.

Use a boilerplate terraform file (you can find one in the docs/tutorials of the website) and terraform destroy after.

## 5.2 
## 5.3 SSH

Follow this [example](https://medium.com/@hmalgewatta/setting-up-an-aws-ec2-instance-with-ssh-access-using-terraform-c336c812322f).  Read comments first.  This is a way for us to SSH into the ec2 instance.

#### 5.3.1 Installing packages

You can copy paste this code (it is just basic packages we will need)

update the system:
        sudo su
        apt update
        apt upgrade -y

update docker:
        apt install docker.io -y
        systemctl enable docker
        systemctl start docker

update kubernetes:
        apt install kubelet kubeadm kubectl -y

Reboot:
        reboot

Wait a minute and SSH back into it and it should give you a status log of resources, of which you will see docker.
Let's go back to our local machine, or where you wish to have the control node.  Since I am using macOS, I will be using k3s to create a local cluster, in which we can connect our ec2 to.  If you're using windows or linux, you can use apt-get or chocolatey to find suitable products like k3s, kubeadm, etc.
For linux users:
        
        curl -sfL https://get.k3s.io | sh -
        k3d cluster create mycluster
We also need [WireGuard](https://www.wireguard.com/install/) installed
        apt install wireguard


        



# 6. Jenkins


