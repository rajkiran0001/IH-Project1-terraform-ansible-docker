worker app contacts to redis and db
Key points:
set security groups correctly 
open ports correctly
ssh into docker
docker logs container name


 terraform validate (To validate the code)
 terraform plan (To see the plan what is going to happen in the aws when you apply)
 terraform apply (Go to apply in the aws in real time)
 The files outside the module (main.tf, provider.tf) are globlly available

 Ansible
 you need to check the environmental variable after the terraform creates the resources
 ansible-playbook -i inventory.ini deploy_app.yml