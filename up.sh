#!/bin/bash
docker stop adminerCon postgreSQLCon vaultCon
docker rm adminerCon postgreSQLCon vaultCon
docker-compose up -d
sleep 5
docker-compose logs
