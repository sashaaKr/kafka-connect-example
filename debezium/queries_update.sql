INSERT INTO articles ( author, title, diagram, body, footnote ) VALUES
( "Paul", "Kafka Connect", "https://globomantics.com/kafka-connect.png", "It will never get easier..." , "1 - High Throughput" );

UPDATE articles SET  footnote = "1 - large sets of data" WHERE author = "Maria";

DELETE FROM articles WHERE author="Tom";