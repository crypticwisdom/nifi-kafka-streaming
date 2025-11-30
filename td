
kafka-topics --create --topic financial_risk --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1 

kafka-topics --list --bootstrap-server localhost:9092
23059368342

kafka-topics --describe --topic my-topic --bootstrap-server localhost:9092 

kafka-console-consumer --topic financial_risk --bootstrap-server localhost:9092 --from-beginning 

kafka-console-producer.sh --broker-list localhost:9092 --topic simswap  



echo "# nifi-kafka-streaming" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M master
git remote add origin https://github.com/crypticwisdom/nifi-kafka-streaming.git
git push -u origin master