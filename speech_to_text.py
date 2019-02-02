import io
import os



from google.cloud import speech
from google.cloud.speech import enums
from google.cloud.speech import types

def convert_to_text(file_name):
    client = speech.SpeechClient()

    with io.open(file_name, 'rb') as audio_file:
        content = audio_file.read()
        audio = types.RecognitionAudio(content=content)

    config = types.RecognitionConfig(
        encoding=enums.RecognitionConfig.AudioEncoding.FLAC,
        sample_rate_hertz=44100,
        language_code='en-US'
    )

    response = client.recognize(config, audio)

    return response.results


