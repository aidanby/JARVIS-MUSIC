import io
import os
#import webbroser as wb
#import speech_recognition as sr
#import time
#from gtts import gTTS
#from google import search

from google.cloud import speech
from google.cloud.speech import enums
from google.cloud.speech import types

os.environ["GOOGLE_APPLICATION_CREDENTIALS"]='QHacks-ce31dc001d82.json'


def convert_to_text(file_name):
    client = speech.SpeechClient().from_service_account_json('QHacks-ce31dc001d82.json')

    with io.open(file_name, 'rb') as audio_file:
        content = audio_file.read()
        audio = types.RecognitionAudio(content=content)

    config = types.RecognitionConfig(
        encoding=enums.RecognitionConfig.AudioEncoding.FLAC,
        language_code='en-US'
    )

    response = client.recognize(config, audio)
    translation = ""
    for result in response.results:
        translation = translation+result.alternatives[0].transcript+""
    print(translation)
    return translation


def main():
    convert_to_text('test2.flac')


if __name__ == "__main__":
    main()


