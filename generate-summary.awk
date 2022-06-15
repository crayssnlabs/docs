{
	topicDir = $2;
	i = topicLength[topicDir];
	topicContent[topicDir][i] = $3;
	topicLength[topicDir]++;
}
END {
	for(topic in topicContent) {
		topicName = toupper(substr(topic,1,1)) substr(topic, 2);
		printf "* [%s](adr/%s/README.md)\n", topicName, topic; 
		for(i=1; i<topicLength[topic]; i++) {
			file = topicContent[topic][i];
			if (file == "README.md") continue;
			name = file;
			sub(/^[0-9]{4}-[0-9]{2}-[0-9]{2}-/, "", name);
			sub(/\.md/, "", name);
			gsub(/-/, " ", name);
			name = toupper(substr(name,1,1)) substr(name, 2);
			printf "  * [%s](adr/%s/%s)\n", name, topic, file 
		}
	}
}
