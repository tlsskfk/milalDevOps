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

Email is a powerful tool.  With the right containers, email can be used as an extremely well-designed api.  Consider the kindle.  If you want to load your own pdf to your kindle, you can set the accepted emails, and send emails to the kindle and have it loaded into your library.  How neat is that! 

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
      const { q1, Other, q2, q2Boolean, q3, lastName, firstName, email, telNo, comments,  } = req.body
      const command = new SendEmailCommand({
        Destination: {
          ToAddresses: [processs.env.HOST_EMAIL],
        },
        Message: {
          Body: {
            Text: { Data: q1, Other, q2, q2Boolean, q3, lastName, firstName, email, telNo, comments, },
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
-- 
[Example](https://github.com/tlsskfk/milalwebsite/blob/master/api/controllers/aws.js)

#### 2.6.5 Lambda
#### 2.6.6 Route53

# 3. Kubernetes
## 3.1 Pod Designs
## 3.2 Services
## 3.2 Helm Chart

# 4. Ansible

# 5. Terraform

# 6. Jenkins
## 6.1 ENV Variables
## 6.2 Github
## 6.3 Pl


