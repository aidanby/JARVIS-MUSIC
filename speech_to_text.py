import io
import os
import webbroser as wb
import speech recognition as sr
import time
from gtts import gTTS
from google import search

from google.cloud import speech
from google.cloud.speech import enums
from google.cloud.speech import types

def convert_to_text(file_name):
    client = speech.SpeechClient('QHacks-ce31dc001d82.json')

    with io.open(file_name, 'rb') as audio_file:
        content = audio_file.read()
        audio = types.RecognitionAudio(content=content)

    config = types.RecognitionConfig(
        encoding=enums.RecognitionConfig.AudioEncoding.FLAC,
        sample_rate_hertz=44100,
        language_code='en-US'
    )

    response = client.recognize(config, audio)
	print(response)
	print(
    return response.results
	
def main():
	covert_to_text('output-1.flac')

if __name__ == "__main__";
	main()


