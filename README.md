## AWS Cloud Engineer

**Greetings! We'll be going over the tasks for Tech Challenge 1 of the Cloud Engineering program. Lets get started!**

## Tech Challenge 1 - Action Steps

* Create and Connect to EC2 Linux Server
* Update System, Install Packages, Enable Services, and Check Service Status'
* Secure MySQL
* Download WordPress & Extract WordPress Files
* Move WordPress Files to Apache Directory & Set Appropriate Permissions
* Log into MySQL, Create a WordPress Database & Database User
* Rename the Sample Configuration File
* Edit the wp-config.php File
* Restart Apache & Access WordPress Portal

________________________


## Create and Connect to EC2 Linux Server

Welcome to our first major project! We'll be migrating a company's legacy system to AWS. Instead of hosting a company's WordPress webpage in their on-premise (on-prem) servers, we're going to migrate everything over to an AWS EC2 instance where the Apache Web Server (httpd) will host the frontend webpage and a MariaDB instance will cover the backend database (DB) information for our webpage. The end goal will be to make sure we're able to reach the WordPress start-up portal in our EC2 instance's web browser. 

Ready? Lets go!

Now, to make this project easily repeatable, I chose to use Terraform (TF) to build my infrastructure and Ansible to configure my web server node (titled `webserver-vm`) with all the appropriate packages. This took longer on the front end but it's quicker to deploy. Even if that isn't true, it's easier to destroy all of my infrastructure so I don't have to manually recreate it. With that being said, I'm borrowing the IaC syntax from my TF lab and my Ansible syntax from my Ansible lab. I will not be explaining all of these in detail since I've alreayd gone over this in the past. 

Here's a glimpse of my TF code: 

![Spin up the EC2 instance](images/OnePercentWeek7Project1_Task1.png)

The tree structure is essentially the same. I removed the S3 bucket module since I don't need it for this project. I edited my worker nodes to only have one node and I renamed it `webserver`. I changed the name of the output files and I also added an output variable in my ec2_general module for my web server's private IP. I also had to add this to my root output.tf file to get that private IP. It wasn't necessary but I did it anyway. Lastly, I also needed to update the region in one of my files because AWS just wasn't accepting my general `us-east-1` region any longer. 

Once you save all of that, you know what to do. Terraform init, plan, and apply!

![EC2 control and web server node creation](images/OnePercentWeek7Project1_Task2.png)

Quick and easy! Now, you're probably wondering why I made a control node and a web server node. I wanted to reuse my TF and Ansible automation code but also, I was running into some dependency issues on my local machine to run my Ansible commands. Im on a Windows computer and apparently Git Bash wouldn't cut it for Ansible. I would've had to switch to WSL and I didn't want to do that. Lastly, with TF, I can destroy my infrastructure more easily so this works better for me. 

Lets get logged in our control node. We need to SSH in our virtual machine (VM) using the private key generated from our TF code. Then, we'll copy that key over to the control node to use it for all SSH activity into our web server. Run the following commands but swap `X.X.X.X` with your public IP (PIP) of your control node. 

![Set up control node for Ansible](images/OnePercentWeek7Project1_Task3.png)

Once you've completed that, use `ls -l` to make sure your key is your ec2-user home directory. 

![SSH into control node and copy private key](images/OnePercentWeek7Project1_Task4.png)

Now, run the following commands on your control node to set it up for Ansible. We need to install Ansible, change the permissions on the private key, verify Ansible is installed and make sure we don't have to answer the fingerprint prompt for SSH (overkill for this lab but a good habit for now). 

![Set up control node for Ansible](images/OnePercentWeek7Project1_Task5.png)

Here's what everything should look like when you're done. 

![Ansible install verification](images/OnePercentWeek7Project1_Task6.png)

Lets move to the next section to get our packages up and running!

## Update System, Install Packages, Enable Services, and Check Service Status'

Lets use more automation to set up our web server. Once again, this was more work on the frontend but it allows us to copy and paste in order to make sure our web server works the same way every time. 

Lets get our inventory file working on our control node. Once again, I won't be going over our inventory and playbook files in detail because I already did that in the Ansible labs. Here's a snapshot of the inventory file with our web server's private IP:


![Ansible inventory file](images/OnePercentWeek7Project1_Task7.png)

I also changed the name of our hosts group and the name of the overall inventory file. Here's a screenshot of our playbook YAML file:

![Ansible playbook file](images/OnePercentWeek7Project1_Task8.png)

Now here, we're just installing more services and packages at one time. We're also starting and enabling more services at one time. I googled the syntax for the loop when it came to starting the services. Ansible will just circle through each item in the loop until all the items in the service block are started. 

Now, lets ping our web server from our control node and then run the playbook. First, we need to create the files on our control node so copy and paste the file contents over. 

![Ansible ping](images/OnePercentWeek7Project1_Task9.png)

Now that the ping was successful, lets run our playbook!

![Ansible run playbook](images/OnePercentWeek7Project1_Task10.png)

That was successful so now lets log into our web server node and check the status of our services. On to the next section!


## Check the Status of Apache & MySQL

Use the private key to SSH into your web server and run `sudo systemctl status {httpd,mariadb}` to make sure both services are started. 

![Both Apache (HTTPD) and Maria DB are up and running](images/OnePercentWeek7Project1_Task11.png)

Since MySQL is included in Maria DB, we already know that's installed. Verify that PHP is installed as well (we need this for the Apache web server pages) by using `php -v`. 

![Verify PHP installation](images/OnePercentWeek7Project1_Task12.png)

That concludes this section! The rest of this lab isn't automated so we'll work through it piece by piece. 

## Secure MySQL

We want to make sure our MySQL server is as secure as possible. We will still be leaving it pretty open to make this project easy but here's how you would harden the security for it. Use the command `sudo mysql_secure_installation` and follow the prompt. There are about 8 parts so click through them as you see fit. 

![Securing your DB!](images/OnePercentWeek7Project1_Task13.png)

I pretty much pressed no to all of the prompts. The above is what your finished command should look like. That conlcudes this section. 

## Download WordPress & Extract WordPress Files

Lets down WordPress and move the files to the correct directory. You can use the command `wget` which downloads files directly from the internet. Use `wget https://wordpress.org/latest.tar.gz` to download the tar file. Then we'll extract the compressed tar file using `tar xvzf latest.tar.gz`. The flags for this tar command are x for extract, v for verbose (shows you all the output during the process), z for uncompress I believe and f for file. You usually need f for all of your tar commands so get used to it. 

![WordPress final file extract](images/OnePercentWeek7Project1_Task14.png)

Now, lets move our wordpress directory and files to the right location!


## Move WordPress Files to Apache Directory & Set Appropriate Permissions

We want our Apache Web Server to read the index files from our WordPress word tree. So lets move the entire directory to the `/var/www/html` directory. Based on the Apache configuration (conf) files, this is where Apache will read the contents it serves to the public. Run `sudo mv wordpress/* /var/www/html` where mv is short for move. You can also use mv to rename files which you'll see later. 

Now, the service user that runs all of our Apache services is called `apache`. We need to give it permission over these files since currently, the owner and group are `ec2-user` by default. Then, we'll give the files and directories the permissions 755. 

![WordPress directory transfer and permission change + verification](images/OnePercentWeek7Project1_Task15.png)

Lets configure the DB part of this project.

## Log into MySQL, Create a WordPress Database & Database User

Lets log into our MySQL DB using the root user and no password. Run the command `sudo mysql -u root -p`. Once you're logged in, create a DB for our WordPress site using `CREATE DATABASE wordpress_db;`. Don't forget the semi-colon! I won't show this part since we already went through this in our DB lab. 

The part we haven't done before was create a DB user so I'll show that input. The `CREATE USER 'wordpress_user'@'localhost' IDENTIFIED BY '<your_password>';` is pretty straight forward. You're creating a user named `wordpress_user` on your local machine which would be the web server EC2 instance. You can make this user anything you want but for documentation purposes, it will be easiest to read as wordpress_user. You're identified by your password. You can type in any password your want between the quotation marks.

`GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress_user'@'localhost';` basically says allow the wordpress_user on the local host to be able to do whatever it wants with the wordpress_db DB along with all tables that belong to that DB (hence the .*) portion. 

`FLUSH PRIVILEGES` is similar to Flush DNS for my network engineers. It says forget all the privileges your currently know and renew it from the DB. This is how you'll pick up on the privileges you just granted the wordpress_user. 

![DB User creation + privileges](images/OnePercentWeek7Project1_Task16.png)

That wasn't too bad! Now lets do some more Apache related tasks. 

## Rename the Sample Configuration File

Lets rename the sample configuration WordPress file so we can actually use it for our web portal. Remember when I said you can use the `mv` command to rename files? We'll do that here. Run `sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php`. Verify the name change by using the list commmand with grep to search for the file in the directory. 

![wp-config file rename](images/OnePercentWeek7Project1_Task17.png)

Now, lets edit the config file. 

## Edit the wp-config.php File

We'll simply be inputting our wordpress_user credentials into the `wp-config.php` file in order to allow Apache to work with our DB. Open the file using `vim` and using the `/` to search for the define lines. Alter them with the information we created for our wordpress_user.

`sudo vim /var/www/html/wp-config.php`

Use `cat` + `grep` to confirm we changed the lines appropriately. 

![define confirmation](images/OnePercentWeek7Project1_Task18.png)

Now, we're almost there! Last few steps. 

## Restart Apache & Access WordPress

Now, restart your Apache service so that it will pick up the changes you made to the configuration (config) files. Run `sudo systemctl restart httpd`. Once you've done that, take your web server's PIP and put it in the web browser. You should be able to access the Word Press wizard. 

![WordPress wizard confirmation](images/OnePercentWeek7Project1_Task19.png)

And that concludes our legacy migration project!

## Personal Notes

10/02/2026

We got everything to work!!! Okay nice. So the backend listener rule had the path `/api/*` so anything that matched at least `/api/` at the end of the ALB would get routed to the backend. This his how we were able to see the backend ID message. The backend code said app.get which grabs the id: ID. Then is shows id with some UUID. I still don't quite understand the frontend part so we'll need to review that. 

We just created the webhook. We disabled SSL as well but everything else was pretty much by the book. About to test it out. One more time. 
Jesus



10/01/206

Lets talk about Phase 5 which is the real final phase. The rest is testing and using GitOps. Okay now we're getting our Jenkinsfile together. All I really had to do was put in my region and my ECR frontend and backend URIs. You can find this in the AWS console. 

I needed to also come up with my file tree structure before I created my GitHub repo online. I created it but I organized all my files first before I pushed them up. It caused some issues because of a duplication error but once I removed the empty Tech-Challenge-1 folder, I was able to push my code up. I had it ignore my .pem file as well. 

I forgot to include the frontend and backend additional files in my push to my repo so I had to clone the challenge repo again to my Downloads folder, then move them over to my frontend and backend directories. I also messed this up because I accidentally copied the entire frontend directory into my frontend directory. So it was frontend/frontend/src. Same with the backend directories.

Now, I followed the instructions for the CI/CD pipeline build. I had to modify my script path to fit exactly what I have in my GitHub repo `jenkins-tech-challenge-1/Jenkinsfile`. I ran the pipeline to test it out before the GitHub webhook. It made it to the frontend Dockerfile and got stuck at RUN npm install. Apparently this can be resource intensive. I'm going to reboot my instance in a second. 

Okay after about 45 minutes, I decided to stopped the instance, upgrade it to a t3.small, and start it back up. The public IP changed automatically. I'm able to log back into it now. I had to restart my Jenkins container using `docker start jenkins`. 

So the pipeline failed. This was probably due to the instance restart. We're going to test on our EC2 instance outside of our Jenkins container to make sure that the frontend image is being created properly. Okay this time it ran without any issues! But we noticed the ECS wasn't pulling the right image. We found this out by going to both of the ECS frontend and backend services and looking at the Events (basic the logs). It showed the error `CannotPullContainerError`. It was looking at the docker.io registry and not my ECR I believe. We needed to grab the ECR URIs for both the frontend and backend images, create a new revision in the ECS service for the frontend and backend, and replae the image with the ECR URI followed by :latest. For example, `177989593957.dkr.ecr.us-east-1.amazonaws.com/backend-repository:latest`. 

After that, go back to your clusters and update both frontend-ecs-service and backend. Use the latest revision and press save. They should run again. That's working now but when we went to the ALB's URL, we got a failure to fetch. Now, I'm getting sleepy at this point so AI is doing the heavy lifting. It appears we need to change our CORS_ORIGIN and our API URL in our backend and frontend in order to get this going. 

Go into frontend and config.js. Change the local host to http://tech-challenge-1-alb-486707836.us-east-1.elb.amazonaws.com/api. Then go into the same file in the backend and put the same URL but remove the `/api` at the end. After you push your changes to your GitHub repo, make sure you check the repo to make sure the changes are there. Now, Build Now again in Jenkins. 

We were still running into the Failed to fetch issue. I think we determined it's because the backend SG had the wrong source. We needed to change this to ALB security group. 

***** MAKE SURE TO ADD THIS TO TERRAFORM ***** (I believe I did)

Low key we got it to work on the /api/test URL path. Now we have to get the regular URL to work. 





09/30/2026

Okay we're moving onto Phase 4 of the porject which is setting up the Jenkins server in AWS. I'm going to deploy my resources again and get logged into the Jenkins server. We need to update our packages so we'll run an update and upgrade in dnf right quick. Then, lets install docker and get the service started. Now, we need to get the Jenkins container running. I remember two things we had to do: link the docker.sock socket from the host machine to the container. We also needed to make sure the docker groups matched on the container and the host machine which means we need to add docker as a secondary group to the jenkins user on the container. This is to allow the Jenkins container to actually use Docker. So in that case, we need to create a custom Jenkins Dockerfile. I'll include that in the documentation. 

We got that up and running. Now lets get logged into the Jenkins UI and get the plugins installed. We can also install these plugins while the container is being created. I added the lines in the Dockerfile. We need to install the AWS CLI `apt-get install -y awscli`. The Git CLI is already installed. You have to log into the container as root and not jenkins to install these packages using apt-get. 

You'll also need to install the AWS Credentials plugin inside the Jenkins UI. Also, follow the documentation for the GitHub PAT token. You go to Settings and look at the very bottom of options on the left side of the screen. You'll see Developer settings or whatever.

Okay I entered my AWS token as well. You'll need to go to the AWS Console, click on your username and click Security Credentials. I had to generate a new Access Key which it then gave me the secret to go with it. I entered this information in Jenkins. I asked Copilot to give me some verification checks that these creds work so it gave me one for GitHub, one for AWS, and another for Docker. I used my No Zero Days repo for the GitHub check. After you run the pipeline, go to Workspaces to see the cloned repo. That was pretty cool. 

The AWS and Docker checks came back successfully too so this is great. Lets move on to Phase 5. 

_____________
This project was a little overwhelming at first. I didn't think it would be this involved especially connecting the frontend to the backend portion because I'm simply not used to working with front or backends. So that was my first plan of action. What does verification of this process look like? So I wanted to make sure I got the right message when running the application. Apparently, the frontend will just show you the `ID` that the backend has. So the frontend and backend both show the same information when you visit the web server on port 8080 or 3000. 

While I was able to get the frontend and backend portions working on my local machine (an EC2 instance), it became another problem when I tried to access the frontend on my EC2 instance's PIP. I had to go change the CORS origin in my backend I believe to match the PIP. Well, if you do this on the fly, the code doesn't like it so much. I kept running into an error message with the backend saying there was already a process listening on port 8080. So I had to use `ss` to find that process (and the frontend process), use `kill -9 <process-id>` to stop both processes, and then restart them in different terminals. Once I did this, I was able to receive the frontend message. 

To even see some of these issues, I had to go into Google Chrome's JavaScript panel to see there were networking issues on localhost and cross domains (CORS) which I've never done before in my life. That's the page you just accidentally click on when you're moving too fast in your web browswer. So it was interesting having to use that to troubleshoot. 

(package.json is like the node.js equivalent of the requirements.txt file for Python). (npm run build stores React source code into static HTML, CSS, and JS files and puts them in a build folder). (serve is a lightweight web server. Think Apache but tiny). (serve -s build starts the web server)(npm start is for developers and development mode. since we're going to prod, we use npm run build and server -s build). 

I built the images in each respective directory but when I ran the containers, I put an `.` at the end. That overrode the CMD command and broke the images so moving forward, do not put a period at the end of the `docker run` command. Also, I changed the success message in my frontend container using single quotes instead of backticks ``. So I was able to get the confirmation message on the web browser but it didn't appear the way I thought. So I stopped the container, removed it, edited my App.js file, rebuilt the image as v2 and ran it again. 

Okay we got that up and running. Here's the overall big picture with running these containers next. We're going to use Elastic Container Registry (ECR) to store our images after the Jenkins pipeline creates them. We'll use Elastic Container Services (ECS) to run our containers and it will pull them from ECR. Usually, we would run our containers on a VM like EC2 but we can instruct ECS to run our containers on Fargate which is just compute that we don't have to manage. Like serverless containers instead of using a VM. 

Terraform troubleshooting notes:


09/25/2026

Everything deployed perfectly. I did add a listener rule for the backend group since that was the only thing in the solution that I didn't have. I made the edits. Hopefully it will still deploy perfectly. 

09/24/2026

We're working on the ecs.tf file again. I'm comparing my file with the answer file. The answer file has the CloudWatch resource block in the ecs.tf file but I moved this to my monitoring.tf file. I also needed to add the task_role_arn to my ecs_task_definition blocks. The execution role allows ECS to do tasks. The task role allows the application inside the container to execute tasks. Since the application isn't an AWS resource, we're going to create the role but not assign it to anything. AWS will just pass this role to the application if the application wants to do anything AWS related. 

I copied some of the CloudWatch code because I'm not sure where they even got this from. I can't find it on the Terraform website. Also, the awslogs-stream-prefix basically says name log streams starting with ecs. Everything else is straight forward. Also, the essential = true makes ECS make sure the container is healthy before it says the ECS task is healthy. 

I put together the ALB and Autoscaling files. These were straight forward enough although AI had me change the autoscaling policy from a step policy to a target tracking policy. Once we did that, I ran through my Terraform commands. Then I ran into an issue with the ecs.tf file. The container defintion name didn't match the load balancer container name I believe. I fixed that for both the frontend and backend. 

Then I ran into another issue. I needed to fix the type of policy for my autoscaling. I kept it to StepScaling whenI changed it earlier. 



09/23/2026

So we worked on fixing the cycle between the frontend and backend dependency when it came to the security group. Since they relied on each other, Terraform couldn't build it. We changed the egress for the frontend poll to by any-any. We let the backend pool keep the frontend security group and changed the backend to any-any. Also, for my IAM roles, I had to change ecs.amazonaws.com to ecs-tasks.amazonaws.com. 

Just ran a terraform fmt -recursive, validate, and plan. I had to remove a lot of the tags in the networking.tf file but once I did that, my apply went through. Going to destroy everything and start on the next module. 

Created my ecr.tf file. This was pretty straight forward. I just copied the blocks from the Terraform website. I didn't change anything in either file. Just made sure I paired the blocks together. The policy states that all images be recycle after 14 days. Works for me. I had to go back and fix the name of the repos because AWS didn't like the capital letters. I changed everything back to lowercase (Frontend-Repository to frontend-repository) and then the apply worked. 

08/2026

I had to ask Copilot how to think about the IAM roles here. As an Azure engineer, I'm not particularly used to having to grant services or resources permissions to do things. They're typically just allowed to do what they need to do. In AWS, if you don't give a service the right role and policy, it won't work. So we needed to give the ECS service the task execution permissions. We also wanted to allow it to create logs for us in CloudWatch. Both of these require a role. I thought the Jenkins server would need a role. Maybe it doesn't right now. I'm like, does the ECR need a role? Fargate? I'm still learning the distinctions between things but also, to set these up, you should also look at the AWS documentation. It will tell you what needs a role and what doesnt. Okay cool. So we needed to create two roles for ECS: task execution and the logging role. Task execution role is mandatory. You can copy the code from the TF AWS IAM webpage. The only thing you're really changing is ec2 to ec2 and giving it a specific name. As far as the policy_arn, now I already knew what that was because of the solution. But I didn't want to copy this. I tried to find it myself on the Terraform website. No dice. I went to the AWS console and went to IAM. I found the AWS-managed policy myself and it had a copy button for the ARN! So that was refreshing to know if I need to do this in the future (say I'm following the wizard and it tells me the policy but I don't know what that looks like for TF) then I know I can find it in the console and copy it. 

Now, the logging policy was a custom policy. You can copy and TF code for this as well but in the Actions section, you can list off all the permissions you want using "<permission>", to separate each permission. To read these permissions, the first part denotes the service so you'll see things like s3, ec2, ecr, logs, etc. That lets you know which service this policy is acting ON. The next part says what the permission is. The logs category is for CloudWatch actually. The good thing about this as well is you can go into the custom policies in the column and use the JSON view. It will show you how the each permission would show up in JSON which is pretty much how it would show up in Terraform as well. Use the JSON to help you write custom codes in TF. 

Last but not least, once you create the roles and policies, you need to create another resource block to attach the policy to the role. The policy_arn syntax is different for custom policies as opposed to AWS-managed policies so keep that in mind. 

