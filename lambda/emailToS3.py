import boto3
import requests
import json
import lambda_function

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
                # todo: dynamic name to prevent overwriting
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