# JARVIS-MUSIC

Have a song stuck in your head but can't sing it? Use our web app to play the music that's on your mind!

We are building a web application for users to find songs by lyrics or any information that is related to your song.

In our web home page, you press the audio recording button to sing your songs, or tell something about your song.
We use google speech to text API to convert your voice to text and show it to you.
Of course, you can always input the text directly, if you are uncomfortable about saying anything.
The text is transformed to our server side. We have a machine learning algorithm to search for the most related song.

Here is our algorithm to search the song. We firstly download tons of songs using the Genius API. We build a word filtering API using the standard library (stdlib). The word filtering API filters bad words (such as "f*ck") in the lyrics of the songs. We then index the songs to our database. Given your input text, i.e., a query, our unsupervised algorithm aims to find the most relevant song. We use the Vector Space Model and doc2vec to build our unsupervised algorithm.
Basically, Vector Space Model locates the exact words that you want to search and doc2vec extracts the semantic meaning of your input text and the lyrics, such that we are not lossing any information. We give a score of each song, denoting how relevant the song is to the input text. We rank the songs based the returned scores. and return the top five songs. We not only return song name and singer name, but also return YouTube links for you to check out!

