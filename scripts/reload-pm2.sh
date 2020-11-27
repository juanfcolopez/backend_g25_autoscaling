#!/bin/bash
cp ~/local_env.yml ~/aws-codedeploy/config
cd ~/aws-codedeploy
touch .env
sudo docker-compose -f /home/ubuntu/aws-codedeploy/docker-compose.yml down
sudo docker-compose -f /home/ubuntu/aws-codedeploy/docker-compose.yml build
sudo docker-compose -f /home/ubuntu/aws-codedeploy/ run --rm web bundle install
sudo docker-compose -f /home/ubuntu/aws-codedeploy/ run --rm web yarn install
sudo docker-compose -f /home/ubuntu/aws-codedeploy/ run web rails db:migrate
sudo docker-compose -f /home/ubuntu/aws-codedeploy/ run web rails db:migrate RAILS_ENV=development
sudo docker-compose -f /home/ubuntu/aws-codedeploy/docker-compose.yml up -d  
