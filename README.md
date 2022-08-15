# ANSIBLE

includes: 
- client and server source code
- docker-compose.yaml
- ansible playbook.yml
- run.sh script

## to start docker-compose locally using ansible
cd ./ANSIBLE 
chmod +x run.sh && ./run.sh

docker ps

visit http://localhost:3000

# BASH
includes:
- extract.sh
- test folder with some nested folders including compressed and regular files

## test
cd ./BASH

chmod +x extract.sh

./extract.sh -v -r file test some-dummy-bad-input test1.txt

# GROOVY

includes: 
- Jenkinsfile
